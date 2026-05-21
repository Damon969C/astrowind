const commandList = {
    name: "screen",
    commands: [
        {
            fields: [
            { "type": "desc", "value": "\u4f7f\u7528\u65b9\u6cd5", "isBase64": false },
            { "type": "info", "value": "\u5b89\u88c5 screen", "isBase64": false },
            { "type": "code", "value": "sudo apt install screen", "isBase64": false },
            { "type": "info", "value": "\u542f\u52a8", "isBase64": false },
            { "type": "code", "value": "screen -S mysession", "isBase64": false },
            { "type": "info", "value": "\u5728 screen \u5185\uff0c\u4f60\u53ef\u4ee5\u4f7f\u7528\u4ee5\u4e0b\u7ec4\u5408\u952e \u201c\u5206\u79bb\u201d (detach) screen\uff1aCtrl + A, \u7136\u540e\u6309 D", "isBase64": false },
            { "type": "info", "value": "\u67e5\u770b\u5f53\u524d\u8fd0\u884c\u7684 screen \u4f1a\u8bdd\uff1a", "isBase64": false },
            { "type": "code", "value": "screen -ls", "isBase64": false },
            { "type": "info", "value": "\u91cd\u65b0\u8fde\u63a5\u67d0\u4e2a screen\uff1a", "isBase64": false },
            { "type": "code", "value": "screen -r mysession", "isBase64": false },
            { "type": "code", "value": "screen -r 12345", "isBase64": false },
            { "type": "info", "value": "\u5982\u679c screen \u4ecd\u7136\u663e\u793a Attached\uff08\u5df2\u8fde\u63a5\uff09\uff0c\u4f46\u4f60\u65e0\u6cd5\u8bbf\u95ee\uff0c\u53ef\u4ee5\u5f3a\u5236\u8fde\u63a5\uff1a", "isBase64": false },
            { "type": "code", "value": "screen -d -r mysession", "isBase64": false },
            { "type": "info", "value": "\u5728 screen \u7a97\u53e3\u4e2d\uff0c\u8fd0\u884c exit \u6216\u6309 Ctrl + D \u5173\u95ed\u4f1a\u8bdd\uff1a", "isBase64": false },
            { "type": "code", "value": "exit", "isBase64": false },
            { "type": "info", "value": "\u5f3a\u5236\u7ec8\u6b62\u6240\u6709 screen\uff1a", "isBase64": false },
            { "type": "code", "value": "pkill screen", "isBase64": false },
            { "type": "info", "value": "\u624b\u52a8\u6740\u6b7b screen \u4f1a\u8bdd\uff1a", "isBase64": false },
            { "type": "code", "value": "screen -X -S mysession quit", "isBase64": false },
            { "type": "info", "value": "\u6c38\u4e45\u542f\u7528\u9f20\u6807\u652f\u6301\uff0c\u7f16\u8f91 ~/.screenrc \u6587\u4ef6\uff08\u5982\u679c\u4e0d\u5b58\u5728\u5c31\u521b\u5efa\uff09\uff1a", "isBase64": false },
            { "type": "code", "value": "nano ~/.screenrc", "isBase64": false },
            { "type": "info", "value": "\u6dfb\u52a0\u4ee5\u4e0b\u5185\u5bb9", "isBase64": false },
            { "type": "code", "value": "termcapinfo xterm* ti@:te@\nmousespeed 2", "isBase64": false },
            { "type": "info", "value": "\u5728 screen \u5185\uff0c\u6240\u6709\u547d\u4ee4\u90fd\u901a\u8fc7 Ctrl + A \u4f5c\u4e3a\u524d\u7f00\uff1a\n\n\u5feb\u6377\u952e\t\u4f5c\u7528\nCtrl + A\uff0cD\t\u5206\u79bb (detach) screen\uff0c\u8fdb\u7a0b\u4ecd\u5728\u540e\u53f0\u8fd0\u884c\nCtrl + A\uff0cC\t\u521b\u5efa\u65b0\u7684 screen \u7a97\u53e3\nCtrl + A\uff0cN\t\u5207\u6362\u5230\u4e0b\u4e00\u4e2a screen \u7a97\u53e3\nCtrl + A\uff0cP\t\u5207\u6362\u5230\u4e0a\u4e00\u4e2a screen \u7a97\u53e3\nCtrl + A\uff0c\"\t\u663e\u793a screen \u5185\u7684\u7a97\u53e3\u5217\u8868\nCtrl + A\uff0c0-9\t\u76f4\u63a5\u8df3\u8f6c\u5230\u5bf9\u5e94\u7f16\u53f7\u7684 screen \u7a97\u53e3\nCtrl + A\uff0cK\t\u6740\u6b7b\u5f53\u524d\u7a97\u53e3\nCtrl + A\uff0c[\t\u8fdb\u5165 \u6eda\u52a8\u6a21\u5f0f\uff08\u53ef\u4ee5\u7528\u65b9\u5411\u952e\u67e5\u770b\u4e4b\u524d\u7684\u8f93\u51fa\uff09\nCtrl + A\uff0c]\t\u7c98\u8d34\nCtrl + A\uff0cX\t\u9501\u5b9a screen\uff08\u9700\u8981\u5bc6\u7801\u89e3\u9501\uff09", "isBase64": false },
            { "type": "info", "value": "Ctrl + A, C   # \u521b\u5efa\u65b0\u7a97\u53e3\nCtrl + A, N   # \u4e0b\u4e00\u4e2a\u7a97\u53e3\nCtrl + A, P   # \u4e0a\u4e00\u4e2a\u7a97\u53e3\nCtrl + A, \"   # \u663e\u793a\u7a97\u53e3\u5217\u8868\nCtrl + A, K   # \u5173\u95ed\u5f53\u524d\u7a97\u53e3", "isBase64": false },
            { "type": "info", "value": "screen -S mysession\ntop   # \u8fd0\u884c top \u76d1\u63a7\u8fdb\u7a0b\n# \u6309 Ctrl + A, C \u65b0\u5efa\u7a97\u53e3\nhtop  # \u5728\u65b0\u7a97\u53e3\u8fd0\u884c htop", "isBase64": false }
            ]
        }
    ]
};
