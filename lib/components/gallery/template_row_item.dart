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
                width: 150,
                height: 150,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7FF),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(hovered ? 0.08 : 0.04),
                      blurRadius: hovered ? 20 : 15,
                      offset: Offset(0, hovered ? 12 : 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Top-right glossy highlight
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),

                    // Bottom-left decoration
                    Positioned(
                      left: -5,
                      bottom: -5,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEDE7F6).withOpacity(0.4),
                        ),
                      ),
                    ),

                    // Main Icon
                    Center(
                      child: Hero(
                        tag: 'template_${hashCode == 0 ? icon.hashCode : hashCode}',
                        child: IconTheme(
                          data: const IconThemeData(size: 85, color: Colors.black),
                          child: icon,
                        ),
                      ),
                    ),

                    // Ad Badge
                    if (isAd)
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
