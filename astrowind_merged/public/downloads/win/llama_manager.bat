@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "DOWNLOAD_DIR=%SCRIPT_DIR%downloads"
set "LLAMA_DIR=%SCRIPT_DIR%llama"
set "BIN_DIR=%LLAMA_DIR%\llama-bin"

set "LLAMA_PACKAGE_COUNT=2"
set "llama_pkg[1].label=llama.cpp b8984 Windows x64 CUDA 12.4"
set "llama_pkg[1].file=llama-b8984-bin-win-cuda-12.4-x64.zip"
set "llama_pkg[1].url=https://github.com/ggml-org/llama.cpp/releases/download/b8984/llama-b8984-bin-win-cuda-12.4-x64.zip"
set "llama_pkg[2].label=llama.cpp b8984 Windows x64 CUDA 13.1"
set "llama_pkg[2].file=llama-b8984-bin-win-cuda-13.1-x64.zip"
set "llama_pkg[2].url=https://github.com/ggml-org/llama.cpp/releases/download/b8984/llama-b8984-bin-win-cuda-13.1-x64.zip"

set "DEFAULT_CTX_SIZE=32768"
set "DEFAULT_NGL=99"
set "DEFAULT_THREADS=8"
set "DEFAULT_BATCH_SIZE=512"
set "DEFAULT_PARALLEL=1"
set "DEFAULT_CACHE_TYPE_K=q4_0"
set "DEFAULT_CACHE_TYPE_V=q4_0"
set "DEFAULT_TEMP=1.0"
set "DEFAULT_TOP_P=0.95"
set "DEFAULT_TOP_K=20"
set "DEFAULT_MIN_P=0.0"
set "DEFAULT_PRESENCE_PENALTY=1.5"
set "DEFAULT_REPEAT_PENALTY=1.0"
set "DEFAULT_HOST=127.0.0.1"
set "DEFAULT_PORT=8080"

set "CUDA_COUNT=6"
set "cuda[1].label=CUDA Toolkit 13.2.1"
set "cuda[1].file=cuda_13.2.1_windows.exe"
set "cuda[1].url=https://developer.download.nvidia.com/compute/cuda/13.2.1/local_installers/cuda_13.2.1_windows.exe"
set "cuda[2].label=CUDA Toolkit 12.9.1"
set "cuda[2].file=cuda_12.9.1_576.57_windows.exe"
set "cuda[2].url=https://developer.download.nvidia.com/compute/cuda/12.9.1/local_installers/cuda_12.9.1_576.57_windows.exe"
set "cuda[3].label=CUDA Toolkit 12.8.1"
set "cuda[3].file=cuda_12.8.1_572.61_windows.exe"
set "cuda[3].url=https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/cuda_12.8.1_572.61_windows.exe"
set "cuda[4].label=CUDA Toolkit 12.6.3"
set "cuda[4].file=cuda_12.6.3_561.17_windows.exe"
set "cuda[4].url=https://developer.download.nvidia.com/compute/cuda/12.6.3/local_installers/cuda_12.6.3_561.17_windows.exe"
set "cuda[5].label=CUDA Toolkit 12.4.1"
set "cuda[5].file=cuda_12.4.1_551.78_windows.exe"
set "cuda[5].url=https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda_12.4.1_551.78_windows.exe"
set "cuda[6].label=CUDA Toolkit 11.8.0"
set "cuda[6].file=cuda_11.8.0_522.06_windows.exe"
set "cuda[6].url=https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_522.06_windows.exe"

set "MODEL_COUNT=4"
set "model[1].label=Qwen3.6-27B-Q6_K"
set "model[1].main.file=Qwen3.6-27B-Q6_K.gguf"
set "model[1].main.url=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/Qwen3.6-27B-Q6_K.gguf?download=true"
set "model[1].mmproj.file=mmproj-F16.gguf"
set "model[1].mmproj.url=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/mmproj-F16.gguf?download=true"
set "model[2].label=Qwen3.6-35B-A3B-APEX-I-Balanced"
set "model[2].main.file=Qwen3.6-35B-A3B-APEX-I-Balanced.gguf"
set "model[2].main.url=https://huggingface.co/mudler/Qwen3.6-35B-A3B-APEX-GGUF/resolve/main/Qwen3.6-35B-A3B-APEX-I-Balanced.gguf?download=true"
set "model[2].mmproj.file=mmproj.gguf"
set "model[2].mmproj.url=https://huggingface.co/mudler/Qwen3.6-35B-A3B-APEX-GGUF/resolve/main/mmproj.gguf?download=true"
set "model[3].label=Qwen3.6-27B-Q5_K_S"
set "model[3].main.file=Qwen3.6-27B-Q5_K_S.gguf"
set "model[3].main.url=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/Qwen3.6-27B-Q5_K_S.gguf?download=true"
set "model[3].mmproj.file=mmproj-BF16.gguf"
set "model[3].mmproj.url=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/mmproj-BF16.gguf?download=true"
set "model[4].label=Qwen3.6-27B-Q4_K_M"
set "model[4].main.file=Qwen3.6-27B-Q4_K_M.gguf"
set "model[4].main.url=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/Qwen3.6-27B-Q4_K_M.gguf?download=true"
set "model[4].mmproj.file=mmproj-F16.gguf"
set "model[4].mmproj.url=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/mmproj-F16.gguf?download=true"

call :check_powershell
if errorlevel 1 goto :end

call :ensure_dir "%DOWNLOAD_DIR%"
if errorlevel 1 goto :end

call :ensure_dir "%LLAMA_DIR%"
if errorlevel 1 goto :end

:menu_main
cls
echo ========================================
echo Llama Manager
echo ========================================
echo.
echo Script folder:
echo   %SCRIPT_DIR%
echo.
echo  1. Install CUDA
echo  2. Install llama
echo  3. Download model
echo  4. Run
echo  5. Exit
echo.
set "choice="
set /p "choice=Select an option: "
call :normalize_choice choice

