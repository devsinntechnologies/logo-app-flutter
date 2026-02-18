import 'package:flutter/material.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';

class StepTrailWidget extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;
  final ScrollController scrollController;

  const StepTrailWidget({
    super.key,
    required this.currentStep,
    required this.stepTitles,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            stepTitles.length,
            (index) => _buildStep(context, index),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, int index) {
    bool isCompleted = index < currentStep;
    bool isActive = index == currentStep;

    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? ThemeColors.purple
                : Theme.of(context).disabledColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: (isCompleted || isActive)
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          stepTitles[index],
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(width: 8),
        if (index != stepTitles.length - 1)
          Container(
            width: 50,
            height: 2,
            color: isCompleted
                ? ThemeColors.purple
                : Theme.of(context).disabledColor.withOpacity(0.1),
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}
