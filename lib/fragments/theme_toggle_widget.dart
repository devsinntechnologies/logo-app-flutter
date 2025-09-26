import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logo_app_flutter/provider/theme_provider.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final double iconSize;

  const ThemeToggleWidget({
    super.key,
    this.showLabel = false,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: IconButton(
            key: ValueKey(themeProvider.isDarkMode),
            icon: Icon(
              themeProvider.isDarkMode 
                  ? Icons.light_mode_rounded 
                  : Icons.dark_mode_rounded,
              size: iconSize,
              color: themeProvider.isDarkMode 
                  ? Colors.yellow 
                  : Colors.grey[700],
            ),
            onPressed: () {
              themeProvider.toggleTheme();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    themeProvider.isDarkMode 
                        ? '🌙 Dark mode enabled' 
                        : '☀️ Light mode enabled',
                  ),
                  duration: const Duration(milliseconds: 1000),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: themeProvider.isDarkMode 
                ? 'Switch to Light Mode' 
                : 'Switch to Dark Mode',
          ),
        );
      },
    );
  }
}

class ThemeToggleSwitch extends StatelessWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.light_mode_rounded,
              size: 16,
              color: !themeProvider.isDarkMode 
                  ? Colors.orange 
                  : Colors.grey,
            ),
            const SizedBox(width: 8),
            Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.setTheme(value);
              },
              activeColor: Colors.blue,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.dark_mode_rounded,
              size: 16,
              color: themeProvider.isDarkMode 
                  ? Colors.blue 
                  : Colors.grey,
            ),
          ],
        );
      },
    );
  }
}