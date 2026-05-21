const commandList = {
    name: "PVE ZFS",
    commands: [
{
    desc: `PVE ZFS设置`,
    code: [
        `zfs get primarycache`,
        `zfs set primarycache=metadata rpool`,
        `nano /etc/kernel/cmdline`,
        `proxmox-boot-tool refresh`,
        `update-initramfs -u -k all`,
        `crontab -l`,
        `crontab -e`,
        `0 0 * * 7 /usr/sbin/zpool scrub rpool`,
        `service cron reload`,
        `intel_iommu=on i915.enable_guc=3 i915.max_vfs=7`,
        `amd_iommu=on pcie_acs_override=downstream,multifunction initcall_blacklist=sysfb_init`
    ]
}
    ]
};
