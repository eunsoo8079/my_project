# MoodLog 개발 가이드

## ⚠️ 경로 주의사항

| 용도 | 경로 |
|---|---|
| **빌드/실행 (필수)** | `C:\Users\eunso\my_project` |
| Git 저장소 | `C:\Users\eunso\OneDrive\문서\my_project` |

> OneDrive 경로에서 `flutter run`이나 `flutter build`를 실행하면 **파일 잠금 에러**가 발생합니다.
> 반드시 `C:\Users\eunso\my_project`에서 실행하세요.

## 자주 쓰는 명령어

```powershell
# 빌드 경로로 이동
cd C:\Users\eunso\my_project

# 디바이스에서 디버그 실행
flutter run

# release APK 빌드
flutter clean
flutter pub get
flutter build apk --release
# → 결과: build\app\outputs\flutter-apk\app-release.apk

# 코드 분석
flutter analyze

# 연결된 디바이스 확인
flutter devices
```

## 파일 동기화 (빌드 경로 → Git 경로)

코드를 수정한 후 Git에 올리기 전에 동기화:

```powershell
# 예시: 변경된 파일 복사
Copy-Item "C:\Users\eunso\my_project\lib\*.dart" "C:\Users\eunso\OneDrive\문서\my_project\lib\" -Recurse -Force
```

## Git 푸시

```powershell
cd C:\Users\eunso\OneDrive\문서\my_project
git add -A
git commit -m "커밋 메시지"
git push
```

## ADB 문제 해결

```powershell
# ADB 재시작
adb kill-server
adb start-server
adb devices

# 기기가 unauthorized로 뜰 때:
# 휴대폰 → 설정 → 개발자 옵션 → USB 디버깅 인증 취소 → USB 다시 연결 → 허용
```

## SDK 경로

| 항목 | 경로 |
|---|---|
| Flutter SDK | `C:\Users\eunso\flutter` |
| Android SDK | `C:\Users\eunso\AppData\Local\Android\Sdk` |
| Java (Android Studio 번들) | `C:\Program Files\Android\Android Studio\jbr\bin\java` |
