import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart'; // Your image package

/* ===============================
   PUBLIC METHOD
================================ */

Future<void> exportCanvas({
  required BuildContext context,
  required GlobalKey repaintKey,
  required LogoStateData logoState,
}) async {
  final format = await _pickFormat(context);
  if (format == null) return;

  if (format == ExportFormat.svg) {
    await _saveSvg(logoState, context);
  } else if (format == ExportFormat.eps) {
    await _saveEps(logoState, context);
  } else {
    await _saveImageOrPdf(repaintKey, format, context);
  }
}

/* ===============================
   FORMAT PICKER
================================ */

enum ExportFormat { png, jpg, pdf, svg, webp, ico, tiff, bmp, eps }

Future<ExportFormat?> _pickFormat(BuildContext context) {
  return showDialog<ExportFormat>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text("Save As"),
      children: [
        SimpleDialogOption(
          child: const Text("PNG"),
          onPressed: () => Navigator.pop(dialogContext, ExportFormat.png),
        ),
        SimpleDialogOption(
          child: const Text("JPG"),
          onPressed: () => Navigator.pop(dialogContext, ExportFormat.jpg),
        ),
        SimpleDialogOption(
          child: const Text("SVG"),
          onPressed: () => Navigator.pop(dialogContext, ExportFormat.svg),
        ),
        SimpleDialogOption(
          child: const Text("PDF"),
          onPressed: () => Navigator.pop(dialogContext, ExportFormat.pdf),
        ),
        SimpleDialogOption(
          child: const Text("EPS"),
          onPressed: () => Navigator.pop(dialogContext, ExportFormat.eps),
        ),
        SimpleDialogOption(
          child: const Text("WebP"),
          onPressed: () => Navigator.pop(dialogContext, ExportFormat.webp),
        ),
        SimpleDialogOption(
          child: const Text("ICO"),
          onPressed: () => Navigator.pop(dialogContext, ExportFormat.ico),
        ),
        SimpleDialogOption(
          child: const Text("TIFF"),
          onPressed: () => Navigator.pop(dialogContext, ExportFormat.tiff),
        ),
        SimpleDialogOption(
          child: const Text("BMP"),
          onPressed: () => Navigator.pop(dialogContext, ExportFormat.bmp),
        ),
      ],
    ),
  );
}

/* ===============================
   PNG/JPG/PDF EXPORT
================================ */

Future<void> _saveImageOrPdf(
  GlobalKey repaintKey,
  ExportFormat format,
  BuildContext context,
) async {
  try {
    // Capture the canvas as image
    final boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    switch (format) {
      case ExportFormat.png:
        await _savePng(pngBytes, timestamp, context);
        break;
      case ExportFormat.jpg:
        await _saveJpg(pngBytes, timestamp, context);
        break;
      case ExportFormat.webp:
        await _saveWebp(pngBytes, timestamp, context);
        break;
      case ExportFormat.ico:
        await _saveIco(pngBytes, timestamp, context);
        break;
      case ExportFormat.tiff:
        await _saveTiff(pngBytes, timestamp, context);
        break;
      case ExportFormat.bmp:
        await _saveBmp(pngBytes, timestamp, context);
        break;
      case ExportFormat.pdf:
        await _savePdf(pngBytes, timestamp, context);
        break;
      case ExportFormat.svg:
      case ExportFormat.eps:
        // Handled separately
        break;
    }
  } catch (e) {
    _showErrorMessage(context, "Error capturing canvas: $e");
  }
}

/* ===============================
   PERMISSION HELPER
================================ */

Future<bool> _requestStoragePermission() async {
  if (!Platform.isAndroid) return true;

  // For Android 13+ (SDK 33), we need Photos permission
  // For older Android, we need Storage permission
  if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
    return true;
  }

  final status = await Permission.storage.request();
  if (status.isGranted) return true;

  // On Android 13+, storage request might fail but photos might work
  final photoStatus = await Permission.photos.request();
  return photoStatus.isGranted;
}

/* ===============================
   PNG SAVE (WORKS ON VIVO)
================================ */

