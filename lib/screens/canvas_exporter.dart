import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img; // Your image package

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
  } else {
    await _saveImageOrPdf(repaintKey, format, context);
  }
}

/* ===============================
   FORMAT PICKER
================================ */

enum ExportFormat { png, jpg, pdf, svg }

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
          child: const Text("PDF"),
          onPressed: () {
            Navigator.pop(dialogContext, ExportFormat.pdf);
          },
        ),
        SimpleDialogOption(
          child: const Text("SVG"),
          onPressed: () {
            Navigator.pop(dialogContext, ExportFormat.svg);
          },
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
      case ExportFormat.pdf:
        await _savePdf(pngBytes, timestamp, context);
        break;
      case ExportFormat.svg:
        // Handled separately
        break;
    }
  } catch (e) {
    _showErrorMessage(context, "Error capturing canvas: $e");
  }
}

/* ===============================
   PNG SAVE (WORKS ON VIVO)
================================ */

Future<void> _savePng(Uint8List pngBytes, int timestamp, BuildContext context) async {
  try {
    // Save to temporary file first
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/logo_$timestamp.png';
    final tempFile = await File(tempPath).writeAsBytes(pngBytes);

    // Save to gallery
    final saved = await GallerySaver.saveImage(
      tempFile.path,
      albumName: "LogoMaker",
    );
    
    if (saved == true) {
      _showGalleryMessage(context, "PNG");
    } else {
      // If gallery save fails, show file location
      _showFileLocationMessage(context, tempPath, "PNG");
    }
  } catch (e) {
    _showErrorMessage(context, "Failed to save PNG: $e");
  }
}

/* ===============================
   JPG SAVE (USING IMAGE PACKAGE)
================================ */

Future<void> _saveJpg(Uint8List pngBytes, int timestamp, BuildContext context) async {
  try {
    // Convert PNG to JPG using image package
    final imageData = img.decodeImage(pngBytes);
    if (imageData == null) {
      throw Exception('Failed to decode image');
    }
    
    final jpgBytes = img.encodeJpg(imageData, quality: 95);
    
    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/logo_$timestamp.jpg';
    final tempFile = await File(tempPath).writeAsBytes(jpgBytes);

    // Save to gallery
    final saved = await GallerySaver.saveImage(
      tempFile.path,
      albumName: "LogoMaker",
    );
    
    if (saved == true) {
      _showGalleryMessage(context, "JPG");
    } else {
      _showFileLocationMessage(context, tempPath, "JPG");
    }
  } catch (e) {
    _showErrorMessage(context, "Failed to save JPG: $e");
  }
}

/* ===============================
   PDF SAVE (VIVO FIXED)
================================ */

Future<void> _savePdf(Uint8List pngBytes, int timestamp, BuildContext context) async {
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
      showDialog: false,
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
      showDialog: false,
    );
  } catch (e) {
    _showErrorMessage(context, "Failed to save SVG: $e");
  }
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
    final c = state.backgroundColor ?? Colors.white;
    final fill = _colorToSvgFill(c);
    buffer.writeln('<rect width="800" height="600" fill="$fill"/>');
  }
  
  // Text elements
  for (final t in state.customTexts) {
    if (!t.isVisible) continue;
    final c = t.color;
    final fill = _colorToSvgFill(c);

    // Use explicit units and basic text styling for wider viewer support
    buffer.writeln('<text x="${t.position.dx}" y="${t.position.dy}" '
        'font-size="${t.size}px" '
        'fill="$fill" '
        'font-family="Arial, sans-serif" '
        'dominant-baseline="middle">${_escapeXml(t.text)}</text>');
  }
  
  // Simple placeholders for images
  for (final i in state.customImages) {
    if (!i.isVisible) continue;
    
    buffer.writeln(
      '<rect x="${i.position.dx}" y="${i.position.dy}" '
      'width="${i.size}" height="${i.size}" '
      'fill="#888888" stroke="#000000" stroke-width="1" '
      '/>'
    );
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
    // Try multiple locations for better compatibility
    final List<Map<String, String>> savedLocations = [];
    
    // 1. App's Documents directory (always works)
    final docsDir = await getApplicationDocumentsDirectory();
    final docsPath = '${docsDir.path}/$filename';
    await File(docsPath).writeAsBytes(bytes);
    savedLocations.add({
      'name': 'Documents Folder',
      'path': docsPath,
    });
    
    // 2. Create a LogoMaker folder in Downloads (if accessible)
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final downloadDir = Directory('${externalDir.path}/LogoMaker');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        final downloadPath = '${downloadDir.path}/$filename';
        await File(downloadPath).writeAsBytes(bytes);
        savedLocations.add({
          'name': 'LogoMaker Folder',
          'path': downloadPath,
        });
      }
    } catch (e) {
      print('External storage not accessible: $e');
    }
    
    // 3. Save to a public directory
    try {
      final appSupportDir = await getApplicationSupportDirectory();
      final publicDir = Directory('${appSupportDir.path}/Public');
      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }
      final publicPath = '${publicDir.path}/$filename';
      await File(publicPath).writeAsBytes(bytes);
      savedLocations.add({
        'name': 'Public Folder',
        'path': publicPath,
      });
    } catch (e) {
      print('Public directory error: $e');
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

void _showGalleryMessage(BuildContext context, String fileType) {
  // Gallery save acknowledged by caller; no snackbar here to avoid duplicates.
  // Optionally keep this function for future hooks (e.g., open gallery).
}

void _showFileLocationMessage(BuildContext context, String path, String fileType) {
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
          Text('📱 On Vivo Phone:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              // Clipboard.setData(ClipboardData(text: location['path']));
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(content: Text('Path copied')),
                              // );
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
            Text('💡 Tips for Vivo:', style: TextStyle(fontWeight: FontWeight.bold)),
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