if "%choice%"=="1" (
    call :menu_cuda
    goto :menu_main
)
if "%choice%"=="2" (
    call :install_llama
    goto :menu_main
)
if "%choice%"=="3" (
    call :menu_download_model
    goto :menu_main
)
if "%choice%"=="4" (
    call :menu_run_model
    goto :menu_main
)
if "%choice%"=="5" goto :end
if /I "%choice%"=="Q" goto :end

echo.
echo Invalid choice.
pause
goto :menu_main

:menu_cuda
cls
echo ========================================
echo Install CUDA
echo ========================================
echo.
echo Download folder:
echo   %DOWNLOAD_DIR%
echo.
for /L %%I in (1,1,%CUDA_COUNT%) do (
    call echo   %%I. %%cuda[%%I].label%%
)
echo   B. Back
echo.
set "choice="
set /p "choice=Select a CUDA version: "
call :normalize_choice choice

if /I "%choice%"=="B" exit /b 0
if "%choice%"=="" goto :menu_cuda_invalid

call :load_cuda_selection "%choice%"
if errorlevel 1 goto :menu_cuda_invalid

set "CUDA_TARGET=%DOWNLOAD_DIR%\%CUDA_FILE%"
cls
echo ========================================
echo Install CUDA
echo ========================================
echo.
echo Selected:
echo   %CUDA_LABEL%
echo.
echo Target file:
echo   %CUDA_TARGET%
echo.

call :prepare_download "%CUDA_URL%" "%CUDA_TARGET%" "%CUDA_LABEL%"
set "PREPARE_RC=%ERRORLEVEL%"
if "%PREPARE_RC%"=="2" goto :menu_cuda
if not "%PREPARE_RC%"=="0" (
    pause
    goto :menu_cuda
)

call :launch_file "%CUDA_TARGET%" "CUDA installer"
if errorlevel 1 (
    pause
    goto :menu_cuda
)

pause
exit /b 0

:menu_cuda_invalid
echo.
echo Invalid CUDA choice.
pause
goto :menu_cuda

:install_llama
cls
echo ========================================
echo Install llama
echo ========================================
echo.
echo Target folder:
echo   %LLAMA_DIR%
echo.
echo Select llama.cpp package:
for /L %%I in (1,1,%LLAMA_PACKAGE_COUNT%) do (
    call echo   %%I. %%llama_pkg[%%I].label%%
)
echo   B. Back
echo.
set "choice="
set /p "choice=Select a llama.cpp package: "
call :normalize_choice choice

if /I "%choice%"=="B" exit /b 0
if "%choice%"=="" goto :install_llama_invalid

call :load_llama_package "%choice%"
if errorlevel 1 goto :install_llama_invalid

set "ZIP_FILE=%LLAMA_DIR%\%ZIP_NAME%"

call :ensure_dir "%LLAMA_DIR%"
if errorlevel 1 (
    pause
    exit /b 1
)

cls
echo ========================================
echo Install llama
echo ========================================
echo.
echo Selected:
echo   %ZIP_LABEL%
echo.
echo Package:
echo   %ZIP_NAME%
echo.
echo Target folder:
echo   %LLAMA_DIR%
echo.

call :prepare_download "%ZIP_URL%" "%ZIP_FILE%" "llama.cpp Windows CUDA package"
set "PREPARE_RC=%ERRORLEVEL%"
if "%PREPARE_RC%"=="2" exit /b 0
if not "%PREPARE_RC%"=="0" (
    pause
    exit /b 1
)

call :resolve_server_exe
if errorlevel 1 (
    echo [INFO] llama-server.exe was not found. Extracting package now.
    call :extract_package
    if errorlevel 1 (
        pause
        exit /b 1
    )
    goto :install_llama_done
)

:install_llama_existing
echo [INFO] Existing llama-server.exe found:
echo   %SERVER_EXE%
echo.
echo   U. Use existing binaries
echo   E. Extract package again
echo   B. Back
echo.
set "extract_choice="
set /p "extract_choice=Choose U, E, or B: "
call :normalize_choice extract_choice

if /I "%extract_choice%"=="U" goto :install_llama_done
if /I "%extract_choice%"=="E" (
    call :extract_package
    if errorlevel 1 (
        pause
        exit /b 1
    )
    goto :install_llama_done
)
if /I "%extract_choice%"=="B" exit /b 0

echo.
echo Invalid choice.
pause
cls
echo ========================================
echo Install llama
echo ========================================
echo.
goto :install_llama_existing

:install_llama_done
call :resolve_server_exe
if errorlevel 1 (
    echo [ERROR] llama-server.exe was not found after extraction.
    pause
    exit /b 1
)

echo.
echo [OK] llama is ready.
echo [INFO] llama-server.exe:
echo   %SERVER_EXE%
pause
exit /b 0

:install_llama_invalid
echo.
echo Invalid llama.cpp package choice.
pause
goto :install_llama

:menu_download_model
cls
echo ========================================
echo Download Model
echo ========================================
echo.
for /L %%I in (1,1,%MODEL_COUNT%) do (
    call echo   %%I. %%model[%%I].label%%
)
echo   S. View local GGUF files
echo   B. Back
echo.
set "choice="
set /p "choice=Select a model set: "
call :normalize_choice choice

if /I "%choice%"=="B" exit /b 0
if /I "%choice%"=="S" (
    call :show_local_models
    goto :menu_download_model
)

call :load_builtin_model "%choice%"
if errorlevel 1 goto :menu_download_invalid

call :download_model_set "%choice%"
if errorlevel 1 pause
goto :menu_download_model

:menu_download_invalid
echo.
echo Invalid model choice.
pause
goto :menu_download_model

