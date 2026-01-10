import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Texture Image')),
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
                assetPath: images[index],
              ); // Pass asset path for undo/redo
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
