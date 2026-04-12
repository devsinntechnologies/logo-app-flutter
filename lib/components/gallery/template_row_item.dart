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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 150,
            height: 150,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7FF), // Pale lavender/pink tint from image
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
                  blurRadius: _isHovered ? 20 : 15,
                  offset: Offset(0, _isHovered ? 8 : 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Top-right glossy highlight (Large & Subtle)
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
                
                // Bottom-left decoration (Small & Very Subtle)
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

                // Main Icon (Prominent)
                Center(
                  child: Hero(
                    tag: 'template_${widget.hashCode}',
                    child: IconTheme(
                      data: const IconThemeData(size: 85, color: Colors.black),
                      child: widget.icon,
                    ),
                  ),
                ),

                // Ad Badge
                if (widget.isAd)
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
  }
}