:menu_run_model
cls
echo ========================================
echo Run
echo ========================================
echo.
for /L %%I in (1,1,%MODEL_COUNT%) do (
    call echo   %%I. %%model[%%I].label%%
)
echo   S. Scan local GGUF files
echo   B. Back
echo.
set "choice="
set /p "choice=Select a model to run: "
call :normalize_choice choice

if /I "%choice%"=="B" exit /b 0
if /I "%choice%"=="S" (
    call :menu_run_local_model
    goto :menu_run_model
)

call :load_builtin_model "%choice%"
if errorlevel 1 goto :menu_run_invalid

call :run_builtin_model "%choice%"
pause
goto :menu_run_model

:menu_run_invalid
echo.
echo Invalid run choice.
pause
goto :menu_run_model

:download_model_set
set "MODEL_ID=%~1"
set "MODEL_LABEL="
set "MODEL_MAIN_FILE="
set "MODEL_MAIN_URL="
set "MODEL_MMPROJ_FILE="
set "MODEL_MMPROJ_URL="
call :load_builtin_model "%MODEL_ID%"
if errorlevel 1 exit /b 1

set "MODEL_MAIN_PATH=%LLAMA_DIR%\%MODEL_MAIN_FILE%"
set "MODEL_MMPROJ_PATH=%LLAMA_DIR%\%MODEL_MMPROJ_FILE%"

set "MODEL_READY=1"
call :file_ready "%MODEL_MAIN_PATH%"
if errorlevel 1 set "MODEL_READY=0"
if defined MODEL_MMPROJ_FILE (
    call :file_ready "%MODEL_MMPROJ_PATH%"
    if errorlevel 1 set "MODEL_READY=0"
)

if "%MODEL_READY%"=="1" (
    cls
    echo ========================================
    echo Download Model
    echo ========================================
    echo.
    echo Files for %MODEL_LABEL% already exist.
    echo.
    echo   U. Use existing files
    echo   R. Re-download files
    echo   B. Back
    echo.
    set "ready_choice="
    set /p "ready_choice=Choose U, R, or B: "
    call :normalize_choice ready_choice

    if /I "!ready_choice!"=="U" (
        echo.
        echo [OK] Existing model files will be used.
        exit /b 0
    )
    if /I "!ready_choice!"=="R" (
        del /f /q "%MODEL_MAIN_PATH%" >nul 2>&1
        if defined MODEL_MMPROJ_FILE del /f /q "%MODEL_MMPROJ_PATH%" >nul 2>&1
    ) else if /I "!ready_choice!"=="B" (
        exit /b 0
    ) else (
        echo.
        echo Invalid choice.
        exit /b 1
    )
)

cls
echo ========================================
echo Download Model
echo ========================================
echo.
echo Selected:
echo   %MODEL_LABEL%
echo.

call :prepare_download "%MODEL_MAIN_URL%" "%MODEL_MAIN_PATH%" "%MODEL_MAIN_FILE%"
set "PREPARE_RC=%ERRORLEVEL%"
if "%PREPARE_RC%"=="2" exit /b 0
if not "%PREPARE_RC%"=="0" exit /b 1

if defined MODEL_MMPROJ_FILE (
    call :prepare_download "%MODEL_MMPROJ_URL%" "%MODEL_MMPROJ_PATH%" "%MODEL_MMPROJ_FILE%"
    set "PREPARE_RC=%ERRORLEVEL%"
    if "%PREPARE_RC%"=="2" exit /b 0
    if not "%PREPARE_RC%"=="0" exit /b 1
)

echo.
echo [OK] %MODEL_LABEL% is ready.
exit /b 0

:run_builtin_model
set "MODEL_ID=%~1"
set "MODEL_LABEL="
set "MODEL_MAIN_FILE="
set "MODEL_MMPROJ_FILE="
call :load_builtin_model "%MODEL_ID%"
if errorlevel 1 exit /b 1

set "MODEL_PATH=%LLAMA_DIR%\%MODEL_MAIN_FILE%"
set "MODEL_MMPROJ_PATH=%LLAMA_DIR%\%MODEL_MMPROJ_FILE%"

call :file_ready "%MODEL_PATH%"
if errorlevel 1 (
    echo.
    echo [ERROR] Main model file is missing:
    echo   %MODEL_PATH%
    echo Use menu 3 to download the model first.
    exit /b 1
)

if defined MODEL_MMPROJ_FILE (
    call :file_ready "%MODEL_MMPROJ_PATH%"
    if errorlevel 1 (
        echo.
        echo [ERROR] mmproj file is missing:
        echo   %MODEL_MMPROJ_PATH%
        echo Use menu 3 to download the model set first.
        exit /b 1
    )
)

call :run_server "%MODEL_PATH%" "%MODEL_MMPROJ_PATH%" "%MODEL_LABEL%"
exit /b %ERRORLEVEL%

:menu_run_local_model
call :build_local_model_list
if "%SCAN_COUNT%"=="0" (
    echo.
    echo [ERROR] No local GGUF model files were found in:
    echo   %LLAMA_DIR%
    pause
    exit /b 0
)

:menu_run_local_loop
cls
echo ========================================
echo Run Local Model
echo ========================================
echo.
echo Model folder:
echo   %LLAMA_DIR%
echo.
for /L %%I in (1,1,%SCAN_COUNT%) do (
    call echo   %%I. %%scan[%%I].file%%
)
echo   B. Back
echo.
set "choice="
set /p "choice=Select a local model: "
call :normalize_choice choice

if /I "%choice%"=="B" exit /b 0
if "%choice%"=="" goto :menu_run_local_invalid

call :load_scan_model "%choice%"
if errorlevel 1 goto :menu_run_local_invalid

