import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoDesignProvider extends ChangeNotifier {
  int _selectedFontIndex = 0;
  int _selectedPaletteIndex = 0;

  int get selectedFontIndex => _selectedFontIndex;
  int get selectedPaletteIndex => _selectedPaletteIndex;

  final List<Map<String, dynamic>> fontStyles = [
    {'name': 'Modern Sans', 'style': GoogleFonts.roboto(fontWeight: FontWeight.bold)},
    {'name': 'Classic Serif', 'style': GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)},
    {'name': 'Bold Display', 'style': GoogleFonts.bebasNeue()},
    {'name': 'Elegant Script', 'style': GoogleFonts.dancingScript(fontWeight: FontWeight.bold)},
    {'name': 'Geometric', 'style': GoogleFonts.poppins(fontWeight: FontWeight.w600)},
    {'name': 'Rounded', 'style': GoogleFonts.lato(fontWeight: FontWeight.bold)},
    {'name': 'Tech Modern', 'style': GoogleFonts.orbitron(fontWeight: FontWeight.bold)},
    {'name': 'Handwritten', 'style': GoogleFonts.pacifico()},
  ];

  final List<Map<String, dynamic>> colorPalettes = [
    {
      'name': 'Vibrant',
      'colors': [Colors.purpleAccent, Colors.deepPurpleAccent, Colors.cyanAccent]
    },
    {
      'name': 'Sunset',
      'colors': [Colors.orange, Colors.pink, Colors.purple]
    },
    {
      'name': 'Professional',
      'colors': [Colors.blue, Colors.blueGrey, Colors.indigo]
    },
    {
      'name': 'Warm',
      'colors': [Colors.redAccent, Colors.orangeAccent, Colors.amber]
    },
    {
      'name': 'Cool',
      'colors': [Colors.cyan, Colors.blue, Colors.indigoAccent]
    },
    {
      'name': 'Nature',
      'colors': [Colors.lightGreenAccent, Colors.green, Colors.teal]
    },
    {
      'name': 'Tropical',
      'colors': [Colors.amber, Colors.tealAccent, Colors.cyan]
    },
    {
      'name': 'Berry',
      'colors': [Colors.redAccent, Colors.pinkAccent, Colors.purple]
    },
    {
      'name': 'Ocean',
      'colors': [Colors.lightBlueAccent, Colors.blueAccent, Colors.blue]
    },
    {
      'name': 'Monochrome',
      'colors': [Colors.blueGrey, Colors.grey, Colors.blueGrey.shade200]
    },
  ];

  void setFont(int index) {
    _selectedFontIndex = index;
    notifyListeners();
  }

  void setPalette(int index) {
    _selectedPaletteIndex = index;
    notifyListeners();
  }
}
