import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseFontsWidget extends StatefulWidget {
  final Function(int) onFontSelected;

  const ChooseFontsWidget({super.key, required this.onFontSelected});

  @override
  State<ChooseFontsWidget> createState() => _ChooseFontsWidgetState();
}

class _ChooseFontsWidgetState extends State<ChooseFontsWidget> {
  int selectedIndex = 0;

  final List<String> fontNames = [
    'MODERN',
    'HANDWRITTEN',
    'CONTEMPORARY',
    'CALLIGRAPHY',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "CHOOSE FONTS",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            fontNames.length,
            (index) => _buildFontButton(context, index),
          ),
        ),
      ],
    );
  }

  TextStyle _getFontStyle(int index) {
    switch (index) {
      case 0:
        return GoogleFonts.roboto(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 18,
        );
      case 1:
        return GoogleFonts.pacifico(
          color: Colors.black87,
          letterSpacing: 1.5,
          fontSize: 18,
        );
      case 2:
        return GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 18,
        );
      case 3:
        return GoogleFonts.dancingScript(
          color: Colors.black87,
          letterSpacing: 1.5,
          fontSize: 18,
        );
      default:
        return const TextStyle();
    }
  }

  Widget _buildFontButton(BuildContext context, int index) {
    bool isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            widget.onFontSelected(index); // Pass the selected font index back
          },
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: Center(
              child: Text(fontNames[index], style: _getFontStyle(index)),
            ),
          ),
        ),
      ),
    );
  }
}
