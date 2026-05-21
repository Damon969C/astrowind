; ======================================================
; Telegram 视频上传助手 (最终完美版)
; 快捷键：Ctrl + Shift + V
; ======================================================

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance Force

; 仅在资源管理器中生效
#IfWinActive ahk_class CabinetWClass

^+v::
    ; 0. 防误触
    KeyWait, Ctrl
    KeyWait, Shift

    ; ======================================================
    ; 【智能标签逻辑】
    ; ======================================================
    SmartTag := "#" 

    if DllCall("IsClipboardFormatAvailable", "uint", 1) 
    {
        RawText := Clipboard
        if (StrLen(RawText) < 50 && StrLen(RawText) > 0)
        {
            if (SubStr(RawText, 1, 1) == "#")
                SmartTag := RawText
            else
                SmartTag := "#" . RawText
        }
    }

    ; 1. 备份剪贴板
    ClipSaved := ClipboardAll
    Clipboard := ""

    ; 2. 获取选中文件
    Send, ^c
    ClipWait, 1
    if (ErrorLevel)
    {
        MsgBox, 未检测到选中文件。
        Clipboard := ClipSaved
        return
    }
    
    fullList := Clipboard

    ; ======================================================
    ; 【排序逻辑】
    ; ======================================================
    fullList := Trim(fullList, " `t`r`n")
    Sort, fullList, CL D`n

    ; ======================================================
    ; 【解决蓝色全选问题】
    ; 启动一个一次性定时器，在 100毫秒后(等输入框弹出来后)
    ; 自动按一下 End 键，把光标移到最后
    ; ======================================================
    SetTimer, MoveCursorToEnd, -100

    ; ======================================================
    ; 【输入框】
    ; ======================================================
    InputBox, UserTag, 添加统一标签, 请输入标签内容（已自动添加 #）：`n`n按 Backspace 可清空标签。, , 350, 160, , , , , %SmartTag%
    
    if (ErrorLevel)
    {
        Clipboard := ClipSaved
        return
    }

    ; 标签处理
    if (Trim(UserTag) == "#" || UserTag == "")
        TagPrefix := ""
    else
        TagPrefix := UserTag . " " 

    ; ======================================================
    ; 【预览确认】
    ; ======================================================
    MsgBox, 1, 确认顺序, 📌 最终标签：【%TagPrefix%】`n`n📂 确认发送顺序：`n----------------------`n%fullList%`n----------------------`n`n点击【确定】开始发送。
    IfMsgBox Cancel
    {
        Clipboard := ClipSaved
        return
    }

    ToolTip, 🚀 正在发送...

    ; 3. 循环处理
    Loop, Parse, fullList, `n, `r
    {
        currentFilePath := A_LoopField
        if (currentFilePath = "")
            continue

        SplitPath, currentFilePath, , , , NameNoExt

        ; --- 步骤 D: 激活 TG ---
        if WinExist("ahk_exe Telegram.exe")
        {
            WinActivate
            WinWaitActive, ahk_exe Telegram.exe, , 2
        }
        else
        {
            MsgBox, 未找到 Telegram。
            break
        }

        ; --- 步骤 E: 粘贴视频 ---
        SetClipboardFiles(currentFilePath)
        Sleep, 100
        Send, ^v
        
        Sleep, 1800 

        ; --- 步骤 F: 粘贴文件名 ---
        FinalCaption := TagPrefix . NameNoExt
        Clipboard := FinalCaption
        Sleep, 100
        Send, ^v   
        Sleep, 500

        ; --- 步骤 G: 发送 ---
        Send, {Enter}
        Sleep, 2200
    }

    ToolTip 
    Clipboard := ClipSaved
    MsgBox, ✅ 发送完成！
return

; ======================================================
; 辅助标签：自动移动光标到末尾
; ======================================================
MoveCursorToEnd:
    ; 等待标题为 "添加统一标签" 的窗口出现 (就是我们的InputBox)
    WinWaitActive, 添加统一标签, , 2
    if !ErrorLevel
    {
        Send, {End} ; 发送 End 键取消选中
    }
return

#IfWinActive

; 核心底层函数
SetClipboardFiles(FilesToSet) {
    DROPFILES_SIZE := 20
    TotalSize := DROPFILES_SIZE + (StrLen(FilesToSet) + 1) * 2 + 2
    hMem := DllCall("GlobalAlloc", "uint", 0x42, "ptr", TotalSize, "ptr")
    pMem := DllCall("GlobalLock", "ptr", hMem, "ptr")
    NumPut(DROPFILES_SIZE, pMem + 0, "uint")
    NumPut(1, pMem + 16, "uint")
    StrPut(FilesToSet, pMem + DROPFILES_SIZE, "UTF-16")
    DllCall("GlobalUnlock", "ptr", hMem)
    if DllCall("OpenClipboard", "ptr", 0)
    {
        DllCall("EmptyClipboard")
        DllCall("SetClipboardData", "uint", 15, "ptr", hMem)
        DllCall("CloseClipboard")
    }
}