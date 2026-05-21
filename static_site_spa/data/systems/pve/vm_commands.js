const commandList = {
    name: "PVE 虚拟机管理",
    commands: [
        { desc: "# 启动 VM 100", code: "qm start 100" },
        { desc: "# 关闭 VM 100", code: "qm stop 100" },
        { desc: "# 列出所有 VM", code: "qm list" },
        { desc: "# 克隆 VM 100 到 101", code: "qm clone 100 101 --name new-vm" }
    ]
};
