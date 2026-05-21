#!/usr/bin/env bash
set -Eeuo pipefail

ACTION="deploy"
ACTION_SET=0
REMOTE_USER="root"
REMOTE_HOST=""
SSH_PORT="22"
KEY_PATH="${HOME}/.ssh/id_ed25519"
KEY_COMMENT="auto-ssh-key"
KEY_OUTPUT_DIR=""
SCP_PUBLIC_KEY=""
TARGET_USER="root"
NEW_USER=""
NEW_USER_PUBLIC_KEY=""
ADDUSER_INSTALL_PUBKEY=1
SUDO_MODE="auto"
SUDO_GROUP="auto"
ASSUME_YES=0
DRY_RUN=0

usage() {
  cat <<'USAGE'
用法:
  默认部署并加固:
    ssh_harden.sh [选项] <host>
    ssh_harden.sh [选项] <user> <host>
    ssh_harden.sh [选项] <user@host>

  只在本机生成一组新密钥:
    ssh_harden.sh -key [dir]

  只把指定公钥追加到远端用户 authorized_keys:
    ssh_harden.sh -scp <pubkey> [host|user@host]

  在远端创建新用户、加入 sudo/wheel，并配置密钥登录:
    ssh_harden.sh -adduser [new_user] [host|root@host]

作用:
  这个脚本是小规模 Linux 运维辅助工具。默认模式保持原功能：生成本机默认
  Ed25519 密钥、把公钥部署到远端、验证密钥登录、加固 sshd 为仅密钥登录。

模式:
  -key [dir]              只生成本地密钥对。dir 省略时放到 ~，自动命名且不覆盖
  -scp <pubkey>           把指定公钥追加到远端用户 authorized_keys，不修改 sshd_config
  -adduser [user]         远端创建普通用户，加入 sudo/wheel，并安装用户公钥

通用选项:
  -u, --user <user>       SSH 登录远端时使用的用户，默认 root
  -p, --port <port>       SSH 端口，默认 22
  -i, --identity <path>   默认部署模式使用的本地私钥，默认 ~/.ssh/id_ed25519
  -c, --comment <text>    新生成密钥的 comment，默认 auto-ssh-key
      --pubkey <path>     -adduser 使用的公钥；默认使用 <identity>.pub
      --no-pubkey         -adduser 只创建用户和 sudo 权限，不安装公钥
      --to-user <user>    -scp 安装公钥到哪个远端用户，默认 root
      --sudo-group <name> -adduser 加入的 sudo 组；默认 auto，可设 sudo/wheel/none
      --sudo              远端非 root 时使用 sudo -n 执行管理动作
      --no-sudo           不使用 sudo，要求远端登录用户本身有权限
      --dry-run           只解析并显示计划，不连接远端、不生成密钥
  -y, --yes               跳过加固前确认
  -h, --help              显示帮助

常见场景:
  1. 默认一键部署并加固 root 登录:
     ssh_harden.sh root@10.0.0.26

  2. 本机生成一组给其他服务器使用的新密钥，默认输出到 ~:
     ssh_harden.sh -key
     ssh_harden.sh -key ~/server-keys

  3. 把另一台主机生成的公钥加入远端 root，允许它也登录 root:
     ssh_harden.sh -scp /tmp/host-166.pub 10.0.0.26

  4. 在 10.0.0.26 上创建 alice，给她 sudo，并安装她的公钥:
     ssh_harden.sh -adduser alice --pubkey /tmp/alice.pub 10.0.0.26

  5. 拆开执行：先创建用户，再单独为该用户添加公钥:
     ssh_harden.sh -adduser alice --no-pubkey 10.0.0.26
     ssh_harden.sh -scp /tmp/alice.pub --to-user alice 10.0.0.26

说明:
  - SSH 授权看的是 authorized_keys 中的公钥，不是客户端 IP。
  - 专业运维通常不给多人共用 root，而是每人独立用户，再按需给 sudo。
  - 私钥不要上传到服务器，也不要发给别人；只分发 .pub 公钥。
USAGE
}

die() {
  printf '错误: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '%s\n' "$*"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "缺少本地命令: $1"
}

expand_path() {
  case "$1" in
    "~")
      printf '%s\n' "$HOME"
      ;;
    "~/"*)
      printf '%s/%s\n' "$HOME" "${1#~/}"
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}

