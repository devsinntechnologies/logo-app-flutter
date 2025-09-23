import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:provider/provider.dart';

class SelectBgImages extends StatefulWidget {
  const SelectBgImages({super.key});

  @override
  State<SelectBgImages> createState() => _SelectBgImagesState();
}

class _SelectBgImagesState extends State<SelectBgImages> {
  Future<ui.Image> loadUiImageFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  final List<String> images = [
    'assets/bg_images/bg_1.jpg',
    'assets/bg_images/bg_2.jpg',
    'assets/bg_images/bg_3.jpeg',
    'assets/bg_images/bg_4.jpg',
    'assets/bg_images/bg_5.jpg',
    'assets/bg_images/bg_6.jpg',
    'assets/bg_images/bg_7.jpg',
    'assets/bg_images/bg_8.jpg',
    'assets/bg_images/bg_9.jpg',
    'assets/bg_images/bg_10.jpg',
  ];

  void _onBackgroundImageSelectedWithUndo(String imagePath) {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    // Save current state before applying background image
    final currentState = colorProvider.captureCurrentState();
    undoProvider.saveState(
      action: 'Set background image: ${imagePath.split('/').last}',
      state: currentState,
    );

    // Apply background image
    loadUiImageFromAsset(imagePath).then((uiImage) {
      colorProvider.setBackgroundImage(uiImage, null);
    });
  }

  void _onBackgroundImageRemovedWithUndo() {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    // Save state before removing background image
    final currentState = colorProvider.captureCurrentState();
    undoProvider.saveState(
      action: 'Remove background image',
      state: currentState,
    );

    // Remove background image
    colorProvider.setBackgroundImage(null, null);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Images'),
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
