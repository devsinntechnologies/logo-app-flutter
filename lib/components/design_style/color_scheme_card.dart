import 'package:flutter/material.dart';

class ColorSchemeCard extends StatelessWidget {
  final String name;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorSchemeCard({
    super.key,
    required this.name,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 360;

    final ValueNotifier<bool> isHovered = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isHovered,
      builder: (context, hovered, child) {
        final active = hovered || isSelected;

        return MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              transform: Matrix4.identity()
                ..translate(0.0, active ? (isSmall ? -4.0 : -6.0) : 0.0)
                ..scale(active ? (isSmall ? 1.02 : 1.04) : 1.0),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFC27AFF)
                      : Colors.grey.withOpacity(0.15),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF7C4DFF).withOpacity(0.2)
                        : Colors.black.withOpacity(hovered ? 0.08 : 0.03),
                    blurRadius: active ? 12 : 8,
                    offset: Offset(0, active ? 6 : 4),
                  ),
                ],
              ),

              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// 🌈 COLORS ROW (RESPONSIVE)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 6,
                          children: colors.map((color) {
                            return Container(
                              width: isSmall ? 22 : 28,
                              height: isSmall ? 22 : 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.25),
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: isSmall ? 8 : 12),

                        /// NAME
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmall ? 12 : 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4A4A6A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// SELECTED CHECK
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFE12AFB),
                              Color(0xFF9810FA),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
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