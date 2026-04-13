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
    return ValueListenableBuilder<bool>(
      valueListenable: isInteracting,
      builder: (context, interacting, child) {
        return MouseRegion(
          onEnter: (_) => isInteracting.value = true,
          onExit: (_) => isInteracting.value = false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTapDown: (_) => isInteracting.value = true,
                onTapUp: (_) => isInteracting.value = false,
                onTapCancel: () => isInteracting.value = false,
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..translate(0.0, interacting ? -12.0 : 0.0)
                    ..scale(interacting ? 1.02 : 1.0),
                  width: double.infinity,
                  height: 152,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: interacting
                            ? const Color(0xFFFF4081).withOpacity(0.15)
                            : Colors.black.withOpacity(0.03),
                        blurRadius: interacting ? 30 : 20,
                        offset: Offset(0, interacting ? 18 : 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Consumer2<BusinessInfoProvider, LogoDesignProvider>(
                          builder: (context, info, design, child) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.string(
                                  widget.svg,
                                  height: 40,
                                  width: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  info.businessName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _getFontStyle(
                                    context,
                                    design.selectedFontIndex,
                                    Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Favorite Button
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: widget.onFavoriteTap,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.isFavorite
                                  ? Colors.red
                                  : Colors.grey.shade400,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF1F1F39),
                  fontSize: 12,
                  fontWeight: interacting ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
