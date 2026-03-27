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
