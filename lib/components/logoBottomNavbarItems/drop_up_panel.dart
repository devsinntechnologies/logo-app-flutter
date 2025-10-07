// ignore_for_file: public_member_api_docs, sort_constructors_first, use_super_parameters, use_build_context_synchronously
import 'dart:async';
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
  Timer? _undoDebounceTimer;
  bool _isSliderBeingDragged = false;
  Map<String, dynamic>? _sliderStartState;

  Future<void> pickImageFromDevice(BuildContext context) async {
    // Save state before picking image
    _saveUndoState(context, 'Pick background image from device');

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

      // Apply the change and save another undo state
      provider.setBackgroundImage(image, file);

      // Save final state after the change is applied
      _saveUndoStateDelayed(context, 'Set background image from device');
    }
  }

  String? selectedShapeName;
  int selectedIndex = 0;
  final Color _baseColor = Colors.red;

  final List<String> options = [
    'Color',
    'Gradient',
    'Background',
    'Texture',
    'Image',
  ];
  double _opacityValue = 1.0;

  void _saveUndoStateDebounced(
    BuildContext context,
    String action, {
    int delayMs = 400,
  }) {
    _undoDebounceTimer?.cancel();
    _undoDebounceTimer = Timer(Duration(milliseconds: delayMs), () {
      _saveUndoState(context, action);
    });
  }

  void _saveUndoStateDelayed(
    BuildContext context,
    String action, {
    int delayMs = 100,
  }) {
    Timer(Duration(milliseconds: delayMs), () {
      if (mounted) {
        _saveUndoState(context, action);
      }
    });
  }

  void _captureSliderStartState(BuildContext context) {
    if (!_isSliderBeingDragged) {
      final colorProvider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      _sliderStartState = colorProvider.captureCurrentState();
      _isSliderBeingDragged = true;
    }
  }

  void _handleSliderEndWithUndo(BuildContext context, String action) {
    _isSliderBeingDragged = false;
    _undoDebounceTimer?.cancel();
    _saveUndoState(context, action);
    _sliderStartState = null;
  }

  void _handleColorSelection(BuildContext context) {
    // Save state before navigation
    _saveUndoState(context, 'Open color picker');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ColorScreen()),
    ).then((_) {
      // Save state after returning from color screen
      if (mounted) {
        _saveUndoStateDelayed(context, 'Background color changed');
      }
    });
  }

  void _handleGradientSelection(BuildContext context) {
    // Save state before navigation
    _saveUndoState(context, 'Open gradient picker');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GradientPickerScreen()),
    ).then((_) {
      // Save state after returning from gradient screen
      if (mounted) {
        _saveUndoStateDelayed(context, 'Background gradient changed');
      }
    });
  }

  void _handleBackgroundSelection(BuildContext context) {
    // Save state before navigation
    _saveUndoState(context, 'Open background images');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectBgImages()),
    ).then((_) {
      // Save state after returning from background screen
      if (mounted) {
        _saveUndoStateDelayed(context, 'Background image changed');
      }
    });
  }

  void _handleTextureSelection(BuildContext context) {
    // Save state before navigation
    _saveUndoState(context, 'Open texture images');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectTextureImages()),
    ).then((_) {
      // Save state after returning from texture screen
      if (mounted) {
        _saveUndoStateDelayed(context, 'Background texture changed');
      }
    });
  }

  void _handleOpacityChange(double value) {
    setState(() {
      _opacityValue = value;
    });

    // Apply the opacity change immediately for smooth UI
    widget.onOpacityChanged(_opacityValue);

    // Save to provider with undo
    final provider = Provider.of<SelectedColorProvider>(context, listen: false);
    provider.setBackgroundOpacityWithUndo(value);
  }

  void _handleShapeSelection(String shapeName) {
    // Save state before making shape changes
    String actionDescription;

    if (shapeName == "Transparent") {
      actionDescription = 'Enable transparent background';
      _saveUndoState(context, actionDescription);
      widget.onToggleCheckerboard(true);
    } else if (shapeName == "TransparentOff") {
      actionDescription = 'Disable transparent background';
      _saveUndoState(context, actionDescription);
      widget.onToggleCheckerboard(false);
    } else {
      actionDescription = 'Change logo shape to $shapeName';
      _saveUndoState(context, actionDescription);
      widget.onToggleCheckerboard(true);
      widget.onShapeSelected(shapeName);
    }

    // Save final state after shape change is applied
    _saveUndoStateDelayed(context, actionDescription);
  }

  void _saveUndoState(BuildContext context, String action) {
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    if (!undoProvider.isUndoRedoInProgress) {
      final currentState = colorProvider.captureCurrentState();
      undoProvider.saveState(action: action, state: currentState);
      print('✅ Saved undo state: $action');
    }
  }

  @override
  void dispose() {
    _undoDebounceTimer?.cancel();
    super.dispose();
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
                        onTap: () => _handleColorSelection(context),
                      ),
                      _TopOption(
                        label: options[1],
                        onTap: () => _handleGradientSelection(context),
                      ),
                      _TopOption(
                        label: options[2],
                        onTap: () => _handleBackgroundSelection(context),
                      ),
                      _TopOption(
                        label: options[3],
                        onTap: () => _handleTextureSelection(context),
                      ),
                      _TopOption(
                        label: options[4],
                        onTap: () => pickImageFromDevice(context),
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
                          onChangeStart: (value) {
                            _captureSliderStartState(context);
                          },
                          onChanged: (val) {
                            setState(() {
                              _opacityValue = val;
                            });
                            widget.onOpacityChanged(_opacityValue);
                          },
                          onChangeEnd: (val) {
                            _handleSliderEndWithUndo(
                              context,
                              'Change background opacity to ${(val * 100).round()}%',
                            );
                          },
                        ),
                      ),
                      Text(
                        "${(_opacityValue * 100).round()}%",
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
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
                          onShapeSelected:
                              (shapeName) => _handleShapeSelection(shapeName),
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
