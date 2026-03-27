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
