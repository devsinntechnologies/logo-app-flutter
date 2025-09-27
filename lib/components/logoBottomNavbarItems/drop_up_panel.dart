// ignore_for_file: public_member_api_docs, sort_constructors_first, use_super_parameters, use_build_context_synchronously
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logo_app_flutter/components/logoBottomNavbarItems/shape_selector_widget.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:logo_app_flutter/screens/color_screen.dart';
import 'package:logo_app_flutter/screens/gradiant_picker_screen.dart';
import 'package:logo_app_flutter/screens/select_bg_images.dart';
import 'package:logo_app_flutter/screens/select_texture_images.dart';
import 'package:provider/provider.dart';

class DropUpPanel extends StatefulWidget {
  final VoidCallback onClose;
  final Function(bool) onToggleCheckerboard;
  final Function(double) onOpacityChanged;
  final Function(String) onShapeSelected;
  final Function(Gradient)? onGradientSelected;
  final Function(String)? onTextureSelected;

  const DropUpPanel({
    super.key,
    required this.onClose,
    required this.onToggleCheckerboard,
    required this.onOpacityChanged,
    required this.onShapeSelected,
    this.onGradientSelected,
    this.onTextureSelected,
  });

  @override
  State<DropUpPanel> createState() => _DropUpPanelState();
}

class _DropUpPanelState extends State<DropUpPanel> {
  Future<void> pickImageFromDevice(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await pickedFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final provider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      provider.setBackgroundImage(image, file);
    }
  }

  String? selectedShapeName;
  int selectedIndex = 0;
  final Color _baseColor = Colors.red; // Default palette color

  final List<String> options = [
    'Color',
    'Gradient',
    'Background',
    'Texture',
    'Image',
  ];
  double _opacityValue = 1.0;

  void _saveUndoState(BuildContext context, String action) {
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    if (!undoProvider.isUndoRedoInProgress) {
      final currentState = colorProvider.captureCurrentState();
      undoProvider.saveState(action: action, state: currentState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      color: theme.scaffoldBackgroundColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _TopOption(
                        label: options[0],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ColorScreen(),
                            ),
                          );
                        },
                      ),
                      _TopOption(
                        label: options[1],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GradientPickerScreen(),
                            ),
                          );
                        },
                      ),
                      _TopOption(
                        label: options[2],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectBgImages(),
                            ),
                          );
                        },
                      ),
                      _TopOption(
                        label: options[3],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectTextureImages(),
                            ),
                          );
                        },
                      ),
                      _TopOption(
                        label: options[4],
                        onTap: () {
                          pickImageFromDevice(context);
                        },
                      ),
                    ],
                  ),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.opacity, color: theme.iconTheme.color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Slider(
                          activeColor: theme.colorScheme.primary,
                          value: _opacityValue,
                          min: 0,
                          max: 1,
                          onChanged: (val) {
                            setState(() {
                              _opacityValue = val;
                            });
                            widget.onOpacityChanged(_opacityValue);
                          },
                        ),
                      ),
                      Text(
                        "${(_opacityValue * 100).round()}%",
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: theme.dividerColor),
                  SizedBox(
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Logo Shape",
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        ShapeSelectorWidget(
                          onShapeSelected: (shapeName) {
                            if (shapeName == "Transparent") {
                              widget.onToggleCheckerboard(true);
                            } else if (shapeName == "TransparentOff") {
                              widget.onToggleCheckerboard(false);
                            } else {
                              widget.onToggleCheckerboard(true);
                              widget.onShapeSelected(shapeName);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TopOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
