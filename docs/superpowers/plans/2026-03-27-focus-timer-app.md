# 집중해 햄콩! Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flutter Android MVP 집중 타이머 앱 "집중해 햄콩!" 전체 구현

**Architecture:** HomeScreen(시간 선택) + TimerScreen(타이머 + 결과 처리) 2화면 구조. 상태관리는 `setState`만 사용. `TimerState` enum으로 idle/running/success/fail 전이. 햄콩 캐릭터는 placeholder(이모지+컬러 원)로 구현 후 에셋 교체 용이하게 설계.

**Tech Stack:** Flutter latest stable, `dart:async Timer`, `google_mobile_ads ^5.1.0`, `HapticFeedback` (flutter/services.dart)

---

## 파일 구조

| 파일 | 역할 |
|------|------|
| `lib/main.dart` | 앱 진입점, AdMob 초기화, MaterialApp |
| `lib/constants.dart` | 색상, 메시지 함수, 시간 포맷, 광고 ID |
| `lib/screens/home_screen.dart` | 시간 선택, 시작 버튼 화면 |
| `lib/screens/timer_screen.dart` | 타이머 로직, 상태 관리, 성공/중도종료 처리, AdMob |
| `lib/widgets/hamcon_character.dart` | 햄콩 캐릭터 placeholder (상태별 이모지+컬러 원) |
| `lib/widgets/circular_timer.dart` | 원형 프로그레스 바 (CustomPaint) |
| `test/constants_test.dart` | formatTime, 메시지 함수 단위 테스트 |
| `test/widgets/hamcon_character_test.dart` | HamconCharacter 위젯 테스트 |
| `test/widgets/circular_timer_test.dart` | CircularTimer 위젯 테스트 |
| `test/screens/home_screen_test.dart` | HomeScreen 위젯 테스트 |
| `test/screens/timer_screen_test.dart` | TimerScreen 위젯 테스트 |
| `android/app/src/main/AndroidManifest.xml` | AdMob App ID 메타데이터 추가 |
| `pubspec.yaml` | `google_mobile_ads` 의존성 추가 |

---

### Task 1: Flutter 프로젝트 생성 및 기본 설정

**Files:**
- Create: `pubspec.yaml` (flutter create 후 수정)
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Flutter 프로젝트 생성**

```bash
cd /Users/n-hryu/Dev/workspace/homework/focusTimerApp
flutter create . --project-name focus_timer_app --org com.example --platforms android
```

Expected: `lib/main.dart`, `pubspec.yaml`, `android/`, `test/` 등 생성. 기존 `docs/` 폴더는 유지됨.

- [ ] **Step 2: `pubspec.yaml` dependencies 수정**

`pubspec.yaml`의 `dependencies` 섹션을 다음으로 교체:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_mobile_ads: ^5.1.0
```

`flutter:` 섹션 (파일 하단):

```yaml
flutter:
  uses-material-design: true
  # assets는 실제 이미지 준비 후 아래 주석 해제
  # assets:
  #   - assets/images/
```

- [ ] **Step 3: 의존성 설치**

```bash
flutter pub get
```

Expected: `Resolving dependencies...` 후 `Changed N dependencies!`

- [ ] **Step 4: AndroidManifest.xml에 AdMob App ID 추가**

`android/app/src/main/AndroidManifest.xml`의 `<application>` 태그 안에 추가:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

- [ ] **Step 5: assets 디렉토리 생성**

```bash
mkdir -p assets/images
```

- [ ] **Step 6: 기본 빌드 확인**

```bash
flutter build apk --debug
```

Expected: `Built build/app/outputs/flutter-apk/app-debug.apk.` (에러 없음)

- [ ] **Step 7: Commit**

```bash
git init
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml
git commit -m "chore: init flutter project with AdMob setup"
```

---

### Task 2: constants.dart 구현 (TDD)

**Files:**
- Create: `lib/constants.dart`
- Create: `test/constants_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/constants_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_timer_app/constants.dart';

