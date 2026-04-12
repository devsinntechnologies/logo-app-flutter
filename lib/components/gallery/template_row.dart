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
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFC32BAC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.w600,
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

        // Custom scroll indicator (as seen in image)
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.arrow_left, size: 24, color: Colors.grey),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF757575),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const Icon(Icons.arrow_right, size: 24, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
