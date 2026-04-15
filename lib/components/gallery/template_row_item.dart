import 'package:flutter/material.dart';

class TemplateRowItem extends StatefulWidget {
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
  State<TemplateRowItem> createState() => _TemplateRowItemState();
}

class _TemplateRowItemState extends State<TemplateRowItem> {
  bool isHovered = false;

  void setHovered(bool value) {
    setState(() {
      isHovered = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setHovered(true),
      onExit: (_) => setHovered(false),
      child: GestureDetector(
        onTapDown: (_) => setHovered(true),
        onTapUp: (_) => setHovered(false),
        onTapCancel: () => setHovered(false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..translate(0.0, isHovered ? -10.0 : 0.0)
            ..scale(isHovered ? 1.05 : 1.0),
          child: Container(
            width: 180, // Adjusted to match mockup
            height: 100,
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
                  child: IconTheme(
                    data: const IconThemeData(size: 60),
                    child: widget.icon,
                  ),
                ),

                // Ad Badge (Ignored for now)
                if (widget.isAd)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A3FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Ad',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
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
