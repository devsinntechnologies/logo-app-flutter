import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isHovered = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isHovered,
      builder: (context, hovered, child) {
        return MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: GestureDetector(
            onTapDown: (_) => isHovered.value = true,
            onTapUp: (_) => isHovered.value = false,
            onTapCancel: () => isHovered.value = false,
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..translate(0.0, hovered ? -8.0 : 0.0)
                ..scale(hovered ? 1.05 : 1.0),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(hovered ? 0.4 : 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (gradient as LinearGradient)
                        .colors
                        .first
                        .withOpacity(hovered ? 0.5 : 0.3),
                    blurRadius: hovered ? 20 : 12,
                    offset: Offset(0, hovered ? 12 : 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Glossy Bubble Top-Right
                  Positioned(
                    right: -10,
                    top: -10,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: hovered ? 0.3 : 0.15,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Glossy Bubble Bottom-Left
                  Positioned(
                    left: -5,
                    bottom: -15,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: hovered ? 0.2 : 0.1,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'cat_icon_$title',
                          child: Icon(
                            icon,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
