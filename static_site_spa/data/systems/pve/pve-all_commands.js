const commandList = {
    name: "ALL",
    commands: [
        {
            fields: [
            { "type": "info", "value": "swap", "isBase64": false },
            { "type": "code", "value": "cat /proc/sys/vm/swappiness", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "cat /etc/sysctl.conf", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "importdisk", "isBase64": false },
            { "type": "code", "value": "qm importdisk 111 /var/lib/vz/template/iso/openwrt_x86-64-2502030953_6.6.74_uefi-gpt_dev_Lenyu.img local-lvm", "isBase64": false },
            { "type": "code", "value": "qm importdisk 900 /var/lib/vz/images/debian-12-generic-amd64.qcow2 local-lvm", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "virt-customize", "isBase64": false },
            { "type": "code", "value": "apt install virt-customize", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "virt-customize -a /var/lib/vz/images/debian-12-generic-amd64.qcow2 --root-password password:yourpassword", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "qm set 900 --ide2 local-lvm:cloudinit", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "lxc", "isBase64": false },
            { "type": "code", "value": "ps aux | grep lxc", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "lxc\u6dfb\u52a0\u6620\u5c04\u76ee\u5f55\u811a\u672c", "isBase64": false },
            { "type": "code", "value": "nano lxc.sh", "isBase64": false },
            { "type": "code", "value": "IyEvYmluL2Jhc2gKCiMg5qOA5p+l5piv5ZCm5LulIHJvb3Qg55So5oi36L+Q6KGMCmlmIFsgIiQoaWQgLXUpIiAtbmUgMCBdOyB0aGVuCiAgICBlY2hvICLor7fku6Ugcm9vdCDnlKjmiLfov5DooYzmraTohJrmnKzjgIIiCiAgICBleGl0IDEKZmkKCiMg6K+i6Zeu6ZyA6KaB5oyC6L2955qEIExYQyDlrrnlmaggSUQg5oiW5ZCN56ewCnJlYWQgLXAgIuivt+i+k+WFpeimgeaMgui9veebruW9leeahCBMWEMg5a655ZmoIElE77yaIiBDT05UQUlORVJfSUQKCiMg5qOA5p+l5a655Zmo6YWN572u5paH5Lu25piv5ZCm5a2Y5ZyoCkNPTkZfRklMRT0iL2V0Yy9wdmUvbHhjLyR7Q09OVEFJTkVSX0lEfS5jb25mIgppZiBbICEgLWYgIiRDT05GX0ZJTEUiIF07IHRoZW4KICAgIGVjaG8gIuWuueWZqOmFjee9ruaWh+S7tiAkQ09ORl9GSUxFIOS4jeWtmOWcqO+8jOivt+ajgOafpeWuueWZqCBJRCDmmK/lkKbmraPnoa7jgIIiCiAgICBleGl0IDEKZmkKCiMg5p+l5om+5bey5pyJ55qEIG1wIOaVsOmHj++8jOehruWumuS4i+S4gOS4quWPr+eUqOeahCBtcCDnvJblj7cKTEFTVF9NUD0kKGdyZXAgLUUgJ15tcFswLTldKzonICIkQ09ORl9GSUxFIiB8IHRhaWwgLW4xIHwgc2VkIC1FICdzL15tcChbMC05XSspOi4qL1wxLycpCmlmIFsgLXogIiRMQVNUX01QIiBdOyB0aGVuCiAgICBORVhUX01QPTAKZWxzZQogICAgTkVYVF9NUD0kKChMQVNUX01QICsgMSkpCmZpCgojIOivoumXruS4u+acuuebruW9lQpyZWFkIC1wICLor7fovpPlhaXkuLvmnLrkuIropoHmjILovb3nmoTnm67lvZXvvIjkvovlpoIgL2RhdGHvvInvvJoiIEhPU1RfRElSCgojIOajgOafpeS4u+acuuebruW9leaYr+WQpuWtmOWcqO+8jOS4jeWtmOWcqOWImeWIm+W7ugppZiBbICEgLWQgIiRIT1NUX0RJUiIgXTsgdGhlbgogICAgZWNobyAi5Li75py655uu5b2VICRIT1NUX0RJUiDkuI3lrZjlnKjvvIzmmK/lkKbliJvlu7rvvJ8oeS9uKSIKICAgIHJlYWQgQ1JFQVRFX0RJUgogICAgaWYgWyAiJENSRUFURV9ESVIiID0gInkiIF0gfHwgWyAiJENSRUFURV9ESVIiID0gIlkiIF07IHRoZW4KICAgICAgICBta2RpciAtcCAiJEhPU1RfRElSIgogICAgICAgIGVjaG8gIuW3suWIm+W7uuS4u+acuuebruW9lSAkSE9TVF9ESVLjgIIiCiAgICBlbHNlCiAgICAgICAgZWNobyAi5Li75py655uu5b2VICRIT1NUX0RJUiDkuI3lrZjlnKjvvIzkuJTmnKrliJvlu7rjgILpgIDlh7rjgIIiCiAgICAgICAgZXhpdCAxCiAgICBmaQpmaQoKIyDor6Lpl67lrrnlmajlhoXnmoTmjILovb3ngrnnm67lvZUKcmVhZCAtcCAi6K+36L6T5YWl5a655Zmo5YaF55qE5oyC6L2955uu5b2V77yI5L6L5aaCIC92YXIvZGF0Ye+8ie+8miIgQ09OVEFJTkVSX0RJUgoKIyDnoa7orqTkv6Hmga8KZWNobyAi5Y2z5bCG5Zyo5a655ZmoICRDT05UQUlORVJfSUQg5Lit5bCG5Li75py655uu5b2VICRIT1NUX0RJUiDmjILovb3liLDlrrnlmajlhoXnmoQgJENPTlRBSU5FUl9ESVLjgIIiCnJlYWQgLXAgIuehruiupOe7p+e7reWQl++8nyh5L24pICIgQ09ORklSTQppZiBbICIkQ09ORklSTSIgIT0gInkiIF0gJiYgWyAiJENPTkZJUk0iICE9ICJZIiBdOyB0aGVuCiAgICBlY2hvICLmk43kvZzlt7Llj5bmtojjgIIiCiAgICBleGl0IDAKZmkKCiMg6LCD5pW05Li75py655uu5b2V55qE5p2D6ZmQCmVjaG8gIuato+WcqOiwg+aVtOS4u+acuuebruW9leeahOadg+mZkC4uLiIKY2hvd24gLVIgMTAwMDAwOjEwMDAwMCAiJEhPU1RfRElSIgpjaG1vZCAtUiA3NTUgIiRIT1NUX0RJUiIKCiMg5re75Yqg5oyC6L2954K55Yiw5a655Zmo6YWN572u5paH5Lu2Ck1QX0VOVFJZPSJtcCR7TkVYVF9NUH06ICR7SE9TVF9ESVJ9LG1wPSR7Q09OVEFJTkVSX0RJUn0sYmFja3VwPTAiCmVjaG8gIiRNUF9FTlRSWSIgPj4gIiRDT05GX0ZJTEUiCmVjaG8gIuW3suWwhuS7peS4i+aMgui9veeCuea3u+WKoOWIsOWuueWZqOmFjee9ruaWh+S7tiAkQ09ORl9GSUxF77yaIgplY2hvICIkTVBfRU5UUlkiCgojIOmHjeWQr+WuueWZqOS7peS9v+mFjee9rueUn+aViAplY2hvICLmmK/lkKbnjrDlnKjph43lkK/lrrnlmaggJENPTlRBSU5FUl9JRCDku6Xkvb/phY3nva7nlJ/mlYjvvJ8oeS9uKSIKcmVhZCBSRVNUQVJUCmlmIFsgIiRSRVNUQVJUIiA9ICJ5IiBdIHx8IFsgIiRSRVNUQVJUIiA9ICJZIiBdOyB0aGVuCiAgICBlY2hvICLmraPlnKjph43lkK/lrrnlmaggJENPTlRBSU5FUl9JRC4uLiIKICAgIHBjdCBzdG9wICIkQ09OVEFJTkVSX0lEIgogICAgcGN0IHN0YXJ0ICIkQ09OVEFJTkVSX0lEIgogICAgZWNobyAi5a655ZmoICRDT05UQUlORVJfSUQg5bey6YeN5ZCv44CCIgplbHNlCiAgICBlY2hvICLor7fnqI3lkI7miYvliqjph43lkK/lrrnlmaggJENPTlRBSU5FUl9JRCDku6Xkvb/phY3nva7nlJ/mlYjjgIIiCmZpCgplY2hvICLmk43kvZzlrozmiJDjgIIiCg==", "isBase64": true }
            ]
        }
    ]
};