Future<void> _savePng(
    Uint8List pngBytes, int timestamp, BuildContext context) async {
  try {
    if (!await _requestStoragePermission()) {
      _showErrorMessage(context,
          "Storage permission denied. Please allow access to save the logo.");
      return;
    }

    final filename = 'logo_$timestamp.png';

    // Save to a more permanent location first as backup
    final docsDir = await getApplicationDocumentsDirectory();
    final backupPath = '${docsDir.path}/$filename';
    final backupFile = await File(backupPath).writeAsBytes(pngBytes);

    // Try to save to gallery
    bool? saved = await GallerySaver.saveImage(
      backupFile.path,
      albumName: "LogoMaker",
    );

    if (saved == true) {
      _showGalleryMessage(context, "PNG", backupPath);
    } else {
      // If gallery save fails, try saving as a non-image file to public-ish folder
      await _saveNonImageFile(
        bytes: pngBytes,
        filename: filename,
        context: context,
        fileType: "PNG",
      );
    }
  } catch (e) {
    _showErrorMessage(context, "Failed to save PNG: $e");
  }
}

/* ===============================
   JPG SAVE (USING IMAGE PACKAGE)
================================ */

Future<void> _saveJpg(
    Uint8List pngBytes, int timestamp, BuildContext context) async {
  try {
    if (!await _requestStoragePermission()) {
      _showErrorMessage(context, "Storage permission denied.");
      return;
    }

    // Convert PNG to JPG using image package
    final imageData = img.decodeImage(pngBytes);
    if (imageData == null) {
      throw Exception('Failed to decode image');
    }

    final jpgBytes = img.encodeJpg(imageData, quality: 95);

    final filename = 'logo_$timestamp.jpg';
    final docsDir = await getApplicationDocumentsDirectory();
    final backupPath = '${docsDir.path}/$filename';

    // Save to a more permanent location first as backup
    final backupFile = await File(backupPath).writeAsBytes(jpgBytes);

    // Try to save to gallery
    bool? saved = await GallerySaver.saveImage(
      backupFile.path,
      albumName: "LogoMaker",
    );

    if (saved == true) {
      _showGalleryMessage(context, "JPG", backupPath);
    } else {
      // If gallery save fails, try saving as a non-image file to public-ish folder
      await _saveNonImageFile(
        bytes: jpgBytes, // Use jpgBytes here
        filename: filename,
        context: context,
        fileType: "JPG",
      );
    }
  } catch (e) {
    _showErrorMessage(context, "Failed to save JPG: $e");
  }
}

/* ===============================
   PDF SAVE (VIVO FIXED)
================================ */

Future<void> _savePdf(
    Uint8List pngBytes, int timestamp, BuildContext context) async {
  try {
    // Create PDF
    final pdf = pw.Document();
    final imgPdf = pw.MemoryImage(pngBytes);

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Center(
          child: pw.Image(imgPdf),
        ),
      ),
    );

    final pdfBytes = await pdf.save();
    final filename = 'logo_$timestamp.pdf';

    // Save PDF to accessible location
    await _saveNonImageFile(
      bytes: pdfBytes,
      filename: filename,
      context: context,
      fileType: "PDF",
      showDialog: true, // Always show dialog for non-image files
    );
  } catch (e) {
    _showErrorMessage(context, "Failed to save PDF: $e");
  }
}

/* ===============================
   SVG SAVE (VIVO FIXED)
================================ */

Future<void> _saveSvg(LogoStateData state, BuildContext context) async {
  try {
    final svg = _generateSimpleSvg(state);
    final filename = 'logo_${DateTime.now().millisecondsSinceEpoch}.svg';
    final svgBytes = Uint8List.fromList(utf8.encode(svg));

    // Save SVG to accessible location
    await _saveNonImageFile(
      bytes: svgBytes,
      filename: filename,
      context: context,
      fileType: "SVG",
      showDialog: true, // Always show dialog for non-image files
    );
  } catch (e) {
    _showErrorMessage(context, "Failed to save SVG: $e");
  }
}

