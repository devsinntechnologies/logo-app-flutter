import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logo_app_flutter/screens/download_logo.dart';
import 'package:logo_app_flutter/services/logo_service.dart';
import 'package:google_fonts/google_fonts.dart';

class TemplateWidget extends StatefulWidget {
  final String companyName;
  final String slogan;
  final String category;
  final int selectedFontIndex;
  final TextStyle fontStyle;

  const TemplateWidget({
    super.key,
    required this.companyName,
    required this.slogan,
    required this.category,
    required this.selectedFontIndex,
    required this.fontStyle,
    required String fontFamily,
  });

  @override
  State<TemplateWidget> createState() => _TemplateWidgetState();
}

class _TemplateWidgetState extends State<TemplateWidget> {
  int? selectedIndex;

  late Future<List<String>> _futureSvgList;

  @override
  void initState() {
    super.initState();
    _futureSvgList = LogoService().fetchLogoSVGs(
      widget.companyName,
      widget.slogan,
    );
  }

  TextStyle _getFontStyle(int index, {double fontSize = 14}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87; 
    
    switch (index) {
      case 0:
        return GoogleFonts.roboto(
          fontSize: fontSize,
          color: textColor, 
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        );
      case 1:
        return GoogleFonts.pacifico(
          fontSize: fontSize,
          color: textColor, 
          letterSpacing: 1.2,
        );
      case 2:
        return GoogleFonts.poppins(
          fontSize: fontSize,
          color: textColor, 
          fontWeight: FontWeight.normal,
          letterSpacing: 1.2,
        );
      case 3:
        return GoogleFonts.dancingScript(
          fontSize: fontSize,
          color: textColor, 
          letterSpacing: 1.2,
        );
      case 4:
        return GoogleFonts.satisfy(
          fontSize: fontSize,
          color: textColor, 
          letterSpacing: 1.2,
        );
      case 5:
        return GoogleFonts.lato(
          fontSize: fontSize,
          color: textColor, 
          letterSpacing: 1.2,
        );
      case 6:
        return GoogleFonts.orbitron(
          fontSize: fontSize,
          color: textColor, 
          letterSpacing: 1.2,
        );
      case 7:
        return GoogleFonts.openSans(
          fontSize: fontSize,
          color: textColor, 
          letterSpacing: 1.2,
        );
      case 8:
        return GoogleFonts.bebasNeue(
          fontSize: fontSize,
          color: textColor, 
          letterSpacing: 1.2,
        );
      case 9:
        return GoogleFonts.pressStart2p(
          fontSize: fontSize - 2,
          color: textColor, 
          letterSpacing: 1.2,
        );
      default:
        return TextStyle(
          fontSize: fontSize,
          color: textColor, 
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      body: FutureBuilder<List<String>>(
        future: _futureSvgList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? Colors.white : Colors.black, 
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No logos found.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                ),
              ),
            );
          }

          final svgList = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: svgList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                
                return InkWell(
                  onTap: () {
                    if (selectedIndex == index) {
                      final selectedSvg = svgList[index];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DownloadLogo(
                            svgLogo: selectedSvg,
                            companyName: widget.companyName,
                            sloganName: widget.slogan,
                          ),
                        ),
                      );
                    } else {
                      setState(() {
                        selectedIndex = index;
                      });
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        width: screenWidth * 1.7,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Colors.orange
                                : (isDark ? Colors.grey[600]! : Colors.grey.shade300),
                            width: isSelected ? 2.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: isDark 
                                  ? Colors.black.withOpacity(0.5) 
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SvgPicture.string(
                              svgList[index],
                              placeholderBuilder: (context) => Center(
                                child: CircularProgressIndicator(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              height: 80,
                              width: 80,
                            ),
                            const SizedBox(height: 8),
                            Flexible(
                              child: Text(
                                widget.companyName,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _getFontStyle(
                                  widget.selectedFontIndex,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                widget.slogan,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: _getFontStyle(
                                  widget.selectedFontIndex,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                widget.category,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey[400] : Colors.grey, // ✅ Theme-aware grey
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isSelected)
                        Positioned(
                          bottom: 20,
                          child: SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                final selectedSvg = svgList[index];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DownloadLogo(
                                      svgLogo: selectedSvg,
                                      companyName: widget.companyName,
                                      sloganName: widget.slogan,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.white),
                                  SizedBox(width: 5),
                                  const Text("Edit"),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}