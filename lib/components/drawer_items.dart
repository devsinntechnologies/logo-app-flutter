import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/smart_interstitial_manager.dart';
import 'package:provider/provider.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const DrawerItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(text),
      onTap: () {
        Navigator.pop(context); // Closes the drawer
      },
    );
  }
}

// When settings is opened for the first time:
void onSettingsPressed(BuildContext context) {
  final adManager = Provider.of<SmartInterstitialManager>(
    context,
    listen: false,
  );
  adManager.onSettingsOpened();
  adManager.onButtonClick('settings');
}
