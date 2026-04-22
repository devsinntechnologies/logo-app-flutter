import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool isMain;
  final List<Widget>? backgroundDecorations;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.isMain = false,
    this.backgroundDecorations,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isHovered = ValueNotifier<bool>(false);

    return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;

      // 🔥 Breakpoints
      final isSmall = width < 350;
      final isTablet = width > 600;

      // 🎯 Dynamic values
      final padding = isSmall ? 14.0 : 20.0;
      final iconSize = isSmall ? 26.0 : 34.0;
      final titleSize = isSmall ? 13.0 : 16.0;
      final subtitleSize = isSmall ? 11.0 : 13.0;

      return ValueListenableBuilder<bool>(
        valueListenable: isHovered,
        builder: (context, hovered, child) {
          return MouseRegion(
            onEnter: (_) => isHovered.value = true,
            onExit: (_) => isHovered.value = false,
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()
                  ..translate(0.0, hovered ? -8.0 : 0.0)
                  ..scale(hovered ? 1.03 : 1.0),
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: (gradient as LinearGradient)
                            .colors
                            .first
                            .withOpacity(hovered ? 0.4 : 0.25),
                        blurRadius: hovered ? 22 : 16,
                        offset: Offset(0, hovered ? 10 : 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      if (backgroundDecorations != null)
                        ...backgroundDecorations!,

                      Padding(
                        padding: EdgeInsets.all(padding),
                        child:isMain
  ? _buildMainLayoutResponsive(
      iconSize, titleSize, subtitleSize, isSmall)
  : _buildSecondaryLayoutResponsive(
      iconSize, titleSize, subtitleSize),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
  }

Widget _buildMainLayoutResponsive(
    double iconSize, double titleSize, double subtitleSize, bool isSmall) {
  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(isSmall ? 16 : 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: IconTheme(
          data: IconThemeData(color: Colors.white, size: iconSize),
          child: icon,
        ),
      ),
      SizedBox(width: isSmall ? 10 : 18),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: subtitleSize,
              ),
            ),
          ],
        ),
      ),
      Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white,
        size: isSmall ? 16 : 22,
      ),
    ],
  );
}
Widget _buildSecondaryLayoutResponsive(
    double iconSize, double titleSize, double subtitleSize) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmall = constraints.maxHeight < 120;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 KEY FIX
        children: [
          IconTheme(
            data: IconThemeData(
              color: Colors.white,
              size: isSmall ? iconSize * 0.85 : iconSize,
            ),
            child: icon,
          ),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: isSmall ? 2 : 4),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: subtitleSize,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: iconSize * 0.45,
          ),
        ],
      );
    },
  );
}}

