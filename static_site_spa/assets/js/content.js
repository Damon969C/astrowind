export const siteContent = {
  title: "系统配置与命令文档",
  systems: [
    {
      id: "debian",
      title: "Debian",
      summary: "Linux 服务部署、网络、容器、证书与常用运维命令。",
      accent: "linux",
      categories: [
        commandCategory("debian", "debian-all", "工具", "集合工具与通用片段"),
        commandCategory("debian", "debian-changyong", "常用命令", "Debian 高频系统命令"),
        commandCategory("debian", "debian-python", "Python", "Python 环境与包管理"),
        commandCategory("debian", "debian-docker", "Docker", "容器安装、镜像与运行管理"),
        commandCategory("debian", "debian-wg", "WireGuard", "WireGuard 配置与维护"),
        commandCategory("debian", "debian-acme", "ACME 证书", "域名证书申请与续签"),
        commandCategory("debian", "debian-compose", "Docker Compose", "常用 compose 服务模板"),
        commandCategory("debian", "debian-mountdisk", "硬盘挂载", "磁盘挂载、分区与持久化"),
        commandCategory("debian", "debian-keadhcp", "Kea DHCP Server", "Kea DHCP 服务配置"),
        commandCategory("debian", "debian-nftables", "Nftables 防火墙", "nftables 规则与防火墙配置"),
        commandCategory("debian", "debian-adguard", "AdGuardHome 安装", "AdGuardHome 部署命令"),
        commandCategory("debian", "debian-ssh", "SSH", "SSH 登录、密钥与服务配置"),
        commandCategory("debian", "debian-screen", "Screen", "screen 会话管理"),
        commandCategory("debian", "debian-tmux", "Tmux", "tmux 会话管理"),
        commandCategory("debian", "debian-tar", "tar 命令", "压缩、解压与备份"),
        commandCategory("debian", "debian-tee", "tee 命令", "重定向写入与权限场景"),
        commandCategory("debian", "debian-find", "find 命令", "文件查找与批处理"),
      ],
    },
    {
      id: "pve",
      title: "PVE",
      summary: "Proxmox VE 初始化、磁盘、ZFS、虚拟机与硬件相关配置。",
      accent: "virtual",
      categories: [
        commandCategory("pve", "pve-all", "杂项", "PVE 常用综合命令"),
        commandCategory("pve", "pve-importdisk", "导入磁盘镜像", "虚拟机磁盘导入流程"),
        commandCategory("pve", "pve-changyong", "初始配置", "PVE 安装后的基础配置"),
        commandCategory("pve", "pve-diskrdm", "磁盘 RDM 直通", "物理磁盘直通给虚拟机"),
        commandCategory("pve", "pve-zfs", "ZFS", "ZFS 池与数据集维护"),
        commandCategory("pve", "vm", "虚拟机管理", "PVE 虚拟机管理命令"),
      ],
    },
    {
      id: "openwrt",
      title: "OpenWrt",
      summary: "OpenWrt 网络、DHCP、DNS 与基础配置。",
      accent: "router",
      categories: [
        commandCategory("openwrt", "op-dhcp", "DHCP 与 DNS", "dnsmasq、DHCP 与解析配置"),
        commandCategory("openwrt", "op-network", "网络管理", "接口、路由与网络配置"),
      ],
    },
    {
      id: "windows",
      title: "Windows",
      summary: "Windows 网络、PowerShell、ADB、FFmpeg 与 Server 运维。",
      accent: "desktop",
      categories: [
        commandCategory("windows", "win-net", "网络命令", "Windows 网络排查与配置"),
        commandCategory("windows", "win-ffmpeg", "FFmpeg", "媒体处理命令"),
        commandCategory("windows", "win-adb", "ADB 命令", "Android 调试桥常用命令"),
        commandCategory("windows", "win-2022", "MD5 / WIN2022 激活", "校验与 Windows Server 2022 相关命令"),
        commandCategory("windows", "powershell", "PowerShell", "PowerShell 运维命令"),
        commandCategory("windows", "network", "Network", "Windows 网络命令补充"),
      ],
    },
  ],
  documents: [
    documentPage("acme", "ACME", "证书申请、续签、安装与 nginx 自动重载脚本。", "pages/acme.html", "Debian"),
    documentPage("adb", "ADB", "Android 调试桥命令合集，支持复制与快速检索。", "pages/adb.html", "Windows"),
    documentPage("adguard", "AdGuard", "AdGuardHome 安装与常用配置。", "pages/adguard.html", "Debian"),
    documentPage("kernel-build", "Linux 内核编译", "Linux 内核编译与 Deb 打包完整流程。", "pages/kernel-build.html", "Debian"),
    documentPage("pve-aspm-guide", "PVE ASPM 指南", "PVE 使用内核选项禁用 PCIe ASPM。", "pages/pve-aspm-guide.html", "PVE"),
    documentPage("vyos", "VyOS 配置", "VyOS 安装、接口、LAN/WAN、DNS 与防火墙配置。", "pages/vyos.html", "Network"),
    documentPage("common-commands", "常用命令", "端口、时区、IP、内核、清理与 Docker 常用操作。", "pages/common-commands.html", "Debian"),
  ],
};

function commandCategory(systemId, id, title, summary) {
  return {
    id,
    title,
    summary,
    dataPath: `data/systems/${systemId}/${id}_commands.js`,
  };
}

function documentPage(id, title, summary, sourcePath, group) {
  return {
    id,
    title,
    summary,
    sourcePath,
    group,
  };
}
