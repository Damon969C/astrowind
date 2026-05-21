import hashlib
import tkinter as tk
from tkinter import filedialog
import sys
import os

def calculate_sha256(file_path):
    sha256 = hashlib.sha256()
    try:
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(8192), b""):
                sha256.update(chunk)
        return sha256.hexdigest()
    except Exception as e:
        print(f"读取文件失败: {e}")
        return None

def select_file(prompt):
    root = tk.Tk()
    root.withdraw()  # 隐藏主窗口
    print(prompt)
    file_path = filedialog.askopenfilename(title=prompt)
    root.destroy()
    return file_path

def main():
    print("=== SHA256 文件校验工具 ===\n")

    # 选择源文件
    file1 = select_file("请选择源文件（可拖入）")
    if not file1:
        print("未选择文件，程序退出")
        sys.exit()

    print(f"已选择源文件: {file1}\n")

    # 选择对比文件
    file2 = select_file("请选择对比文件（可拖入）")
    if not file2:
        print("未选择文件，程序退出")
        sys.exit()

    print(f"已选择对比文件: {file2}\n")

    # 计算 SHA256
    print("正在计算 SHA256，请稍候...\n")
    sha1 = calculate_sha256(file1)
    sha2 = calculate_sha256(file2)

    if not sha1 or not sha2:
        print("计算失败")
        sys.exit()

    print(f"源文件 SHA256:\n{sha1}\n")
    print(f"对比文件 SHA256:\n{sha2}\n")

    # 对比结果
    if sha1 == sha2:
        print("结果：两个文件 SHA256 相同 ✅")
    else:
        print("结果：两个文件 SHA256 不相同 ❌")

    input("\n按回车键退出...")

if __name__ == "__main__":
    main()