remote_quote() {
  local value
  value=$(printf '%s' "$1" | sed "s/'/'\\\\''/g")
  printf "'%s'" "$value"
}

sanitize_name() {
  printf '%s' "$1" | tr -c 'A-Za-z0-9_.-' '_'
}

set_action() {
  local next_action=$1

  if [[ "$ACTION_SET" -eq 1 && "$ACTION" != "$next_action" ]]; then
    die "一次只能使用一个模式，不能同时使用 $ACTION 和 $next_action"
  fi

  ACTION="$next_action"
  ACTION_SET=1
}

confirm() {
  local answer
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    return 0
  fi

  printf '%s [y/N] ' "$1"
  read -r answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

prompt_value() {
  local prompt=$1
  local default_value=${2:-}
  local answer

  [[ -t 0 ]] || die "缺少必要参数，且当前不是交互式终端，无法提示输入: $prompt"

  if [[ -n "$default_value" ]]; then
    printf '%s [%s]: ' "$prompt" "$default_value" >&2
  else
    printf '%s: ' "$prompt" >&2
  fi

  read -r answer
  if [[ -z "$answer" ]]; then
    printf '%s\n' "$default_value"
  else
    printf '%s\n' "$answer"
  fi
}

parse_remote_spec() {
  local spec=$1

  if [[ "$spec" == *@* ]]; then
    REMOTE_USER="${spec%@*}"
    REMOTE_HOST="${spec#*@}"
  else
    REMOTE_HOST="$spec"
  fi
}

parse_remote_positionals() {
  local -n positional_ref=$1

  case "${#positional_ref[@]}" in
    0)
      ;;
    1)
      parse_remote_spec "${positional_ref[0]}"
      ;;
    2)
      REMOTE_USER="${positional_ref[0]}"
      REMOTE_HOST="${positional_ref[1]}"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

