import 'package:flutter/material.dart';

class DividerContainer extends StatelessWidget {
  const DividerContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF6B21),
            Color(0xFFE91E63),
            Color(0xFF9C27B0),
          ],
        ),
      ),
    );
  }
}
