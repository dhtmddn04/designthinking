from collections import deque
from statistics import median

import cv2
import requests
from ultralytics import YOLO

# =========================
# 1. YOLO 모델 불러오기
# =========================
model = YOLO("yolov8n.pt")

# =========================
# 서버 설정
# =========================
SERVER_URL = "http://localhost:3000/waiting-count"


def send_waiting_count(count):
    """검출된 정문 대기인원 수를 Node.js 서버로 전송한다."""
    try:
        response = requests.post(
            SERVER_URL,
            json={
                "station": "정문",
                "count": count,
            },
            timeout=2,
        )

        response.raise_for_status()
        print(f"[서버 전송 성공] 정문 현재 대기인원: {count}명")

    except requests.RequestException as error:
        print(f"[서버 전송 실패] {error}")

# =========================
# 2. 노트북 웹캠 실행
# =========================
cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("카메라를 열 수 없습니다.")
    print("다른 프로그램이 카메라를 사용 중인지 확인하세요.")
    exit()

# 최근 검출 인원 저장: 숫자 흔들림 방지
recent_counts = deque(maxlen=7)
last_stable_count = -1

while True:
    ret, frame = cap.read()

    if not ret:
        print("카메라 프레임을 읽을 수 없습니다.")
        break

    height, width, _ = frame.shape

    # =========================
    # 3. 대기구역 설정
    # =========================
    # 카메라 화면 중앙 아래쪽을 정류장 대기구역으로 가정
    roi_x1 = int(width * 0.15)
    roi_y1 = int(height * 0.35)
    roi_x2 = int(width * 0.85)
    roi_y2 = int(height * 0.95)

    # 파란색 대기구역 표시
    cv2.rectangle(
        frame,
        (roi_x1, roi_y1),
        (roi_x2, roi_y2),
        (255, 0, 0),
        2,
    )

    cv2.putText(
        frame,
        "Waiting Zone",
        (roi_x1, roi_y1 - 10),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.7,
        (255, 0, 0),
        2,
    )

    # =========================
    # 4. 사람 객체검출
    # =========================
    results = model(frame, classes=[0], conf=0.35, verbose=False)

    current_count = 0

    for result in results:
        for box in result.boxes:
            x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())

            # 사람의 발 위치를 박스 아래쪽 중앙점으로 판단
            foot_x = (x1 + x2) // 2
            foot_y = y2

            # 발 위치가 대기구역 안인지 확인
            is_inside_waiting_zone = (
                roi_x1 <= foot_x <= roi_x2
                and roi_y1 <= foot_y <= roi_y2
            )

            if is_inside_waiting_zone:
                current_count += 1
                box_color = (0, 255, 0)       # 초록색: 대기인원 포함
                label = "waiting"
            else:
                box_color = (0, 165, 255)     # 주황색: 대기구역 밖
                label = "outside"

            # 사람 박스 표시
            cv2.rectangle(frame, (x1, y1), (x2, y2), box_color, 2)

            # 발 위치 표시
            cv2.circle(frame, (foot_x, foot_y), 5, box_color, -1)

            cv2.putText(
                frame,
                label,
                (x1, max(y1 - 8, 20)),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.55,
                box_color,
                2,
            )

    # =========================
    # 5. 인원 수 안정화
    # =========================
    recent_counts.append(current_count)
    stable_count = int(median(recent_counts))

    if stable_count != last_stable_count:
        print(f"정문 현재 대기인원: {stable_count}명")

        send_waiting_count(stable_count)

        last_stable_count = stable_count

    # =========================
    # 6. 화면 표시
    # =========================
    cv2.putText(
        frame,
        "Station: Main Gate",
        (20, 35),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.75,
        (255, 255, 255),
        2,
    )

    cv2.putText(
        frame,
        f"Waiting People: {stable_count}",
        (20, 70),
        cv2.FONT_HERSHEY_SIMPLEX,
        1,
        (0, 0, 255),
        3,
    )

    cv2.putText(
        frame,
        "Press Q to quit",
        (20, height - 20),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.55,
        (255, 255, 255),
        2,
    )

    cv2.imshow("IDLE - Main Gate CCTV", frame)

    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cap.release()
cv2.destroyAllWindows()