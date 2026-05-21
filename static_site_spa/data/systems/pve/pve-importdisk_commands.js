const commandList = {
    name: "importdisk",
    commands: [
{
    desc: `导入镜像文件`,
    code: [
        `qm importdisk 100 /var/lib/vz/template/iso/op.img local-lvm`,
        `qm importdisk 100 /var/lib/vz/template/iso/op.img local-zfs`
    ]
}
    ]
};
