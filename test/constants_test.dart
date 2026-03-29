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
    test('failConfirmMessage에 경과 분+초 포함', () {
      expect(failConfirmMessage(3, 30), '지금 3분 30초 버텼어, 여기서 끝낼거야?');
    });
    test('0분 0초 경과 시 failConfirmMessage', () {
      expect(failConfirmMessage(0, 0), '지금 0분 0초 버텼어, 여기서 끝낼거야?');
    });
  });
}
