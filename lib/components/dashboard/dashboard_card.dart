import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool isMain;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.isMain = false,
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
                ..scale(hovered ? 1.04 : 1.0),
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: (gradient as LinearGradient)
                          .colors
                          .first
                          .withOpacity(hovered ? 0.4 : 0.25),
                      blurRadius: hovered ? 25 : 18,
                      offset: Offset(0, hovered ? 12 : 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Glossy Arc Highlight (Top Left)
                    Positioned(
                      left: -20,
                      top: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                    ),

                    // Decorative Bubble (Bottom Right)
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),

                    // Content Layer
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 26),
                      child:
                          isMain ? _buildMainLayout() : _buildSecondaryLayout(),
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

  Widget _buildMainLayout() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconTheme(
            data: const IconThemeData(color: Colors.white, size: 36),
            child: icon,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [ 
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white, size: 24),
      ],
    );
  }

  Widget _buildSecondaryLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTheme(
          data: const IconThemeData(color: Colors.white, size: 36),
          child: icon,
        ),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
      ],
    );
  }
}
