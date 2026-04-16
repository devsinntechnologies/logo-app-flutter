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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        margin: const EdgeInsets.only(right: 14),
        // ── Outer container bg: #FDF2F8 (light pink)
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade100, blurRadius: 0.2, spreadRadius: 0.2)
          ],
          color: const Color(0xffFCE7F3),
          borderRadius: BorderRadius.circular(22),
        ),
        // Clips children (circles) inside the rounded corners
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // ── Top-right highlight circle: #FCCEE8 at ~30% opacity
            Positioned(
              right: -45,
              top: -25,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 247, 219, 235), // #FCCEE84D
                ),
              ),
            ),
            // Positioned(
            //   left: -45,
            //   bottom: -40,
            //   child: Container(
            //     width: 80,
            //     height: 80,
            //     decoration: const BoxDecoration(
            //       shape: BoxShape.circle,
            //       color: Color.fromARGB(255, 245, 211, 231), // #FCCEE84D
            //     ),
            //   ),
            // ),

            // ── Bottom-left soft accent bubble
            Positioned(
              left: -45,
              bottom: -40,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 247, 219, 235), // #FCCEE84D
                ),
              ),
            ),
            // ── Template image centered
            Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: icon,
              ),
            ),

            // ── Ad badge (bottom-left)
            if (isAd)
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A3FF),
                    borderRadius: BorderRadius.circular(8),
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
    );
  }
}