validate_remote_common() {
  [[ -n "$REMOTE_USER" ]] || die "远端登录用户不能为空"
  [[ -n "$REMOTE_HOST" ]] || die "远端主机不能为空"
  [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || die "SSH 端口必须是数字"
  [[ "$SSH_PORT" -ge 1 && "$SSH_PORT" -le 65535 ]] || die "SSH 端口范围必须是 1-65535"
}

looks_like_host() {
  [[ "$1" == *@* || "$1" == *.* || "$1" == *:* ]]
}

validate_linux_user() {
  local user=$1

  [[ "$user" =~ ^[a-z_][a-z0-9_-]*$ ]] \
    || die "Linux 用户名不合法: $user"
}

parse_args() {
  local positional=()

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -key|--key)
        set_action "key"
        if [[ "$#" -ge 2 && "$2" != -* ]]; then
          KEY_OUTPUT_DIR=$(expand_path "$2")
          shift 2
        else
          KEY_OUTPUT_DIR="$HOME"
          shift
        fi
        ;;
      -scp|--scp)
        set_action "scp"
        if [[ "$#" -ge 2 && "$2" != -* ]]; then
          SCP_PUBLIC_KEY=$(expand_path "$2")
          shift 2
        else
          shift
        fi
        ;;
      -adduser|--adduser)
        set_action "adduser"
        if [[ "$#" -ge 2 && "$2" != -* ]]; then
          NEW_USER="$2"
          shift 2
        else
          shift
        fi
        ;;
      -u|--user)
        [[ "$#" -ge 2 ]] || die "$1 需要参数"
        REMOTE_USER="$2"
        shift 2
        ;;
      -p|--port)
        [[ "$#" -ge 2 ]] || die "$1 需要参数"
        SSH_PORT="$2"
        shift 2
        ;;
      -i|--identity)
        [[ "$#" -ge 2 ]] || die "$1 需要参数"
        KEY_PATH=$(expand_path "$2")
        shift 2
        ;;
      -c|--comment)
        [[ "$#" -ge 2 ]] || die "$1 需要参数"
        KEY_COMMENT="$2"
        shift 2
        ;;
      --pubkey)
        [[ "$#" -ge 2 ]] || die "$1 需要参数"
        NEW_USER_PUBLIC_KEY=$(expand_path "$2")
        shift 2
        ;;
      --no-pubkey)
        ADDUSER_INSTALL_PUBKEY=0
        shift
        ;;
      --to-user)
        [[ "$#" -ge 2 ]] || die "$1 需要参数"
        TARGET_USER="$2"
        shift 2
        ;;
      --sudo-group)
        [[ "$#" -ge 2 ]] || die "$1 需要参数"
        SUDO_GROUP="$2"
        shift 2
        ;;
      --sudo)
        SUDO_MODE="always"
        shift
        ;;
      --no-sudo)
        SUDO_MODE="never"
        shift
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      -y|--yes)
        ASSUME_YES=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        positional+=("$@")
        break
        ;;
      -*)
        die "未知选项: $1"
        ;;
      *)
        positional+=("$1")
        shift
        ;;
    esac
  done

  case "$ACTION" in
    key)
      [[ "${#positional[@]}" -eq 0 ]] || die "-key 模式不需要 host；目录请直接写在 -key 后面"
      [[ -n "$KEY_OUTPUT_DIR" ]] || KEY_OUTPUT_DIR="$HOME"
      ;;
    scp)
      parse_remote_positionals positional
      ;;
    adduser)
      if [[ -n "$NEW_USER" && "${#positional[@]}" -eq 0 ]] && looks_like_host "$NEW_USER"; then
        parse_remote_spec "$NEW_USER"
        NEW_USER=""
      else
        parse_remote_positionals positional
      fi
      ;;
    deploy)
      parse_remote_positionals positional
      ;;
    *)
      die "未知模式: $ACTION"
      ;;
  esac

  [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || die "SSH 端口必须是数字"
  [[ "$SSH_PORT" -ge 1 && "$SSH_PORT" -le 65535 ]] || die "SSH 端口范围必须是 1-65535"

  case "$SUDO_MODE" in
    auto|always|never)
      ;;
    *)
      die "无效 sudo 策略: $SUDO_MODE"
      ;;
  esac

  case "$SUDO_GROUP" in
    auto|sudo|wheel|none)
      ;;
    *)
      die "--sudo-group 只支持 auto、sudo、wheel、none"
      ;;
  esac

  if [[ "$ACTION" != "adduser" && -n "$NEW_USER_PUBLIC_KEY" ]]; then
    die "--pubkey 只用于 -adduser；-scp 请把公钥路径直接写在 -scp 后面"
  fi

  if [[ "$ACTION" != "adduser" && "$ADDUSER_INSTALL_PUBKEY" -eq 0 ]]; then
    die "--no-pubkey 只用于 -adduser"
  fi

  if [[ "$ACTION" == "adduser" && "$ADDUSER_INSTALL_PUBKEY" -eq 0 && -n "$NEW_USER_PUBLIC_KEY" ]]; then
    die "--no-pubkey 不能和 --pubkey 同时使用"
  fi

  if [[ "$ACTION" != "scp" && "$TARGET_USER" != "root" ]]; then
    die "--to-user 只用于 -scp"
  fi

  if [[ "$ACTION" != "adduser" && "$SUDO_GROUP" != "auto" ]]; then
    die "--sudo-group 只用于 -adduser"
  fi
}

complete_interactive_args() {
  case "$ACTION" in
    deploy)
      if [[ -z "$REMOTE_HOST" ]]; then
        REMOTE_HOST=$(prompt_value "请输入远端服务器 IP/主机名，例如 10.0.0.26")
      fi
      ;;
    scp)
      if [[ -z "$SCP_PUBLIC_KEY" ]]; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
          SCP_PUBLIC_KEY="${KEY_PATH}.pub"
        else
          SCP_PUBLIC_KEY=$(prompt_value "请输入要上传的公钥文件路径" "${KEY_PATH}.pub")
          SCP_PUBLIC_KEY=$(expand_path "$SCP_PUBLIC_KEY")
        fi
      fi
      if [[ -z "$REMOTE_HOST" ]]; then
        REMOTE_HOST=$(prompt_value "请输入远端服务器 IP/主机名，例如 10.0.0.26")
      fi
      ;;
    adduser)
      if [[ -z "$NEW_USER" ]]; then
        NEW_USER=$(prompt_value "请输入要创建的新用户名")
      fi
      if [[ "$ADDUSER_INSTALL_PUBKEY" -eq 1 && -z "$NEW_USER_PUBLIC_KEY" ]]; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
          NEW_USER_PUBLIC_KEY="${KEY_PATH}.pub"
        else
          NEW_USER_PUBLIC_KEY=$(prompt_value "请输入新用户公钥文件路径" "${KEY_PATH}.pub")
          NEW_USER_PUBLIC_KEY=$(expand_path "$NEW_USER_PUBLIC_KEY")
        fi
      fi
      if [[ -z "$REMOTE_HOST" ]]; then
        REMOTE_HOST=$(prompt_value "请输入远端服务器 IP/主机名，例如 10.0.0.26")
      fi
      ;;
  esac

  if [[ "$ACTION" != "key" ]]; then
    validate_remote_common
  fi

  if [[ "$ACTION" == "adduser" ]]; then
    validate_linux_user "$NEW_USER"
  fi

  if [[ "$ACTION" == "scp" ]]; then
    validate_linux_user "$TARGET_USER"
  fi
}

