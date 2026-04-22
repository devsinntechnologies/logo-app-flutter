import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CanvasUploadService {
  /// Upload canvas image to Supabase under the current user's folder
  static Future<String?> uploadCanvas({required GlobalKey canvasKey}) async {
    try {
      // Allow any pending UI updates (like clearing selection) to complete
      await Future.delayed(const Duration(milliseconds: 50));
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 50));
      await WidgetsBinding.instance.endOfFrame;

      final context = canvasKey.currentContext;
      if (context == null) {
        print('❌ Canvas context is null');
        return null;
      }

      final boundary =
          context.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print('❌ byteData is null');
        return null;
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not found');
        return null;
      }
      final uid = user.id;
      final fileName = 'logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = 'logos/$uid/$fileName';

      await supabase.storage.from('logos').uploadBinary(
            filePath,
            pngBytes,
            fileOptions: const FileOptions(contentType: 'image/png'),
          );

      final url = supabase.storage.from('logos').getPublicUrl(filePath);
      print('✅ Uploaded logo URL: $url');
      return url;
    } catch (e) {
      print('❌ Canvas upload error: $e');
      rethrow;
    }
  }
}
