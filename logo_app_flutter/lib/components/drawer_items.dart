import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const DrawerItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color:Color.fromARGB(255, 47, 50, 85),),
      title: Text(text),
      onTap: () {
        Navigator.pop(context); // Closes the drawer
      },
    );
  }
}