validate_public_key_file() {
  local public_key_file=$1
  local public_key

  [[ -f "$public_key_file" ]] || die "找不到公钥文件: $public_key_file"
  public_key=$(<"$public_key_file")
  [[ "$public_key" != *$'\n'* ]] || die "公钥文件不应包含多行内容: $public_key_file"
  [[ "$public_key" =~ ^(ssh-ed25519|ssh-rsa|ecdsa-sha2-|sk-ssh-ed25519|sk-ecdsa-sha2-) ]] \
    || die "公钥格式异常: $public_key_file"
}

ensure_local_key() {
  local key_dir
  key_dir=$(dirname "$KEY_PATH")

  umask 077
  mkdir -p "$key_dir"
  chmod 700 "$key_dir"

  if [[ ! -f "$KEY_PATH" ]]; then
    ssh-keygen -t ed25519 -a 200 -f "$KEY_PATH" -N "" -C "$KEY_COMMENT"
  else
    log "已存在私钥: $KEY_PATH"
  fi

  if [[ ! -f "${KEY_PATH}.pub" ]]; then
    log "未找到公钥，正在从私钥重新生成: ${KEY_PATH}.pub"
    ssh-keygen -y -f "$KEY_PATH" > "${KEY_PATH}.pub"
  fi

  chmod 600 "$KEY_PATH"
  chmod 644 "${KEY_PATH}.pub"
  validate_public_key_file "${KEY_PATH}.pub"
}

generate_standalone_key() {
  local output_dir=$1
  local local_user local_host timestamp base key_path counter

  require_cmd ssh-keygen
  local_user=$(sanitize_name "${USER:-user}")
  local_host=$(sanitize_name "$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf 'host')")
  timestamp=$(date +%Y%m%d%H%M%S)

  umask 077
  mkdir -p "$output_dir"
  chmod 700 "$output_dir"

  base="${output_dir}/id_ed25519_${local_user}_${local_host}_${timestamp}"
  key_path="$base"
  counter=1
  while [[ -e "$key_path" || -e "${key_path}.pub" ]]; do
    key_path="${base}_${counter}"
    counter=$((counter + 1))
  done

  ssh-keygen -t ed25519 -a 200 -f "$key_path" -N "" -C "${KEY_COMMENT}-${local_user}@${local_host}"
  chmod 600 "$key_path"
  chmod 644 "${key_path}.pub"

  log "已生成私钥: $key_path"
  log "已生成公钥: ${key_path}.pub"
  log "只把 .pub 公钥交给管理员或上传到服务器，私钥不要离开本机。"
}

ssh_base() {
  ssh -p "$SSH_PORT" -o ServerAliveInterval=10 -o ServerAliveCountMax=3 "$@"
}

ssh_remote() {
  ssh_base "${REMOTE_USER}@${REMOTE_HOST}" "$@"
}