/* ===============================
   EPS SAVE (MANUAL GENERATION)
 ================================ */

Future<void> _saveEps(LogoStateData state, BuildContext context) async {
  try {
    // EPS is technically PostScript. We can generate a simplified version for logos.
    final eps = _generateSimpleEps(state);
    final filename = 'logo_${DateTime.now().millisecondsSinceEpoch}.eps';
    final epsBytes = Uint8List.fromList(utf8.encode(eps));

    await _saveNonImageFile(
      bytes: epsBytes,
      filename: filename,
      context: context,
      fileType: "EPS",
      showDialog: true, // Always show dialog for non-image files
    );
  } catch (e) {
    _showErrorMessage(context, "Failed to save EPS: $e");
  }
}

/* ===============================
   WEBP SAVE (USING COMPRESS PKG)
 ================================ */

Future<void> _saveWebp(
    Uint8List pngBytes, int timestamp, BuildContext context) async {
  try {
    if (!await _requestStoragePermission()) {
      _showErrorMessage(context, "Storage permission denied.");
      return;
    }

    final webpBytes = await FlutterImageCompress.compressWithList(
      pngBytes,
      format: CompressFormat.webp,
      quality: 100,
    );

    final filename = 'logo_$timestamp.webp';
    final docsDir = await getApplicationDocumentsDirectory();
    final backupPath = '${docsDir.path}/$filename';
    final backupFile = await File(backupPath).writeAsBytes(webpBytes);

    bool? saved = await GallerySaver.saveImage(
      backupFile.path,
      albumName: "LogoMaker",
    );

    if (saved == true) {
      _showGalleryMessage(context, "WebP", backupPath);
    } else {
      await _saveNonImageFile(
        bytes: webpBytes,
        filename: filename,
        context: context,
        fileType: "WebP",
      );
    }
  } catch (e) {
    _showErrorMessage(context, "Failed to save WebP: $e");
  }
}

/* ===============================
   ICO SAVE (USING IMAGE PKG)
 ================================ */

Future<void> _saveIco(
    Uint8List pngBytes, int timestamp, BuildContext context) async {
  try {
    if (!await _requestStoragePermission()) {
      _showErrorMessage(context, "Storage permission denied.");
      return;
    }

    final imageData = img.decodeImage(pngBytes);
    if (imageData == null) throw Exception('Failed to decode image');

    // Encode to ICO (standard size 64x64 for better compatibility if needed, but original works too)
    final icoBytes = img.encodeIco(imageData);

    final filename = 'logo_$timestamp.ico';
    final docsDir = await getApplicationDocumentsDirectory();
    final backupPath = '${docsDir.path}/$filename';
    final backupFile = await File(backupPath).writeAsBytes(icoBytes);

    final saved =
        await GallerySaver.saveImage(backupFile.path, albumName: "LogoMaker");

    if (saved == true) {
      _showGalleryMessage(context, "ICO", backupPath);
    } else {
      await _saveNonImageFile(
        bytes: icoBytes,
        filename: filename,
        context: context,
        fileType: "ICO",
      );
    }
  } catch (e) {
    _showErrorMessage(context, "Failed to save ICO: $e");
  }
}

/* ===============================
   TIFF SAVE (USING IMAGE PKG)
 ================================ */

Future<void> _saveTiff(
    Uint8List pngBytes, int timestamp, BuildContext context) async {
  try {
    if (!await _requestStoragePermission()) {
      _showErrorMessage(context, "Storage permission denied.");
      return;
    }

    final imageData = img.decodeImage(pngBytes);
    if (imageData == null) throw Exception('Failed to decode image');

    final tiffBytes = img.encodeTiff(imageData);

    final filename = 'logo_$timestamp.tiff';
    final docsDir = await getApplicationDocumentsDirectory();
    final backupPath = '${docsDir.path}/$filename';
    final backupFile = await File(backupPath).writeAsBytes(tiffBytes);

    final saved =
        await GallerySaver.saveImage(backupFile.path, albumName: "LogoMaker");

    if (saved == true) {
      _showGalleryMessage(context, "TIFF", backupPath);
    } else {
      await _saveNonImageFile(
        bytes: tiffBytes,
        filename: filename,
        context: context,
        fileType: "TIFF",
      );
    }
  } catch (e) {
    _showErrorMessage(context, "Failed to save TIFF: $e");
  }
}

