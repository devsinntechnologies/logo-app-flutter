import 'package:flutter/material.dart';

class StepTrail extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;
  final ScrollController scrollController;

  const StepTrail({
    super.key,
    required this.currentStep,
    required this.stepTitles,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            stepTitles.length,
            (index) => _buildStep(index),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int index) {
    bool isCompleted = index < currentStep;
    bool isActive = index == currentStep;

    return Row(
      children: [
        Row(
          children: [
            // Step circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isCompleted || isActive ? Colors.orange : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Step title
            Text(
              stepTitles[index],
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        if (index != stepTitles.length - 1)
          Container(
            width: 80,
            height: 2,
            color: index < currentStep ? Colors.orange : Colors.grey[300],
          ),
      ],
    );
  }
}
