const commandList = {
    name: "RDM直通",
    commands: [
{
    desc: `映射`,
    code: [
        `ls -la /dev/disk/by-id/|grep -v dm|grep -v lvm|grep -v part`,
        `qm set <vmid> --scsiX /dev/disk/by-id/xxxxxxx`,
        `qm set 101 --scsi1 /dev/disk/by-id/nvme-INTEL_SSDPE2KX020T8_BTLJ039307142P0BGN`,
        `qm set 101 --sata1 /dev/disk/by-id/nvme-INTEL_SSDPE2KX020T8_BTLJ039307142P0BGN`,
        `qm set 101 --ide1 /dev/disk/by-id/nvme-INTEL_SSDPE2KX020T8_BTLJ039307142P0BGN`
    ]
},
{
    desc: `取消`,
    code: `qm set 101 --delete scsi1`
}
    ]
};
