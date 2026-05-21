const commandList = {
    name: "python",
    commands: [
        {
            fields: [
            { "type": "info", "value": "\u521b\u5efa Python \u865a\u62df\u73af\u5883", "isBase64": false },
            { "type": "code", "value": "apt install python3-venv", "isBase64": false },
            { "type": "code", "value": "python3 -m venv myenv", "isBase64": false },
            { "type": "info", "value": "\u6fc0\u6d3b\u865a\u62df\u73af\u5883", "isBase64": false },
            { "type": "code", "value": "source myenv/bin/activate", "isBase64": false },
            { "type": "code", "value": "pip install requests", "isBase64": false },
            { "type": "info", "value": "\u6307\u5b9a Python \u811a\u672c\u4f7f\u7528\u8be5\u865a\u62df\u73af\u5883", "isBase64": false },
            { "type": "code", "value": "#!/path/to/your/venv/bin/python", "isBase64": false },
            { "type": "info", "value": "\u9000\u51fa\u865a\u62df\u73af\u5883", "isBase64": false },
            { "type": "code", "value": "deactivate", "isBase64": false }
            ]
        }
    ]
};