void main() {
  group('formatTime', () {
    test('0초 → 00:00', () {
      expect(formatTime(0), '00:00');
    });
    test('65초 → 01:05', () {
      expect(formatTime(65), '01:05');
    });
    test('1500초(25분) → 25:00', () {
      expect(formatTime(1500), '25:00');
    });
    test('59초 → 00:59', () {
      expect(formatTime(59), '00:59');
    });
  });

  group('UX 메시지', () {
    test('startMessage에 분 포함', () {
      expect(startMessage(25), '화이팅! 25분 후에 만나자 💪');
    });
    test('successMessage에 분 포함', () {
      expect(successMessage(10), '10분 집중 성공!! 고생했어 🎉');
    });
    test('failConfirmMessage에 경과 분 포함', () {
      expect(failConfirmMessage(3), '지금 3분 버텼어, 여기서 끝낼거야?');
    });
    test('0분 경과 시 failConfirmMessage', () {
      expect(failConfirmMessage(0), '지금 0분 버텼어, 여기서 끝낼거야?');
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/constants_test.dart
```

Expected: FAIL with `Target of URI doesn't exist: 'package:focus_timer_app/constants.dart'`

- [ ] **Step 3: `lib/constants.dart` 구현**

```dart
import 'package:flutter/material.dart';

// 색상
const Color kBackgroundColor = Color(0xFFFFF8F0);  // 크림
const Color kPointColor = Color(0xFFFFB7C5);        // 파스텔 핑크
const Color kSelectedButtonColor = Color(0xFFFFDDE1); // 연핑크
const Color kTextColor = Color(0xFF5C4A4A);          // 브라운

// 기본 시간 옵션 (분)
const List<int> kTimeOptions = [5, 10, 25];

// AdMob 테스트 광고 ID
const String kInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

// 시간 포맷: 초 → MM:SS
String formatTime(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

// UX 메시지
String startMessage(int minutes) => '화이팅! $minutes분 후에 만나자 💪';
String successMessage(int minutes) => '$minutes분 집중 성공!! 고생했어 🎉';
String failConfirmMessage(int minutes) => '지금 $minutes분 버텼어, 여기서 끝낼거야?';
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/constants_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/constants.dart test/constants_test.dart
git commit -m "feat: add constants (colors, messages, formatTime)"
```

---

### Task 3: HamconCharacter 위젯 구현 (TDD)

**Files:**
- Create: `lib/widgets/hamcon_character.dart`
- Create: `test/widgets/hamcon_character_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/widgets/hamcon_character_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_timer_app/widgets/hamcon_character.dart';

void main() {
  testWidgets('idle 상태 이모지 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HamconCharacter(state: HamconState.idle)),
      ),
    );
    expect(find.text('🐹'), findsOneWidget);
  });

  testWidgets('focusing 상태 이모지 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HamconCharacter(state: HamconState.focusing)),
      ),
    );
    expect(find.text('😤'), findsOneWidget);
  });

  testWidgets('success 상태 이모지 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HamconCharacter(state: HamconState.success)),
      ),
    );
    expect(find.text('🎉'), findsOneWidget);
  });

  testWidgets('fail 상태 이모지 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HamconCharacter(state: HamconState.fail)),
      ),
    );
    expect(find.text('😢'), findsOneWidget);
  });

  testWidgets('기본 size=120 적용', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: HamconCharacter(state: HamconState.idle))),
      ),
    );
    final size = tester.getSize(find.byType(HamconCharacter));
    expect(size.width, closeTo(120, 1));
    expect(size.height, closeTo(120, 1));
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/widgets/hamcon_character_test.dart
```

Expected: FAIL with `Target of URI doesn't exist`

- [ ] **Step 3: `lib/widgets/hamcon_character.dart` 구현**

```dart
import 'package:flutter/material.dart';

enum HamconState { idle, focusing, success, fail }

/// 햄콩 캐릭터 위젯.
/// 현재는 placeholder(이모지 + 컬러 원). 실제 에셋 준비 후:
/// 1. pubspec.yaml assets 섹션 주석 해제
/// 2. _buildCharacter()를 Image.asset(_assetPath)으로 교체
class HamconCharacter extends StatelessWidget {
  final HamconState state;
  final double size;

  const HamconCharacter({
    super.key,
    required this.state,
    this.size = 120,
  });

  Color get _color {
    switch (state) {
      case HamconState.idle:
        return const Color(0xFFFFDDE1);
      case HamconState.focusing:
        return const Color(0xFFFFB7C5);
      case HamconState.success:
        return const Color(0xFFB7FFCA);
      case HamconState.fail:
        return const Color(0xFFD0D0D0);
    }
  }

  String get _emoji {
    switch (state) {
      case HamconState.idle:
        return '🐹';
      case HamconState.focusing:
        return '😤';
      case HamconState.success:
        return '🎉';
      case HamconState.fail:
        return '😢';
    }
  }

  // 에셋 교체 시 사용할 경로 (현재 미사용)
  // String get _assetPath {
  //   switch (state) {
  //     case HamconState.idle:      return 'assets/images/hamcon_idle.png';
  //     case HamconState.focusing:  return 'assets/images/hamcon_focusing.png';
  //     case HamconState.success:   return 'assets/images/hamcon_success.png';
  //     case HamconState.fail:      return 'assets/images/hamcon_fail.png';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            _emoji,
            style: TextStyle(fontSize: size * 0.45),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/widgets/hamcon_character_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/hamcon_character.dart test/widgets/hamcon_character_test.dart
git commit -m "feat: add HamconCharacter placeholder widget"
```

---

### Task 4: CircularTimer 위젯 구현 (TDD)

**Files:**
- Create: `lib/widgets/circular_timer.dart`
- Create: `test/widgets/circular_timer_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/widgets/circular_timer_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_timer_app/widgets/circular_timer.dart';

void main() {
  testWidgets('시간 텍스트 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CircularTimer(progress: 0.5, timeText: '12:30'),
        ),
      ),
    );
    expect(find.text('12:30'), findsOneWidget);
  });

  testWidgets('progress=1.0 으로 렌더 에러 없음', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CircularTimer(progress: 1.0, timeText: '25:00'),
        ),
      ),
    );
    expect(find.text('25:00'), findsOneWidget);
  });

  testWidgets('progress=0.0 으로 렌더 에러 없음', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CircularTimer(progress: 0.0, timeText: '00:00'),
        ),
      ),
    );
    expect(find.text('00:00'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/widgets/circular_timer_test.dart
```

Expected: FAIL with `Target of URI doesn't exist`

- [ ] **Step 3: `lib/widgets/circular_timer.dart` 구현**

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants.dart';

class CircularTimer extends StatelessWidget {
  /// 0.0(종료) ~ 1.0(시작) 사이의 진행률
  final double progress;
  final String timeText;
  final double size;

  const CircularTimer({
    super.key,
    required this.progress,
    required this.timeText,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _TimerPainter(progress: progress.clamp(0.0, 1.0)),
          ),
          Text(
            timeText,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;

  _TimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;

    // 배경 트랙
    final bgPaint = Paint()
      ..color = kSelectedButtonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // 진행 호 (12시 방향 기준, 시계 방향)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = kPointColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,           // 12시 방향 시작
        2 * math.pi * progress, // 진행률만큼 호 그리기
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TimerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/widgets/circular_timer_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/circular_timer.dart test/widgets/circular_timer_test.dart
git commit -m "feat: add CircularTimer widget with CustomPaint"
```

---

### Task 5: HomeScreen 구현 (TDD)

**Files:**
- Create: `lib/screens/home_screen.dart`
- Create: `test/screens/home_screen_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/screens/home_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_timer_app/screens/home_screen.dart';

void main() {
  testWidgets('시간 선택 버튼 3개 + 직접입력 표시', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('5분'), findsOneWidget);
    expect(find.text('10분'), findsOneWidget);
    expect(find.text('25분'), findsOneWidget);
    expect(find.text('직접입력'), findsOneWidget);
  });

  testWidgets('시작하기 버튼 표시', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('시작하기'), findsOneWidget);
  });

  testWidgets('앱 타이틀 표시', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('집중해 햄콩!'), findsOneWidget);
  });

  testWidgets('5분 버튼 탭 시 선택 상태로 변경', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('5분'));
    await tester.pump();
    // 탭 후 에러 없이 화면 유지 확인
    expect(find.text('5분'), findsOneWidget);
  });

  testWidgets('시작하기 버튼 탭 시 TimerScreen으로 이동', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('시작하기'));
    await tester.pump(); // 탭 처리
    await tester.pump(const Duration(milliseconds: 400)); // 네비게이션 애니메이션 완료
    // TimerScreen에 '그만할래' 버튼이 있어야 함
    expect(find.text('그만할래'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/screens/home_screen_test.dart
```

Expected: FAIL with `Target of URI doesn't exist`

- [ ] **Step 3: `lib/screens/home_screen.dart` 구현**

```dart
import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/hamcon_character.dart';
import 'timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedMinutes = 25;

  void _showCustomTimePicker() {
    int tempMinutes = _selectedMinutes.clamp(1, 60);
    showModalBottomSheet(
      context: context,
      backgroundColor: kBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempMinutes분',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: tempMinutes.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    activeColor: kPointColor,
                    inactiveColor: kSelectedButtonColor,
                    onChanged: (value) {
                      setModalState(() => tempMinutes = value.round());
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedMinutes = tempMinutes);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPointColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('확인',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '집중해 햄콩!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 32),
              const HamconCharacter(state: HamconState.idle),
              const SizedBox(height: 40),
              // 시간 선택 버튼 행
              Wrap(
                spacing: 10,
                children: [
                  ...kTimeOptions.map((min) => _TimeButton(
                        label: '$min분',
                        selected: _selectedMinutes == min,
                        onTap: () => setState(() => _selectedMinutes = min),
                      )),
                  _TimeButton(
                    label: '직접입력',
                    selected: !kTimeOptions.contains(_selectedMinutes),
                    onTap: _showCustomTimePicker,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TimerScreen(minutes: _selectedMinutes),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPointColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 52, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TimeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kPointColor : kSelectedButtonColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/screens/home_screen_test.dart
```

Expected: `All tests passed!`

Note: 마지막 테스트(`시작하기 버튼 탭 시 TimerScreen으로 이동`)는 TimerScreen이 없으면 실패함. Task 6 완료 후 재확인.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/home_screen.dart test/screens/home_screen_test.dart
git commit -m "feat: add HomeScreen with time selection and start button"
```

---

### Task 6: TimerScreen 구현 (TDD)

**Files:**
- Create: `lib/screens/timer_screen.dart`
- Create: `test/screens/timer_screen_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/screens/timer_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_timer_app/screens/timer_screen.dart';

void main() {
  testWidgets('초기 남은 시간 표시 (25분)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TimerScreen(minutes: 25)),
    );
    expect(find.text('25:00'), findsOneWidget);
  });

  testWidgets('초기 남은 시간 표시 (5분)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TimerScreen(minutes: 5)),
    );
    expect(find.text('05:00'), findsOneWidget);
  });

  testWidgets('그만할래 버튼 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TimerScreen(minutes: 25)),
    );
    expect(find.text('그만할래'), findsOneWidget);
  });

  testWidgets('시작 메시지 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TimerScreen(minutes: 25)),
    );
    expect(find.text('화이팅! 25분 후에 만나자 💪'), findsOneWidget);
  });

  testWidgets('그만할래 탭 시 확인 다이얼로그 표시', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TimerScreen(minutes: 25)),
    );
    await tester.tap(find.text('그만할래'));
    await tester.pump();
    expect(find.text('계속할래'), findsOneWidget);
    expect(find.text('끝낼래'), findsOneWidget);
  });

  testWidgets('다이얼로그에서 계속할래 탭 시 타이머 화면 유지', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TimerScreen(minutes: 25)),
    );
    await tester.tap(find.text('그만할래'));
    await tester.pump();
    await tester.tap(find.text('계속할래'));
    await tester.pump();
    // 다이얼로그 닫히고 타이머 화면 유지
    expect(find.text('그만할래'), findsOneWidget);
    expect(find.text('계속할래'), findsNothing);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/screens/timer_screen_test.dart
