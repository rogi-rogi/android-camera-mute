#================================================================
# Helper Functions
#================================================================

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [ValidateSet("Info", "Success", "Error", "Warning", "Debug")]
        [string]$Type = "Info"
    )

    $color = "White"
    $prefix = ""

    switch ($Type) {
        "Success" { $color = "Green"; $prefix = "[DONE] " }
        "Error"   { $color = "Red";   $prefix = "[ERROR!] " }
        "Warning" { $color = "Yellow" }
        "Debug"   { $color = "DarkGray" }
    }

    Write-Host ($prefix + $Message) -ForegroundColor $color
}

function Invoke-AdbCommand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Arguments
    )

    try {
        # adb 명령어 실행 및 표준 오류(2)를 표준 출력(1)으로 리디렉션
        $commandOutput = & ".\adb\adb.exe" $Arguments 2>&1 | ForEach-Object { $_.ToString() } | Out-String
        
        if ($commandOutput.Trim()) {
            Write-Log -Message $commandOutput.TrimEnd() -Type Debug
        }

        return $commandOutput.Trim()
    }
    catch {
        Write-Log -Message "Failed to execute 'adb $Arguments'. Error: $_" -Type Error
        return $null
    }
}

function Show-Header {
    Clear-Host
    $line = "=" * 58
    Write-Log -Message $line
    Write-Log -Message "      Android Camera Shutter Sound Mute Script"
    Write-Log -Message $line
    Write-Host ""
}


#================================================================
# Main Script Logic
#================================================================

Show-Header
Read-Host -Prompt "Press Enter to continue..."
Clear-Host

try {
    # 1. 연결된 기기 확인
    Write-Log -Message "[1/5] Checking for devices with USB debugging enabled..."
    Write-Host ""
    $adbOutput = Invoke-AdbCommand -Arguments "devices"
    Write-Host ""

    $deviceList = $adbOutput -replace "List of devices attached", "" -replace "(\*.*\s*\r?\n?)", ""

    if (-not $deviceList.Trim()) {
        Write-Host ""
        Write-Log -Message "No device with USB debugging enabled was found." -Type Error
        Write-Log -Message "        Please check the following:"
        Write-Log -Message "        1. Ensure your device is connected to the PC with a USB cable."
        Write-Log -Message "        2. Make sure 'USB debugging' is ON in your phone's [Developer options]."
        return
    }

    Write-Log -Message "... Device connection confirmed. Checking for debugging authorization next."
    Write-Host ""

    # 2. USB 디버깅 권한 확인
    Write-Log -Message "[2/5] Checking for USB debugging authorization..."
    $stateResult = Invoke-AdbCommand -Arguments "get-state"

    if ($stateResult -ne "device") {
        Write-Log -Message "... Authorization not found. Restarting the ADB server."
        Write-Host ""

        # 3. ADB 서버 재시작
        Write-Log -Message "[3/5] Restarting the ADB server, will check again in 3 seconds..."
        Invoke-AdbCommand -Arguments "kill-server"
        Invoke-AdbCommand -Arguments "start-server"
        Start-Sleep -Seconds 3
        Write-Host ""

        # 4. 권한 재확인
        Write-Log -Message "[4/5] Re-checking for debugging authorization..."
        $stateResult = Invoke-AdbCommand -Arguments "get-state"

        if ($stateResult -ne "device") {
            Write-Host ""
            Write-Log -Message "Still unable to get authorization. Please try the following:" -Type Error
            Write-Host ""
            Write-Log -Message "        1. If a 'Allow USB debugging' pop-up appears on your phone, tap 'Allow'."
            Write-Log -Message "        2. If there's no pop-up, go to [Developer options] -> [Revoke USB debugging authorizations] on your phone."
            Write-Log -Message "        3. Then, unplug and reconnect the USB cable, and restart this script."
            return
        }
    }

    # 5. 셔터 사운드 설정 변경
    Write-Log -Message "... Debugging authorization successfully confirmed."
    Write-Host ""
    Write-Log -Message "[5/5] Changing the camera shutter sound to 0..."
    Invoke-AdbCommand -Arguments "shell settings put system csc_pref_camera_forced_shuttersound_key 0"
    Write-Log -Message "... Settings change command has been sent."
    Write-Host ""
    Write-Log -Message "All tasks have been completed successfully." -Type Success
    Write-Host ""
    Write-Log -Message ("=" * 58)
}
finally {
    # 스크립트 종료 시 항상 ADB 서버를 정리
    Write-Host ""
    Write-Log -Message "Shutting down the ADB server for cleanup..." -Type Warning
    Invoke-AdbCommand -Arguments "kill-server"
    Write-Host ""
    Read-Host -Prompt "Press Enter to exit."
}
