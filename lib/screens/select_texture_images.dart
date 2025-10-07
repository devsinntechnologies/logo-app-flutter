import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:logo_app_flutter/components/undo_redo_widget.dart';
import 'package:provider/provider.dart';

class SelectTextureImages extends StatefulWidget {
  const SelectTextureImages({super.key});

  @override
  State<SelectTextureImages> createState() => SelectTextureImagesState();
}

class SelectTextureImagesState extends State<SelectTextureImages> {
  Future<ui.Image> loadUiImageFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  final List<String> images = [
    'assets/texture_images/texture_1.jpg',
    'assets/texture_images/texture_2.jpg',
    'assets/texture_images/texture_3.jpg',
    'assets/texture_images/texture_4.jpg',
    'assets/texture_images/texture_5.png',
    'assets/texture_images/texture_6.jpg',
    'assets/texture_images/texture_7.jpg',
    'assets/texture_images/texture_8.jpg',
    'assets/texture_images/texture_9.jpg',
    'assets/texture_images/texture_10.jpg',
  ];

  Future<void> _onTextureSelectedWithUndo(String texturePath) async {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    // Save current state before applying texture
    final currentState = colorProvider.captureCurrentState();
    undoProvider.saveState(
      action: 'Apply texture: ${texturePath.split('/').last}',
      state: currentState,
    );

    // Apply texture
    try {
      final uiImage = await loadUiImageFromAsset(texturePath);
      colorProvider.setBackgroundImage(uiImage, null);

      if (colorProvider.selectedElementId != null) {
        colorProvider.setElementTexture(
          colorProvider.selectedElementId!,
          texturePath,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Texture applied: ${texturePath.split('/').last}'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
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
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    // Save state before removing texture
    final currentState = colorProvider.captureCurrentState();
    undoProvider.saveState(action: 'Remove texture', state: currentState);

    // Remove texture
    colorProvider.setBackgroundImage(null, null);
    if (colorProvider.selectedElementId != null) {
      colorProvider.setElementTexture(colorProvider.selectedElementId!, null);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texture removed'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Textures'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Column(
        children: [
          // Button to remove texture
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _onTextureRemovedWithUndo,
              icon: const Icon(Icons.format_color_reset),
              label: const Text('Remove Texture'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
              ),
            ),
          ),
          // Texture grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onTextureSelectedWithUndo(images[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(images[index]),
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
