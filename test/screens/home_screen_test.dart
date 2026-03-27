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
    // 초기 상태: 25분이 선택되어 있음 (kPointColor 배경)
    // 5분 탭 후: 5분이 선택, 25분은 비선택 상태로 변경
    await tester.tap(find.text('5분'));
    await tester.pump();
    // 5분 버튼 컨테이너가 선택색(kPointColor)을 갖는지 확인
    final selectedButton = tester.widget<Container>(
      find.ancestor(
        of: find.text('5분'),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = selectedButton.decoration as BoxDecoration;
    expect(decoration.color, const Color(0xFFFFB7C5)); // kPointColor
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
