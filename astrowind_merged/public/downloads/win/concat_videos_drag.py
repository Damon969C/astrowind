import sys
import os
import re
import subprocess
import tempfile
import tkinter.messagebox as msgbox

def natural_key(s):
    """自然排序，如 2.mkv < 10.mkv"""
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r'(\d+)', s)]

def main():
    # sys.argv[0] 是脚本本身，后面是被拖入的文件
    if len(sys.argv) < 2:
        msgbox.showinfo("提示", "请将要拼接的视频文件拖到此脚本上运行。")
        return

    files = sys.argv[1:]
    files.sort(key=natural_key)

    # 检查文件存在性
    for f in files:
        if not os.path.exists(f):
            msgbox.showerror("错误", f"文件不存在：{f}")
            return

    # 扩展名（假定相同）
    ext = os.path.splitext(files[0])[1]

    # 输出文件名 = 第一个-最后一个 + 扩展名
    first_name = os.path.splitext(os.path.basename(files[0]))[0]
    last_name = os.path.splitext(os.path.basename(files[-1]))[0]
    output_name = f"{first_name}-{last_name}{ext}"

    # 创建 ffmpeg 列表文件
    with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".txt", encoding="utf-8") as list_file:
        for f in files:
            abs_path = os.path.abspath(f).replace("\\", "/")
            list_file.write(f"file '{abs_path}'\n")
        list_path = list_file.name

    # ffmpeg 命令
    cmd = [
        "ffmpeg",
        "-f", "concat",
        "-safe", "0",
        "-i", list_path,
        "-c", "copy",
        output_name
    ]

    # 运行 ffmpeg
    try:
        subprocess.run(cmd, check=True)
        msgbox.showinfo("成功", f"拼接完成！输出文件：\n{output_name}")
    except subprocess.CalledProcessError:
        msgbox.showerror("错误", "执行 ffmpeg 时出错，请检查输入文件是否兼容。")
    finally:
        os.remove(list_path)

if __name__ == "__main__":
    main()
