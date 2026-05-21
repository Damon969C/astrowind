# coding: utf-8
import os
import shutil
import re
import math
import sys
# --- 新增导入 ---
import tkinter as tk
from tkinter import filedialog

def natural_sort_key(s):
    """
    为字符串提供自然排序的键。
    """
    return [int(text) if text.isdigit() else text.lower() for text in re.split('([0-9]+)', s)]

def get_folder_path_gui():
    """
    使用图形界面让用户选择文件夹。
    """
    root = tk.Tk()
    root.withdraw()  # 隐藏主窗口
    folder_path = filedialog.askdirectory(title="请选择需要整理的文件夹")
    return folder_path

def group_folder_contents():
    """
    主函数，用于获取用户输入并执行文件分组和移动操作。
    """
    target_folder = ""

    # --- 1. 获取用户输入 (修改部分) ---
    # 检查是否有命令行参数传入
    if len(sys.argv) > 1:
        target_folder = sys.argv[1].strip().strip('"')
        print(f"已通过命令行参数识别文件夹路径: {target_folder}")
    else:
        # 如果没有命令行参数，则弹出图形化文件夹选择窗口
        print("未检测到命令行参数，正在打开文件夹选择对话框...")
        target_folder = get_folder_path_gui()
        if not target_folder:
            print("您没有选择文件夹，程序已取消。")
            return

    # 检查路径是否存在且为文件夹
    if not os.path.isdir(target_folder):
        print(f"错误：路径 '{target_folder}' 无效或不是一个文件夹。")
        return

    print(f"目标文件夹: {target_folder}")

    while True:
        try:
            group_size_str = input("请输入每个分组的数量 (例如 15): ")
            group_size = int(group_size_str)
            if group_size > 0:
                break
            else:
                print("错误：分组数量必须是大于0的整数。")
        except ValueError:
            print("错误：请输入一个有效的数字。")

    # --- 2. 获取并排序文件列表 (与原脚本相同) ---
    try:
        all_items = os.listdir(target_folder)
        script_name = os.path.basename(os.path.realpath(sys.argv[0]))
        if script_name in all_items:
            all_items.remove(script_name)
            print(f"提示：已将脚本文件 '{script_name}' 从处理列表中排除。")

        all_items.sort(key=natural_sort_key)
        
        if not all_items:
            print("文件夹为空，无需整理。")
            return
            
        print("-" * 30)
        print(f"找到 {len(all_items)} 个项目准备整理。")
        print("-" * 30)

    except Exception as e:
        print(f"读取文件夹内容时发生错误: {e}")
        return

    # --- 3. 执行移动操作 (与原脚本相同) ---
    for i, item_name in enumerate(all_items):
        group_folder_name = str(math.floor(i / group_size) + 1)
        source_path = os.path.join(target_folder, item_name)
        destination_folder_path = os.path.join(target_folder, group_folder_name)

        try:
            if not os.path.exists(destination_folder_path):
                os.makedirs(destination_folder_path)
                print(f"已创建新文件夹: {destination_folder_path}")

            shutil.move(source_path, destination_folder_path)
            print(f"正在移动: '{item_name}' -> .\\{group_folder_name}\\")
            
        except Exception as e:
            print(f"移动 '{item_name}' 时发生错误: {e}")
            return

    print("-" * 30)
    print("操作完成！所有项目已成功分组。")


if __name__ == "__main__":
    group_folder_contents()
    # 在GUI模式下，如果用户取消选择，程序会直接退出，
    # 这里的input可以保留，以便在命令行模式下暂停。
    input("\n按 Enter 键退出...")