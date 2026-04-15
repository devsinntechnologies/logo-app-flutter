import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logo_app_flutter/provider/business_info_provider.dart';
import 'package:logo_app_flutter/provider/logo_design_provider.dart';
import 'package:logo_app_flutter/screens/download_logo.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:logo_app_flutter/services/user_design_service.dart';
import 'package:logo_app_flutter/screens/canvas_exporter.dart';
import 'package:logo_app_flutter/components/google_alert.dart';

class LogoDetailDialog extends StatefulWidget {
  final String name;
  final String svg;
  final List<Color> colors;

  const LogoDetailDialog({
    super.key,
    required this.name,
    required this.svg,
    required this.colors,
  });

  @override
  State<LogoDetailDialog> createState() => _LogoDetailDialogState();
}

class _LogoDetailDialogState extends State<LogoDetailDialog> {
  final GlobalKey _previewKey = GlobalKey();

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

  Future<void> _saveLogo() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      showCustomGoogleDialog(context);
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final info = context.read<BusinessInfoProvider>();
      final design = context.read<LogoDesignProvider>();

      final logoState = LogoStateData(
        logoPosition: const Offset(150, 100),
        logoSize: 100,
        logoRotation: 0,
        isLogoVisible: true,
        svgLogo: widget.svg,
        companyNamePosition: const Offset(160, 200),
        companyNameSize: 20,
        companyNameRotation: 0,
        isCompanyNameVisible: true,
        companyName: info.businessName,
        sloganPosition: const Offset(150, 240),
        sloganSize: 18,
        sloganRotation: 0,
        isSloganVisible: true,
        sloganName: info.slogan,
        isLogo2Visible: false,
        isCompanyName2Visible: false,
        isSlogan2Visible: false,
        companyFontIndex: design.selectedFontIndex,
        sloganFontIndex: design.selectedFontIndex,
      );

      final svc = UserDesignService();
      await svc.saveNewDesign(
        canvasKey: _previewKey,
        designJson: logoState.toJson(),
      );

      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo saved to My Designs!')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving logo: $e')),
        );
      }
    }
  }

  void _editLogo() {
    final info = context.read<BusinessInfoProvider>();
    final design = context.read<LogoDesignProvider>();
    Navigator.pop(context); // Close dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadLogo(
          svgLogo: widget.svg,
          companyName: info.businessName,
          sloganName: info.slogan,
          selectedFontIndex: design.selectedFontIndex,
        ),
      ),
    );
  }

  Future<void> _downloadLogo() async {
    final info = context.read<BusinessInfoProvider>();
    final design = context.read<LogoDesignProvider>();

    final logoState = LogoStateData(
      logoPosition: const Offset(150, 100),
      logoSize: 100,
      logoRotation: 0,
      isLogoVisible: true,
      svgLogo: widget.svg,
      companyNamePosition: const Offset(160, 200),
      companyNameSize: 20,
      companyNameRotation: 0,
      isCompanyNameVisible: true,
      companyName: info.businessName,
      sloganPosition: const Offset(150, 240),
      sloganSize: 18,
      sloganRotation: 0,
      isSloganVisible: true,
      sloganName: info.slogan,
      isLogo2Visible: false,
      isCompanyName2Visible: false,
      isSlogan2Visible: false,
      companyFontIndex: design.selectedFontIndex,
      sloganFontIndex: design.selectedFontIndex,
    );

    await exportCanvas(
      context: context,
      repaintKey: _previewKey,
      logoState: logoState,
    );
  }

  Future<void> _shareLogo() async {
    try {
      final boundary = _previewKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/shared_logo.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Check out my new logo designed with LogoMaker!',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing logo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Title + Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Color(0xFF1F1F39),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.black, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Large Logo Preview
            RepaintBoundary(
              key: _previewKey,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: widget.colors.first.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Consumer2<BusinessInfoProvider, LogoDesignProvider>(
                  builder: (context, info, design, child) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.string(
                            widget.svg,
                            height: 80,
                            width: 80,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            info.businessName,
                            textAlign: TextAlign.center,
                            style: _getFontStyle(
                              context,
                              design.selectedFontIndex,
                              Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions Grid (2x2)
            Row(
              children: [
                Expanded(
                  child: _LogoActionTile(
                    colors: [
                      Color(0xffFE5A54),
                      Color(0xffAE2EE3),
                    ],
                    icon: Icons.folder_open_outlined,
                    label: 'Save',
                    textcolor: Colors.white,
                    color: const Color(0xFFFFFFFF),
                    onTap: _saveLogo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LogoActionTile(
                    colors: [
                      Color(0xff00C3C0),
                      Color(0xff00C3C0),
                    ],
                    icon: Icons.edit,
                    label: 'Edit',
                    textcolor: Colors.white,
                    color: const Color(0xFFFFFFFF),
                    onTap: _editLogo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _LogoActionTile(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFFFFFFF),
                    ],
                    icon: Icons.file_download_outlined,
                    label: 'Download',
                    color: const Color(0xFF7C4DFF),
                    textcolor: Color(0xff9810FA),
                    onTap: _downloadLogo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LogoActionTile(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFFFFFFF),
                    ],
                    icon: Icons.share,
                    label: 'Share',
                    textcolor: Color(0xffE8117F),
                    color: const Color(0xFFFF6D00),
                    onTap: _shareLogo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final List<Color> colors;
  final VoidCallback onTap;
  final Color textcolor;

  const _LogoActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.colors,
    required this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          // color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textcolor,
                //  Color(0xFF1F1F39),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
