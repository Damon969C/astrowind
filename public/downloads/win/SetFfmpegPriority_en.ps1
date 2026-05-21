# PowerShell Script: SetFfmpegPriority.ps1

# Target registry path
$baseKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
$appName = "ffmpeg.exe"
$perfOptionsName = "PerfOptions"
$propertyName = "CpuPriorityClass"
$propertyValue = 3  # DWORD value for CPU priority

Write-Host "Setting CPU priority for $appName to $propertyValue ..."

# 1. Ensure ffmpeg.exe subkey exists; create it if it does not
New-Item -Path $baseKey -Name $appName -Force | Out-Null

# 2. Create PerfOptions subkey under ffmpeg.exe
$ffmpegKey = Join-Path $baseKey $appName
New-Item -Path $ffmpegKey -Name $perfOptionsName -Force | Out-Null

# 3. Create or set the CpuPriorityClass value under PerfOptions
$perfOptionsKey = Join-Path $ffmpegKey $perfOptionsName
New-ItemProperty -Path $perfOptionsKey -Name $propertyName -PropertyType DWord -Value $propertyValue -Force | Out-Null

Write-Host "Done! Registry updated at: $perfOptionsKey\$propertyName"
