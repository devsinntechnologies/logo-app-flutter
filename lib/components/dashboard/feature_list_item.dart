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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                gradient: iconBgColor,
                // color: iconBgColor,
                borderRadius: BorderRadius.circular(10)
                // shape: BoxShape.circle,
                ),
            child: IconTheme(
              data: IconThemeData(color: Colors.white, size: 22),
              child: icon,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
