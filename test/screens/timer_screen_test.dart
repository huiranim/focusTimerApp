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

  testWidgets('다이얼로그에서 끝낼래 탭 시 화면 종료', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const TimerScreen(minutes: 25),
              ));
            },
            child: const Text('go'),
          ),
        ),
      ),
    );
    // TimerScreen으로 이동
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // 종료 다이얼로그 열기
    await tester.tap(find.text('그만할래'));
    await tester.pump();
    expect(find.text('끝낼래'), findsOneWidget);
    // 끝낼래 탭
    await tester.tap(find.text('끝낼래'));
    await tester.pumpAndSettle();
    // TimerScreen이 닫혀서 'go' 버튼으로 돌아와야 함
    expect(find.text('go'), findsOneWidget);
    expect(find.text('그만할래'), findsNothing);
  });
}
