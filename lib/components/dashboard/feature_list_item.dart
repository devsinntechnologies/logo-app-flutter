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
    final isSmall = MediaQuery.of(context).size.width < 460;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 8 : 10),
            decoration: BoxDecoration(
              gradient: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconTheme(
              data: IconThemeData(
                color: Colors.white,
                size: isSmall ? 24 : 30, // 👈 responsive icon size
              ),
              child: icon,
            ),
          ),

          SizedBox(width: isSmall ? 8 : 10),

          Expanded(
            child: Text(
              text,
              maxLines: 2, // 👈 prevents overflow
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isSmall ? 13 : 16, // 👈 responsive text
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