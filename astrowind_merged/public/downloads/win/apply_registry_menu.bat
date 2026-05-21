@echo off
setlocal EnableExtensions EnableDelayedExpansion

chcp 65001 >nul
title Registry Menu

rem ASCII-only batch source. Chinese UI text is printed from UTF-8 Base64.
rem Registry data is written directly with reg add / reg delete.
set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS_EXE%" set "PS_EXE=powershell.exe"

set "REG_EXE=%SystemRoot%\System32\reg.exe"
if not exist "%REG_EXE%" set "REG_EXE=reg.exe"

set "REG_VIEW="
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "REG_VIEW=/reg:64"
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "REG_VIEW=/reg:64"
if defined PROCESSOR_ARCHITEW6432 set "REG_VIEW=/reg:64"

set "ERR_FILE=%TEMP%\apply_registry_menu_%RANDOM%%RANDOM%.err"

call :RequireAdmin
if errorlevel 1 goto :ExitError

:Menu
cls
call :PrintUtf8 "PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09DQogICAgICAgICAgICAgICAg5rOo5YaM6KGo6YWN572u5YaZ5YWl6I+c5Y2VDQo9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0NCg0KICBbMV0g6ZmQ5Yi2IE1pY3Jvc29mdCBEZWZlbmRlciDmiavmj48gQ1BVIOS9v+eUqOeOh+S4uiA1JQ0KICBbMl0g56aB55So5paH5Lu25aS557G75Z6L6Ieq5Yqo5Y+R546wICsg56aB55So5byA5aeL6I+c5Y2VIEJpbmcg5Zyo57q/5pCc57SiDQogIFszXSDlhpnlhaUgUG90UGxheWVyTWluaTY0IOmFjee9rg0KICBbNF0g56aB5q2iIFdpbmRvd3Mg6Ieq5Yqo5pu05paw6amx5YqoDQoNCiAgQSAg5YWo6YCJDQogIFEgIOmAgOWHug0KDQrovpPlhaXnpLrkvovvvJoxIDMgNCAg5oiWICAxLDMsNCAg5oiWICBBICDmiJYgIFENCg0K"
set "RAW_INPUT="
call :PrintUtf8 "6K+36L6T5YWl6KaB5YaZ5YWl55qE6YCJ6aG577ya"
set /p "RAW_INPUT="
if not defined RAW_INPUT goto :NoValidChoice

set "SELECT_1="
set "SELECT_2="
set "SELECT_3="
set "SELECT_4="
set "HAS_VALID="
set "HAS_INVALID="

set "NORMALIZED=!RAW_INPUT:,= !"
set "NORMALIZED=!NORMALIZED:;= !"
set "NORMALIZED=!NORMALIZED:/= !"

