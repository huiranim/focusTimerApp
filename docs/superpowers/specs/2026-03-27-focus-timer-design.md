# 집중해 햄콩! — Flutter MVP 설계 문서

**날짜:** 2026-03-27
**플랫폼:** Android
**기술 스택:** Flutter (latest stable), setState, Google AdMob

---

## 1. 개요

"집중해 햄콩!"은 10~20대 여성을 타겟으로 한 초미니멀 집중 타이머 앱이다.
귀여운 햄스터 캐릭터 "햄콩"의 감정 기반 피드백을 통해 생각 없이 바로 집중을 시작할 수 있는 경험을 제공한다.

---

## 2. 파일 구조

```
lib/
├── main.dart                  # 앱 진입점, MaterialApp 설정
├── screens/
│   ├── home_screen.dart       # 시간 선택, 시작 버튼, 햄콩 idle
│   └── timer_screen.dart      # 타이머 진행, 결과 처리, AdMob
├── widgets/
│   ├── hamcon_character.dart  # 햄콩 이미지 + 상태별 에셋 매핑
│   └── circular_timer.dart    # 원형 프로그레스 바 (CustomPaint)
└── constants.dart             # 색상, 메시지 문자열, 시간 옵션

assets/
└── images/
    ├── hamcon_idle.png
    ├── hamcon_focusing.png
    ├── hamcon_success.png
    └── hamcon_fail.png        # (현재는 placeholder 컬러 박스)

android/app/src/main/AndroidManifest.xml  # AdMob App ID 설정
pubspec.yaml                              # google_mobile_ads 의존성
```

---

## 3. 상태 정의 및 전이

### TimerState enum
| 상태 | 설명 |
|------|------|
| `idle` | 홈 화면, 시간 선택 전 |
| `running` | 타이머 진행 중 |
| `success` | 카운트다운 0 도달 |
| `fail` | 사용자가 중도 종료 확인 |

### 상태 전이 흐름
```
idle
  → [시작 버튼] → running
      → [카운트다운 완료] → success → AdMob 전면광고 → 홈으로 pop
      → [종료 버튼 or 뒤로가기] → 확인 다이얼로그
          → [끝낼래] → fail → 홈으로 pop (광고 없음)
          → [계속할래] → running 유지
```

### 타이머 로직
- `dart:async`의 `Timer.periodic(Duration(seconds: 1), ...)` 사용
- 선택 시간(초)을 `int _remainingSeconds`로 관리, 매 틱 -1
- 원형 프로그레스: `_remainingSeconds / _totalSeconds` 비율로 `CustomPaint` 업데이트
- 뒤로가기 차단: `WillPopScope`로 종료 다이얼로그 표시

---

## 4. UI 구조

### 색상 테마 (파스텔톤)
| 역할 | 색상 |
|------|------|
| 배경 | `#FFF8F0` (크림) |
| 포인트 | `#FFB7C5` (파스텔 핑크) |
| 선택 버튼 | `#FFDDE1` (연핑크) |
| 텍스트 | `#5C4A4A` (브라운) |

### HomeScreen
```
Scaffold
└── Column
    ├── Text("집중해 햄콩!")
    ├── HamconCharacter(state: idle)
    ├── Row
    │   ├── TimeButton(5분)
    │   ├── TimeButton(10분)
    │   ├── TimeButton(25분)
    │   └── TimeButton(직접입력) → BottomSheet 슬라이더 (1~60분)
    └── ElevatedButton("시작하기") → push TimerScreen
```

### TimerScreen
```
Scaffold
└── WillPopScope
    └── Column
        ├── Text("화이팅! {N}분 후에 만나자 💪")  # 시작 3초 표시 후 숨김
        ├── Stack
        │   ├── CircularTimer(progress)
        │   └── Text("{MM:SS}")
        ├── HamconCharacter(state: focusing)
        └── TextButton("그만할래") → 종료 다이얼로그
```

### 중도 종료 다이얼로그
```
AlertDialog
├── HamconCharacter(state: fail)
├── content: "지금 {N}분 버텼어, 여기서 끝낼거야?"
├── [계속할래] → dismiss, 타이머 재개
└── [끝낼래]   → state = fail, Navigator.pop()
```