/* ===============================
   BMP SAVE (USING IMAGE PKG)
 ================================ */

Future<void> _saveBmp(
    Uint8List pngBytes, int timestamp, BuildContext context) async {
  try {
    if (!await _requestStoragePermission()) {
      _showErrorMessage(context, "Storage permission denied.");
      return;
    }

    final imageData = img.decodeImage(pngBytes);
    if (imageData == null) throw Exception('Failed to decode image');

    final bmpBytes = img.encodeBmp(imageData);

    final filename = 'logo_$timestamp.bmp';
    final docsDir = await getApplicationDocumentsDirectory();
    final backupPath = '${docsDir.path}/$filename';
    final backupFile = await File(backupPath).writeAsBytes(bmpBytes);

    final saved =
        await GallerySaver.saveImage(backupFile.path, albumName: "LogoMaker");

    if (saved == true) {
      _showGalleryMessage(context, "BMP", backupPath);
    } else {
      await _saveNonImageFile(
        bytes: bmpBytes,
        filename: filename,
        context: context,
        fileType: "BMP",
      );
    }
  } catch (e) {
    _showErrorMessage(context, "Failed to save BMP: $e");
  }
}

/* ===============================
   SIMPLE EPS BUILDER
 ================================ */

String _generateSimpleEps(LogoStateData state) {
  final buffer = StringBuffer();
  buffer.writeln("%!PS-Adobe-3.0 EPSF-3.0");
  buffer.writeln("%%BoundingBox: 0 0 800 600");
  buffer.writeln("%%Title: Logo Design");
  buffer.writeln("%%Creator: Logo Maker App");
  buffer.writeln("%%EndComments");

  // Define helper for RGB color
  buffer.writeln("/setcolor { setrgbcolor } def");

  // Background
  if (state.backgroundColor != null) {
    final c = state.backgroundColor!;
    buffer
        .writeln("${c.red / 255} ${c.green / 255} ${c.blue / 255} setrgbcolor");
    buffer.writeln(
        "newpath 0 0 moveto 800 0 lineto 800 600 lineto 0 600 lineto closepath fill");
  }

  // Main Logo Placeholder (since embedding complex SVG/bitmaps in EPS manually is hard)
  if (state.isLogoVisible) {
    final c = state.logoColor;
    buffer
        .writeln("${c.red / 255} ${c.green / 255} ${c.blue / 255} setrgbcolor");
    buffer.writeln(
        "newpath ${state.logoPosition.dx} ${600 - state.logoPosition.dy} moveto");
    buffer.writeln(
        "${state.logoSize} 0 rlineto 0 ${-state.logoSize} rlineto ${-state.logoSize} 0 rlineto closepath stroke");
    buffer.writeln("/Arial findfont 12 scalefont setfont");
    buffer.writeln(
        "${state.logoPosition.dx} ${600 - state.logoPosition.dy - 15} moveto (LOGO) show");
  }

  // Texts: Company Name, Slogan, Custom Texts
  final textElements = [
    if (state.isCompanyNameVisible && state.companyName != null)
      {
        'text': state.companyName!,
        'pos': state.companyNamePosition,
        'size': state.companyNameSize,
        'color': state.companyNameColor
      },
    if (state.isSloganVisible && state.sloganName != null)
      {
        'text': state.sloganName!,
        'pos': state.sloganPosition,
        'size': state.sloganSize,
        'color': state.sloganColor
      },
    for (final t in state.customTexts)
      if (t.isVisible)
        {'text': t.text, 'pos': t.position, 'size': t.size, 'color': t.color}
  ];

  for (final t in textElements) {
    final c = t['color'] as Color;
    final pos = t['pos'] as Offset;
    buffer
        .writeln("${c.red / 255} ${c.green / 255} ${c.blue / 255} setrgbcolor");
    buffer.writeln("/Arial findfont ${t['size']} scalefont setfont");
    buffer.writeln("${pos.dx} ${600 - pos.dy} moveto");
    buffer.writeln("(${t['text']}) show");
  }

  buffer.writeln("%%EOF");
  return buffer.toString();
}

