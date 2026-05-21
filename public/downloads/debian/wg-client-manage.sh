#!/usr/bin/env bash
#
# WireGuard Client Manager - Optimized v2
#

set -o pipefail

WG_CONF="${WG_CONF:-/etc/wireguard/wg0.conf}"
WG_IFACE="${WG_IFACE:-wg0}"
QRENCODE_BIN="${QRENCODE_BIN:-qrencode}"

usage() {
  echo "用法: $0 [--start]"
  echo
  echo "  --start   清空并重建 $WG_CONF，不修改当前运行中的 WireGuard 状态"
}

die() {
  echo "错误：$*" >&2
  exit 1
}

print_error() {
  echo "错误：$*" >&2
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    die "请使用 root 权限运行此脚本。"
  fi
}

require_wg() {
  if ! command -v wg &>/dev/null; then
    die "未找到 wg 命令，请安装 wireguard-tools。"
  fi
}

require_existing_config() {
  if [[ ! -f "$WG_CONF" ]]; then
    die "未找到配置文件 $WG_CONF。可先运行：$0 --start"
  fi
}

read_input() {
  local prompt=$1
  local __var=$2
  read -r -p "$prompt" "${__var?}" || return 1
}

trim() {
  local value=$1
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

sanitize_client_name() {
  local name=$1
  name=${name//[^0-9A-Za-z_-]/_}
  printf '%.15s' "$name"
}

############################################
#  函数: 获取公网 IP (Endpoint)           #
############################################
get_public_ip() {
  local public_ip
  if command -v curl &>/dev/null; then
    public_ip=$(curl -s4m 5 https://api.ipify.org || true)
    if [[ -z "$public_ip" ]]; then
      public_ip=$(curl -s6m 5 https://api64.ipify.org || true)
    fi
  fi
  if [[ -z "$public_ip" ]]; then
    read_input "无法自动探测公网 IP，请输入服务器公网 IP 或域名: " public_ip || exit 1
  fi
  echo "$public_ip"
}

validate_port() {
  local port=$1
  [[ "$port" =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535))
}

validate_ipv4_cidr_24() {
  local cidr=$1
  local a b c d mask
  [[ "$cidr" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/24$ ]] || return 1
  IFS=./ read -r a b c d mask <<<"$cidr"
  [[ "$mask" == "24" ]] || return 1
  for part in "$a" "$b" "$c" "$d"; do
    [[ "$part" =~ ^[0-9]+$ ]] || return 1
    ((part >= 0 && part <= 255)) || return 1
  done
}

validate_ipv6_cidr_64() {
  local cidr=$1
  [[ "$cidr" =~ ^[0-9A-Fa-f:]+/64$ && "$cidr" == *:* ]]
}

init_server_config() {
  local confirm endpoint port ipv4_cidr ipv6_cidr address_line server_privkey
  local conf_dir tmp_conf

  echo "即将清空并重建 $WG_CONF。"
  echo "此操作不会修改当前运行中的 $WG_IFACE 状态。"
  read_input "确认继续? [y/N]: " confirm || return 1
  if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo "取消操作。"
    return 0
  fi

  read_input "服务器 Endpoint (公网 IP 或域名，留空自动探测): " endpoint || return 1
  endpoint=$(trim "$endpoint")
  if [[ -z "$endpoint" ]]; then
    endpoint=$(get_public_ip)
    endpoint=$(trim "$endpoint")
  fi
  if [[ -z "$endpoint" ]]; then
    print_error "Endpoint 不能为空。"
    return 1
  fi

  while true; do
    read_input "监听端口 [51820]: " port || return 1
    port=$(trim "$port")
    [[ -z "$port" ]] && port="51820"
    if validate_port "$port"; then
      break
    fi
    echo "端口无效，请输入 1-65535。"
  done

  while true; do
    read_input "服务器 IPv4 Address CIDR [10.8.0.1/24]: " ipv4_cidr || return 1
    ipv4_cidr=$(trim "$ipv4_cidr")
    [[ -z "$ipv4_cidr" ]] && ipv4_cidr="10.8.0.1/24"
    if validate_ipv4_cidr_24 "$ipv4_cidr"; then
      break
    fi
    echo "IPv4 地址无效，目前仅支持 /24，例如 10.8.0.1/24。"
  done

  while true; do
    read_input "服务器 IPv6 Address CIDR (留空禁用): " ipv6_cidr || return 1
    ipv6_cidr=$(trim "$ipv6_cidr")
    [[ -z "$ipv6_cidr" ]] && break
    if validate_ipv6_cidr_64 "$ipv6_cidr"; then
      break
    fi
    echo "IPv6 地址无效，目前仅支持 /64，例如 fd42::1/64。"
  done

  address_line="$ipv4_cidr"
  if [[ -n "$ipv6_cidr" ]]; then
    address_line="$address_line, $ipv6_cidr"
  fi

  server_privkey=$(wg genkey) || {
    print_error "生成服务器 PrivateKey 失败。"
    return 1
  }

  conf_dir=$(dirname "$WG_CONF")
  mkdir -p "$conf_dir" || {
    print_error "无法创建目录 $conf_dir。"
    return 1
  }
  chmod 700 "$conf_dir" 2>/dev/null || true

  tmp_conf=$(mktemp "${WG_CONF}.tmp.XXXXXX") || {
    print_error "无法创建临时配置文件。"
    return 1
  }

  {
    echo "# Managed by wg-client-manage.sh"
    echo "# ENDPOINT $endpoint"
    echo "[Interface]"
    echo "Address = $address_line"
    echo "ListenPort = $port"
    echo "PrivateKey = $server_privkey"
  } >"$tmp_conf" || {
    rm -f "$tmp_conf"
    print_error "写入临时配置文件失败。"
    return 1
  }

  chmod 600 "$tmp_conf" || {
    rm -f "$tmp_conf"
    print_error "设置配置文件权限失败。"
    return 1
  }

  mv -f "$tmp_conf" "$WG_CONF" || {
    rm -f "$tmp_conf"
    print_error "替换 $WG_CONF 失败。"
    return 1
  }

  echo "已重建配置文件：$WG_CONF"
}

############################################
#  函数: 解析服务器配置                   #
############################################
parse_server_info() {
  # Endpoint
  server_endpoint=$(sed -n 's/^[[:space:]]*# ENDPOINT[[:space:]]*\(.*\)/\1/p' "$WG_CONF" | head -1)
  server_endpoint=$(trim "$server_endpoint")
  if [[ -z "$server_endpoint" ]]; then
    server_endpoint=$(get_public_ip)
  fi

  # Port
  server_port=$(sed -n 's/^[[:space:]]*ListenPort[[:space:]]*=[[:space:]]*\(.*\)/\1/p' "$WG_CONF" | head -1)
  server_port=$(trim "$server_port")
  [[ -z "$server_port" ]] && server_port="51820"

  # Keys
  server_privkey=$(sed -n 's/^[[:space:]]*PrivateKey[[:space:]]*=[[:space:]]*\(.*\)/\1/p' "$WG_CONF" | head -1)
  server_privkey=$(trim "$server_privkey")
  if [[ -z "$server_privkey" ]]; then
    echo "错误：无法解析服务器 PrivateKey。"
    exit 1
  fi
  server_pubkey=$(printf '%s\n' "$server_privkey" | wg pubkey) || {
    echo "错误：服务器 PrivateKey 无法生成 PublicKey。"
    exit 1
  }

  local address_line item v4_addr v6_addr suffix
  local -a address_items
  HAS_IPV4=0
  HAS_IPV6=0
  IPV4_PREFIX=""
  IPV6_PREFIX=""
  SERVER_IPV4_LAST=""
  SERVER_IPV6_LAST_NUM=""

  address_line=$(sed -n 's/^[[:space:]]*Address[[:space:]]*=[[:space:]]*\(.*\)/\1/p' "$WG_CONF" | head -1)
  IFS=',' read -r -a address_items <<<"$address_line"
  for item in "${address_items[@]}"; do
    item=$(trim "$item")
    if [[ "$item" =~ ^(([0-9]{1,3}\.){3}[0-9]{1,3})/24$ ]]; then
      v4_addr="${BASH_REMATCH[1]}"
      IPV4_PREFIX="${v4_addr%.*}"
      SERVER_IPV4_LAST="${v4_addr##*.}"
      HAS_IPV4=1
    elif [[ "$item" =~ ^([0-9A-Fa-f:]+)/64$ ]]; then
      v6_addr="${BASH_REMATCH[1]}"
      if [[ "$v6_addr" =~ ^(.*::)([0-9A-Fa-f]+)$ ]]; then
        IPV6_PREFIX="${BASH_REMATCH[1]}"
        suffix="${BASH_REMATCH[2]}"
        SERVER_IPV6_LAST_NUM=$((16#$suffix))
        HAS_IPV6=1
      elif [[ "$v6_addr" =~ ^(.*::)$ ]]; then
        IPV6_PREFIX="${BASH_REMATCH[1]}"
        SERVER_IPV6_LAST_NUM=0
        HAS_IPV6=1
      elif [[ "$v6_addr" =~ ^(.+):([0-9A-Fa-f]+)$ ]]; then
        IPV6_PREFIX="${BASH_REMATCH[1]}:"
        suffix="${BASH_REMATCH[2]}"
        SERVER_IPV6_LAST_NUM=$((16#$suffix))
        HAS_IPV6=1
      fi
    fi
  done
}

############################################
#     函数: 选择 DNS (新增系统读取)        #
############################################
choose_dns() {
  # 读取本机 /etc/resolv.conf 中的 nameserver
  local dns_opt
  local sys_dns_raw
  local sys_dns_display="无法获取"

  if [[ -f /etc/resolv.conf ]]; then
    # 提取 IP 并用逗号拼接
    sys_dns_raw=$(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | xargs | sed 's/ /, /g')
    if [[ -n "$sys_dns_raw" ]]; then
      sys_dns_display="$sys_dns_raw"
    fi
  fi

  echo "设置客户端 DNS："
  echo "   1) 系统默认 ($sys_dns_display)"
  echo "   2) Google (8.8.8.8, 2001:4860:4860::8888)"
  echo "   3) Cloudflare (1.1.1.1, 2606:4700:4700::1111)"
  echo "   4) AdGuard (94.140.14.14, 2a10:50c0::ad1:ff)"
  echo "   5) 阿里云 (223.5.5.5, 2400:3200::1)"
  echo "   6) 自定义..."
  read_input "请选择 [1]: " dns_opt || return 1

  case "$dns_opt" in
    1 | "")
      if [[ -n "$sys_dns_raw" ]]; then
        DNS="$sys_dns_raw"
      else
        echo "系统 DNS 获取失败，使用 Google DNS。"
        DNS="8.8.8.8"
      fi
      ;;
    2) DNS="8.8.8.8, 2001:4860:4860::8888" ;;
    3) DNS="1.1.1.1, 2606:4700:4700::1111" ;;
    4) DNS="94.140.14.14, 2a10:50c0::ad1:ff" ;;
    5) DNS="223.5.5.5, 2400:3200::1" ;;
    6)
      read_input "请输入 DNS (逗号分隔): " DNS || return 1
      DNS=$(trim "$DNS")
      if [[ -z "$DNS" ]]; then
        echo "DNS 为空，使用 Google DNS。"
        DNS="8.8.8.8"
      fi
      ;;
    *) DNS="8.8.8.8" ;;
  esac
}

show_client_qr() {
  local client_conf=$1

  if ! command -v "$QRENCODE_BIN" &>/dev/null; then
    echo "提示：未找到 qrencode，无法生成二维码。"
    echo "      Debian/Ubuntu 可运行：sudo apt-get install qrencode"
    echo "      安装后可手动生成：qrencode -t ANSI256UTF8 < \"$client_conf\""
    return 0
  fi

  echo "📱 二维码："
  if ! "$QRENCODE_BIN" -t ANSI256UTF8 <"$client_conf"; then
    print_error "二维码生成失败。"
    return 1
  fi
}

############################################
#     函数: 添加客户端                     #
############################################
add_client() {
  parse_server_info

  if [[ $HAS_IPV4 -eq 0 && $HAS_IPV6 -eq 0 ]]; then
    echo "错误：服务器未配置 Address (IPv4 或 IPv6)，无法分配 IP。"
    return 1
  fi

  echo "请输入新客户端名称 (字母/数字/下划线/减号，最多15字符)："
  local input_name
  read_input "Name: " input_name || return
  local client_name
  client_name=$(sanitize_client_name "$input_name")

  while [[ -z "$client_name" ]] || grep -q "^# BEGIN_PEER $client_name\$" "$WG_CONF"; do
    echo "名称无效或已存在。"
    read_input "Name: " input_name || return
    client_name=$(sanitize_client_name "$input_name")
  done

  if ! choose_dns; then
    print_error "读取 DNS 配置失败。"
    return 1
  fi

  # 生成密钥
  local client_privkey client_pubkey client_psk
  client_privkey=$(wg genkey) || {
    print_error "生成客户端 PrivateKey 失败。"
    return 1
  }
  client_pubkey=$(printf '%s\n' "$client_privkey" | wg pubkey) || {
    print_error "生成客户端 PublicKey 失败。"
    return 1
  }
  client_psk=$(wg genpsk) || {
    print_error "生成客户端 PresharedKey 失败。"
    return 1
  }

  # 寻找可用 IP
  local octet=2
  while ((octet <= 253)); do
    local used4=0 used6=0
    if [[ $HAS_IPV4 -eq 1 ]]; then
      if [[ "$SERVER_IPV4_LAST" == "$octet" ]]; then used4=1; fi
      if grep -Fq "${IPV4_PREFIX}.${octet}/32" "$WG_CONF"; then used4=1; fi
    fi
    if [[ $HAS_IPV6 -eq 1 ]]; then
      if [[ -n "$SERVER_IPV6_LAST_NUM" && "$SERVER_IPV6_LAST_NUM" -eq "$octet" ]]; then used6=1; fi
      if grep -Fq "${IPV6_PREFIX}${octet}/128" "$WG_CONF"; then used6=1; fi
    fi
    if [[ $used4 -eq 0 && $used6 -eq 0 ]]; then break; fi

    ((octet++))
  done

  if ((octet > 253)); then
    echo "错误：地址池已耗尽。"
    return 1
  fi

  # 构建 IP
  local client_v4 client_v6 allowed_ips address_line
  if [[ $HAS_IPV4 -eq 1 ]]; then client_v4="${IPV4_PREFIX}.${octet}"; fi
  if [[ $HAS_IPV6 -eq 1 ]]; then client_v6="${IPV6_PREFIX}${octet}"; fi

  if [[ -n "$client_v4" && -n "$client_v6" ]]; then
    allowed_ips="$client_v4/32, $client_v6/128"
    address_line="Address = $client_v4/24, $client_v6/64"
  elif [[ -n "$client_v4" ]]; then
    allowed_ips="$client_v4/32"
    address_line="Address = $client_v4/24"
  else
    allowed_ips="$client_v6/128"
    address_line="Address = $client_v6/64"
  fi

  local tmp_peer tmp_client
  tmp_peer=$(mktemp) || {
    print_error "创建临时 peer 配置失败。"
    return 1
  }

  # 写入服务端 peer 片段
  {
    echo "# BEGIN_PEER $client_name"
    echo "[Peer]"
    echo "PublicKey = $client_pubkey"
    echo "PresharedKey = $client_psk"
    echo "AllowedIPs = $allowed_ips"
    echo "# END_PEER $client_name"
  } >"$tmp_peer" || {
    rm -f "$tmp_peer"
    print_error "写入临时 peer 配置失败。"
    return 1
  }

  # 写入客户端文件
  local client_conf="${HOME}/${client_name}.conf"
  tmp_client=$(mktemp "${client_conf}.tmp.XXXXXX") || {
    rm -f "$tmp_peer"
    print_error "创建临时客户端配置失败。"
    return 1
  }
  {
    echo "[Interface]"
    echo "PrivateKey = $client_privkey"
    echo "$address_line"
    echo "DNS = $DNS"
    echo
    echo "[Peer]"
    echo "PublicKey = $server_pubkey"
    echo "PresharedKey = $client_psk"
    echo "AllowedIPs = 0.0.0.0/0, ::/0"
    echo "Endpoint = $server_endpoint:$server_port"
    echo "PersistentKeepalive = 25"
  } >"$tmp_client" || {
    rm -f "$tmp_peer" "$tmp_client"
    print_error "写入临时客户端配置失败。"
    return 1
  }
  chmod 600 "$tmp_client" || {
    rm -f "$tmp_peer" "$tmp_client"
    print_error "设置客户端配置权限失败。"
    return 1
  }

  if ! cat "$tmp_peer" >>"$WG_CONF"; then
    rm -f "$tmp_peer" "$tmp_client"
    print_error "写入服务端配置失败。"
    return 1
  fi

  # 动态生效
  local iface_active=0
  if wg show "$WG_IFACE" &>/dev/null; then
    iface_active=1
  fi

  if [[ $iface_active -eq 1 ]] && ! wg addconf "$WG_IFACE" "$tmp_peer"; then
    sed -i "/^# BEGIN_PEER $client_name\$/,/^# END_PEER $client_name\$/d" "$WG_CONF" || true
    rm -f "$tmp_peer" "$tmp_client" "$client_conf"
    print_error "动态添加 peer 失败，已回滚配置文件。"
    return 1
  fi

  if ! mv -f "$tmp_client" "$client_conf"; then
    if [[ $iface_active -eq 1 ]]; then
      wg set "$WG_IFACE" peer "$client_pubkey" remove &>/dev/null || true
    fi
    sed -i "/^# BEGIN_PEER $client_name\$/,/^# END_PEER $client_name\$/d" "$WG_CONF" || true
    rm -f "$tmp_peer" "$tmp_client"
    print_error "保存客户端配置失败，已回滚服务端配置。"
    return 1
  fi
  rm -f "$tmp_peer"

  echo
  echo "✅ 已添加客户端：$client_name"
  echo "📂 配置文件生成于：$client_conf"
  if [[ $iface_active -eq 0 ]]; then
    echo "提示：$WG_IFACE 当前未运行，客户端配置将在接口启动后生效。"
  fi

  show_client_qr "$client_conf"
}

############################################
#     函数: 删除客户端                     #
############################################
remove_client() {
  local confirm idx
  local client_list
  client_list=$(grep '^# BEGIN_PEER' "$WG_CONF" | cut -d ' ' -f 3)

  if [[ -z "$client_list" ]]; then
    echo "当前没有客户端。"
    return 0
  fi

  echo "当前客户端列表："
  echo "$client_list" | nl -s ') '
  read_input "请输入要删除的编号: " idx || return

  local count
  count=$(echo "$client_list" | wc -l)

  if ! [[ "$idx" =~ ^[0-9]+$ ]] || ((idx < 1 || idx > count)); then
    echo "无效编号。"
    return 1
  fi

  local client_name
  client_name=$(echo "$client_list" | sed -n "${idx}p")

  read_input "确认删除 [$client_name]? [y/N]: " confirm || return
  if [[ "$confirm" =~ ^[yY]$ ]]; then
    local pubk tmp_conf iface_active=0
    pubk=$(sed -n "/^# BEGIN_PEER $client_name\$/,/^# END_PEER $client_name\$/p" "$WG_CONF" | grep '^PublicKey' | awk '{print $3}')
    tmp_conf=$(mktemp "${WG_CONF}.tmp.XXXXXX") || {
      print_error "创建临时配置文件失败。"
      return 1
    }
    sed "/^# BEGIN_PEER $client_name\$/,/^# END_PEER $client_name\$/d" "$WG_CONF" >"$tmp_conf" || {
      rm -f "$tmp_conf"
      print_error "生成删除后的配置失败。"
      return 1
    }
    chmod 600 "$tmp_conf" || {
      rm -f "$tmp_conf"
      print_error "设置临时配置权限失败。"
      return 1
    }

    if wg show "$WG_IFACE" &>/dev/null; then
      iface_active=1
    fi
    if [[ $iface_active -eq 1 && -n "$pubk" ]]; then
      if ! wg set "$WG_IFACE" peer "$pubk" remove; then
        rm -f "$tmp_conf"
        print_error "删除运行中 peer 失败，已保留配置文件。"
        return 1
      fi
    fi

    if ! mv -f "$tmp_conf" "$WG_CONF"; then
      rm -f "$tmp_conf"
      print_error "替换配置文件失败。"
      return 1
    fi
    rm -f "${HOME}/${client_name}.conf" || echo "警告：客户端配置文件删除失败：${HOME}/${client_name}.conf"
    echo "✅ 已删除客户端：$client_name"
  else
    echo "取消操作。"
  fi
}

############################################
#                主菜单                    #
############################################
main() {
  local choice
  local start_mode=0

  case "${1:-}" in
    "") ;;
    --start)
      start_mode=1
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac

  if (($# > 1)); then
    usage
    exit 2
  fi

  require_root
  require_wg

  if [[ $start_mode -eq 1 ]]; then
    init_server_config
    exit $?
  fi

  require_existing_config

  while true; do
    clear 2>/dev/null || true
    echo "=================================="
    echo "   WireGuard 客户端管理"
    echo "=================================="
    echo "1) 添加客户端"
    echo "2) 删除客户端"
    echo "3) 退出"
    echo
    read_input "选择 [1-3]: " choice || exit 1

    case "$choice" in
      1)
        add_client
        exit $?
        ;;
      2)
        remove_client
        exit $?
        ;;
      3) exit 0 ;;
      *) echo "无效选项。" ;;
    esac
  done
}

main "$@"
