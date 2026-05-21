const commandList = {
    name: "Windows Server 2022",
    commands: [
        {
            fields: [
            { type: "desc", value: "MD5\u6821\u9a8c", isBase64: false },
            { type: "info", value: "MD2\u3001MD4\u3001MD5\u3001SHA1\u3001SHA256\u3001SHA384\u3001SHA512", isBase64: false },
            { type: "code", value: "CertUtil -hashfile 000 SHA256", isBase64: false }
            ]
        },
        {
            fields: [
            { type: "desc", value: "\u6fc0\u6d3b", isBase64: false },
            { type: "code", value: "slmgr /ipk WX4NM-KYWYW-QJJR4-XV3QB-6VM33", isBase64: false },
            { type: "code", value: "slmgr /ipk WMDGN-G9PQG-XVVXX-R3X43-63DFG", isBase64: false },
            { type: "code", value: "slmgr /skms kms.luody.info", isBase64: false },
            { type: "code", value: "slmgr /ato", isBase64: false },
            { type: "code", value: "slmgr -ipk WX4NM-KYWYW-QJJR4-XV3QB-6VM33", isBase64: false },
            { type: "code", value: "slmgr -skms kms.0t.net.cn", isBase64: false },
            { type: "code", value: "slmgr -ato", isBase64: false },
            { type: "info", value: "Windows Server 2016 Datacenter Retail\uff1a\n\n[Key]\uff1a6CNGG-BJP34-H923Y-6DMWR-37BMF\n\n[Key]\uff1aHHRN4-BW4JY-GC9FP-TW3V8-7FT34\n\n[Key]\uff1aDBNBR-9R8Q8-PPPT7-8J64C-MP3D4\n\n[Key]\uff1aJD3N6-PXR8T-JQGRD-WVTXB-VQXQ4\n\nCB7KF-BWN84-R7R2Y-793K2-8XDDG", isBase64: false }
            ]
        },
        {
            fields: [
            { type: "desc", value: "\u5353\u8d8a\u6027\u80fd", isBase64: false },
            { type: "code", value: "powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61", isBase64: false }
            ]
        },
        {
            fields: [
            { type: "desc", value: "\u5f00\u673a\u81ea\u52a8\u767b\u5f55", isBase64: false },
            { type: "code", value: "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\PasswordLess\\Device", isBase64: false },
            { type: "code", value: "DevicePasswordLessBuildVersion", isBase64: false },
            { type: "code", value: "netplwiz", isBase64: false },
            { type: "code", value: "services.msc", isBase64: false },
            { type: "code", value: "Shell:Startup", isBase64: false }
            ]
        },
        {
            fields: [
            { type: "desc", value: "\u8fdc\u7a0b\u684c\u9762\u5e27\u7387", isBase64: false },
            { type: "code", value: "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\WinStations", isBase64: false },
            { type: "info", value: "\u9009\u62e9\u300c\u65b0\u5efa\u300d\uff0c\u7136\u540e\u9009\u62e9\u300cDWORD\uff0832 \u4f4d\uff09\u503c\u300d\uff1a", isBase64: false },
            { type: "code", value: "DWMFRAMEINTERVAL", isBase64: false },
            { type: "info", value: "\u57fa\u6570\u9009\u62e9\u5341\u8fdb\u5236\uff0c\u6570\u503c\u6570\u636e\u586b\u5199\uff1a15", isBase64: false },
            { type: "code", value: "\u8ba1\u7b97\u673a\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\WindowsUpdate\\UX\\Settings", isBase64: false }
            ]
        }
    ]
};
