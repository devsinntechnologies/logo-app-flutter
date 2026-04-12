import 'dart:async';
import 'package:flutter/material.dart';

class LogoGenerationProvider extends ChangeNotifier {
  double _progress = 0.0;
  int _currentStepIndex = 0;
  Timer? _timer;

  double get progress => _progress;
  int get currentStepIndex => _currentStepIndex;

  final List<Map<String, dynamic>> steps = [
    {
      'title': 'Analyzing your preferences...',
      'icon': Icons.auto_fix_high_outlined,
      'colors': [const Color(0xFFFB6859), const Color(0xFFC834C6)],
    },
    {
      'title': 'Selecting color palettes...',
      'icon': Icons.palette_outlined,
      'colors': [const Color(0xFFFC2E75), const Color(0xFFEA35CE)],
    },
    {
      'title': 'Generating logo concepts...',
      'icon': Icons.auto_awesome_outlined,
      'colors': [const Color(0xFF01C774), const Color(0xFF01CDCD)],
    },
  ];

  void startSimulation({required VoidCallback onComplete}) {
    _progress = 0.0;
    _currentStepIndex = 0;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _progress += 0.02; // Roughly 5 seconds total

      if (_progress >= 1.0) {
        _progress = 1.0;
        _currentStepIndex = 2;
        timer.cancel();
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 500), onComplete);
      } else {
        if (_progress < 0.4) {
          _currentStepIndex = 0;
        } else if (_progress < 0.9) {
          _currentStepIndex = 1;
        } else {
          _currentStepIndex = 2;
        }
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
