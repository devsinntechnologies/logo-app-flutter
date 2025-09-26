import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).textTheme.bodyLarge?.color, 
      ),
      title: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color, 
          fontSize: 16,
        ),
      ),
      onTap: onTap ?? () {
        print('$text tapped');
      },
    );
  }
}