```

Expected: FAIL with `Target of URI doesn't exist`

- [ ] **Step 3: `lib/screens/timer_screen.dart` 구현**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants.dart';
import '../widgets/hamcon_character.dart';
import '../widgets/circular_timer.dart';

enum _TimerState { running, success }

class TimerScreen extends StatefulWidget {
  final int minutes;
  const TimerScreen({super.key, required this.minutes});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late int _totalSeconds;
  late int _remainingSeconds;
  _TimerState _state = _TimerState.running;
  Timer? _timer;
  bool _showStartMessage = true;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.minutes * 60;
    _remainingSeconds = _totalSeconds;
    _loadAd();
    _startTimer();
    // 3초 후 시작 메시지 페이드아웃
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showStartMessage = false);
    });
  }

  void _loadAd() {
    try {
      InterstitialAd.load(
        adUnitId: kInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                if (mounted) Navigator.pop(context);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                if (mounted) Navigator.pop(context);
              },
            );
          },
          onAdFailedToLoad: (_) {
            _interstitialAd = null;
          },
        ),
      );
    } catch (_) {
      // 테스트 환경 등 AdMob 미초기화 시 광고 없이 진행
      _interstitialAd = null;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _onSuccess();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _onSuccess() {
    HapticFeedback.vibrate();
    setState(() {
      _remainingSeconds = 0;
      _state = _TimerState.success;
    });
    // 2초 후 광고 표시 (없으면 바로 pop)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_interstitialAd != null) {
        _interstitialAd!.show();
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _showExitDialog() {
    _timer?.cancel();
    // 경과 시간(분) 계산
    final elapsedMinutes = ((_totalSeconds - _remainingSeconds) / 60).floor();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: kBackgroundColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HamconCharacter(state: HamconState.fail, size: 80),
            const SizedBox(height: 16),
            Text(
              failConfirmMessage(elapsedMinutes),
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextColor, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              _startTimer();          // 타이머 재개
            },
            child: const Text(
              '계속할래',
              style: TextStyle(color: kTextColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 타이머 화면 닫기 (광고 없음)
            },
            child: Text(
              '끝낼래',
              style: TextStyle(color: kPointColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          child: Center(
            child: _state == _TimerState.success
                ? _buildSuccessView()
                : _buildTimerView(),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerView() {
    final progress = _remainingSeconds / _totalSeconds;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 시작 메시지 (3초 표시 후 페이드아웃)
        AnimatedOpacity(
          opacity: _showStartMessage ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Text(
            startMessage(widget.minutes),
            style: const TextStyle(fontSize: 16, color: kTextColor),
          ),
        ),
        const SizedBox(height: 32),
        CircularTimer(
          progress: progress,
          timeText: formatTime(_remainingSeconds),
        ),
        const SizedBox(height: 32),
        const HamconCharacter(state: HamconState.focusing),
        const SizedBox(height: 40),
        TextButton(
          onPressed: _showExitDialog,
          child: const Text(
            '그만할래',
            style: TextStyle(color: kTextColor, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const HamconCharacter(state: HamconState.success, size: 150),
        const SizedBox(height: 28),
        Text(
          successMessage(widget.minutes),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/screens/timer_screen_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: HomeScreen 테스트 전체 재확인**

```bash
flutter test test/screens/home_screen_test.dart
```

Expected: `All tests passed!` (TimerScreen 의존 테스트 포함)

- [ ] **Step 6: Commit**

```bash
git add lib/screens/timer_screen.dart test/screens/timer_screen_test.dart
git commit -m "feat: add TimerScreen with countdown, exit dialog, success state, AdMob"
```

---

### Task 7: main.dart 완성 및 전체 통합

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: `lib/main.dart` 작성**

```dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const FocusTimerApp());
}

class FocusTimerApp extends StatelessWidget {
  const FocusTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '집중해 햄콩!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB7C5),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

- [ ] **Step 2: 전체 테스트 통과 확인**

```bash
flutter test
```

Expected: `All tests passed!`

- [ ] **Step 3: debug APK 빌드 확인**

```bash
flutter build apk --debug
```

Expected: `Built build/app/outputs/flutter-apk/app-debug.apk.`

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart
git commit -m "feat: wire up main.dart with AdMob init and HomeScreen"
```

---

### Task 8: QA 체크리스트 (에뮬레이터 또는 실기기)

- [ ] **Step 1: 에뮬레이터 실행**

```bash
flutter run
```

- [ ] **Step 2: 수동 테스트 시나리오 확인**

| 시나리오 | 기대 동작 |
|----------|-----------|
| 앱 실행 | 홈 화면, 햄콩 idle 이모지, 5/10/25분/직접입력 버튼 표시 |
| 5분 탭 | 5분 버튼 선택 상태 (핑크 배경, 흰 글씨) |
| 직접입력 탭 | BottomSheet 슬라이더 열림, 1~60분 조절 가능 |
| 시작하기 탭 | "화이팅! N분 후에 만나자 💪" 메시지 + 타이머 화면 전환 |
| 3초 후 | 시작 메시지 페이드아웃 |
| 그만할래 탭 | 타이머 일시정지 + 확인 다이얼로그 표시 |
| 다이얼로그 "계속할래" | 다이얼로그 닫힘, 타이머 재개 |
| 다이얼로그 "끝낼래" | 홈 화면으로 복귀 (광고 없음) |
| 타이머 완료 | 진동 + 성공 화면 (햄콩 success 이모지 + 메시지) |
| 2초 후 | 테스트 광고 표시 |
| 광고 닫기 | 홈 화면 복귀 |
| 뒤로가기 제스처 | 종료 다이얼로그 표시 (홈으로 바로 나가기 안됨) |

- [ ] **Step 3: 최종 Commit**

```bash
git add -A
git commit -m "chore: complete MVP QA"
```

---

## 에셋 교체 가이드 (실제 이미지 준비 후)

1. `assets/images/` 폴더에 PNG 4개 추가 (`hamcon_idle.png`, `hamcon_focusing.png`, `hamcon_success.png`, `hamcon_fail.png`)
2. `pubspec.yaml`의 assets 주석 해제:
   ```yaml
   assets:
     - assets/images/
   ```
3. `lib/widgets/hamcon_character.dart`의 `build()` 메서드를 다음으로 교체:
   ```dart
   @override
   Widget build(BuildContext context) {
     return Image.asset(
       _assetPath,  // 주석 처리된 getter 주석 해제
       width: size,
       height: size,
     );
   }
   ```
4. `flutter pub get && flutter build apk --debug`로 확인
