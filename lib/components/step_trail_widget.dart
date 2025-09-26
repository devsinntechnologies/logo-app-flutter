import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3) 
                : Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                ? Colors.orange 
                : (isDark ? Colors.grey[700] : Colors.grey[300]),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark 
                  ? Colors.grey[600]! 
                  : Colors.grey[400]!,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check, 
                    color: Colors.white,
                    size: 20,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: (isCompleted || isActive) 
                          ? Colors.white 
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          stepTitles[index],
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
            color: isActive 
                ? (isDark ? Colors.orange : Colors.orange) 
                : (isDark ? Colors.grey[300] : Colors.grey[600]),
          ),
        ),
        const SizedBox(width: 8),
        if (index != stepTitles.length - 1)
          Container(
            width: 50,
            height: 2,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Colors.orange 
                  : (isDark ? Colors.grey[700] : Colors.grey[300]),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}