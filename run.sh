# 터미널 출력 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # 색상 없음

# 스크립트 시작 제목
echo -e "${GREEN}===============================================${NC}"
echo -e "${GREEN}   🤫 Android Camera Mute for macOS/Linux     ${NC}"
echo -e "${GREEN}===============================================${NC}"
echo ""

# ADB 실행 파일 경로 설정
ADB_PATH="./adb/adb"

# adb 폴더 및 실행 파일 존재 여부 확인
if [ ! -f "$ADB_PATH" ]; then
    echo -e "${RED}[오류] 'adb' 실행 파일을 찾을 수 없습니다.${NC}"
    echo -e "${YELLOW}'run.sh' 스크립트와 'adb' 폴더가 같은 위치에 있는지 확인해주세요.${NC}"
    exit 1
fi

# adb 실행 권한 부여
chmod +x "$ADB_PATH"

# ADB 서버 시작
echo "[정보] ADB 서버를 시작합니다..."
"$ADB_PATH" start-server > /dev/null 2>&1

# 연결된 기기 확인
echo "[정보] 연결된 기기를 확인합니다..."
# `adb devices` 명령어 결과에서 헤더와 빈 줄을 제외하고 기기 목록만 가져옵니다.
DEVICE_LIST=$("$ADB_PATH" devices | tail -n +2 | grep .)

if [ -z "$DEVICE_LIST" ]; then
    echo -e "${RED}[오류] 연결된 기기를 찾을 수 없습니다.${NC}"
    echo -e "${YELLOW}안내: 기기의 '개발자 옵션'에서 'USB 디버깅'을 활성화한 후, PC와 연결해주세요.${NC}"
    exit 1
fi

# 기기 인증 상태 확인
if echo "$DEVICE_LIST" | grep -q "unauthorized"; then
    echo -e "${RED}[오류] 기기 인증에 실패했습니다 (unauthorized).${NC}"
    echo -e "${YELLOW}안내: 스마트폰 화면을 확인하여 'USB 디버깅 허용' 팝업을 승인해주세요.${NC}"
    exit 1
fi

echo "[정보] 기기가 성공적으로 연결되었습니다."
echo "[정보] 카메라 셔터음 무음 설정을 시도합니다..."

# 카메라 셔터음 강제 설정 값 변경
"$ADB_PATH" shell settings put system csc_pref_camera_forced_shuttersound_key 0

echo ""
echo -e "${GREEN}🎉 성공! 카메라 셔터음이 무음으로 설정되었습니다.${NC}"
echo -e "${YELLOW}이제 기기에서 카메라 앱을 열어 소리가 나지 않는지 확인해보세요.${NC}"
echo ""
read -p "아무 키나 눌러 종료합니다..."

exit 0