set "LOCAL_MODEL_PATH=%LLAMA_DIR%\%LOCAL_FILE%"
set "RESOLVED_MMPROJ="
call :find_mmproj_for_model "%LOCAL_MODEL_PATH%"

echo.
if defined RESOLVED_MMPROJ (
    echo [INFO] Found mmproj:
    echo   %RESOLVED_MMPROJ%
) else (
    echo [INFO] No matching mmproj file found. Running as a text-only model.
)
echo.

call :run_server "%LOCAL_MODEL_PATH%" "%RESOLVED_MMPROJ%" "%LOCAL_FILE%"
pause
goto :menu_run_local_loop

:menu_run_local_invalid
echo.
echo Invalid local model choice.
pause
goto :menu_run_local_loop

:show_local_models
cls
echo ========================================
echo Local GGUF Files
echo ========================================
echo.
echo Folder:
echo   %LLAMA_DIR%
echo.

set "FILE_COUNT=0"
for /f "delims=" %%F in ('dir /b /a-d "%LLAMA_DIR%\*.gguf" 2^>nul') do (
    set /a FILE_COUNT+=1
    echo   %%F
)

if "%FILE_COUNT%"=="0" echo   [none]
echo.
pause
exit /b 0

:prepare_download
set "DOWNLOAD_URL=%~1"
set "DOWNLOAD_DEST=%~2"
set "DOWNLOAD_LABEL=%~3"

:prepare_download_check
call :file_ready "%DOWNLOAD_DEST%"
if errorlevel 1 goto :prepare_download_start

echo [INFO] File already exists:
echo   %DOWNLOAD_DEST%
echo.
echo   U. Use existing file
echo   R. Re-download
echo   B. Back
echo.
set "existing_action="
set /p "existing_action=Choose U, R, or B: "
call :normalize_choice existing_action

if /I "%existing_action%"=="U" exit /b 0
if /I "%existing_action%"=="R" (
    del /f /q "%DOWNLOAD_DEST%" >nul 2>&1
    goto :prepare_download_start
)
if /I "%existing_action%"=="B" exit /b 2

echo.
echo Invalid choice.
goto :prepare_download_check

:prepare_download_start
echo [INFO] Downloading %DOWNLOAD_LABEL%...
set "PS_DL_URL=%DOWNLOAD_URL%"
set "PS_DL_DEST=%DOWNLOAD_DEST%"
set "PS_DL_LABEL=%DOWNLOAD_LABEL%"
call :download_with_progress
if errorlevel 1 (
    echo [ERROR] Failed to download %DOWNLOAD_LABEL%.
    exit /b 1
)

call :file_ready "%DOWNLOAD_DEST%"
if errorlevel 1 (
    echo [ERROR] Downloaded file is missing or empty:
    echo   %DOWNLOAD_DEST%
    exit /b 1
)

exit /b 0

:download_with_progress
setlocal DisableDelayedExpansion
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference='Stop';" ^
    "[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12;" ^
    "$url = $env:PS_DL_URL;" ^
    "$dest = $env:PS_DL_DEST;" ^
    "$label = $env:PS_DL_LABEL;" ^
    "$dir = Split-Path -Parent $dest;" ^
    "if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }" ^
    "$tmp = $dest + '.part';" ^
    "if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }" ^
    "$request = [System.Net.HttpWebRequest]::Create($url);" ^
    "$request.UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)';" ^
    "$request.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate;" ^
    "$request.AllowAutoRedirect = $true;" ^
    "$response = $null;" ^
    "$stream = $null;" ^
    "$file = $null;" ^
    "$downloaded = 0L;" ^
    "$sw = [System.Diagnostics.Stopwatch]::StartNew();" ^
    "$lastTick = -1;" ^
    "try {" ^
    "  $response = $request.GetResponse();" ^
    "  $total = $response.ContentLength;" ^
    "  $stream = $response.GetResponseStream();" ^
    "  $file = [System.IO.File]::Open($tmp, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None);" ^
    "  $buffer = New-Object byte[] 1048576;" ^
    "  while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {" ^
    "    $file.Write($buffer, 0, $read);" ^
    "    $downloaded += $read;" ^
    "    $elapsed = [Math]::Max($sw.Elapsed.TotalSeconds, 0.001);" ^
    "    $speed = $downloaded / 1MB / $elapsed;" ^
    "    $tick = [int]($sw.Elapsed.TotalMilliseconds / 250);" ^
    "    if ($tick -ne $lastTick) {" ^
    "      if ($total -gt 0) {" ^
    "        $pct = [Math]::Min(100, [int](($downloaded * 100) / $total));" ^
    "        $filled = [Math]::Min(30, [int](($pct * 30) / 100));" ^
    "        $bar = ('#' * $filled).PadRight(30, '.');" ^
    "        $status = ('[{0}] {1,3}%% {2,8:N2}/{3,8:N2} MB  {4,6:N2} MB/s' -f $bar, $pct, ($downloaded / 1MB), ($total / 1MB), $speed);" ^
    "      } else {" ^
    "        $status = ('[downloading......................] {0,8:N2} MB  {1,6:N2} MB/s' -f ($downloaded / 1MB), $speed);" ^
    "      }" ^
    "      [Console]::Write(([char]13 + ('{0,-96}' -f $status)));" ^
    "      $lastTick = $tick;" ^
    "    }" ^
    "  }" ^
    "  if ($file) { $file.Dispose(); $file = $null }" ^
    "  if ($stream) { $stream.Dispose(); $stream = $null }" ^
    "  if ($response) { $response.Dispose(); $response = $null }" ^
    "  Write-Host '';" ^
    "  if ($downloaded -le 0) { throw 'Downloaded file is empty.' }" ^
    "  if (Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue }" ^
    "  Move-Item -LiteralPath $tmp -Destination $dest -Force;" ^
    "  Write-Host ('[OK] ' + $label + ' downloaded to: ' + $dest);" ^
    "} catch {" ^
    "  if ($file) { $file.Dispose(); $file = $null }" ^
    "  if ($stream) { $stream.Dispose(); $stream = $null }" ^
    "  if ($response) { $response.Dispose(); $response = $null }" ^
    "  Write-Host '';" ^
    "  if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }" ^
    "  Write-Error ('Download failed: ' + $_.Exception.Message);" ^
    "  exit 1;" ^
    "} finally {" ^
    "  if ($file) { $file.Dispose() }" ^
    "  if ($stream) { $stream.Dispose() }" ^
    "  if ($response) { $response.Dispose() }" ^
    "}"
