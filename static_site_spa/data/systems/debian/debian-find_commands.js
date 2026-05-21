const commandList = {
    name: "find 命令",
    commands: [
        { 
            desc: "# 匹配包含特定字符串的文件名", 
            info: "要查找包含`example`字符串的文件：",
            code: `find / -name "*example*"`
        },
        { 
            desc: "# 匹配特定扩展名的文件", 
            info: "要查找所有以`.txt`结尾的文件：",
            code: `find / -name "*.txt"`
        },
        { 
            desc: "# 匹配任意单个字符", 
            info: "要查找名称中第二个字符是`x`的文件，可以使用：",
            code: `find / -name "?x*"`
        },
        { 
            desc: "# 匹配特定范围内的字符", 
            info: "要查找名称中包含`1`到`3`之间数字的文件，可以使用：",
            code: `find / -name "*[1-3]*"`
        },
        { 
            desc: "### 结合其他选项进行搜索", 
            info: `- **按文件类型搜索**：
  - 查找目录：\`-type d\`
  - 查找普通文件：\`-type f\`
  - 查找符号链接：\`-type l\`

例如，查找所有包含\`example\`的目录：
find / -type d -name "*example*"

- **按大小搜索**：
  - 查找大于1MB的文件：\`-size +1M\`
  - 查找小于10KB的文件：\`-size -10k\`

例如，查找大于1MB的所有\`.log\`文件：
`,
            code: `find / -name "*.log" -size +1M`
        },
        { 
            desc: "# 使用正则表达式搜索", 
            info: "如果需要更复杂的匹配，可以使用`-regex`选项：",
            code: `find / -regex ".*example.*"`
        },
        { 
            desc: "# 示例命令", 
            code: [
                `find / -name "*config*"`,
                `find ~/ -name "test*"`,
                `find . -name "*.sh"`
            ]
        }
    ]
};
