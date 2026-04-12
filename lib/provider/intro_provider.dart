import 'dart:async';
import 'package:flutter/material.dart';

class IntroProvider extends ChangeNotifier {
  bool _showStageTwo = false;
  bool _isSequenceStarted = false;

  bool get showStageTwo => _showStageTwo;
  bool get isSequenceStarted => _isSequenceStarted;

  void startSequence({
    required VoidCallback onStageTwo,
    required VoidCallback onComplete,
  }) {
    if (_isSequenceStarted) return;
    _isSequenceStarted = true;

    // Phase 1 -> Phase 2 delay
    Timer(const Duration(milliseconds: 600), () {
      _showStageTwo = true;
      notifyListeners();
      onStageTwo();
    });

    // Final completion delay (total intro time)
    Timer(const Duration(milliseconds: 4000), () {
      onComplete();
    });
  }

  void reset() {
    _showStageTwo = false;
    _isSequenceStarted = false;
    notifyListeners();
  }
}
