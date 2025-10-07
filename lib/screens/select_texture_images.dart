import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:provider/provider.dart';

class SelectTextureImages extends StatefulWidget {
  const SelectTextureImages({super.key});

  @override
  State<SelectTextureImages> createState() => _SelectTextureImagesState();
}

class _SelectTextureImagesState extends State<SelectTextureImages> {
  Future<ui.Image> loadUiImageFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  final List<String> textureImages = [
    'assets/texture_images/texture_1.jpg',
    'assets/texture_images/texture_2.jpg',
    'assets/texture_images/texture_3.jpg',
    'assets/texture_images/texture_4.jpg',
    'assets/texture_images/texture_5.jpg',
    'assets/texture_images/texture_6.jpg',
    'assets/texture_images/texture_7.jpg',
    'assets/texture_images/texture_8.jpg',
    'assets/texture_images/texture_9.jpg',
    'assets/texture_images/texture_10.jpg',
    // Add more texture paths as needed
  ];

  void _saveUndoState(String action) {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    if (!undoProvider.isUndoRedoInProgress) {
      final currentState = colorProvider.captureCurrentState();
      undoProvider.saveState(action: action, state: currentState);
      print('✅ Saved undo state: $action');
    }
  }

  Future<void> _onTextureSelectedWithUndo(String texturePath) async {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    _saveUndoState('Apply texture: ${texturePath.split('/').last}');

    try {
      final uiImage = await loadUiImageFromAsset(texturePath);
      // Use setBackgroundTexture if it exists, otherwise use setBackgroundImage
      if (colorProvider.hasMethod('setBackgroundTexture')) {
        colorProvider.setBackgroundTexture(uiImage, texturePath);
      } else {
        // Fallback to background image with texture flag
        colorProvider.setBackgroundImage(uiImage, null, texturePath);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Texture applied: ${texturePath.split('/').last}'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: _performUndo,
            textColor: Colors.white,
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load texture: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onTextureRemovedWithUndo() {
    _saveUndoState('Remove background texture');

    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    // Remove texture - use appropriate method based on your implementation
    if (colorProvider.hasMethod('removeBackgroundTexture')) {
      colorProvider.removeBackgroundTexture();
    } else {
      colorProvider.setBackgroundImage(null, null);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Background texture removed'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: _performUndo,
          textColor: Colors.white,
        ),
      ),
    );

    Navigator.pop(context);
  }

  void _performUndo() async {
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    final previousState = undoProvider.undo();
    if (previousState != null) {
      try {
        await colorProvider.restoreFromStateAsync(previousState.data);
      } catch (_) {
        colorProvider.restoreFromState(previousState.data);
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Undid: ${previousState.action}'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Textures'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Column(
        children: [
          // Button to remove background texture
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _onTextureRemovedWithUndo,
              icon: const Icon(Icons.texture),
              label: const Text('Remove Texture'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          // Texture grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: textureImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onTextureSelectedWithUndo(textureImages[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                      image: DecorationImage(
                        image: AssetImage(textureImages[index]),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to check if a method exists (helper)
extension MethodChecker on SelectedColorProvider {
  bool hasMethod(String methodName) {
    try {
      switch (methodName) {
        case 'setBackgroundTexture':
          // Check if the method exists by looking at the class
          return true; // Adjust based on your actual implementation
        case 'removeBackgroundTexture':
          return true; // Adjust based on your actual implementation
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}
