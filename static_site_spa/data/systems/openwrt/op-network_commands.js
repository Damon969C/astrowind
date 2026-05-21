const commandList = {
    name: "OpenWrt 网络管理",
    commands: [
        { desc: "# 重启网络", code: "/etc/init.d/network restart" },
        { desc: "# 列出所有接口", code: "ip a" },
        { desc: "# 显示路由表", code: "ip route" },
        { desc: "# 刷新防火墙", code: "/etc/init.d/firewall restart" }
    ]
};