print_plan() {
  log "执行计划:"
  log "  模式: $ACTION"

  case "$ACTION" in
    key)
      log "  密钥目录: $KEY_OUTPUT_DIR"
      log "  新密钥 comment: $KEY_COMMENT"
      ;;
    scp)
      log "  目标: ${REMOTE_USER}@${REMOTE_HOST}:${SSH_PORT}"
      log "  安装到远端用户: $TARGET_USER"
      log "  公钥: ${SCP_PUBLIC_KEY:-${KEY_PATH}.pub}"
      log "  sudo 策略: $SUDO_MODE"
      ;;
    adduser)
      log "  目标: ${REMOTE_USER}@${REMOTE_HOST}:${SSH_PORT}"
      log "  新用户: $NEW_USER"
      if [[ "$ADDUSER_INSTALL_PUBKEY" -eq 1 ]]; then
        log "  安装公钥: yes"
        log "  新用户公钥: ${NEW_USER_PUBLIC_KEY:-${KEY_PATH}.pub}"
      else
        log "  安装公钥: no"
      fi
      log "  sudo 组: $SUDO_GROUP"
      log "  sudo 策略: $SUDO_MODE"
      ;;
    deploy)
      log "  目标: ${REMOTE_USER}@${REMOTE_HOST}:${SSH_PORT}"
      log "  私钥: $KEY_PATH"
      log "  新密钥 comment: $KEY_COMMENT"
      log "  sudo 策略: $SUDO_MODE"
      log "  跳过确认: $ASSUME_YES"
      ;;
  esac

  log "  dry-run: $DRY_RUN"
}

install_public_key_for_user() {
  local public_key_file=$1
  local target_user=$2
  local public_key public_key_q target_user_q sudo_mode_q

  validate_public_key_file "$public_key_file"
  validate_linux_user "$target_user"

  public_key=$(<"$public_key_file")
  public_key_q=$(remote_quote "$public_key")
  target_user_q=$(remote_quote "$target_user")
  sudo_mode_q=$(remote_quote "$SUDO_MODE")

  ssh_remote "REMOTE_PUBLIC_KEY=$public_key_q TARGET_USER=$target_user_q SUDO_MODE=$sudo_mode_q sh -s" <<'REMOTE_SCRIPT'
set -eu

NEED_SUDO=0

fail() {
  printf '错误: %s\n' "$*" >&2
  exit 1
}

as_root() {
  if [ "$NEED_SUDO" -eq 1 ]; then
    sudo -n "$@"
  else
    "$@"
  fi
}

case "$SUDO_MODE" in
  auto|always|never)
    ;;
  *)
    fail "无效 SUDO_MODE: $SUDO_MODE"
    ;;
esac

if [ "$(id -u)" -ne 0 ]; then
  if [ "$SUDO_MODE" = "never" ]; then
    fail "当前远端用户不是 root，且已指定 --no-sudo，无法安装公钥"
  fi
  command -v sudo >/dev/null 2>&1 || fail "当前远端用户不是 root，且远端未安装 sudo"
  sudo -n true >/dev/null 2>&1 || fail "远端 sudo 需要密码或不可用；请使用 root、配置免密 sudo，或手动执行"
  NEED_SUDO=1
fi

id "$TARGET_USER" >/dev/null 2>&1 || fail "远端用户不存在: $TARGET_USER"
home_dir=$(awk -F: -v user="$TARGET_USER" '$1 == user { print $6 }' /etc/passwd)
[ -n "$home_dir" ] || fail "无法找到用户家目录: $TARGET_USER"
group_name=$(id -gn "$TARGET_USER")
ssh_dir="${home_dir}/.ssh"
auth_file="${ssh_dir}/authorized_keys"
tmp_key=$(mktemp)
trap 'rm -f "$tmp_key"' EXIT

printf '%s\n' "$REMOTE_PUBLIC_KEY" > "$tmp_key"

if command -v install >/dev/null 2>&1; then
  as_root install -d -m 700 -o "$TARGET_USER" -g "$group_name" "$ssh_dir" 2>/dev/null || {
    as_root mkdir -p "$ssh_dir"
    as_root chown "$TARGET_USER:$group_name" "$ssh_dir"
    as_root chmod 700 "$ssh_dir"
  }
else
  as_root mkdir -p "$ssh_dir"
  as_root chown "$TARGET_USER:$group_name" "$ssh_dir"
  as_root chmod 700 "$ssh_dir"
fi

as_root touch "$auth_file"
as_root chown "$TARGET_USER:$group_name" "$auth_file"
as_root chmod 600 "$auth_file"

if as_root grep -qxF "$REMOTE_PUBLIC_KEY" "$auth_file"; then
  printf '公钥已存在: %s\n' "$auth_file"
