// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ChooseFontsWidget extends StatefulWidget {
//   final Function(int) onFontSelected;

//   const ChooseFontsWidget({super.key, required this.onFontSelected});

//   @override
//   State<ChooseFontsWidget> createState() => _ChooseFontsWidgetState();
// }

// class _ChooseFontsWidgetState extends State<ChooseFontsWidget> {
//   int selectedIndex = 0;

//   final List<String> fontNames = [
//     'MODERN',
//     'HANDWRITTEN',
//     'CONTEMPORARY',
//     'CALLIGRAPHY',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const Text(
//           "CHOOSE FONTS",
//           style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 20),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: List.generate(
//             fontNames.length,
//             (index) => _buildFontButton(context, index),
//           ),
//         ),
//       ],
//     );
//   }

//   TextStyle _getFontStyle(int index) {
//     switch (index) {
//       case 0:
//         return GoogleFonts.roboto(
//           color: Colors.black87,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 1.5,
//           fontSize: 18,
//         );
//       case 1:
//         return GoogleFonts.pacifico(
//           color: Colors.black87,
//           letterSpacing: 1.5,
//           fontSize: 18,
//         );
//       case 2:
//         return GoogleFonts.poppins(
//           color: Colors.black87,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 1.5,
//           fontSize: 18,
//         );
//       case 3:
//         return GoogleFonts.dancingScript(
//           color: Colors.black87,
//           letterSpacing: 1.5,
//           fontSize: 18,
//         );
//       default:
//         return const TextStyle();
//     }
//   }

//   Widget _buildFontButton(BuildContext context, int index) {
//     bool isSelected = selectedIndex == index;
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: isSelected ? Colors.orange : Colors.transparent,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: Colors.black),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             setState(() {
//               selectedIndex = index;
//             });
//             widget.onFontSelected(index); // Pass the selected font index back
//           },
//           borderRadius: BorderRadius.circular(6),
//           child: SizedBox(
//             height: 50,
//             width: double.infinity,
//             child: Center(
//               child: Text(fontNames[index], style: _getFontStyle(index)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';

class ChooseFontsWidget extends StatefulWidget {
  final Function(int) onFontSelected;
  final int initialSelectedIndex;

  const ChooseFontsWidget({
    super.key,
    required this.onFontSelected,
    this.initialSelectedIndex = 0,
  });

  @override
  State<ChooseFontsWidget> createState() => _ChooseFontsWidgetState();
}

class _ChooseFontsWidgetState extends State<ChooseFontsWidget> {
  late int selectedIndex;


  List<String> get fontNames => [
        S.of(context).modern,
        S.of(context).handwritten,
        S.of(context).contemporary,
        S.of(context).calligraphy,
        S.of(context).fancy,
        S.of(context).minimal,
        S.of(context).tech,
        S.of(context).classic,
        S.of(context).display,
        S.of(context).retro,
      ];
  @override
  void initState() {
    super.initState();
    // Ensure selectedIndex is within bounds
    selectedIndex = widget.initialSelectedIndex.clamp(0, 9);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        const SizedBox(height: 20),
         Text(
           S.of(context).chooseFonts,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 20),
    
        SizedBox(
          height: screenHeight * 0.6, 
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
    switch (index) {
      case 0:
        return GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold);
      case 1:
        return GoogleFonts.pacifico(fontSize: 18);
      case 2:
        return GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold);
      case 3:
        return GoogleFonts.dancingScript(fontSize: 18);
      case 4:
        return GoogleFonts.satisfy(fontSize: 18);
      case 5:
        return GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w500);
      case 6:
        return GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold);
      case 7:
        return GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w600);
      case 8:
        return GoogleFonts.bebasNeue(fontSize: 20);
      case 9:
        return GoogleFonts.pressStart2p(fontSize: 12);
      default:
        return const TextStyle(fontSize: 18);
    }
  }

  Widget _buildFontButton(BuildContext context, int index) {
    bool isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        // color: isSelected ? Colors.orange : Colors.transparent,
        gradient: isSelected
            ? ThemeColors.textGradient: null,
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
            widget.onFontSelected(index);
          },
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: Center(
              child: Text(
                index < fontNames.length ? fontNames[index] : "",
                style: _getFontStyle(index).copyWith(
                  color: isSelected ? Colors.white : Colors.black87,
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
