import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CanvasUploadService {
  static Future<String?> uploadCanvas({
    required GlobalKey canvasKey,
  }) async {
    try {
      await WidgetsBinding.instance.endOfFrame;

      final boundary = canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      final ui.Image image =
          await boundary.toImage(pixelRatio: 3);

      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      final Uint8List pngBytes =
          byteData!.buffer.asUint8List();

      final supabase = Supabase.instance.client;

      final fileName =
          'logo_${DateTime.now().millisecondsSinceEpoch}.png';

      await supabase.storage
          .from('logos')
          .uploadBinary(
            'logos/$fileName',
            pngBytes,
            fileOptions:
                const FileOptions(contentType: 'image/png'),
          );

      return supabase.storage
          .from('your_bucket_name')
          .getPublicUrl('logos/$fileName');
    } catch (e) {
      print('❌ Canvas upload error: $e');
      return null;
    }
  }
}