else
  as_root sh -c 'cat "$1" >> "$2"' sh "$tmp_key" "$auth_file"
  as_root chown "$TARGET_USER:$group_name" "$auth_file"
  as_root chmod 600 "$auth_file"
  printf '公钥已写入: %s\n' "$auth_file"
fi
REMOTE_SCRIPT
}

create_remote_user() {
  local new_user_q sudo_group_q sudo_mode_q

  validate_linux_user "$NEW_USER"
  new_user_q=$(remote_quote "$NEW_USER")
  sudo_group_q=$(remote_quote "$SUDO_GROUP")
  sudo_mode_q=$(remote_quote "$SUDO_MODE")

  ssh_remote "NEW_USER=$new_user_q SUDO_GROUP=$sudo_group_q SUDO_MODE=$sudo_mode_q sh -s" <<'REMOTE_SCRIPT'
set -eu

NEED_SUDO=0

fail() {
  printf '错误: %s\n' "$*" >&2
  exit 1
}

as_root() {
  if [ "$NEED_SUDO" -eq 1 ]; then
    sudo -n "$@"
  else
    "$@"
  fi
}

case "$SUDO_MODE" in
  auto|always|never)
    ;;
  *)
    fail "无效 SUDO_MODE: $SUDO_MODE"
    ;;
esac

if [ "$(id -u)" -ne 0 ]; then
  if [ "$SUDO_MODE" = "never" ]; then
    fail "当前远端用户不是 root，且已指定 --no-sudo，无法创建用户"
  fi
  command -v sudo >/dev/null 2>&1 || fail "当前远端用户不是 root，且远端未安装 sudo"
  sudo -n true >/dev/null 2>&1 || fail "远端 sudo 需要密码或不可用；请使用 root、配置免密 sudo，或手动执行"
  NEED_SUDO=1
fi

case "$NEW_USER" in
  ""|[!a-z_]*|*[!a-z0-9_-]*)
    fail "Linux 用户名不合法: $NEW_USER"
    ;;
esac

if id "$NEW_USER" >/dev/null 2>&1; then
  printf '用户已存在: %s\n' "$NEW_USER"
else
  command -v useradd >/dev/null 2>&1 || fail "远端缺少 useradd，无法自动创建用户"
  as_root useradd -m -s /bin/bash "$NEW_USER"
  printf '用户已创建: %s\n' "$NEW_USER"
fi

case "$SUDO_GROUP" in
  none)
    printf '跳过 sudo 组配置: %s\n' "$NEW_USER"
    ;;
  auto)
    if getent group sudo >/dev/null 2>&1; then
      as_root usermod -aG sudo "$NEW_USER"
      printf '已加入 sudo 组: %s\n' "$NEW_USER"
    elif getent group wheel >/dev/null 2>&1; then
      as_root usermod -aG wheel "$NEW_USER"
      printf '已加入 wheel 组: %s\n' "$NEW_USER"
    else
      fail "找不到 sudo 或 wheel 组；可用 --sudo-group none 跳过"
    fi
    ;;
  sudo|wheel)
    getent group "$SUDO_GROUP" >/dev/null 2>&1 || fail "远端不存在组: $SUDO_GROUP"
    as_root usermod -aG "$SUDO_GROUP" "$NEW_USER"
    printf '已加入 %s 组: %s\n' "$SUDO_GROUP" "$NEW_USER"
    ;;
  *)
    fail "无效 sudo 组: $SUDO_GROUP"
    ;;
esac
REMOTE_SCRIPT
}

test_key_login() {
  ssh_base \
    -i "$KEY_PATH" \
    -o IdentitiesOnly=yes \
    -o BatchMode=yes \
    -o PasswordAuthentication=no \
    -o KbdInteractiveAuthentication=no \
    "${REMOTE_USER}@${REMOTE_HOST}" \
    "true" >/dev/null 2>&1
}

warn_if_key_login_unavailable() {
  if ! test_key_login; then
    log "提示: 当前默认私钥无法免密登录 ${REMOTE_USER}@${REMOTE_HOST}。"
    log "      将继续使用普通 ssh；如果远端仍允许密码登录，ssh 会提示输入密码。"
  fi
}

