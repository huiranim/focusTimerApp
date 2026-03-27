import 'package:flutter/material.dart';

enum HamconState { idle, focusing, success, fail }

/// 햄콩 캐릭터 위젯.
/// 현재는 placeholder(이모지 + 컬러 원). 실제 에셋 준비 후:
/// 1. pubspec.yaml assets 섹션 주석 해제
/// 2. build()를 Image.asset(_assetPath)으로 교체
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
