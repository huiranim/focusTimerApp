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

  testWidgets('progress > 1.0 은 클램핑되어 에러 없음', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CircularTimer(progress: 1.5, timeText: '00:00'),
        ),
      ),
    );
    expect(find.text('00:00'), findsOneWidget);
  });
}
