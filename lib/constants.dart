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
String failConfirmMessage(int minutes, int seconds) =>
    '지금 ${minutes}분 ${seconds}초 버텼어, 여기서 끝낼거야?';
