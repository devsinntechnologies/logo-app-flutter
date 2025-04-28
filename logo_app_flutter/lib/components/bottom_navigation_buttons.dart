import 'package:flutter/material.dart';

class BottomNavigationButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const BottomNavigationButtons({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (currentStep < totalSteps - 1)
            OutlinedButton(
              onPressed: onNext,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.transparent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                foregroundColor: Colors.black,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('NEXT', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            )
          else
            OutlinedButton(
              onPressed: onFinish,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'FINISH',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