/* ===============================
   SIMPLE SVG BUILDER
================================ */

String _generateSimpleSvg(LogoStateData state) {
  final buffer = StringBuffer();

  // Standard XML header + SVG root with viewBox for better compatibility
  buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buffer.writeln('<svg xmlns="http://www.w3.org/2000/svg" '
      'xmlns:xlink="http://www.w3.org/1999/xlink" '
      'version="1.1" width="800" height="600" viewBox="0 0 800 600">');

  // Background
  if (state.backgroundColor != null) {
    final fill = _colorToSvgFill(state.backgroundColor!);
    buffer.writeln('<rect width="800" height="600" fill="$fill"/>');
  }

  // Main Logo
  if (state.isLogoVisible && state.svgLogo != null) {
    // If it's an SVG string, we can try to wrap it or embed it
    // For simplicity, we wrap it in a <g> tag with transform
    buffer.writeln(
        '<g transform="translate(${state.logoPosition.dx}, ${state.logoPosition.dy}) scale(${state.logoSize / 100})">');
    buffer.writeln(state.svgLogo);
    buffer.writeln('</g>');
  }

  // Texts: Company Name, Slogan, Custom Texts
  final textElements = [
    if (state.isCompanyNameVisible && state.companyName != null)
      {
        'text': state.companyName!,
        'pos': state.companyNamePosition,
        'size': state.companyNameSize,
        'color': state.companyNameColor
      },
    if (state.isSloganVisible && state.sloganName != null)
      {
        'text': state.sloganName!,
        'pos': state.sloganPosition,
        'size': state.sloganSize,
        'color': state.sloganColor
      },
    for (final t in state.customTexts)
      if (t.isVisible)
        {'text': t.text, 'pos': t.position, 'size': t.size, 'color': t.color}
  ];

  for (final t in textElements) {
    final c = t['color'] as Color;
    final fill = _colorToSvgFill(c);
    final pos = t['pos'] as Offset;
    buffer.writeln('<text x="${pos.dx}" y="${pos.dy}" '
        'font-size="${t['size']}px" '
        'fill="$fill" '
        'font-family="Arial, sans-serif" '
        'dominant-baseline="middle">${_escapeXml(t['text'] as String)}</text>');
  }

  // Custom Images (Placeholder for now as embedding base64 is heavy)
  for (final i in state.customImages) {
    if (!i.isVisible) continue;
    buffer.writeln('<rect x="${i.position.dx}" y="${i.position.dy}" '
        'width="${i.size}" height="${i.size}" '
        'fill="#888888" fill-opacity="0.5" stroke="#000000" stroke-width="1" />');
  }

  buffer.writeln('</svg>');
  return buffer.toString();
}

String _colorToSvgFill(Color color) {
  // If fully opaque, use hex; otherwise use rgba() which some viewers handle better
  final r = color.red;
  final g = color.green;
  final b = color.blue;
  final a = (color.opacity).toStringAsFixed(3);
  if (color.alpha == 255) {
    return '#${_colorToHex(color)}';
  }
  return 'rgba($r,$g,$b,$a)';
}

/* ===============================
   SAVE NON-IMAGE FILES (PDF/SVG)
================================ */

