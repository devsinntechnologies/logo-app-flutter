import 'package:flutter/material.dart';
import 'package:logo_app_flutter/generated/l10n.dart';

class BottomNavigationButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  final String companyName;
  final String slogan;

  const BottomNavigationButtons({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    required this.onFinish,
    required this.companyName,
    required this.slogan,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = companyName.isEmpty || slogan.isEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (currentStep > 0)
              OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.transparent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    SizedBox(width: 8),
                    Text(S.of(context).back,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              const SizedBox(),
            if (currentStep < totalSteps - 1)
              OutlinedButton(
                onPressed: isDisabled && currentStep == 0 ? null : onNext,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.transparent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                child: Row(
                  children: [
                    Text(
                      S.of(context).next,
                      style: TextStyle(
                        color: isDisabled && currentStep == 0
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
