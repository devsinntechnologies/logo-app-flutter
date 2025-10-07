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

  Future<void> _onBackgroundImageSelectedWithUndo(String imagePath) async {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    _saveUndoState('Apply background image: ${imagePath.split('/').last}');

    try {
      final uiImage = await loadUiImageFromAsset(imagePath);
      colorProvider.setBackgroundImage(uiImage, null, imagePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Background applied: ${imagePath.split('/').last}'),
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
          content: Text('Failed to load background image: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onBackgroundImageRemovedWithUndo() {
    _saveUndoState('Remove background image');

    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    colorProvider.setBackgroundImage(null, null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Background image removed'),
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
        title: const Text('Background Images'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Column(
        children: [
          // Button to remove background image
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _onBackgroundImageRemovedWithUndo,
              icon: const Icon(Icons.format_color_reset),
              label: const Text('Remove Background'),
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
          // Background image grid
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
                  onTap:
                      () => _onBackgroundImageSelectedWithUndo(images[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
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
