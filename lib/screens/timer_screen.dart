// lib/screens/timer_screen.dart - STUB (will be replaced in Task 6)
import 'package:flutter/material.dart';

class TimerScreen extends StatelessWidget {
  final int minutes;
  const TimerScreen({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: TextButton(
        onPressed: () {},
        child: const Text('그만할래'),
      )),
    );
  }
}
