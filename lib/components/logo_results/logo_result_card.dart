import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../provider/business_info_provider.dart';
import '../../provider/logo_design_provider.dart';

class LogoResultCard extends StatefulWidget {
  final String name;
  final String svg;
  final List<Color> colors;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const LogoResultCard({
    super.key,
    required this.name,
    required this.svg,
    required this.colors,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  State<LogoResultCard> createState() => _LogoResultCardState();
}

class _LogoResultCardState extends State<LogoResultCard> {
  final ValueNotifier<bool> isInteracting = ValueNotifier<bool>(false);

  TextStyle _getFontStyle(BuildContext context, int index, Color color,
      {double fontSize = 14}) {
    switch (index) {
      case 0:
        return GoogleFonts.roboto(
            fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
      case 1:
        return GoogleFonts.playfairDisplay(
            fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
      case 2:
        return GoogleFonts.bebasNeue(fontSize: fontSize, color: color);
      case 3:
        return GoogleFonts.dancingScript(
            fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
      case 4:
        return GoogleFonts.poppins(
            fontSize: fontSize, color: color, fontWeight: FontWeight.w600);
      case 5:
        return GoogleFonts.lato(
            fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
      case 6:
        return GoogleFonts.orbitron(
            fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
      case 7:
        return GoogleFonts.pacifico(fontSize: fontSize, color: color);
      default:
        return TextStyle(fontSize: fontSize, color: color);
    }
  }

  @override
  void dispose() {
    isInteracting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      final isSmall = MediaQuery.of(context).size.width < 360;
    return ValueListenableBuilder<bool>(
      valueListenable: isInteracting,
      builder: (context, interacting, child) {
        return MouseRegion(
          onEnter: (_) => isInteracting.value = true,
          onExit: (_) => isInteracting.value = false,
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => isInteracting.value = true,
            onTapUp: (_) => isInteracting.value = false,
            onTapCancel: () => isInteracting.value = false,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              transform: Matrix4.identity()
                ..translate(0.0, interacting ? (isSmall ? -6.0 : -10.0) : 0.0)
                ..scale(interacting ? (isSmall ? 1.01 : 1.02) : 1.0),

              width: double.infinity,
              height: isSmall ? 135 : 152, // 👈 responsive height

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: interacting
                        ? const Color(0xFFFF4081).withOpacity(0.12)
                        : Colors.black.withOpacity(0.03),
                    blurRadius: interacting ? 20 : 14,
                    offset: Offset(0, interacting ? 10 : 6),
                  ),
                ],
              ),

              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  /// GRADIENT BOX
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// SVG RESPONSIVE
                          SvgPicture.string(
                            widget.svg,
                            height: isSmall ? 32 : 40,
                            width: isSmall ? 32 : 40,
                          ),

                          const SizedBox(height: 6),

                          Consumer2<BusinessInfoProvider, LogoDesignProvider>(
                            builder: (context, info, design, child) {
                              return Text(
                                info.businessName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: _getFontStyle(
                                  context,
                                  design.selectedFontIndex,
                                  Colors.white,
                                  fontSize: isSmall ? 10 : 12,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// FAVORITE BUTTON
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: widget.onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isFavorite
                              ? Colors.red
                              : Colors.grey,
                          size: isSmall ? 14 : 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

