@echo off
setlocal enabledelayedexpansion

set KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device
set NAME=DevicePasswordLessBuildVersion
set VALUE=0

echo ==============================
echo 注册表配置脚本（增强版）
echo ==============================

:: 1. 检查管理员权限
net session >nul 2>&1
if NOT %errorlevel%==0 (
    echo [错误] 请以管理员身份运行此脚本！
    pause
    exit /b 1
)

:: 2. 检查路径是否存在
reg query "%KEY%" >nul 2>&1
if %errorlevel%==0 (
    echo [信息] 注册表路径已存在
) else (
    echo [信息] 注册表路径不存在，正在创建...
    reg add "%KEY%" /f >nul 2>&1
    if NOT %errorlevel%==0 (
        echo [错误] 创建注册表路径失败！
        pause
        exit /b 1
    )
    echo [成功] 路径创建完成
)

:: 3. 检查键值是否存在
reg query "%KEY%" /v %NAME% >nul 2>&1
if %errorlevel%==0 (
    echo [信息] 键值已存在，准备修改
) else (
    echo [信息] 键值不存在，准备创建
)

:: 4. 写入键值
reg add "%KEY%" /v %NAME% /t REG_DWORD /d %VALUE% /f >nul 2>&1
if %errorlevel%==0 (
    echo [成功] 已设置 %NAME% = %VALUE%
) else (
    echo [错误] 写入注册表失败！
    pause
    exit /b 1
)

:: 5. 校验结果
for /f "tokens=3" %%i in ('reg query "%KEY%" /v %NAME% ^| find "%NAME%"') do (
    set CURRENT=%%i
)

echo [校验] 当前值: !CURRENT!

echo ==============================
echo 操作完成
echo ==============================
pause