Future<void> _saveNonImageFile({
  required Uint8List bytes,
  required String filename,
  required BuildContext context,
  required String fileType,
  // When false, do not show any dialogs; caller will handle user feedback.
  bool showDialog = true,
}) async {
  try {
    if (!await _requestStoragePermission()) {
      _showErrorMessage(context,
          "Storage permission denied. Please allow access to save the file.");
      return;
    }

    final List<Map<String, String>> savedLocations = [];

    // 1. App's Documents directory (always works)
    final docsDir = await getApplicationDocumentsDirectory();
    final docsPath = '${docsDir.path}/$filename';
    await File(docsPath).writeAsBytes(bytes);
    savedLocations.add({
      'name': 'App Documents Folder',
      'path': docsPath,
    });

    // 2. Try to save to a "Public" folder if possible (e.g., Downloads/LogoMaker on Android)
    if (Platform.isAndroid) {
      try {
        final publicDownloadDir =
            Directory('/storage/emulated/0/Download/LogoMaker');
        if (!await publicDownloadDir.exists()) {
          await publicDownloadDir.create(recursive: true);
        }
        final publicPath = '${publicDownloadDir.path}/$filename';
        await File(publicPath).writeAsBytes(bytes);
        savedLocations.add({
          'name': 'Downloads/LogoMaker',
          'path': publicPath,
        });
      } catch (e) {
        print('Downloads directory error: $e');
      }
    }

    // 3. App Support Public Directory
    try {
      final appSupportDir = await getApplicationSupportDirectory();
      final publicDir = Directory('${appSupportDir.path}/Public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }
      final supportPublicPath = '${publicDir.path}/$filename';
      await File(supportPublicPath).writeAsBytes(bytes);
      savedLocations.add({
        'name': 'App Support Folder',
        'path': supportPublicPath,
      });
    } catch (e) {
      print('App Support directory error: $e');
    }

    // Show all saved locations to user (optional)
    if (showDialog) {
      _showMultiLocationMessage(
        context,
        filename,
        fileType,
        savedLocations,
      );
    }
  } catch (e) {
    // Last resort: temporary directory
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$filename';
    await File(tempPath).writeAsBytes(bytes);

    if (showDialog) {
      _showFileLocationMessage(context, tempPath, fileType);
    }
  }
}

/* ===============================
   MESSAGE DIALOGS
================================ */

void _showGalleryMessage(
    BuildContext context, String fileType, String backupPath) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$fileType saved to Gallery and "LogoMaker" album.',
              style: const TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              _showFileLocationMessage(context, backupPath, fileType);
            },
            child: const Text("DETAILS"),
          ),
        ],
      ),
    ),
  );
}

void _showFileLocationMessage(
    BuildContext context, String path, String fileType) {
  final fileName = path.split('/').last;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('✅ $fileType Saved'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('File: $fileName'),
          SizedBox(height: 10),
          Text('Saved to:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              path,
              style: TextStyle(fontSize: 12, fontFamily: 'Monospace'),
            ),
          ),
          SizedBox(height: 15),
          Text('📱 On Vivo Phone:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('1. Open "File Manager" app'),
          Text('2. Navigate to the path above'),
          Text('3. Or search for "$fileName"'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.content_copy, size: 18),
          label: Text('COPY PATH'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: path));
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

void _showMultiLocationMessage(
  BuildContext context,
  String filename,
  String fileType,
  List<Map<String, String>> locations,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('✅ $fileType Saved Successfully'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File "$filename" saved to multiple locations:'),
            SizedBox(height: 15),
            for (var location in locations) ...[
              Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location['name']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location['path']!,
                              style: TextStyle(fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.content_copy, size: 16),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: location['path']!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Path copied')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 15),
            Text('💡 Tips for Vivo:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Use "File Manager" app'),
            Text('• Search for "LogoMaker" folder'),
            Text('• Or look in "Internal Storage"'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('GOT IT'),
        ),
      ],
    ),
  );
}

void _showErrorMessage(BuildContext context, String message) {
  // Delegate error display to caller; show a simple dialog as fallback.
  showDialog(
    context: context,
    builder: (c) => AlertDialog(
      title: Text('Error'),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text('OK')),
      ],
    ),
  );
}

/* ===============================
   HELPER FUNCTIONS
================================ */

String _colorToHex(Color color) {
  return color.red.toRadixString(16).padLeft(2, '0') +
      color.green.toRadixString(16).padLeft(2, '0') +
      color.blue.toRadixString(16).padLeft(2, '0');
}

String _escapeXml(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
