# 디자인적 사고

앱 구현하기

## Project Structure

- lib/screens: 홈, 예약, 실시간 의견, 프로필 (화면별 코드)
- lib/widgets: 버튼, 하단바 등 여러 화면에서 재사용하는 UI
- lib/theme: 앱 전체에서 사용하는 색, 글자 스타일, 테마 설정
- lib/models: 버스 정보, 예약 정보, 사용자 정보 같은 데이터 형태 정의
- lib/services: 추천 로직, 시간 계산, API 연결

## 개발 환경

- Flutter: 3.44.0
- Dart: 3.12.0

## 역할

화면 단위로 역할 나누기

- 채원:
- 승우:
- 준영:

## 현재 개발 범위 (5/24~)

실제 API 연동 없이 화면 UI와 기본 동작 구현

- 실제 API 연동은 나중에 진행
- 로그인은 화면만 구현하고 실제로는 구현하지 않음
- 앱 실행, 화면 이동, 디자인 완성이 목표
- 버스 도착 시간, 혼잡도, 예약 정보 등은 임시로 하드코딩

## 규칙 및 방법

### 1. 처음 프로젝트 받기

처음 시작할 때 GitHub 저장소 clone 해서 project 가져오기

주의) git clone하면 현재 directory에 생기기 때문에 원하는 폴더 선택하고 거기서 clone 하세요

```bash
git clone https://github.com/dhtmddn04/designthinking.git
cd designthinking
flutter run -d chrome
```

순서대로 해서 정상적으로 실행되는지 꼭 확인하고 넘어가세요

### 2. main branch 직접 push 금지

main 브랜치는 최종적으로 합칠 branch 이기 때문에 main에 직접 push 하지 말고 pull request 생성하세요.

확인 후 merge 예정

---

### 3. 작업 시작 전 최신 main 가져오기

작업 시작 전 항상 최신 main 가져오기

```bash
git checkout main
git pull origin main
```

그 다음 자기 작업 브랜치 만들기

```bash
git checkout -b feature/기능명
```

예시:

```bash
git checkout -b feature/reservation-screen
```

이미 브랜치가 만들어져 있다면 새로 만들지 않고 이동

```bash
git checkout feature/reservation-screen
```

---

### 4. 화면 작업 방법

각자 담당 화면은 자기 기능 브랜치에서 작업

예시:

```bash
git checkout main
git pull origin main
git checkout -b feature/reservation-screen
```

담당 화면 파일을 중심으로 수정

```text
lib/screens/home_screen.dart
lib/screens/reservation_screen.dart
lib/screens/opinion_screen.dart
lib/screens/profile_screen.dart
```

e.g. 예약 담당은 주로 아래 파일 수정

```text
lib/screens/reservation_screen.dart
```

작업 후 변경 파일을 확인

```bash
git status
```

의도한 파일만 add

```bash
git add lib/screens/reservation_screen.dart
```

커밋 후 자기 브랜치에 push

```bash
git commit -m "Add reservation screen UI"
git push origin feature/reservation-screen
```

commit과 push는 작업 저장용으로 중간중간 해도 되지만 Pull Request는 어느정도 완성했을 때 요청

확인 후 main 병합

---

### 5. 수정 전 공유가 필요한 파일

```text
lib/main.dart
lib/screens/main_screen.dart
pubspec.yaml
```

그냥 수정하지 마세요

---

### 6. commit 전에 변경 파일 확인

```bash
git status
```

의도하지 않은 파일이 보이면 `git add .`를 사용하지 말고 필요한 파일만 골라서 add하기
