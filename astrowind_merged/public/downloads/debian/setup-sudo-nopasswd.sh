#!/usr/bin/env bash
set -euo pipefail

SUDOERS_FILE="/etc/sudoers.d/claude-nopasswd"

# 如果脚本带参数，用参数作为用户名；否则用当前用户
USERNAME="${1:-$(whoami)}"

echo "==> 为 $USERNAME 配置免密 sudo 权限..."

# 检查是否以 root 或通过 sudo 运行
if [[ $EUID -ne 0 ]]; then
    echo "错误: 需要 root 权限运行此脚本，请用: sudo $0 $USERNAME"
    exit 1
fi

# 检查用户是否存在
if ! id "$USERNAME" &>/dev/null; then
    echo "错误: 用户 $USERNAME 不存在"
    exit 1
fi

# 写入 sudoers 配置
echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" > "$SUDOERS_FILE"

# 设置正确的权限（sudoers 文件必须是 0440，否则 sudo 会拒绝）
chmod 0440 "$SUDOERS_FILE"

echo "==> 配置写入: $SUDOERS_FILE"
echo "==> 内容:"
cat "$SUDOERS_FILE"
echo "==> 完成。新开一个终端即可免密使用 sudo。"
