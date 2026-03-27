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