### 성공 처리 (TimerScreen 내 인라인)
1. `success` 상태 진입
2. 진동 발생
3. `"{N}분 집중 성공!! 고생했어 🎉"` + `HamconCharacter(state: success)` 표시
4. 2초 후 AdMob 전면광고 표시
5. 광고 닫힘 → `Navigator.pop()`으로 홈 복귀

---

## 5. 캐릭터 (햄콩) 에셋

### 현재 전략 (placeholder)
- 에셋 미준비 상태에서 컬러 박스로 대체
- `hamcon_character.dart`에서 `Image.asset()` 경로만 교체하면 실제 에셋으로 전환 가능

### 에셋 교체 방법
1. `assets/images/` 경로에 PNG 파일 4개 추가
2. `pubspec.yaml` assets 섹션 등록
3. `hamcon_character.dart`의 placeholder 코드를 `Image.asset()` 로 교체

### 상태별 에셋 매핑
| 상태 | 파일명 | 표정 |
|------|--------|------|
| idle | `hamcon_idle.png` | 기본, 대기 |
| focusing | `hamcon_focusing.png` | 집중, 진지함 |
| success | `hamcon_success.png` | 기쁨, 점프 |
| fail | `hamcon_fail.png` | 아쉬움, 슬픔 |

**디자인 가이드:** 파스텔톤, 원형 기반 단순한 형태, 표정 변화 중심, 과한 애니메이션 금지

---

## 6. AdMob 연동

### 의존성
```yaml
dependencies:
  google_mobile_ads: ^5.1.0
```

### Android 설정 (AndroidManifest.xml)
```xml
<meta-data
  android:name="com.google.android.gms.ads.APPLICATION_ID"
  android:value="ca-app-pub-3940256099942544~3347511713"/>
```

### 광고 흐름
- 앱 시작 시 `InterstitialAd.load()` 미리 로드
- `success` 상태 진입 → 2초 후 `ad.show()`
- `onAdDismissedFullScreenContent` 콜백 → `Navigator.pop()`
- 광고 로드 실패 시 광고 없이 바로 `Navigator.pop()` (폴백)

### 테스트 광고 ID
| 항목 | ID |
|------|-----|
| App ID | `ca-app-pub-3940256099942544~3347511713` |
| Interstitial | `ca-app-pub-3940256099942544/1033173712` |

### 광고 정책
- 성공 종료 시에만 광고 노출
- 중도 종료(`fail`) 시 광고 미노출

---

## 7. UX 메시지

| 상황 | 메시지 |
|------|--------|
| 타이머 시작 | "화이팅! {N}분 후에 만나자 💪" |
| 진행 중 | 없음 (집중 유지) |
| 중도 종료 확인 | "지금 {N}분 버텼어, 여기서 끝낼거야?" |
| 성공 | "{N}분 집중 성공!! 고생했어 🎉" |

---

## 8. 알림 / 피드백

- 타이머 완료 시 진동: `HapticFeedback.vibrate()` (flutter/services.dart)
- 알림(Notification): MVP에서는 미구현 (백그라운드 실행 미지원)

---

## 9. 제외 범위 (MVP)

- 앱 차단 기능
- 통계 / 기록 / 데이터 저장
- 로그인 / 서버 연동
- 테마 변경 / 소셜 기능
- iOS 대응

---

## 10. 개발 우선순위

1. Flutter 프로젝트 생성 및 기본 구조 설정
2. `constants.dart` — 색상, 메시지, 시간 옵션 정의
3. `hamcon_character.dart` — placeholder 구현
4. `circular_timer.dart` — CustomPaint 원형 프로그레스
5. `home_screen.dart` — 시간 선택, 시작 버튼
6. `timer_screen.dart` — 타이머 로직, 상태 관리, 다이얼로그
7. AdMob 연동
8. 진동 피드백
9. QA 및 버그 수정

---

## 11. 성공 기준 (MVP)

- 앱 실행 → 3초 내 타이머 시작 가능
- 버그 없이 타이머 완료 가능
- 광고 정상 노출 (성공 시에만)
- 스토어 등록 성공
