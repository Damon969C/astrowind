@echo off

:: 检查是否以管理员权限运行
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [×] 错误：此脚本需要管理员权限运行！
    echo 请右键点击批处理文件，选择 "以管理员身份运行"
    pause
    exit /b 1
)

:: 提示输入用户名
set /p username=请输入要隐藏的用户名（区分大小写）:

:: 检查用户名是否为空
if "%username%"=="" (
    echo [×] 错误：用户名不能为空！
    pause
    exit /b 1
)

:: 验证用户是否存在
net user "%username%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] 警告：用户 "%username%" 在系统中不存在，但仍会添加隐藏规则。
)

echo.
echo 正在检查用户 "%username%" 的当前状态...

:: 检查注册表项是否已存在
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "%username%" >nul 2>&1

if %errorlevel% equ 0 (
    :: 用户项已存在，检查其值
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "%username%" 2^>nul ^| find "%username%"') do (
        if /i "%%a"=="0x0" (
            echo 用户 "%username%" 已经被隐藏，无需重复操作。
            pause
            exit /b 0
        ) else if /i "%%a"=="0x00000000" (
            echo 用户 "%username%" 已经被隐藏，无需重复操作。
            pause
            exit /b 0
        ) else (
            echo 用户 "%username%" 当前可见，正在设置隐藏...
        )
    )
) else (
    echo 用户 "%username%" 当前可见，正在设置隐藏...
)

:: 确保 SpecialAccounts 键存在
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts" /f >nul 2>&1

:: 确保 UserList 键存在
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /f >nul 2>&1

:: 添加或修改用户隐藏设置
echo 正在修改注册表...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "%username%" /t REG_DWORD /d 0 /f >nul 2>&1

:: 验证操作是否成功
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "%username%" >nul 2>&1
if %errorlevel% equ 0 (
    :: 再次检查值是否正确设置
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "%username%" 2^>nul ^| find "%username%"') do (
        if /i "%%a"=="0x0" (
            call :success
        ) else if /i "%%a"=="0x00000000" (
            call :success
        ) else (
            echo [×] 操作失败：注册表值设置不正确
        )
    )
) else (
    echo [×] 操作失败：无法验证注册表更改
    echo 可能原因：
    echo 1. 权限不足（请以管理员身份运行）
    echo 2. 注册表访问被限制
    echo 3. 系统组策略阻止了此操作
)

pause
exit /b 0

:success
echo.
echo [√] 成功！用户 "%username%" 已被隐藏在登录界面。
echo.
echo 注意事项：
echo - 隐藏的用户仍然可以通过手动输入用户名和密码登录
echo - 如需恢复显示，请将注册表值改为 1 或删除该项
echo - 更改将在下次重启后生效
exit /b 0