apply_remote_hardening() {
  local sudo_mode_q
  sudo_mode_q=$(remote_quote "$SUDO_MODE")

  ssh_remote "SUDO_MODE=$sudo_mode_q sh -s" <<'REMOTE_SCRIPT'
set -eu

CONFIG="/etc/ssh/sshd_config"
BEGIN_MARK="# BEGIN ssh_harden.sh managed block"
END_MARK="# END ssh_harden.sh managed block"
NEED_SUDO=0

fail() {
  printf '错误: %s\n' "$*" >&2
  exit 1
}

as_root() {
  if [ "$NEED_SUDO" -eq 1 ]; then
    sudo -n "$@"
  else
    "$@"
  fi
}

find_sshd() {
  for path in /usr/sbin/sshd /usr/local/sbin/sshd /sbin/sshd; do
    if [ -x "$path" ]; then
      printf '%s\n' "$path"
      return 0
    fi
  done
  command -v sshd 2>/dev/null
}

reload_ssh_service() {
  if command -v systemctl >/dev/null 2>&1; then
    for service_name in sshd ssh; do
      if as_root systemctl reload "$service_name" >/dev/null 2>&1; then
        printf '已重载服务: %s\n' "$service_name"
        return 0
      fi
    done
  fi

  if command -v service >/dev/null 2>&1; then
    for service_name in sshd ssh; do
      if as_root service "$service_name" reload >/dev/null 2>&1; then
        printf '已重载服务: %s\n' "$service_name"
        return 0
      fi
    done
  fi

  return 1
}

case "$SUDO_MODE" in
  auto|always|never)
    ;;
  *)
    fail "无效 SUDO_MODE: $SUDO_MODE"
    ;;
esac

if [ "$(id -u)" -ne 0 ]; then
  if [ "$SUDO_MODE" = "never" ]; then
    fail "当前远端用户不是 root，且已指定 --no-sudo，无法修改 $CONFIG"
  fi
  command -v sudo >/dev/null 2>&1 || fail "当前远端用户不是 root，且远端未安装 sudo"
  sudo -n true >/dev/null 2>&1 || fail "远端 sudo 需要密码或不可用；请使用 root、配置免密 sudo，或手动执行"
  NEED_SUDO=1
fi

[ -f "$CONFIG" ] || fail "找不到 $CONFIG"
SSHD_BIN=$(find_sshd) || fail "找不到 sshd 可执行文件"

tmp_current=$(mktemp)
tmp_next=$(mktemp)
trap 'rm -f "$tmp_current" "$tmp_next"' EXIT

as_root cat "$CONFIG" > "$tmp_current"

{
  printf '%s\n' "$BEGIN_MARK"
  printf '%s\n' '# Managed by ssh_harden.sh. Keep this block before other global auth directives.'
  printf '%s\n' 'PubkeyAuthentication yes'
  printf '%s\n' 'PasswordAuthentication no'
  printf '%s\n' 'KbdInteractiveAuthentication no'
  printf '%s\n' 'ChallengeResponseAuthentication no'
  printf '%s\n' 'PermitEmptyPasswords no'
  printf '%s\n' 'PermitRootLogin prohibit-password'
  printf '%s\n' 'AuthenticationMethods publickey'
  printf '%s\n' "$END_MARK"
  printf '\n'
  awk -v begin="$BEGIN_MARK" -v end="$END_MARK" '
    $0 == begin { skip = 1; next }
    $0 == end { skip = 0; next }
    skip != 1 { print }
  ' "$tmp_current"
} > "$tmp_next"

backup="${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
as_root cp -p "$CONFIG" "$backup"

if command -v install >/dev/null 2>&1; then
  as_root install -m 0644 -o root -g root "$tmp_next" "$CONFIG" 2>/dev/null || {
    as_root cp "$tmp_next" "$CONFIG"
    as_root chmod 0644 "$CONFIG"
  }
else
  as_root cp "$tmp_next" "$CONFIG"
  as_root chmod 0644 "$CONFIG"
fi

if ! as_root "$SSHD_BIN" -t; then
  as_root cp -p "$backup" "$CONFIG"
  fail "sshd 配置校验失败，已回滚到 $backup"
fi

if ! reload_ssh_service; then
  as_root cp -p "$backup" "$CONFIG"
  fail "无法重载 SSH 服务，已回滚到 $backup"
fi

printf '远端备份: %s\n' "$backup"
REMOTE_SCRIPT
}

