const commandList = {
    name: "tee 命令",
    commands: [
        { 
            desc: `tee命令是一个在Linux和Unix系统上非常有用的命令行工具，它可以从标准输入读取数据，并将其同时输出到标准输出和一个或多个文件中。这对于需要在查看命令输出的同时将其保存到文件中的情况非常有用。`,
            info: `### 基本用法
command | tee [options] [file...]

- \`command\`：要执行的命令，其输出将传递给\`tee\`。
- \`file\`：\`tee\`命令将标准输入的内容写入的文件，可以是一个或多个文件。

### 常用选项

- \`-a, --append\`：附加到文件末尾，而不是覆盖文件。
- \`-i, --ignore-interrupts\`：忽略中断信号。
`
        },
        { 
            desc: "# 将命令输出同时写入文件和终端", 
            code: `ls -l | tee output.txt`
        },
        { 
            desc: "# 将命令输出追加到文件", 
            code: `echo "New line" | tee -a output.txt`
        },
        { 
            desc: "# 将命令输出写入多个文件", 
            code: `df -h | tee file1.txt file2.txt`
        },
        { 
            desc: `忽略中断信号
command | tee -i output.txt

此命令在接收到中断信号时将继续运行，并将输出写入\`output.txt\`文件。

### 结合其他命令使用

- **结合\`sudo\`使用**：

有时需要将命令的输出写入需要超级用户权限的文件，这时可以结合\`sudo\`和\`tee\`使用：
echo "example configuration" | sudo tee /etc/example.conf

这条命令将字符串“example configuration”写入\`/etc/example.conf\`文件，避免直接使用\`sudo echo\`命令带来的权限问题。

- **捕获脚本输出**：

可以使用\`tee\`命令捕获整个脚本的输出：
#!/bin/bash
exec > >(tee -i logfile.txt)
exec 2>&1

# your script commands here
echo "This is a test"

这将脚本的所有标准输出和标准错误输出写入\`logfile.txt\`文件，同时在终端显示。`
        }
    ]
};
