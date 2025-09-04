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
  switch (index) {
    case 0:
      return GoogleFonts.roboto(
        fontSize: fontSize,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      );
    case 1:
      return GoogleFonts.pacifico(
        fontSize: fontSize,
        color: Colors.black87,
        letterSpacing: 1.2,
      );
    case 2:
      return GoogleFonts.poppins(
        fontSize: fontSize,
        color: Colors.black87,
        fontWeight: FontWeight.normal,
        letterSpacing: 1.2,
      );
    case 3:
      return GoogleFonts.dancingScript(
        fontSize: fontSize,
        color: Colors.black87,
        letterSpacing: 1.2,
      );
    case 4:
      return GoogleFonts.satisfy(
        fontSize: fontSize,
        color: Colors.black87,
        letterSpacing: 1.2,
      );
    case 5:
      return GoogleFonts.lato(
        fontSize: fontSize,
        color: Colors.black87,
        letterSpacing: 1.2,
      );
    case 6:
      return GoogleFonts.orbitron(
        fontSize: fontSize,
        color: Colors.black87,
        letterSpacing: 1.2,
      );
    case 7:
      return GoogleFonts.openSans(
        fontSize: fontSize,
        color: Colors.black87,
        letterSpacing: 1.2,
      );
    case 8:
      return GoogleFonts.bebasNeue(
        fontSize: fontSize,
        color: Colors.black87,
        letterSpacing: 1.2,
      );
    case 9:
      return GoogleFonts.pressStart2p(
        fontSize: fontSize - 2, // this font is blocky, reduce size a bit
        color: Colors.black87,
        letterSpacing: 1.2,
      );
    default:
      return TextStyle(
        fontSize: fontSize,
        color: Colors.black87,
      );
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: _futureSvgList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logos found.'));
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
                return InkWell(
                  onTap: () {
                    if (selectedIndex == index) {
                      final selectedSvg = svgList[index];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DownloadLogo(
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
                          border: Border.all(
                            color:
                                selectedIndex == index
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                            width: selectedIndex == index ? 2.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          children: [
                            SvgPicture.string(
                              svgList[index],
                              placeholderBuilder:
                                  (context) => const Center(
                                    child: CircularProgressIndicator(),
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
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (selectedIndex == index)
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
                                    builder:
                                        (context) => DownloadLogo(
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