run_deploy() {
  require_cmd ssh
  require_cmd ssh-keygen
  require_cmd sed

  log "[1/7] 检查/生成本地 Ed25519 密钥..."
  ensure_local_key

  log "[2/7] 推送公钥到远端 ${REMOTE_USER} 的 authorized_keys（首次可能需要输入远端密码）..."
  install_public_key_for_user "${KEY_PATH}.pub" "$REMOTE_USER"

  log "[3/7] 验证当前密钥能建立新的 SSH 连接..."
  if ! test_key_login; then
    die "密钥登录验证失败。请确认远端 authorized_keys、用户、端口和本地私钥是否正确。"
  fi

  log "[4/7] 准备加固远端 SSH 配置..."
  log "目标: ${REMOTE_USER}@${REMOTE_HOST}:${SSH_PORT}"
  log "私钥: $KEY_PATH"
  if ! confirm "将禁用密码登录并要求公钥认证，确认继续？"; then
    log "已取消，公钥已部署但未修改远端 sshd_config。"
    exit 0
  fi

  log "[5/7] 写入、校验并重载远端 sshd 配置..."
  apply_remote_hardening

  log "[6/7] 重载后再次验证密钥登录..."
  if ! test_key_login; then
    die "重载后无法用当前密钥建立新连接。请保持现有会话并使用远端备份回滚 sshd_config。"
  fi

  log "[7/7] 完成。建议另开终端再次测试："
  log "ssh -p ${SSH_PORT} -i ${KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST}"
}

run_scp_key() {
  require_cmd ssh
  require_cmd sed

  if [[ -z "$SCP_PUBLIC_KEY" ]]; then
    SCP_PUBLIC_KEY="${KEY_PATH}.pub"
  fi

  if [[ ! -f "$SCP_PUBLIC_KEY" && "$SCP_PUBLIC_KEY" == "${KEY_PATH}.pub" ]]; then
    require_cmd ssh-keygen
    ensure_local_key
  fi

  warn_if_key_login_unavailable
  install_public_key_for_user "$SCP_PUBLIC_KEY" "$TARGET_USER"

  log "完成。目标用户可使用对应私钥尝试登录："
  log "ssh -p ${SSH_PORT} ${TARGET_USER}@${REMOTE_HOST}"
}

run_adduser() {
  require_cmd ssh
  require_cmd sed

  if [[ "$ADDUSER_INSTALL_PUBKEY" -eq 1 && -z "$NEW_USER_PUBLIC_KEY" ]]; then
    NEW_USER_PUBLIC_KEY="${KEY_PATH}.pub"
  fi

  if [[ "$ADDUSER_INSTALL_PUBKEY" -eq 1 && ! -f "$NEW_USER_PUBLIC_KEY" && "$NEW_USER_PUBLIC_KEY" == "${KEY_PATH}.pub" ]]; then
    require_cmd ssh-keygen
    ensure_local_key
  fi

  warn_if_key_login_unavailable
  create_remote_user
  if [[ "$ADDUSER_INSTALL_PUBKEY" -eq 1 ]]; then
    install_public_key_for_user "$NEW_USER_PUBLIC_KEY" "$NEW_USER"
  else
    log "已按 --no-pubkey 跳过公钥安装。"
  fi

  if [[ "$ADDUSER_INSTALL_PUBKEY" -eq 1 ]]; then
    log "完成。新用户可使用对应私钥登录："
    log "ssh -p ${SSH_PORT} ${NEW_USER}@${REMOTE_HOST}"
  else
    log "完成。下一步可单独添加公钥："
    log "./ssh_harden.sh -scp /path/to/${NEW_USER}.pub --to-user ${NEW_USER} ${REMOTE_HOST}"
  fi
  log "登录后可运行 sudo -l 检查 sudo 权限。"
}

main() {
  parse_args "$@"
  complete_interactive_args

  if [[ "$DRY_RUN" -eq 1 ]]; then
    print_plan
    exit 0
  fi

  case "$ACTION" in
    key)
      generate_standalone_key "$KEY_OUTPUT_DIR"
      ;;
    scp)
      run_scp_key
      ;;
    adduser)
      run_adduser
      ;;
    deploy)
      run_deploy
      ;;
    *)
      die "未知模式: $ACTION"
      ;;
  esac
}

main "$@"