for %%I in (!NORMALIZED!) do (
    set "TOKEN=%%~I"
    if /i "!TOKEN!"=="Q" goto :ExitOk
    if /i "!TOKEN!"=="A" (
        set "SELECT_1=1"
        set "SELECT_2=1"
        set "SELECT_3=1"
        set "SELECT_4=1"
        set "HAS_VALID=1"
    ) else if "!TOKEN!"=="1" (
        set "SELECT_1=1"
        set "HAS_VALID=1"
    ) else if "!TOKEN!"=="2" (
        set "SELECT_2=1"
        set "HAS_VALID=1"
    ) else if "!TOKEN!"=="3" (
        set "SELECT_3=1"
        set "HAS_VALID=1"
    ) else if "!TOKEN!"=="4" (
        set "SELECT_4=1"
        set "HAS_VALID=1"
    ) else (
        call :PrintUtf8 "6K2m5ZGK77ya5bey5b+955Wl5peg5pWI6YCJ6aG577ya"
        echo(!TOKEN!
        set "HAS_INVALID=1"
    )
)

if not defined HAS_VALID goto :NoValidChoice

echo.
call :PrintUtf8 "5bCG5YaZ5YWl5Lul5LiL6YWN572u77yaDQo="
if defined SELECT_1 call :PrintUtf8Ln "ICAtIFsxXSDpmZDliLYgTWljcm9zb2Z0IERlZmVuZGVyIOaJq+aPjyBDUFUg5L2/55So546H5Li6IDUl"
if defined SELECT_2 call :PrintUtf8Ln "ICAtIFsyXSDnpoHnlKjmlofku7blpLnnsbvlnovoh6rliqjlj5HnjrAgKyDnpoHnlKjlvIDlp4voj5zljZUgQmluZyDlnKjnur/mkJzntKI="
if defined SELECT_3 call :PrintUtf8Ln "ICAtIFszXSDlhpnlhaUgUG90UGxheWVyTWluaTY0IOmFjee9rg=="
if defined SELECT_4 call :PrintUtf8Ln "ICAtIFs0XSDnpoHmraIgV2luZG93cyDoh6rliqjmm7TmlrDpqbHliqg="
if defined HAS_INVALID echo.
if defined HAS_INVALID call :PrintUtf8Ln "5o+Q56S677ya5peg5pWI6YCJ6aG55bey5b+955Wl77yM5LiN5Lya5b2x5ZON5pyJ5pWI6YCJ6aG55omn6KGM44CC"
echo.

call :PrintUtf8 "56Gu6K6k5YaZ5YWl77yfW1kvTl0g"
set "CONFIRM_INPUT="
set /p "CONFIRM_INPUT="
if /i not "!CONFIRM_INPUT:~0,1!"=="Y" goto :Menu

set /a TOTAL_ITEM_OK=0
set /a TOTAL_ITEM_FAIL=0
set /a TOTAL_OPS=0
set /a TOTAL_OK=0
set /a TOTAL_FAIL=0
set /a TOTAL_SKIP=0

echo.
call :PrintUtf8 "PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09DQrlvIDlp4vlhpnlhaXms6jlhozooaguLi4NCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQ0K"

if defined SELECT_1 call :ApplyDefenderCpu
if defined SELECT_2 call :ApplyFolderAndBing
if defined SELECT_3 call :ApplyPotPlayer
if defined SELECT_4 call :ApplyDisableDriverUpdate

echo.
call :PrintUtf8 "PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09DQrlhpnlhaXnu5PmnpzmsYfmgLsNCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQ0K"
call :PrintUtf8 "ICDphY3nva7miJDlip/vvJo="
echo(!TOTAL_ITEM_OK!
call :PrintUtf8 "ICDphY3nva7lpLHotKXvvJo="
echo(!TOTAL_ITEM_FAIL!
call :PrintUtf8 "ICDms6jlhozooajmk43kvZzmiJDlip/vvJo="
echo(!TOTAL_OK!
call :PrintUtf8 "ICDms6jlhozooajmk43kvZzlpLHotKXvvJo="
echo(!TOTAL_FAIL!
call :PrintUtf8 "ICDms6jlhozooajmk43kvZzot7Pov4fvvJo="
echo(!TOTAL_SKIP!
echo.
if !TOTAL_ITEM_FAIL! GTR 0 (
    call :PrintUtf8 "W+aPkOekul0g5a2Y5Zyo5aSx6LSl6aG544CC6K+35p+l55yL5LiK5pa56ZSZ6K+v6L6T5Ye677yM56Gu6K6k5piv5ZCm5Lul566h55CG5ZGY6Lqr5Lu96L+Q6KGM44CBDQogICAgICAg5rOo5YaM6KGo6Lev5b6E5piv5ZCm5Y+v5YaZ77yM5oiW5a6J5YWo6L2v5Lu25piv5ZCm5oum5oiq5LqG5L+u5pS544CCDQo="
) else (
    call :PrintUtf8Ln "5a6M5oiQ77ya5omA6YCJ6YWN572u5Z2H5bey5YaZ5YWl44CC6YOo5YiG562W55Wl5Y+v6IO96ZyA6KaB6YeN5ZCv44CB5rOo6ZSA5oiW6YeN5ZCv6LWE5rqQ566h55CG5Zmo5ZCO55Sf5pWI44CC"
)
echo.
call :PauseMsg
goto :Menu

:NoValidChoice
echo.
call :PrintUtf8Ln "6ZSZ6K+v77ya5rKh5pyJ5qOA5rWL5Yiw5pyJ5pWI6YCJ6aG544CC6K+36L6T5YWlIDEtNOOAgUEg5oiWIFHjgII="
echo.
call :PauseMsg
goto :Menu

:RequireAdmin
fltmc >nul 2>&1
if errorlevel 1 (
    call :PrintUtf8Ln "6ZSZ6K+v77ya5b2T5YmN5LiN5piv566h55CG5ZGY5p2D6ZmQ44CC6K+35Y+z6ZSu5q2kIEJBVCDmlofku7bvvIzpgInmi6nku6XnrqHnkIblkZjouqvku73ov5DooYzvvIznhLblkI7ph43or5XjgII="
    echo.
    call :PauseMsg
    exit /b 1
)
exit /b 0

:StartItem
set "CURRENT_ITEM=%~1"
set /a STEP_OPS=0
set /a STEP_OK=0
set /a STEP_FAILS=0
set /a STEP_SKIP=0
echo.
echo ------------------------------------------------------------
call :PrintUtf8 "5q2j5Zyo5aSE55CG77ya"
echo(%~1
echo ------------------------------------------------------------
exit /b 0

:FinishItem
if !STEP_FAILS! EQU 0 (
    set /a TOTAL_ITEM_OK+=1
    call :PrintUtf8 "5a6M5oiQ77ya"
    echo(%~1 (OK !STEP_OK!, SKIP !STEP_SKIP!, FAIL 0)
) else (
    set /a TOTAL_ITEM_FAIL+=1
    call :PrintUtf8 "5aSx6LSl77ya"
    echo(%~1 (OK !STEP_OK!, SKIP !STEP_SKIP!, FAIL !STEP_FAILS!)
)
exit /b 0

:RegAddDword
set "DESC=%~1"
set "KEY=%~2"
set "NAME=%~3"
set "DATA=%~4"
set /a STEP_OPS+=1
set /a TOTAL_OPS+=1

if /i "!NAME!"=="__DEFAULT__" (
    "%REG_EXE%" add "!KEY!" /ve /t REG_DWORD /d !DATA! /f %REG_VIEW% >nul 2>"%ERR_FILE%"
) else (
    "%REG_EXE%" add "!KEY!" /v "!NAME!" /t REG_DWORD /d !DATA! /f %REG_VIEW% >nul 2>"%ERR_FILE%"
)
set "LAST_RC=!ERRORLEVEL!"
if not "!LAST_RC!"=="0" (
    call :RegFail "!DESC!"
) else (
    call :RegOk
)
exit /b 0

:RegAddSz
set "DESC=%~1"
set "KEY=%~2"
set "NAME=%~3"
set "DATA=%~4"
set /a STEP_OPS+=1
set /a TOTAL_OPS+=1

if /i "!NAME!"=="__DEFAULT__" (
    "%REG_EXE%" add "!KEY!" /ve /t REG_SZ /d "!DATA!" /f %REG_VIEW% >nul 2>"%ERR_FILE%"
) else (
    "%REG_EXE%" add "!KEY!" /v "!NAME!" /t REG_SZ /d "!DATA!" /f %REG_VIEW% >nul 2>"%ERR_FILE%"
)
set "LAST_RC=!ERRORLEVEL!"
if not "!LAST_RC!"=="0" (
    call :RegFail "!DESC!"
) else (
    call :RegOk
)
exit /b 0

:RegDeleteKeyIfExists
set "DESC=%~1"
set "KEY=%~2"
set /a STEP_OPS+=1
set /a TOTAL_OPS+=1

"%REG_EXE%" query "!KEY!" %REG_VIEW% >nul 2>"%ERR_FILE%"
set "LAST_RC=!ERRORLEVEL!"
if not "!LAST_RC!"=="0" (
    set /a STEP_SKIP+=1
    set /a TOTAL_SKIP+=1
    call :PrintUtf8 "6Lez6L+H77ya"
    echo(!DESC!: key not found
    exit /b 0
)

"%REG_EXE%" delete "!KEY!" /f %REG_VIEW% >nul 2>"%ERR_FILE%"
set "LAST_RC=!ERRORLEVEL!"
if not "!LAST_RC!"=="0" (
    call :RegFail "!DESC!"
) else (
    call :RegOk
)
exit /b 0

:RegOk
set /a STEP_OK+=1
set /a TOTAL_OK+=1
exit /b 0

:RegFail
set /a STEP_FAILS+=1
set /a TOTAL_FAIL+=1
call :PrintUtf8 "6ZSZ6K+v77ya"
echo(%~1
call :PrintUtf8 "ICAgICAgIHJlZy5leGUg6L+U5Zue6ZSZ6K+v56CB77ya"
echo(!LAST_RC!
call :PrintRegError
exit /b 0

:PrintRegError
for %%F in ("%ERR_FILE%") do set "ERR_SIZE=%%~zF"
if defined ERR_SIZE if not "!ERR_SIZE!"=="0" (
    for /f "usebackq delims=" %%E in ("%ERR_FILE%") do echo        %%E
) else (
    call :PrintUtf8Ln "ICAgICAgIOacquaNleiOt+WIsCByZWcuZXhlIOeahOivpue7humUmeivr+i+k+WHuuOAgg=="
)
exit /b 0

:PrintUtf8
set "PRINT_B64=%~1"
"%PS_EXE%" -NoProfile -NonInteractive -InputFormat None -ExecutionPolicy Bypass -Command "$b=$env:PRINT_B64;[Console]::OutputEncoding=[Text.Encoding]::UTF8;[Console]::Write([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b)))"
exit /b 0

:PrintUtf8Ln
call :PrintUtf8 "%~1"
echo(
exit /b 0

:PauseMsg
call :PrintUtf8 "5oyJ5Lu75oSP6ZSu57un57utLi4u"
pause >nul
exit /b 0

:ApplyDefenderCpu
call :StartItem "Option 1 - Defender CPU 5 percent"
call :RegAddDword "Defender AvgCPULoadFactor = 5" "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "AvgCPULoadFactor" "0x00000005"
call :FinishItem "Option 1 - Defender CPU 5 percent"
exit /b 0

:ApplyFolderAndBing
call :StartItem "Option 2 - Disable folder auto discovery and Bing search"
call :RegAddSz "FolderType = NotSpecified" "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" "FolderType" "NotSpecified"
call :RegAddDword "BingSearchEnabled = 0" "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" "0x00000000"
call :FinishItem "Option 2 - Disable folder auto discovery and Bing search"
exit /b 0

:ApplyDisableDriverUpdate
call :StartItem "Option 4 - Disable Windows driver updates"
call :RegAddDword "ExcludeWUDriversInQualityUpdate = 1" "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "ExcludeWUDriversInQualityUpdate" "0x00000001"
call :RegAddDword "SearchOrderConfig = 0" "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" "0x00000000"
call :FinishItem "Option 4 - Disable Windows driver updates"
exit /b 0

:ApplyPotPlayer
call :StartItem "Option 3 - PotPlayerMini64 config"
set "POT_ROOT=HKCU\Software\Daum\PotPlayerMini64"

call :RegDeleteKeyIfExists "Delete old PotPlayerMini64 config" "!POT_ROOT!"

call :RegAddSz "AtscAntenaList\0 = empty string" "!POT_ROOT!\AtscAntenaList" "0" ""
call :RegAddSz "AtscCableList\0 = empty string" "!POT_ROOT!\AtscCableList" "0" ""

call :RegAddSz "Dialog310 WindowPosition" "!POT_ROOT!\Dialog310" "WindowPosition" "882,199,1682,1317"
call :RegAddSz "Dialog324 WindowPosition" "!POT_ROOT!\Dialog324" "WindowPosition" "1116,346,2510,1550"
call :RegAddDword "Dialog324 TopMost = 0" "!POT_ROOT!\Dialog324" "TopMost" "0x00000000"
call :RegAddDword "Dialog346 TopMost = 0" "!POT_ROOT!\Dialog346" "TopMost" "0x00000000"
call :RegAddDword "Dialog424 TopMost = 0" "!POT_ROOT!\Dialog424" "TopMost" "0x00000000"

call :RegAddSz "DvbcList\0 = empty string" "!POT_ROOT!\DvbcList" "0" ""
call :RegAddSz "DvbsList\0 = empty string" "!POT_ROOT!\DvbsList" "0" ""
call :RegAddSz "DvbtList\0 = empty string" "!POT_ROOT!\DvbtList" "0" ""

call :RegAddDword "Positions MainX" "!POT_ROOT!\Positions" "MainX" "0x00000165"
call :RegAddDword "Positions MainY" "!POT_ROOT!\Positions" "MainY" "0x00000110"
call :RegAddDword "Positions MainWidth2" "!POT_ROOT!\Positions" "MainWidth2" "0x00000735"
call :RegAddDword "Positions MainHeight2" "!POT_ROOT!\Positions" "MainHeight2" "0x000003cc"
call :RegAddDword "Positions VideoWindowWidth" "!POT_ROOT!\Positions" "VideoWindowWidth" "0xffffffff"
call :RegAddDword "Positions VideoWindowHeight" "!POT_ROOT!\Positions" "VideoWindowHeight" "0xffffffff"
call :RegAddDword "Positions AudioWindowRectL0" "!POT_ROOT!\Positions" "AudioWindowRectL0" "0x000004fa"
call :RegAddDword "Positions AudioWindowRectT0" "!POT_ROOT!\Positions" "AudioWindowRectT0" "0x00000355"
call :RegAddDword "Positions AudioWindowRectR0" "!POT_ROOT!\Positions" "AudioWindowRectR0" "0x00000a06"
call :RegAddDword "Positions AudioWindowRectB0" "!POT_ROOT!\Positions" "AudioWindowRectB0" "0x0000035f"
call :RegAddDword "Positions AudioWindowState1" "!POT_ROOT!\Positions" "AudioWindowState1" "0x00000001"
call :RegAddDword "Positions AudioWindowRectL1" "!POT_ROOT!\Positions" "AudioWindowRectL1" "0x000001b6"
call :RegAddDword "Positions AudioWindowRectT1" "!POT_ROOT!\Positions" "AudioWindowRectT1" "0x00000064"
call :RegAddDword "Positions AudioWindowRectR1" "!POT_ROOT!\Positions" "AudioWindowRectR1" "0x0000040e"
call :RegAddDword "Positions AudioWindowRectB1" "!POT_ROOT!\Positions" "AudioWindowRectB1" "0x00000258"
call :RegAddDword "Positions AudioWindowState2" "!POT_ROOT!\Positions" "AudioWindowState2" "0x00000000"
call :RegAddDword "Positions AudioWindowRectL2" "!POT_ROOT!\Positions" "AudioWindowRectL2" "0x00000365"
call :RegAddDword "Positions AudioWindowRectT2" "!POT_ROOT!\Positions" "AudioWindowRectT2" "0x00000225"
call :RegAddDword "Positions AudioWindowRectR2" "!POT_ROOT!\Positions" "AudioWindowRectR2" "0x000005bf"
call :RegAddDword "Positions AudioWindowRectB2" "!POT_ROOT!\Positions" "AudioWindowRectB2" "0x000003eb"
call :RegAddDword "Positions ChatWindowVisible" "!POT_ROOT!\Positions" "ChatWindowVisible" "0x00000000"
call :RegAddDword "Positions ChatWidth" "!POT_ROOT!\Positions" "ChatWidth" "0x00000258"
call :RegAddDword "Positions PlayListWidth" "!POT_ROOT!\Positions" "PlayListWidth" "0x00000258"
call :RegAddDword "Positions PlayListHeight" "!POT_ROOT!\Positions" "PlayListHeight" "0x000001f4"
call :RegAddDword "Positions TopMostWindow0" "!POT_ROOT!\Positions" "TopMostWindow0" "0x00000000"
call :RegAddDword "Positions TopMostWindow1" "!POT_ROOT!\Positions" "TopMostWindow1" "0x00000000"
call :RegAddDword "Positions TopMostWindow2" "!POT_ROOT!\Positions" "TopMostWindow2" "0x00000000"
call :RegAddDword "Positions TopMostWindow3" "!POT_ROOT!\Positions" "TopMostWindow3" "0x00000000"
call :RegAddDword "Positions TopMostWindow4" "!POT_ROOT!\Positions" "TopMostWindow4" "0x00000000"
call :RegAddDword "Positions TopMostWindow5" "!POT_ROOT!\Positions" "TopMostWindow5" "0x00000000"
call :RegAddDword "Positions TopMostWindow6" "!POT_ROOT!\Positions" "TopMostWindow6" "0x00000000"
call :RegAddDword "Positions TopMostWindow7" "!POT_ROOT!\Positions" "TopMostWindow7" "0x00000000"
call :RegAddDword "Positions TopMostWindow8" "!POT_ROOT!\Positions" "TopMostWindow8" "0x00000000"
call :RegAddDword "Positions TopMostWindow9" "!POT_ROOT!\Positions" "TopMostWindow9" "0x00000000"
call :RegAddDword "Positions ControlBoxWidth" "!POT_ROOT!\Positions" "ControlBoxWidth" "0x0000020f"
call :RegAddDword "Positions ControlBoxHeight" "!POT_ROOT!\Positions" "ControlBoxHeight" "0x0000018d"

call :RegAddDword "PotUrlOpen CaptionLoad" "!POT_ROOT!\PotUrlOpen" "CaptionLoad" "0x00000000"

call :RegAddSz "Settings LanguageIni" "!POT_ROOT!\Settings" "LanguageIni" "Chinese(Simplified).ini"
call :RegAddDword "Settings MftDecoder" "!POT_ROOT!\Settings" "MftDecoder" "0x00000001"
call :RegAddDword "Settings DmoDecoder" "!POT_ROOT!\Settings" "DmoDecoder" "0x00000001"
call :RegAddSz "Settings Info1" "!POT_ROOT!\Settings" "Info1" ""
call :RegAddSz "Settings Info6" "!POT_ROOT!\Settings" "Info6" ""
call :RegAddSz "Settings Info7" "!POT_ROOT!\Settings" "Info7" ""
call :RegAddDword "Settings LastConfigPage" "!POT_ROOT!\Settings" "LastConfigPage" "0x00000166"
call :RegAddDword "Settings PlaybackMode" "!POT_ROOT!\Settings" "PlaybackMode" "0x00000001"
call :RegAddSz "Settings LastPlayListName" "!POT_ROOT!\Settings" "LastPlayListName" "PotPlayerMini64.dpl"
call :RegAddSz "Settings LastSkinXmlName" "!POT_ROOT!\Settings" "LastSkinXmlName" "VideoSkin.xml"
call :RegAddSz "Settings LastSkinXmlNameVideo" "!POT_ROOT!\Settings" "LastSkinXmlNameVideo" "VideoSkin.xml"
call :RegAddSz "Settings LastSkinXmlNameAudio" "!POT_ROOT!\Settings" "LastSkinXmlNameAudio" "AudioSkin.xml"
call :RegAddSz "Settings LastUrlList" "!POT_ROOT!\Settings" "LastUrlList" "Radio.asx"
call :RegAddDword "Settings VideoRen2" "!POT_ROOT!\Settings" "VideoRen2" "0x0000000f"
call :RegAddDword "Settings ScreenFitBySize" "!POT_ROOT!\Settings" "ScreenFitBySize" "0x00000001"
call :RegAddDword "Settings AudioVolume" "!POT_ROOT!\Settings" "AudioVolume" "0x0000001e"
call :RegAddDword "Settings PlayScreenSize" "!POT_ROOT!\Settings" "PlayScreenSize" "0x00000000"
call :RegAddDword "Settings PlayScreenMoveCenter" "!POT_ROOT!\Settings" "PlayScreenMoveCenter" "0x00000001"
call :RegAddDword "Settings OpenWithSameName" "!POT_ROOT!\Settings" "OpenWithSameName" "0x00000002"
call :RegAddDword "Settings RememberPosition" "!POT_ROOT!\Settings" "RememberPosition" "0x00000001"
call :RegAddDword "Settings AutoHideMouse" "!POT_ROOT!\Settings" "AutoHideMouse" "0x00000000"
call :RegAddDword "Settings AllowMultiple" "!POT_ROOT!\Settings" "AllowMultiple" "0x00000000"
call :RegAddDword "Settings EffectPage" "!POT_ROOT!\Settings" "EffectPage" "0x00000000"
call :RegAddDword "Settings EffectCastOnly" "!POT_ROOT!\Settings" "EffectCastOnly" "0x00000001"
call :RegAddDword "Settings SkipCastPreview" "!POT_ROOT!\Settings" "SkipCastPreview" "0x00000000"
call :RegAddDword "Settings BroadcastAttachToMain2" "!POT_ROOT!\Settings" "BroadcastAttachToMain2" "0x00000000"
call :RegAddDword "Settings IntDXVAUseMode" "!POT_ROOT!\Settings" "IntDXVAUseMode" "0x00000001"
call :RegAddDword "Settings IntDXVAD3D11" "!POT_ROOT!\Settings" "IntDXVAD3D11" "0x00000001"
call :RegAddDword "Settings MouseLeftSClick" "!POT_ROOT!\Settings" "MouseLeftSClick" "0x00000004"
call :RegAddDword "Settings MouseLeftDClick" "!POT_ROOT!\Settings" "MouseLeftDClick" "0x00000001"
call :RegAddDword "Settings StartScreenSize" "!POT_ROOT!\Settings" "StartScreenSize" "0x00000003"
call :RegAddDword "Settings StartScreenSizeUserW" "!POT_ROOT!\Settings" "StartScreenSizeUserW" "0x00000500"
call :RegAddDword "Settings StartScreenSizeUserH" "!POT_ROOT!\Settings" "StartScreenSizeUserH" "0x000002d0"
call :RegAddDword "Settings StartCenterPos" "!POT_ROOT!\Settings" "StartCenterPos" "0x00000001"
call :RegAddDword "Settings D3DFullScreenUi" "!POT_ROOT!\Settings" "D3DFullScreenUi" "0x00000000"
call :RegAddDword "Settings AutoResizeFullScreen" "!POT_ROOT!\Settings" "AutoResizeFullScreen" "0x00000001"
call :RegAddDword "Settings AutoHideSkin" "!POT_ROOT!\Settings" "AutoHideSkin" "0x00000001"
call :RegAddDword "Settings AttachWindowIndex" "!POT_ROOT!\Settings" "AttachWindowIndex" "0x00000002"
call :RegAddDword "Settings CheckAutoUpdate" "!POT_ROOT!\Settings" "CheckAutoUpdate" "0x00000000"
call :RegAddDword "Settings AutoDownloadFile" "!POT_ROOT!\Settings" "AutoDownloadFile" "0x00000000"

call :RegAddDword "PotPlayerMini64 default value" "!POT_ROOT!" "__DEFAULT__" "0x00000001"
call :RegAddDword "PotPlayerMini64 AddMyComPL" "!POT_ROOT!" "AddMyComPL" "0x00000001"
call :RegAddDword "PotPlayerMini64 ServiceValue" "!POT_ROOT!" "ServiceValue" "0x00000000"
call :RegAddSz "PotPlayerMini64 MInfo1" "!POT_ROOT!" "MInfo1" "uBAPk+dolj/RmpURxLG6tavCnP/gU7Z+PGNqYDiGE5ERnWc=;K3/fI5ubdtnSgu2HAx8/vWI2cQTtT73tyE/TZ/tpz+ni4kw9NDsHjIqrKThzQuBrktOOIbAz4k86X29WiGomua0E2rjnjH0Lkz+kfRwcPIDNGlWEeXR9ncoxPwfi24Do1G2dF9MIFyIX+jieoWKz41RaNVJByBqM52d3Pfnf+WATK8mjbahSDJrQr6Y="
call :RegAddSz "PotPlayerMini64 MInfo2" "!POT_ROOT!" "MInfo2" "uBAPk+dolj/RmpURxLG6tavCnP/gU7Z+PGNqYDiGE5ERnWc=;LnDYapCZao2X3eCBAkxg6W83Z0GvGbC1kFfCZ7U0hezu/hhudHtU28m1dX01X7s9xIDKOPQx7E1hJh4j/C9w4+5f3KG5wj0c0lKLbhZJad3+DAHX"

call :FinishItem "Option 3 - PotPlayerMini64 config"
exit /b 0

:ExitOk
if exist "%ERR_FILE%" del /q "%ERR_FILE%" >nul 2>&1
echo.
call :PrintUtf8Ln "5bey6YCA5Ye644CC"
exit /b 0

:ExitError
if exist "%ERR_FILE%" del /q "%ERR_FILE%" >nul 2>&1
exit /b 1