set "PS_EXIT=%ERRORLEVEL%"
endlocal & exit /b %PS_EXIT%

:extract_package
echo [INFO] Extracting package to:
echo   %BIN_DIR%
set "PS_ZIP_FILE=%ZIP_FILE%"
set "PS_BIN_DIR=%BIN_DIR%"
setlocal DisableDelayedExpansion
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference='Stop';" ^
    "if (-not (Test-Path -LiteralPath $env:PS_BIN_DIR)) { New-Item -ItemType Directory -Path $env:PS_BIN_DIR -Force | Out-Null }" ^
    "Expand-Archive -LiteralPath $env:PS_ZIP_FILE -DestinationPath $env:PS_BIN_DIR -Force"
set "PS_EXIT=%ERRORLEVEL%"
endlocal & set "PS_EXIT=%PS_EXIT%"
if not "%PS_EXIT%"=="0" (
    echo [ERROR] Failed to extract:
    echo   %ZIP_FILE%
    exit /b 1
)
exit /b 0

:run_server
set "MODEL_PATH=%~1"
set "MMPROJ_PATH=%~2"
set "MODEL_LABEL=%~3"

call :resolve_server_exe
if errorlevel 1 (
    echo [ERROR] llama-server.exe was not found.
    echo Use menu 2 to install llama first.
    exit /b 1
)

call :file_ready "%MODEL_PATH%"
if errorlevel 1 (
    echo [ERROR] Model file is missing:
    echo   %MODEL_PATH%
    exit /b 1
)

call :configure_run_params "%MODEL_LABEL%"
if errorlevel 1 exit /b 0

echo ========================================
echo Starting llama-server
echo ========================================
echo.
echo Server:
echo   %SERVER_EXE%
echo Model:
echo   %MODEL_PATH%
if defined MMPROJ_PATH (
    echo mmproj:
    echo   %MMPROJ_PATH%
) else (
    echo mmproj:
    echo   [none]
)
echo URL:
echo   http://%DEFAULT_HOST%:%DEFAULT_PORT%
echo.
echo Parameters:
echo   --cache-type-k %RUN_CACHE_TYPE_K% --cache-type-v %RUN_CACHE_TYPE_V%
echo   --temp %RUN_TEMP% --top-p %RUN_TOP_P% --top-k %RUN_TOP_K% --min-p %RUN_MIN_P%
echo   --presence-penalty %RUN_PRESENCE_PENALTY% --repeat-penalty %RUN_REPEAT_PENALTY%
echo.

if defined MMPROJ_PATH (
    "%SERVER_EXE%" ^
      -m "%MODEL_PATH%" ^
      --mmproj "%MMPROJ_PATH%" ^
      --ctx-size %DEFAULT_CTX_SIZE% ^
      -ngl %DEFAULT_NGL% ^
      --threads %DEFAULT_THREADS% ^
      --batch-size %DEFAULT_BATCH_SIZE% ^
      --parallel %DEFAULT_PARALLEL% ^
      --flash-attn on ^
      --cache-type-k %RUN_CACHE_TYPE_K% ^
      --cache-type-v %RUN_CACHE_TYPE_V% ^
      --temp %RUN_TEMP% ^
      --top-p %RUN_TOP_P% ^
      --top-k %RUN_TOP_K% ^
      --min-p %RUN_MIN_P% ^
      --presence-penalty %RUN_PRESENCE_PENALTY% ^
      --repeat-penalty %RUN_REPEAT_PENALTY% ^
      --no-mmap ^
      -np 1 ^
      --host %DEFAULT_HOST% ^
      --port %DEFAULT_PORT%
) else (
    "%SERVER_EXE%" ^
      -m "%MODEL_PATH%" ^
      --ctx-size %DEFAULT_CTX_SIZE% ^
      -ngl %DEFAULT_NGL% ^
      --threads %DEFAULT_THREADS% ^
      --batch-size %DEFAULT_BATCH_SIZE% ^
      --parallel %DEFAULT_PARALLEL% ^
      --flash-attn on ^
      --cache-type-k %RUN_CACHE_TYPE_K% ^
      --cache-type-v %RUN_CACHE_TYPE_V% ^
      --temp %RUN_TEMP% ^
      --top-p %RUN_TOP_P% ^
      --top-k %RUN_TOP_K% ^
      --min-p %RUN_MIN_P% ^
      --presence-penalty %RUN_PRESENCE_PENALTY% ^
      --repeat-penalty %RUN_REPEAT_PENALTY% ^
      --no-mmap ^
      -np 1 ^
      --host %DEFAULT_HOST% ^
      --port %DEFAULT_PORT%
)

set "RUN_EXIT=%ERRORLEVEL%"
if not "%RUN_EXIT%"=="0" (
    echo.
    echo [ERROR] llama-server exited with code %RUN_EXIT%.
    exit /b 1
)

echo.
echo [OK] llama-server exited normally.
exit /b 0

