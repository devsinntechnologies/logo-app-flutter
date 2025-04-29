import 'package:flutter/material.dart';

class BottomNavigationButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const BottomNavigationButtons({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Show Back button if not on the first step
          if (currentStep > 0)
            OutlinedButton(
              onPressed: onBack,
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
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  SizedBox(width: 8),
                  Text('BACK', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          else
            const SizedBox(), // empty placeholder to maintain spacing
          // Next or Finish button
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
              child: const Row(
                children: [
                  Text('NEXT', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
