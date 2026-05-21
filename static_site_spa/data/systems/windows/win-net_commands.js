const commandList = {
    name: "网络命令",
    commands: [
        {
            fields: [
            { "type": "info", "value": "\u6e05\u9664 DNS \u7f13\u5b58", "isBase64": false },
            { "type": "code", "value": "ipconfig /flushdns", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u6e05\u9664 ARP \u7f13\u5b58", "isBase64": false },
            { "type": "code", "value": "arp -d *", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u91cd\u7f6e IP \u914d\u7f6e", "isBase64": false },
            { "type": "code", "value": "ipconfig /release", "isBase64": false },
            { "type": "code", "value": "ipconfig /renew", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u91cd\u7f6e\u7f51\u7edc\u9002\u914d\u5668", "isBase64": false },
            { "type": "code", "value": "netsh winsock reset", "isBase64": false },
            { "type": "code", "value": "netsh int ip reset", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u5220\u9664 Windows \u8bb0\u4f4f\u7684 Wi-Fi \u8fde\u63a5\u4fe1\u606f", "isBase64": false },
            { "type": "code", "value": "netsh wlan delete profile name=\"Wi-Fi \u540d\u79f0\"", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u5220\u9664\u6240\u6709 Wi-Fi \u8fde\u63a5", "isBase64": false },
            { "type": "code", "value": "netsh wlan delete profile name=*", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u6e05\u9664 Windows \u7f51\u7edc\u8fde\u63a5\u5386\u53f2\uff0c\u6309 Win + R\uff0c\u8f93\u5165 regedit \u5e76\u56de\u8f66", "isBase64": false },
            { "type": "code", "value": "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\NetworkList\\Profiles", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u5f7b\u5e95\u91cd\u7f6e\u7f51\u7edc", "isBase64": false },
            { "type": "code", "value": "netsh int ip reset all", "isBase64": false },
            { "type": "code", "value": "netsh winsock reset", "isBase64": false },
            { "type": "code", "value": "netsh advfirewall reset", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u91cd\u542f\u7f51\u7edc\u670d\u52a1\uff0c\u4f7f\u7528\u7ba1\u7406\u5458\u6743\u9650\u8fd0\u884c \u547d\u4ee4\u63d0\u793a\u7b26 (CMD)\uff0c\u7136\u540e\u8f93\u5165", "isBase64": false },
            { "type": "code", "value": "net stop NlaSvc", "isBase64": false },
            { "type": "code", "value": "net start NlaSvc", "isBase64": false }
            ]
        }
    ]
};
