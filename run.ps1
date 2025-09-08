# PowerShell 스크립트: 안드로이드 카메라 셔터음 무음 설정

# --- 설정 ---
# 콘솔 색상 변수
$SuccessColor = "Green"
$ErrorColor = "Red"
$WarningColor = "Yellow"
$InfoColor = "White"

# ADB 실행 파일 경로
$AdbPath = ".\adb\adb.exe"

# --- 스크립트 시작 ---
Clear-Host
$Host.UI.RawUI.WindowTitle = "Android Camera Mute"

# 헤더 출력
Write-Host "===============================================" -ForegroundColor $SuccessColor
Write-Host "   🤫 Android Camera Mute for Windows" -ForegroundColor $SuccessColor
Write-Host "===============================================" -ForegroundColor $SuccessColor
Write-Host ""

# 1. ADB 실행 파일 확인
Write-Host "[정보] ADB 실행 파일을 확인합니다..." -ForegroundColor $InfoColor
if (-not (Test-Path $AdbPath)) {
    Write-Host "[오류] '$AdbPath'를 찾을 수 없습니다." -ForegroundColor $ErrorColor
    Write-Host "스크립트와 'adb' 폴더가 같은 위치에 있는지 확인해주세요." -ForegroundColor $WarningColor
    Write-Host ""
    Read-Host "아무 키나 눌러 종료합니다..."
    exit
}

# 2. ADB 서버 시작
Write-Host "[정보] ADB 서버를 시작합니다..." -ForegroundColor $InfoColor
& $AdbPath start-server | Out-Null

# 3. 연결된 기기 확인
Write-Host "[정보] 연결된 기기를 확인합니다..." -ForegroundColor $InfoColor
# `adb devices` 명령어의 출력을 문자열 배열로 받아 처리
$deviceOutput = (& $AdbPath devices)

# "List of devices attached" 헤더와 빈 줄을 제외하고 실제 기기 목록만 필터링
$deviceList = $deviceOutput | Where-Object { $_ -notmatch "List of devices attached" -and $_.Trim() -ne "" }

if ($deviceList.Length -eq 0) {
    Write-Host "[오류] 연결된 기기를 찾을 수 없습니다." -ForegroundColor $ErrorColor
    Write-Host "안내: 기기의 '개발자 옵션'에서 'USB 디버깅'을 활성화한 후, PC와 연결해주세요." -ForegroundColor $WarningColor
    Write-Host ""
    Read-Host "아무 키나 눌러 종료합니다..."
    exit
}

# 4. 기기 인증 상태 확인
if ($deviceList -match "unauthorized") {
    Write-Host "[오류] 기기 인증에 실패했습니다 (unauthorized)." -ForegroundColor $ErrorColor
    Write-Host "안내: 스마트폰 화면을 확인하여 'USB 디버깅 허용' 팝업을 승인해주세요." -ForegroundColor $WarningColor
    Write-Host ""
    Read-Host "아무 키나 눌러 종료합니다..."
    exit
}

# 5. 명령어 실행
Write-Host "[정보] 기기가 성공적으로 연결되었습니다." -ForegroundColor $InfoColor
Write-Host "[정보] 카메라 셔터음 무음 설정을 시도합니다..." -ForegroundColor $InfoColor
& $AdbPath shell settings put system csc_pref_camera_forced_shuttersound_key 0

# 6. 최종 성공 메시지
Write-Host ""
Write-Host "🎉 성공! 카메라 셔터음이 무음으로 설정되었습니다." -ForegroundColor $SuccessColor
Write-Host "이제 기기에서 카메라 앱을 열어 소리가 나지 않는지 확인해보세요." -ForegroundColor $WarningColor
Write-Host ""
Read-Host "아무 키나 눌러 종료합니다..."