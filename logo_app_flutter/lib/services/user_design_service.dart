import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDesignService {
  final supabase = Supabase.instance.client;

  /// Fetch all designs for the current logged-in user
  Future<List<Map<String, dynamic>>> fetchUserDesigns() async {
    final uid = supabase.auth.currentUser!.id;
    try {
      final response = await supabase.from('designs').select().eq('user_id', uid);

      if (response is! List) return [];

      final List<Map<String, dynamic>> normalized = [];
      for (final r in response) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(r);

        // Parse design_json if needed
        final dj = item['design_json'];
        if (dj is String) {
          try {
            item['design_json'] = jsonDecode(dj) as Map<String, dynamic>;
          } catch (_) {}
        }

        // Add public URL for image
        if (item['image_path'] is String) {
          final path = item['image_path'] as String;
          final url = supabase.storage.from('logos').getPublicUrl(path);
          // Append cache-busting timestamp so updated images show immediately
          item['image_url'] = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
        }

        normalized.add(item);
      }

      return normalized;
    } catch (e) {
      print('❌ Fetch designs error: $e');
      return [];
    }
  }

  /// Upload a canvas image to Supabase storage
  /// Returns a map with 'filePath' and 'url'
  Future<Map<String, String>?> uploadCanvasImage({required GlobalKey canvasKey, String? targetPath}) async {
    try {
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final uid = supabase.auth.currentUser!.id;
      final filePath = targetPath ?? 'logos/$uid/logo_${DateTime.now().millisecondsSinceEpoch}.png';

      // If replacing an existing file, attempt to remove it first so upload is a clean replace
      if (targetPath != null) {
        try {
          await supabase.storage.from('logos').remove([targetPath]);
        } catch (_) {}
      }

      await supabase.storage.from('logos').uploadBinary(
            filePath,
            pngBytes,
            fileOptions: const FileOptions(contentType: 'image/png'),
          );

      final url = supabase.storage.from('logos').getPublicUrl(filePath);

      print('✅ Uploaded logo path: $filePath');
      print('✅ Public URL: $url');

      return {'filePath': filePath, 'url': url};
    } catch (e) {
      print('❌ Canvas upload error: $e');
      return null;
    }
  }

  /// Save a new design
  Future<void> saveNewDesign({
    required GlobalKey canvasKey,
    required Map<String, dynamic> designJson,
  }) async {
    final uid = supabase.auth.currentUser!.id;

    try {
      final uploadResult = await uploadCanvasImage(canvasKey: canvasKey);
      if (uploadResult == null) return;

      await supabase.from('designs').insert({
        'user_id': uid,
        'image_path': uploadResult['filePath'],
        'design_json': jsonEncode(designJson),
      });

      print('✅ Design saved successfully');
    } catch (e) {
      print('❌ Save new design error: $e');
    }
  }

  /// Update an existing design
Future<void> updateDesign({
  required String designId,
  required GlobalKey canvasKey,
  required Map<String, dynamic> updatedJson,
  String? imagePath,           // 👈 SAME path pass karne ke liye
  bool updateImage = false,
}) async {
  final uid = supabase.auth.currentUser!.id;

  try {
    String? finalPath = imagePath;

    if (updateImage) {
      // Agar imagePath UI se nahi aayi, DB se le lo
      if (finalPath == null) {
        try {
          final existing = await fetchDesignById(designId);
          finalPath = existing?['image_path'] as String?;
        } catch (_) {
          finalPath = null;
        }
      }

      // 🔥 SAME PATH par overwrite
      final uploadResult = await uploadCanvasImage(
        canvasKey: canvasKey,
        targetPath: finalPath,
      );

      if (uploadResult != null) {
        finalPath = uploadResult['filePath'];
      }
    }

    final updateData = {
      'design_json': jsonEncode(updatedJson),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (finalPath != null) {
      updateData['image_path'] = finalPath;
    }

    await supabase
        .from('designs')
        .update(updateData)
        .eq('id', designId)
        .eq('user_id', uid);

    debugPrint('✅ Design + image updated');
  } catch (e) {
    debugPrint('❌ Update design error: $e');
    rethrow;
  }
}

  /// Fetch a single design by ID
  Future<Map<String, dynamic>?> fetchDesignById(String designId) async {
    final uid = supabase.auth.currentUser!.id;

    try {
      final response = await supabase
          .from('designs')
          .select()
          .eq('id', designId)
          .eq('user_id', uid)
          .limit(1);

      if (response is List && response.isNotEmpty) {
        final item = Map<String, dynamic>.from(response.first);

        // Add public URL
        if (item['image_path'] is String) {
          final path = item['image_path'] as String;
          final url = supabase.storage.from('logos').getPublicUrl(path);
          // Append cache-busting timestamp so updated images show immediately
          item['image_url'] = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
        }

        // Parse design_json
        final dj = item['design_json'];
        if (dj is String) {
          try {
            item['design_json'] = jsonDecode(dj) as Map<String, dynamic>;
          } catch (_) {}
        }

        return item;
      }
    } catch (e) {
      print('❌ Fetch design by ID error: $e');
    }

    return null;
  }

  /// Delete a design and its storage image
  Future<bool> deleteDesign(String designId) async {
    final uid = supabase.auth.currentUser!.id;
    try {
      // fetch design to get image_path
      final design = await fetchDesignById(designId);
      final imagePath = design?['image_path'] as String?;

      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          await supabase.storage.from('logos').remove([imagePath]);
        } catch (e) {
          // ignore storage removal errors but log
          print('⚠️ Failed to remove image from storage: $e');
        }
      }

      await supabase.from('designs').delete().eq('id', designId).eq('user_id', uid);
      print('✅ Design deleted: $designId');
      return true;
    } catch (e) {
      print('❌ Delete design error: $e');
      return false;
    }
  }
}
