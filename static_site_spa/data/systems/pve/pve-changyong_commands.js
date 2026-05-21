const commandList = {
    name: "PVE",
    commands: [
        {
            fields: [
            { "type": "info", "value": "iommu", "isBase64": false },
            { "type": "code", "value": "sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet intel_iommu=on\"/' /etc/default/grub && update-grub", "isBase64": false },
            { "type": "code", "value": "echo -e \"vfio\\nvfio_iommu_type1\\nvfio_pci\\nvfio_virqfd\" | sudo tee -a /etc/modules > /dev/null", "isBase64": false },
            { "type": "code", "value": "systemctl restart rsyslog", "isBase64": false },
            { "type": "code", "value": "apt update", "isBase64": false },
            { "type": "code", "value": "apt full-upgrade", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u7ed1\u5b9a\u7f51\u5361\u540d\u79f0", "isBase64": false },
            { "type": "code", "value": "nano /etc/systemd/network/10-persistent-net.link", "isBase64": false },
            { "type": "code", "value": "[Match]\nMACAddress=a0:36:9f:50:b4:1a\n\n[Link]\nName=enp68s0", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "cpu", "isBase64": false },
            { "type": "code", "value": "lscpu -e", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u78c1\u76d8\u6620\u5c04\u76f4\u901a", "isBase64": false },
            { "type": "code", "value": "bHMgLWxhIC9zeXMvZGV2L2Jsb2NrL3xncmVwIC12IGxvb3AgfGdyZXAgLXYgZG0=", "isBase64": true },
            { "type": "code", "value": "bHMgLWxhIC9kZXYvZGlzay9ieS1pZC98Z3JlcCAtdiBkbXxncmVwIC12IGx2bXxncmVwIC12IHBhcnQ=", "isBase64": true },
            { "type": "code", "value": "cW0gc2V0IDExMiAtLXNhdGEyIC9kZXYvZGlzay9ieS1pZC9udm1lLUtJT1hJQS1FWENFUklBX0cyX1NTRF8zM1ZBMzBWSktNRzU=", "isBase64": true },
            { "type": "info", "value": "\u5b9a\u65f6\u4efb\u52a1", "isBase64": false },
            { "type": "code", "value": "crontab -l", "isBase64": false },
            { "type": "code", "value": "crontab -e", "isBase64": false },
            { "type": "code", "value": "MCAwICogKiA3IC91c3Ivc2Jpbi96cG9vbCBzY3J1YiBycG9vbA==", "isBase64": true },
            { "type": "code", "value": "service cron reload", "isBase64": false },
            { "type": "info", "value": "vifo", "isBase64": false },
            { "type": "code", "value": "ZWNobyAtZSAidmZpb1xudmZpb19pb21tdV90eXBlMVxudmZpb19wY2lcbnZmaW9fdmlycWZkIiB8IHN1ZG8gdGVlIC1hIC9ldGMvbW9kdWxlcyA+IC9kZXYvbnVsbA==", "isBase64": true },
            { "type": "code", "value": "Z3JlcCAtcXhGICJ2ZmlvIiAvZXRjL21vZHVsZXMgfHwgZWNobyAidmZpbyIgfCBzdWRvIHRlZSAtYSAvZXRjL21vZHVsZXMKZ3JlcCAtcXhGICJ2ZmlvX2lvbW11X3R5cGUxIiAvZXRjL21vZHVsZXMgfHwgZWNobyAidmZpb19pb21tdV90eXBlMSIgfCBzdWRvIHRlZSAtYSAvZXRjL21vZHVsZXMKZ3JlcCAtcXhGICJ2ZmlvX3BjaSIgL2V0Yy9tb2R1bGVzIHx8IGVjaG8gInZmaW9fcGNpIiB8IHN1ZG8gdGVlIC1hIC9ldGMvbW9kdWxlcwpncmVwIC1xeEYgInZmaW9fdmlycWZkIiAvZXRjL21vZHVsZXMgfHwgZWNobyAidmZpb192aXJxZmQiIHwgc3VkbyB0ZWUgLWEgL2V0Yy9tb2R1bGVz", "isBase64": true }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "webui\u56fe\u5f62\u7edf\u8ba1\u9519\u8bef", "isBase64": false },
            { "type": "code", "value": "newaliases", "isBase64": false },
            { "type": "code", "value": "ls /etc/aliases*", "isBase64": false },
            { "type": "code", "value": "systemctl stop rrdcached", "isBase64": false },
            { "type": "code", "value": "mv rrdcached rrdcached.bck", "isBase64": false },
            { "type": "code", "value": "systemctl start rrdcached", "isBase64": false },
            { "type": "code", "value": "systemctl restart pve-cluster", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u6838\u663esriov", "isBase64": false },
            { "type": "code", "value": "apt install build-* dkms", "isBase64": false },
            { "type": "code", "value": "apt install proxmox-headers-6.2.16-6-pve", "isBase64": false },
            { "type": "code", "value": "dkms install -m i915-sriov-dkms -v 6.1 --force", "isBase64": false },
            { "type": "code", "value": "cd /usr/src", "isBase64": false },
            { "type": "code", "value": "dkms install -i -m i915-sriov-dkms -v 6.1", "isBase64": false },
            { "type": "code", "value": "nano /etc/default/grub", "isBase64": false },
            { "type": "code", "value": "intel_iommu=on i915.enable_guc=3 i915.max_vfs=7", "isBase64": false },
            { "type": "code", "value": "iommu=pt pcie_acs_override=downstream", "isBase64": false },
            { "type": "code", "value": "update-grub", "isBase64": false },
            { "type": "code", "value": "update-initramfs -u", "isBase64": false },
            { "type": "code", "value": "reboot", "isBase64": false },
            { "type": "code", "value": "systemctl enable sriov.service --now", "isBase64": false },
            { "type": "code", "value": "cat /sys/devices/pci0000:00/0000:00:02.0/sriov_numvfs", "isBase64": false },
            { "type": "code", "value": "nano /etc/systemd/system/sriov.service", "isBase64": false },
            { "type": "code", "value": "W1VuaXRdCkRlc2NyaXB0aW9uPUVuYWJsZSBTUi1JT1YKQWZ0ZXI9bmV0d29yay50YXJnZXQKCltTZXJ2aWNlXQpUeXBlPW9uZXNob3QKIyDliJvlu7pWRgpFeGVjU3RhcnQ9L3Vzci9iaW4vYmFzaCAtYyAnL3Vzci9iaW4vZWNobyAyID4gL3N5cy9kZXZpY2VzL3BjaTAwMDA6MDAvMDAwMDowMDowMi4wL3NyaW92X251bXZmcycKCltJbnN0YWxsXQpXYW50ZWRCeT1tdWx0aS11c2VyLnRhcmdldA==", "isBase64": true },
            { "type": "code", "value": "apt-mark hold linux-image-xxx linux-headers-xxx", "isBase64": false },
            { "type": "code", "value": "apt-mark unhold", "isBase64": false }
            ]
        }
    ]
};
