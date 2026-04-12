import 'package:flutter/material.dart';
import '../../utils/theme_colors.dart';

class BusinessPreviewCard extends StatelessWidget {
  final bool showPreview;
  final String businessName;
  final String slogan;

  const BusinessPreviewCard({
    super.key,
    required this.showPreview,
    required this.businessName,
    required this.slogan,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: showPreview ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: showPreview ? Offset.zero : const Offset(0, 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              gradient: ThemeColors.mainCardGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  left: -15,
                  bottom: -15,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Preview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        businessName.isNotEmpty ? businessName : 'Your Logo Name',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
