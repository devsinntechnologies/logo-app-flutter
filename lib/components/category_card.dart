import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final String heroTag;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 360;

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
                ..translate(0.0, hovered ? -6.0 : 0.0)
                ..scale(hovered ? (isSmall ? 1.02 : 1.04) : 1.0), // 👈 safe scale

              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(19),
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
                    blurRadius: hovered ? 18 : 12,
                    offset: Offset(0, hovered ? 10 : 6),
                  ),
                ],
              ),

              child: Stack(
                children: [
                  Positioned(
                    right: -25,
                    top: -25,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: hovered ? 0.3 : 0.15,
                      child: Container(
                        width: isSmall ? 55 : 70,
                        height: isSmall ? 55 : 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 6 : 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: heroTag,
                            child: icon,
                          ),

                          SizedBox(height: isSmall ? 8 : 12),

                          Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: isSmall ? 13 : 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
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