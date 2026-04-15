import 'package:flutter/material.dart';

class FeatureListItem extends StatelessWidget {
  final Widget icon;
  final String text;
  final Gradient iconBgColor;

  const FeatureListItem({
    super.key,
    required this.icon,
    required this.text,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconTheme(
              data: const IconThemeData(color: Colors.white, size: 30),
              child: icon,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
