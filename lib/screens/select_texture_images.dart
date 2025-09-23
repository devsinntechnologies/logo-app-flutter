import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
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
    final uiImage = await loadUiImageFromAsset(texturePath);
    colorProvider.setBackgroundImage(uiImage, null);
    if (colorProvider.selectedElementId != null) {
      colorProvider.setElementTexture(
        colorProvider.selectedElementId!,
        texturePath,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Textures'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        itemCount: images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              final provider = Provider.of<SelectedColorProvider>(
                context,
                listen: false,
              );
              final uiImage = await loadUiImageFromAsset(images[index]);

              provider.setBackgroundImage(
                uiImage,
                null,
              ); // You can pass `null` for File since it's an asset
              Navigator.pop(context);
            },

            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                image: DecorationImage(
                  image: AssetImage(images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
