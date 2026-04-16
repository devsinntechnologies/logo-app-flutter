import 'package:flutter/material.dart';

class TemplateRow extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final VoidCallback onSeeAll;

  const TemplateRow({
    super.key,
    required this.title,
    required this.items,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row header: gradient bar + title + "See all" ──────────────────
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 8, top: 10, bottom: 8),
          child: Row(
            children: [
              // Gradient vertical bar
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6516),
                      Color(0xFFD73ABA),
                      Color(0xFFA628EB),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: Color(0xFFD73ABA),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFFD73ABA),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),

        // ── Horizontal scrolling items ────────────────────────────────────
        SizedBox(
          height: 162, // 150 item + 12 vertical breathing room
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 6, bottom: 6),
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
          ),
        ),

        const SizedBox(height: 4),
      ],
    );
  }
}
