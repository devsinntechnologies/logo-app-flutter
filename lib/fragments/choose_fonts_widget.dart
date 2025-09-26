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
    'FANCY',          
    'MINIMAL',        
    'TECH',           
    'CLASSIC',        
    'DISPLAY',        
    'RETRO',          
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "CHOOSE FONTS",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color, 
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.55,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: fontNames.length,
            itemBuilder: (context, index) => _buildFontButton(context, index),
          ),
        ),
      ],
    );
  }

  TextStyle _getFontStyle(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87; 
    
    switch (index) {
      case 0:
        return GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor, 
        );
      case 1:
        return GoogleFonts.pacifico(
          fontSize: 18,
          color: textColor, 
        );
      case 2:
        return GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor, 
        );
      case 3:
        return GoogleFonts.dancingScript(
          fontSize: 18,
          color: textColor, 
        );
      case 4:
        return GoogleFonts.satisfy(
          fontSize: 18,
          color: textColor, 
        );
      case 5:
        return GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor, 
        );
      case 6:
        return GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor, 
        );
      case 7:
        return GoogleFonts.openSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor, 
        );
      case 8:
        return GoogleFonts.bebasNeue(
          fontSize: 20,
          color: textColor, 
        );
      case 9:
        return GoogleFonts.pressStart2p(
          fontSize: 12,
          color: textColor, 
        );
      default:
        return TextStyle(
          fontSize: 18,
          color: textColor, 
        );
    }
  }

  Widget _buildFontButton(BuildContext context, int index) {
    bool isSelected = selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.black,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            widget.onFontSelected(index);
          },
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: Center(
              child: Text(
                fontNames[index],
                style: _getFontStyle(index).copyWith(
                  color: isSelected 
                      ? Colors.white 
                      : (isDark ? Colors.white : Colors.black87), 
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}