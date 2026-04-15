import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/gallery/template_row_item.dart';

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
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Colored vertical indicator
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6516),
                      Color(0xFFD73ABA),
                      Color(0xFFA628EB)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onSeeAll,
                child: Row(
                  children: const [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: Color(0xFFFF4081),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFFFF4081),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal scrolling items
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