:configure_run_params
set "PARAM_MODEL_LABEL=%~1"
set "RUN_CACHE_TYPE_K=%DEFAULT_CACHE_TYPE_K%"
set "RUN_CACHE_TYPE_V=%DEFAULT_CACHE_TYPE_V%"
set "RUN_TEMP=%DEFAULT_TEMP%"
set "RUN_TOP_P=%DEFAULT_TOP_P%"
set "RUN_TOP_K=%DEFAULT_TOP_K%"
set "RUN_MIN_P=%DEFAULT_MIN_P%"
set "RUN_PRESENCE_PENALTY=%DEFAULT_PRESENCE_PENALTY%"
set "RUN_REPEAT_PENALTY=%DEFAULT_REPEAT_PENALTY%"
set "PS_PARAM_MODEL_LABEL=%PARAM_MODEL_LABEL%"
set "PS_RUN_CACHE_TYPE_K=%RUN_CACHE_TYPE_K%"
set "PS_RUN_CACHE_TYPE_V=%RUN_CACHE_TYPE_V%"
set "PS_RUN_TEMP=%RUN_TEMP%"
set "PS_RUN_TOP_P=%RUN_TOP_P%"
set "PS_RUN_TOP_K=%RUN_TOP_K%"
set "PS_RUN_MIN_P=%RUN_MIN_P%"
set "PS_RUN_PRESENCE_PENALTY=%RUN_PRESENCE_PENALTY%"
set "PS_RUN_REPEAT_PENALTY=%RUN_REPEAT_PENALTY%"
set "PS_RUN_PARAMS_FILE=%TEMP%\llama_run_params_%RANDOM%%RANDOM%.tmp"

call :configure_run_params_ui
set "CONFIGURE_RC=%ERRORLEVEL%"
if not "%CONFIGURE_RC%"=="0" (
    del /f /q "%PS_RUN_PARAMS_FILE%" >nul 2>&1
    exit /b 1
)
if not exist "%PS_RUN_PARAMS_FILE%" (
    echo [ERROR] Run parameter selection did not return values.
    exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in ("%PS_RUN_PARAMS_FILE%") do set "%%A=%%B"
del /f /q "%PS_RUN_PARAMS_FILE%" >nul 2>&1
exit /b 0

:configure_run_params_ui
setlocal DisableDelayedExpansion
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference='Stop';" ^
    "$items = @(" ^
    "  [pscustomobject]@{ Name='--cache-type-k'; Var='RUN_CACHE_TYPE_K'; Value=$env:PS_RUN_CACHE_TYPE_K }," ^
    "  [pscustomobject]@{ Name='--cache-type-v'; Var='RUN_CACHE_TYPE_V'; Value=$env:PS_RUN_CACHE_TYPE_V }," ^
    "  [pscustomobject]@{ Name='--temp'; Var='RUN_TEMP'; Value=$env:PS_RUN_TEMP }," ^
    "  [pscustomobject]@{ Name='--top-p'; Var='RUN_TOP_P'; Value=$env:PS_RUN_TOP_P }," ^
    "  [pscustomobject]@{ Name='--top-k'; Var='RUN_TOP_K'; Value=$env:PS_RUN_TOP_K }," ^
    "  [pscustomobject]@{ Name='--min-p'; Var='RUN_MIN_P'; Value=$env:PS_RUN_MIN_P }," ^
    "  [pscustomobject]@{ Name='--presence-penalty'; Var='RUN_PRESENCE_PENALTY'; Value=$env:PS_RUN_PRESENCE_PENALTY }," ^
    "  [pscustomobject]@{ Name='--repeat-penalty'; Var='RUN_REPEAT_PENALTY'; Value=$env:PS_RUN_REPEAT_PENALTY }" ^
    ");" ^
    "$selected = 0;" ^
    "$editing = $false;" ^
    "$status = '';" ^
    "function Draw-Screen {" ^
    "  Clear-Host;" ^
    "  Write-Host '========================================';" ^
    "  Write-Host 'Run Parameters';" ^
    "  Write-Host '========================================';" ^
    "  Write-Host '';" ^
    "  Write-Host 'Model:';" ^
    "  Write-Host ('  ' + $env:PS_PARAM_MODEL_LABEL);" ^
    "  Write-Host '';" ^
    "  Write-Host 'Up/Down: move    Type: replace selected value    Backspace: delete char';" ^
    "  Write-Host 'Delete: clear value    Enter: run    Esc: back';" ^
    "  Write-Host '';" ^
    "  for ($i = 0; $i -lt $script:items.Count; $i++) {" ^
    "    $prefix = if ($i -eq $script:selected) { '>' } else { ' ' };" ^
    "    $line = (' {0} {1,-22} {2}' -f $prefix, $script:items[$i].Name, $script:items[$i].Value);" ^
    "    if ($i -eq $script:selected) { Write-Host $line -ForegroundColor Black -BackgroundColor Gray } else { Write-Host $line }" ^
    "  }" ^
    "  Write-Host '';" ^
    "  if ($script:status) { Write-Host $script:status -ForegroundColor Yellow }" ^
    "}" ^
    "$cancel = $false;" ^
    "try {" ^
    "  [Console]::CursorVisible = $false;" ^
    "  while ($true) {" ^
    "    Draw-Screen;" ^
    "    $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');" ^
    "    $script:status = '';" ^
    "    if ($key.VirtualKeyCode -eq 38) { if ($script:selected -gt 0) { $script:selected-- } else { $script:selected = $script:items.Count - 1 }; $script:editing = $false; continue }" ^
    "    if ($key.VirtualKeyCode -eq 40) { if ($script:selected -lt ($script:items.Count - 1)) { $script:selected++ } else { $script:selected = 0 }; $script:editing = $false; continue }" ^
    "    if ($key.VirtualKeyCode -eq 27) { $cancel = $true; break }" ^
    "    if ($key.VirtualKeyCode -eq 13) {" ^
    "      $empty = $script:items | Where-Object { [string]::IsNullOrWhiteSpace($_.Value) } | Select-Object -First 1;" ^
    "      if ($empty) { $script:selected = [array]::IndexOf($script:items, $empty); $script:status = 'Value cannot be empty.'; continue }" ^
    "      break" ^
    "    }" ^
    "    if ($key.VirtualKeyCode -eq 8) {" ^
    "      $value = [string]$script:items[$script:selected].Value;" ^
    "      if ($value.Length -gt 0) { $script:items[$script:selected].Value = $value.Substring(0, $value.Length - 1) }" ^
    "      $script:editing = $true;" ^
    "      continue" ^
    "    }" ^
    "    if ($key.VirtualKeyCode -eq 46) { $script:items[$script:selected].Value = ''; $script:editing = $true; continue }" ^
    "    if (-not [char]::IsControl($key.Character)) {" ^
    "      if (-not $script:editing) { $script:items[$script:selected].Value = [string]$key.Character; $script:editing = $true } else { $script:items[$script:selected].Value = ([string]$script:items[$script:selected].Value) + [string]$key.Character }" ^
    "      continue" ^
    "    }" ^
    "  }" ^
    "} finally {" ^
    "  [Console]::CursorVisible = $true" ^
    "}" ^
    "if ($cancel) { exit 2 }" ^
    "$lines = foreach ($item in $items) { '{0}={1}' -f $item.Var, $item.Value };" ^
    "[System.IO.File]::WriteAllLines($env:PS_RUN_PARAMS_FILE, $lines, [System.Text.Encoding]::ASCII);" ^
    "exit 0"
set "PS_EXIT=%ERRORLEVEL%"
endlocal & exit /b %PS_EXIT%

:resolve_server_exe
set "SERVER_EXE=%BIN_DIR%\llama-server.exe"
if exist "%SERVER_EXE%" exit /b 0

set "SERVER_EXE="
set "PS_SEARCH_DIR=%BIN_DIR%"
for /f "delims=" %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = Get-ChildItem -Path $env:PS_SEARCH_DIR -Filter llama-server.exe -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName; if ($p) { Write-Output $p }"') do (
    set "SERVER_EXE=%%I"
)

