import 'package:flutter/material.dart';
import '../../utils/theme_colors.dart';

class BusinessContinueButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const BusinessContinueButton({
    super.key,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            gradient: isEnabled ? ThemeColors.continueGradient : null,
            color: isEnabled ? null : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFFE91E63).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              // Glossy Bubble Top-Right
              Positioned(
                right: -20,
                top: -10,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Glossy Bubble Bottom-Left
              Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
