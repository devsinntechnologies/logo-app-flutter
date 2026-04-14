import 'package:flutter/material.dart';

class TemplateRowItem extends StatelessWidget {
  final Widget icon;
  final bool isAd;
  final VoidCallback onTap;

  const TemplateRowItem({
    super.key,
    required this.icon,
    this.isAd = false,
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
                ..translate(0.0, hovered ? -10.0 : 0.0)
                ..scale(hovered ? 1.05 : 1.0),
              child: Container(
                width: 140, // Adjusted as mockup cards are roughly square but slightly smaller
                height: 140, 
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF2FF), // Pale pinkish/purple background
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    // Top-right glossy highlight
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),

                    // Main Icon
                    Center(
                      child: Hero(
                        tag: 'template_${hashCode == 0 ? icon.hashCode : hashCode}',
                        child: IconTheme(
                          data: const IconThemeData(size: 60), // inherit color
                          child: icon,
                        ),
                      ),
                    ),

                    // Ad Badge
                    if (false) // Ignoring ads for this redesign
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A3FF),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                            ],
                          ),
                          child: const Text(
                            'Ad',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