if defined SERVER_EXE if exist "%SERVER_EXE%" exit /b 0
exit /b 1

:build_local_model_list
for /L %%I in (1,1,64) do set "scan[%%I].file="
set "SCAN_COUNT=0"

for /f "delims=" %%F in ('dir /b /a-d "%LLAMA_DIR%\*.gguf" 2^>nul') do (
    set "SCAN_NAME=%%F"
    if /I not "!SCAN_NAME:~0,6!"=="mmproj" (
        set /a SCAN_COUNT+=1
        set "scan[!SCAN_COUNT!].file=%%F"
    )
)
exit /b 0

:load_scan_model
set "LOCAL_FILE="
for /L %%I in (1,1,%SCAN_COUNT%) do (
    if "%~1"=="%%I" call set "LOCAL_FILE=%%scan[%%I].file%%"
)
if not defined LOCAL_FILE exit /b 1
exit /b 0

:find_mmproj_for_model
set "RESOLVED_MMPROJ="
set "MODEL_FILE_PATH=%~1"
for %%I in ("%MODEL_FILE_PATH%") do (
    set "MODEL_FILE_DIR=%%~dpI"
    set "MODEL_FILE_STEM=%%~nI"
)

call :maybe_set_mmproj "%MODEL_FILE_DIR%%MODEL_FILE_STEM%.mmproj.gguf"
call :maybe_set_mmproj "%MODEL_FILE_DIR%%MODEL_FILE_STEM%-mmproj.gguf"
call :maybe_set_mmproj "%MODEL_FILE_DIR%%MODEL_FILE_STEM%_mmproj.gguf"
call :maybe_set_mmproj "%MODEL_FILE_DIR%mmproj-F16.gguf"
call :maybe_set_mmproj "%MODEL_FILE_DIR%mmproj.gguf"
exit /b 0

:maybe_set_mmproj
if defined RESOLVED_MMPROJ exit /b 0
if exist "%~1" set "RESOLVED_MMPROJ=%~1"
exit /b 0

:load_cuda_selection
set "CUDA_LABEL="
set "CUDA_FILE="
set "CUDA_URL="
if "%~1"=="1" (
    set "CUDA_LABEL=CUDA Toolkit 13.2.1"
    set "CUDA_FILE=cuda_13.2.1_windows.exe"
    set "CUDA_URL=https://developer.download.nvidia.com/compute/cuda/13.2.1/local_installers/cuda_13.2.1_windows.exe"
    exit /b 0
)
if "%~1"=="2" (
    set "CUDA_LABEL=CUDA Toolkit 12.9.1"
    set "CUDA_FILE=cuda_12.9.1_576.57_windows.exe"
    set "CUDA_URL=https://developer.download.nvidia.com/compute/cuda/12.9.1/local_installers/cuda_12.9.1_576.57_windows.exe"
    exit /b 0
)
if "%~1"=="3" (
    set "CUDA_LABEL=CUDA Toolkit 12.8.1"
    set "CUDA_FILE=cuda_12.8.1_572.61_windows.exe"
    set "CUDA_URL=https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/cuda_12.8.1_572.61_windows.exe"
    exit /b 0
)
if "%~1"=="4" (
    set "CUDA_LABEL=CUDA Toolkit 12.6.3"
    set "CUDA_FILE=cuda_12.6.3_561.17_windows.exe"
    set "CUDA_URL=https://developer.download.nvidia.com/compute/cuda/12.6.3/local_installers/cuda_12.6.3_561.17_windows.exe"
    exit /b 0
)
if "%~1"=="5" (
    set "CUDA_LABEL=CUDA Toolkit 12.4.1"
    set "CUDA_FILE=cuda_12.4.1_551.78_windows.exe"
    set "CUDA_URL=https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda_12.4.1_551.78_windows.exe"
    exit /b 0
)
if "%~1"=="6" (
    set "CUDA_LABEL=CUDA Toolkit 11.8.0"
    set "CUDA_FILE=cuda_11.8.0_522.06_windows.exe"
    set "CUDA_URL=https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_522.06_windows.exe"
    exit /b 0
)
exit /b 1

