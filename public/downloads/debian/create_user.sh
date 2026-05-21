#!/bin/bash
set -euo pipefail

read -rp "用户名: " username

if id "$username" &>/dev/null; then
    echo "用户 $username 已存在"
    exit 1
fi

useradd -m -s /bin/bash "$username"
passwd "$username"
usermod -aG sudo "$username"

echo "用户 $username 创建完成，已加入 sudo 组"
