const commandList = {
    name: "tmux",
    commands: [
        {
            fields: [
            { "type": "desc", "value": "\u4f7f\u7528\u65b9\u6cd5", "isBase64": false },
            { "type": "info", "value": "\u5b89\u88c5 tmux", "isBase64": false },
            { "type": "code", "value": "sudo apt install tmux", "isBase64": false },
            { "type": "info", "value": "\u542f\u52a8", "isBase64": false },
            { "type": "code", "value": "tmux new -s mysession", "isBase64": false },
            { "type": "info", "value": "\u5206\u79bb tmux \u4f1a\u8bdd\uff08\u8ba9\u5b83\u5728\u540e\u53f0\u8fd0\u884c\uff09\nCtrl + B, D  # \u5148\u6309 Ctrl + B\uff0c\u518d\u6309 D", "isBase64": false },
            { "type": "info", "value": "\u5217\u51fa\u6240\u6709 tmux \u4f1a\u8bdd", "isBase64": false },
            { "type": "code", "value": "tmux ls", "isBase64": false },
            { "type": "code", "value": "tmux attach -t mysession  # \u901a\u8fc7\u4f1a\u8bdd\u540d", "isBase64": false },
            { "type": "code", "value": "tmux attach -t 1  # \u901a\u8fc7 ID", "isBase64": false },
            { "type": "info", "value": "\u5f3a\u5236\u8fde\u63a5\u5e76\u8e22\u6389\u5176\u4ed6\u7528\u6237", "isBase64": false },
            { "type": "code", "value": "tmux attach -d -t mysession", "isBase64": false },
            { "type": "info", "value": "\u7ec8\u6b62 tmux \u4f1a\u8bdd", "isBase64": false },
            { "type": "code", "value": "exit", "isBase64": false },
            { "type": "info", "value": "\u6216\u8005\u4f7f\u7528\u5feb\u6377\u952e\uff1aCtrl + D", "isBase64": false },
            { "type": "info", "value": "\u624b\u52a8\u6740\u6b7b\u4f1a\u8bdd\uff1a", "isBase64": false },
            { "type": "code", "value": "tmux kill-session -t mysession", "isBase64": false },
            { "type": "info", "value": "\u5173\u95ed\u6240\u6709 tmux \u4f1a\u8bdd\uff1a", "isBase64": false },
            { "type": "code", "value": "tmux kill-server", "isBase64": false }
            ]
        }
    ]
};