:load_llama_package
set "ZIP_LABEL="
set "ZIP_NAME="
set "ZIP_URL="
if "%~1"=="1" (
    set "ZIP_LABEL=llama.cpp b8984 Windows x64 CUDA 12.4"
    set "ZIP_NAME=llama-b8984-bin-win-cuda-12.4-x64.zip"
    set "ZIP_URL=https://github.com/ggml-org/llama.cpp/releases/download/b8984/llama-b8984-bin-win-cuda-12.4-x64.zip"
    exit /b 0
)
if "%~1"=="2" (
    set "ZIP_LABEL=llama.cpp b8984 Windows x64 CUDA 13.1"
    set "ZIP_NAME=llama-b8984-bin-win-cuda-13.1-x64.zip"
    set "ZIP_URL=https://github.com/ggml-org/llama.cpp/releases/download/b8984/llama-b8984-bin-win-cuda-13.1-x64.zip"
    exit /b 0
)
exit /b 1

:load_builtin_model
set "MODEL_LABEL="
set "MODEL_MAIN_FILE="
set "MODEL_MAIN_URL="
set "MODEL_MMPROJ_FILE="
set "MODEL_MMPROJ_URL="
if "%~1"=="1" (
    set "MODEL_LABEL=Qwen3.6-27B-Q6_K"
    set "MODEL_MAIN_FILE=Qwen3.6-27B-Q6_K.gguf"
    set "MODEL_MAIN_URL=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/Qwen3.6-27B-Q6_K.gguf?download=true"
    set "MODEL_MMPROJ_FILE=mmproj-F16.gguf"
    set "MODEL_MMPROJ_URL=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/mmproj-F16.gguf?download=true"
    exit /b 0
)
if "%~1"=="2" (
    set "MODEL_LABEL=Qwen3.6-35B-A3B-APEX-I-Balanced"
    set "MODEL_MAIN_FILE=Qwen3.6-35B-A3B-APEX-I-Balanced.gguf"
    set "MODEL_MAIN_URL=https://huggingface.co/mudler/Qwen3.6-35B-A3B-APEX-GGUF/resolve/main/Qwen3.6-35B-A3B-APEX-I-Balanced.gguf?download=true"
    set "MODEL_MMPROJ_FILE=mmproj.gguf"
    set "MODEL_MMPROJ_URL=https://huggingface.co/mudler/Qwen3.6-35B-A3B-APEX-GGUF/resolve/main/mmproj.gguf?download=true"
    exit /b 0
)
if "%~1"=="3" (
    set "MODEL_LABEL=Qwen3.6-27B-Q5_K_S"
    set "MODEL_MAIN_FILE=Qwen3.6-27B-Q5_K_S.gguf"
    set "MODEL_MAIN_URL=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/Qwen3.6-27B-Q5_K_S.gguf?download=true"
    set "MODEL_MMPROJ_FILE=mmproj-BF16.gguf"
    set "MODEL_MMPROJ_URL=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/mmproj-BF16.gguf?download=true"
    exit /b 0
)
if "%~1"=="4" (
    set "MODEL_LABEL=Qwen3.6-27B-Q4_K_M"
    set "MODEL_MAIN_FILE=Qwen3.6-27B-Q4_K_M.gguf"
    set "MODEL_MAIN_URL=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/Qwen3.6-27B-Q4_K_M.gguf?download=true"
    set "MODEL_MMPROJ_FILE=mmproj-F16.gguf"
    set "MODEL_MMPROJ_URL=https://huggingface.co/unsloth/Qwen3.6-27B-GGUF/resolve/main/mmproj-F16.gguf?download=true"
    exit /b 0
)
exit /b 1

:launch_file
set "TARGET_FILE=%~1"
set "TARGET_LABEL=%~2"
call :file_ready "%TARGET_FILE%"
if errorlevel 1 (
    echo [ERROR] File is missing or empty:
    echo   %TARGET_FILE%
    exit /b 1
)

echo [INFO] Launching %TARGET_LABEL%...
start "" "%TARGET_FILE%"
if errorlevel 1 (
    echo [ERROR] Failed to start:
    echo   %TARGET_FILE%
    exit /b 1
)

echo [OK] %TARGET_LABEL% started.
echo If Windows blocks the app, use "More info" and then "Run anyway".
exit /b 0

:file_ready
set "CHECK_SIZE="
if not exist "%~1" exit /b 1
for %%A in ("%~1") do set "CHECK_SIZE=%%~zA"
if not defined CHECK_SIZE exit /b 1
if "%CHECK_SIZE%"=="0" exit /b 1
exit /b 0

:is_number
set "NUMBER_TEXT=%~1"
if not defined NUMBER_TEXT exit /b 1
set "NON_DIGIT=%NUMBER_TEXT%"
for %%D in (0 1 2 3 4 5 6 7 8 9) do set "NON_DIGIT=!NON_DIGIT:%%D=!"
if defined NON_DIGIT exit /b 1
exit /b 0

:normalize_choice
set "%~1=!%~1: =!"
exit /b 0

:ensure_dir
if exist "%~1" exit /b 0
mkdir "%~1" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to create directory:
    echo   %~1
    exit /b 1
)
exit /b 0

:check_powershell
where powershell >nul 2>&1
if errorlevel 1 (
    echo [ERROR] PowerShell was not found. This script requires Windows PowerShell.
    pause
    exit /b 1
)
exit /b 0

:end
endlocal
exit /b 0
