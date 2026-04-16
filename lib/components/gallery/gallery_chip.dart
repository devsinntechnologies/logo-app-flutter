import 'package:flutter/material.dart';

class GalleryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GalleryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 9),
          decoration: BoxDecoration(
            // ── Selected: gradient fill, pink glow shadow
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      Color(0xFFFF6928),
                      Color(0xFFD73ABA),
                      Color(0xFFA628EB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            // ── Unselected: white bg, subtle pink border, NO shadow
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: isSelected
                ? null
                : Border.all(
                    color: const Color(0xFFC32BAC).withValues(alpha: 0.28),
                    width: 1,
                  ),
            // Shadow only on selected chip (matches Figma)
            boxShadow: isSelected
                ? null
                // [
                //     BoxShadow(
                //       color: const Color(0xFFC32BAC).withValues(alpha: 0.35),
                //       blurRadius: 10,
                //       offset: const Offset(0, 4),
                //     ),
                //   ]
                : [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 1,
                      spreadRadius: 0.1,
                      // offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF555566),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
