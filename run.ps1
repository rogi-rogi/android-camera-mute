# UTF-8 인코딩으로 저장해야 한글이 깨지지 않습니다.
Clear-Host

Write-Host "==========================================================" -ForegroundColor White
Write-Host "      Android Camera Shutter Sound Mute Script" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor White
Write-Host ""
Read-Host -Prompt "Press Enter to continue..."
Clear-Host

# 1. adb devices로 연결된 기기 확인
Write-Host "[1/5] Checking for devices with USB debugging enabled..." -ForegroundColor White
Write-Host ""
$adbOutput = (.\adb\adb devices 2>&1) | ForEach-Object { $_.ToString() } | Out-String
Write-Host $adbOutput.TrimEnd() -ForegroundColor DarkGray
Write-Host ""

# "List of devices attached" 헤더를 제외하고 실제 기기 목록이 있는지 확인
if ($adbOutput.Trim() -eq "List of devices attached") {
    Write-Host ""
    Write-Host "[ERROR!] No Android device is connected to the PC." -ForegroundColor Red
    Write-Host "       Please connect your device with a USB cable first." -ForegroundColor White
    $killOutput = (.\adb\adb kill-server 2>&1) | ForEach-Object { $_.ToString() } | Out-String
    Write-Host $killOutput.TrimEnd() -ForegroundColor DarkGray
    Read-Host -Prompt "Press Enter to exit."
    exit
}

Write-Host "... Device connection confirmed. Checking for debugging authorization next." -ForegroundColor White
Write-Host ""

# 2. adb get-state로 권한 1차 확인
Write-Host "[2/5] Checking for USB debugging authorization..." -ForegroundColor White
$stateResult = (.\adb\adb get-state 2>&1) | ForEach-Object { $_.ToString() } | Out-String
Write-Host $stateResult.TrimEnd() -ForegroundColor DarkGray

if ($stateResult.Trim() -eq "device") {
    # 성공 시 바로 설정 변경으로 이동
} else {
    Write-Host "... Authorization not found. Restarting the ADB server." -ForegroundColor White
    Write-Host ""

    # 3. 권한 없는 경우 ADB 서버 재시작
    Write-Host "[3/5] Restarting the ADB server, will check again in 3 seconds..." -ForegroundColor White
    $killOutput = (.\adb\adb kill-server 2>&1) | ForEach-Object { $_.ToString() } | Out-String
    Write-Host $killOutput.TrimEnd() -ForegroundColor DarkGray
    $startOutput = (.\adb\adb start-server 2>&1) | ForEach-Object { $_.ToString() } | Out-String
    Write-Host $startOutput.TrimEnd() -ForegroundColor DarkGray
    Start-Sleep -Seconds 3
    Write-Host ""

    # 4. 권한 2차 확인 및 최종 안내
    Write-Host "[4/5] Re-checking for debugging authorization..." -ForegroundColor White
    $stateResult = (.\adb\adb get-state 2>&1) | ForEach-Object { $_.ToString() } | Out-String
    Write-Host $stateResult.TrimEnd() -ForegroundColor DarkGray
    if ($stateResult.Trim() -ne "device") {
        Write-Host ""
        Write-Host "[ERROR!] Still unable to get authorization. Please try the following:" -ForegroundColor Red
        Write-Host ""
        Write-Host "       1. If a 'Allow USB debugging' pop-up appears on your phone, tap 'Allow'." -ForegroundColor White
        Write-Host "       2. If there's no pop-up, go to [Developer options] -> [Revoke USB debugging authorizations] on your phone." -ForegroundColor White
        Write-Host "       3. Then, unplug and reconnect the USB cable, and restart this script." -ForegroundColor White
        Write-Host ""
        Read-Host -Prompt "Press Enter to exit."
        exit
    }
}

# 5. 셔터 사운드 설정 진행
Write-Host "... Debugging authorization successfully confirmed." -ForegroundColor White
Write-Host ""
Write-Host "[5/5] Changing the camera shutter sound to 0..." -ForegroundColor White
$settingsOutput = (.\adb\adb shell settings put system csc_pref_camera_forced_shuttersound_key 0 2>&1) | ForEach-Object { $_.ToString() } | Out-String
Write-Host $settingsOutput.TrimEnd() -ForegroundColor DarkGray
Write-Host "... Settings change command has been sent." -ForegroundColor White
Write-Host ""
Write-Host "[DONE] All tasks have been completed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "==========================================================" -ForegroundColor White
Write-Host ""

Read-Host -Prompt "Press Enter to exit."
