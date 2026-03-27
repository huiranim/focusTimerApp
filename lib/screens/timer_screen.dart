// STUB: This file will be completely replaced in Task 6.
// It exists solely to allow HomeScreen to compile and the navigation test to pass.
import 'package:flutter/material.dart';

class TimerScreen extends StatelessWidget {
  final int minutes;
  const TimerScreen({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('그만할래'),
        ),
      ),
    );
  }
}
