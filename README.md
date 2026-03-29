# 집중해 햄콩!

귀여운 햄스터 캐릭터 "햄콩"과 함께하는 초미니멀 집중 타이머 앱.

**플랫폼:** Android
**타겟:** 10~20대 여성

---

## 기능

- 5분 / 10분 / 25분 빠른 선택 또는 직접 입력 (1~60분)
- 원형 프로그레스 바 카운트다운
- 중도 종료 확인 다이얼로그 (경과 시간 분+초 표시)
- 타이머 성공 완료 시 AdMob 전면 광고 노출
- 중도 종료 시 광고 미노출

---

## 실행 방법

### 요구사항

- Flutter SDK (latest stable)
- Android SDK (API 34 이상)
- Android 에뮬레이터 또는 실기기

### 설치 & 실행

```bash
flutter pub get
flutter run
```

### 테스트

```bash
flutter test
```

---

## 프로젝트 구조

```
lib/
├── main.dart                  # 앱 진입점, AdMob 초기화
├── constants.dart             # 색상, 메시지, 시간 옵션
├── screens/
│   ├── home_screen.dart       # 시간 선택, 시작 버튼
│   └── timer_screen.dart      # 타이머 진행, AdMob 연동
└── widgets/
    ├── hamcon_character.dart  # 햄콩 캐릭터 (현재 placeholder)
    └── circular_timer.dart    # 원형 프로그레스 바

assets/
└── images/                    # 햄콩 이미지 에셋 (현재 미포함)
    ├── hamcon_idle.png
    ├── hamcon_focusing.png
    ├── hamcon_success.png
    └── hamcon_fail.png
```

---

## 햄콩 이미지 에셋 교체 방법

현재 캐릭터는 이모지 placeholder로 구현되어 있습니다. 실제 이미지로 교체하려면:

1. `assets/images/` 경로에 PNG 파일 4개 추가
2. `pubspec.yaml` assets 섹션 주석 해제
3. `lib/widgets/hamcon_character.dart`의 placeholder 코드를 `Image.asset(_assetPath)` 로 교체

**디자인 가이드:** 파스텔톤, 원형 기반 단순한 형태, 표정 변화 중심, 과한 애니메이션 금지

---

## AdMob 설정

현재 테스트 광고 ID로 설정되어 있습니다. 출시 시 실제 ID로 교체 필요:

| 항목 | 위치 |
|------|------|
| App ID | `android/app/src/main/AndroidManifest.xml` |
| Interstitial ID | `lib/constants.dart` — `kInterstitialAdUnitId` |

---

## 향후 계획 (2차 버전)

- 실제 햄콩 이미지 에셋 적용
- 집중 기록 저장
- 캐릭터 성장 시스템
- 앱 차단 기능
