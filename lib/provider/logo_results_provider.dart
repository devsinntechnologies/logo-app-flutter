import 'package:flutter/material.dart';

class LogoResult {
  final String name;
  final IconData icon;
  final List<Color> colors;
  bool isFavorite;

  LogoResult({
    required this.name,
    required this.icon,
    required this.colors,
    this.isFavorite = false,
  });
}

class LogoResultsProvider extends ChangeNotifier {
  final List<LogoResult> _generatedLogos = [
    LogoResult(
      name: 'Minimal Logo',
      icon: Icons.shopping_bag_rounded,
      colors: [const Color(0xFF7C4DFF), const Color(0xFF651FFF)],
    ),
    LogoResult(
      name: 'Modern Logo',
      icon: Icons.store_rounded,
      colors: [const Color(0xFFFF4081), const Color(0xFFF50057)],
    ),
    LogoResult(
      name: 'Classic Logo',
      icon: Icons.card_giftcard_rounded,
      colors: [const Color(0xFF00B0FF), const Color(0xFF0091EA)],
    ),
    LogoResult(
      name: 'Bold Logo',
      icon: Icons.shopping_cart_rounded,
      colors: [const Color(0xFFFF6D00), const Color(0xFFFF3D00)],
    ),
    LogoResult(
      name: 'Elegant Logo',
      icon: Icons.diamond_rounded,
      colors: [const Color(0xFF00BFA5), const Color(0xFF1DE9B6)],
    ),
    LogoResult(
      name: 'Dynamic Logo',
      icon: Icons.auto_awesome,
      colors: [const Color(0xFFFFAB00), const Color(0xFFFFD600)],
    ),
  ];

  List<LogoResult> get generatedLogos => _generatedLogos;

  void toggleFavorite(int index) {
    if (index >= 0 && index < _generatedLogos.length) {
      _generatedLogos[index].isFavorite = !_generatedLogos[index].isFavorite;
      notifyListeners();
    }
  }

  void regenerateVariations() {
    // In a real app, this would trigger new variations
    notifyListeners();
  }
}
