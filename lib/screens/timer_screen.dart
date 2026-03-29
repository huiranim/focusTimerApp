import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants.dart';
import '../widgets/hamcon_character.dart';
import '../widgets/circular_timer.dart';

enum _TimerState { running, success, fail }

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
  Timer? _startMessageTimer;
  Timer? _successTimer;
  bool _showStartMessage = true;
  bool _isDialogOpen = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.minutes * 60;
    _remainingSeconds = _totalSeconds;
    _loadAd();
    _startTimer();
    // 3초 후 시작 메시지 페이드아웃
    _startMessageTimer = Timer(const Duration(seconds: 3), () {
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
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        timer.cancel();
        if (_isDialogOpen) {
          _isDialogOpen = false;
          Navigator.of(context).pop(); // 다이얼로그 자동 닫기 → 성공 처리
        }
        _onSuccess();
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
    _successTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_interstitialAd != null) {
        _interstitialAd!.show();
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _showExitDialog() {
    // 타이머는 계속 진행 (_timer 취소 안 함)
    _startMessageTimer?.cancel();
    _successTimer?.cancel();

    final elapsed = _totalSeconds - _remainingSeconds;
    final elapsedMinutes = elapsed ~/ 60;
    final elapsedSeconds = elapsed % 60;

    _isDialogOpen = true;
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
              failConfirmMessage(elapsedMinutes, elapsedSeconds),
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextColor, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그만 닫기 (타이머 이미 진행 중)
            },
            child: const Text(
              '계속할래',
              style: TextStyle(color: kTextColor),
            ),
          ),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              setState(() => _state = _TimerState.fail);
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
    ).whenComplete(() {
      _isDialogOpen = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _startMessageTimer?.cancel();
    _successTimer?.cancel();
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
