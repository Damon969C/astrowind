#!/bin/bash
set -euo pipefail

TARGET=""
ACTION=""
USER=""
PERMS=""

usage() {
    cat <<'EOF'
Usage: acl-manager.sh -d <目录> <子命令> [参数]

子命令:
  add     -u <用户> -p <权限>    添加用户并设置权限 (权限如: rwx, rx, r)
  remove  -u <用户>              移除用户的所有 ACL
  set     -u <用户> -p <权限>    修改已有用户的 ACL 权限
  list                            列出目录的 ACL
  clear                           清空所有用户 ACL (保留基础 POSIX 权限)
  default -u <用户> -p <权限>    设置默认 ACL (影响未来新建的文件/目录)

权限格式: 一个字符串, 包含 r(读) w(写) x(执行) 的任意组合
示例: rwx   rx   w   r   空字符串表示无权限

示例:
  acl-manager.sh -d /ai add    -u bob   -p rwx
  acl-manager.sh -d /ai add    -u alice -p rx
  acl-manager.sh -d /ai set    -u bob   -p r
  acl-manager.sh -d /ai remove -u bob
  acl-manager.sh -d /ai list
  acl-manager.sh -d /ai clear
  acl-manager.sh -d /ai default -u bob -p rwx
EOF
    exit 0
}

die() { echo "ERROR: $*" >&2; exit 1; }

parse_perms() {
    local p="$1"
    local result=""
    [[ "$p" == *r* ]] && result="${result}r"
    [[ "$p" == *w* ]] && result="${result}w"
    [[ "$p" == *x* ]] && result="${result}x"
    if [ -z "$result" ]; then
        result="---"
    fi
    echo "$result"
}

# ── parse base args ──
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d) TARGET="$2"; shift 2 ;;
        -u) USER="$2"; shift 2 ;;
        -p) PERMS="$2"; shift 2 ;;
        -h|--help) usage ;;
        *)  ACTION="$1"; shift ;;
    esac
done

[ -n "$TARGET" ] || die "请用 -d 指定目录"
[ -d "$TARGET" ] || die "$TARGET 不是一个目录"

# ── dispatch ──
case "${ACTION:-list}" in

    add)
        [ -n "$USER" ] || die "请用 -u 指定用户"
        [ -n "$PERMS" ] || die "请用 -p 指定权限 (如 rwx)"
        PARSED=$(parse_perms "$PERMS")
        echo "→ 为用户 $USER 添加 ACL: $PARSED 到 $TARGET"
        setfacl -R -m "u:${USER}:${PARSED}" "$TARGET"
        echo "✓ 完成"
        ;;

    remove)
        [ -n "$USER" ] || die "请用 -u 指定用户"
        echo "→ 移除用户 $USER 的所有 ACL 从 $TARGET"
        setfacl -R -x "u:${USER}" "$TARGET" 2>/dev/null || true
        # 也清理默认 ACL
        setfacl -R -x "d:u:${USER}" "$TARGET" 2>/dev/null || true
        echo "✓ 完成"
        ;;

    set)
        [ -n "$USER" ] || die "请用 -u 指定用户"
        [ -n "$PERMS" ] || die "请用 -p 指定权限 (如 rwx)"
        PARSED=$(parse_perms "$PERMS")
        echo "→ 修改用户 $USER 的 ACL 为: $PARSED 在 $TARGET"
        # 先删再加
        setfacl -R -x "u:${USER}" "$TARGET" 2>/dev/null || true
        setfacl -R -m "u:${USER}:${PARSED}" "$TARGET"
        echo "✓ 完成"
        ;;

    list)
        echo "=== $TARGET 的 ACL 条目 ==="
        getfacl "$TARGET"
        ;;

    clear)
        echo "→ 清空 $TARGET 的所有用户 ACL (保留 owner/group/other POSIX 位)"
        setfacl -R -b "$TARGET"
        echo "✓ 完成"
        ;;

    default)
        [ -n "$USER" ] || die "请用 -u 指定用户"
        [ -n "$PERMS" ] || die "请用 -p 指定权限 (如 rwx)"
        PARSED=$(parse_perms "$PERMS")
        echo "→ 设置默认 ACL: $USER -> $PARSED 在 $TARGET (影响未来新建文件/目录)"
        setfacl -R -m "d:u:${USER}:${PARSED}" "$TARGET"
        echo "✓ 完成"
        ;;

    *)
        die "未知子命令: $ACTION (使用 add | remove | set | list | clear | default)"
        ;;
esac
