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

  const TemplateWidget({
    super.key,
    required this.companyName,
    required this.slogan,
    required this.category,
    required this.selectedFontIndex,
    required String fontFamily,
  });

  @override
  State<TemplateWidget> createState() => _TemplateWidgetState();
}

class _TemplateWidgetState extends State<TemplateWidget> {
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
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: fontSize,
        );
      case 1:
        return GoogleFonts.pacifico(
          color: Colors.black87,
          letterSpacing: 1.2,
          fontSize: fontSize,
        );
      case 2:
        return GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.normal,
          letterSpacing: 1.2,
          fontSize: fontSize,
        );
      case 3:
        return GoogleFonts.dancingScript(
          color: Colors.black87,
          letterSpacing: 1.2,
          fontSize: fontSize,
        );
      default:
        return TextStyle(fontSize: fontSize, color: Colors.black87);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
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
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
