// ignore_for_file: public_member_api_docs, sort_constructors_first, use_super_parameters, use_build_context_synchronously
// import 'dart:io';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:logo_app_flutter/components/logoBottomNavbarItems/shape_selector_widget.dart';
// import 'package:logo_app_flutter/provider/selected_color_provider.dart';
// import 'package:logo_app_flutter/screens/color_screen.dart';
// import 'package:logo_app_flutter/screens/gradiant_picker_screen.dart';
// import 'package:logo_app_flutter/screens/select_bg_images.dart';
// import 'package:logo_app_flutter/screens/select_texture_images.dart';
// import 'package:logo_app_flutter/utils/theme_colors.dart';
// import 'package:provider/provider.dart';

// class DropUpPanel extends StatefulWidget {
//   final VoidCallback onClose;
//   final Function(bool) onToggleCheckerboard;
//   final Function(double) onOpacityChanged;
//   final Function(String) onShapeSelected;
//   final VoidCallback? onSaveState; // Main widget's _saveState

//   const DropUpPanel({
//     super.key,
//     required this.onClose,
//     required this.onToggleCheckerboard,
//     required this.onOpacityChanged,
//     required this.onShapeSelected,
//     this.onSaveState,
//   });

//   @override
//   State<DropUpPanel> createState() => _DropUpPanelState();
// }

// class _DropUpPanelState extends State<DropUpPanel> {
//   String? selectedShapeName;
//   double _opacityValue = 1.0;

//   Future<void> pickImageFromDevice(BuildContext context) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       final file = File(pickedFile.path);
//       final bytes = await pickedFile.readAsBytes();
//       final codec = await ui.instantiateImageCodec(bytes);
//       final frame = await codec.getNextFrame();
//       final image = frame.image;

//       final provider = Provider.of<SelectedColorProvider>(context, listen: false);
//       provider.setBackgroundImage(image, file);

//       // Push new state to main widget undo stack
//       widget.onSaveState?.call();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<SelectedColorProvider>(context);

//     return Material(
//       borderRadius: BorderRadius.circular(12),
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // --- Header Close Button ---
//             Container(
//               height: 30,
//               color: Colors.grey.shade200,
//               child: Align(
//                 alignment: Alignment.topRight,
//                 child: InkWell(
//                   onTap: widget.onClose,
//                   child: Container(
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(9),
//                         topRight: Radius.circular(9),
//                       ),
//                     ),
//                     child: Icon(
//                       Icons.keyboard_double_arrow_down_sharp,
//                       size: 25,
//                       color: ThemeColors.purple,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // --- Top Options ---
//             Container(
//               color: Colors.grey.shade100,
//               height: 30,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _TopOption(
//                     label: 'Color',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => ColorScreen()),
//                       ).then((_) => widget.onSaveState?.call());
//                     },
//                   ),
//                   _TopOption(
//                     label: 'Gradient',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => GradientPickerScreen()),
//                       ).then((_) => widget.onSaveState?.call());
//                     },
//                   ),
//                   _TopOption(
//                     label: 'Background',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => SelectBgImages()),
//                       ).then((_) => widget.onSaveState?.call());
//                     },
//                   ),
//                   _TopOption(
//                     label: 'Texture',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => SelectTextureImages()),
//                       ).then((_) => widget.onSaveState?.call());
//                     },
//                   ),
//                   _TopOption(
//                     label: 'Image',
//                     onTap: () {
//                       pickImageFromDevice(context);
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 8),

//             // --- Opacity Slider ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: Row(
//                 children: [
//                   const Icon(Icons.opacity, color: Colors.grey),
//                   const SizedBox(width: 5),
//                   Expanded(
//                     child: SliderTheme(
//                       data: SliderTheme.of(context).copyWith(
//                         trackHeight: 2,
//                         thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
//                       ),
//                       child: Slider(
//                         activeColor: Colors.yellow,
//                         value: _opacityValue,
//                         min: 0,
//                         max: 1,
//                         onChanged: (val) {
//                           setState(() => _opacityValue = val);
//                           widget.onOpacityChanged(_opacityValue);
//                           widget.onSaveState?.call(); // Save for undo
//                         },
//                       ),
//                     ),
//                   ),
//                   Text(
//                     "${(_opacityValue * 100).round()}%",
//                     style: const TextStyle(color: Colors.black),
//                   ),
//                 ],
//               ),
//             ),

//             // --- Shape Selector ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: SizedBox(
//                 height: 50,
//                 child: ShapeSelectorWidget(
//                   onShapeSelected: (shapeName) {
//                     selectedShapeName = shapeName;

//                     if (shapeName == "Transparent") {
//                       widget.onToggleCheckerboard(true);
//                     } else if (shapeName == "TransparentOff") {
//                       widget.onToggleCheckerboard(false);
//                     } else {
//                       widget.onToggleCheckerboard(true);
//                       widget.onShapeSelected(shapeName);
//                     }

//                     widget.onSaveState?.call(); // Save for undo
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _TopOption extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;

//   const _TopOption({required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           color: ThemeColors.purple,
//           fontWeight: FontWeight.normal,
//         ),
//       ),
//     );
//   }
// }

// // ignore_for_file: public_member_api_docs, sort_constructors_first, use_super_parameters, use_build_context_synchronously
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logo_app_flutter/components/logoBottomNavbarItems/shape_selector_widget.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/screens/color_screen.dart';
import 'package:logo_app_flutter/screens/gradiant_picker_screen.dart';
import 'package:logo_app_flutter/screens/select_bg_images.dart';
import 'package:logo_app_flutter/screens/select_texture_images.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:provider/provider.dart';

class DropUpPanel extends StatefulWidget {
  final VoidCallback onClose;
  final Function(bool) onToggleCheckerboard;
  final Function(double) onOpacityChanged;
  final Function(String) onShapeSelected;
  final VoidCallback? onSaveState;

  const DropUpPanel({
    super.key,
    required this.onClose,
    required this.onToggleCheckerboard,
    required this.onOpacityChanged,
    required this.onShapeSelected,
    this.onSaveState,
  });

  @override
  State<DropUpPanel> createState() => _DropUpPanelState();
}

class _DropUpPanelState extends State<DropUpPanel> {
  Future<void> pickImageFromDevice(BuildContext context) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Image selection from gallery is not supported on Web.')),
      );
      return;
    }
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

      // Save state for undo/redo
      widget.onSaveState?.call();
    }
  }

  String? selectedShapeName;
  int selectedIndex = 0;
  Color _baseColor = Colors.red; // Default palette color

  double _opacityValue = 1.0;

  @override
  Widget build(BuildContext context) {
    final List<String> options = [
      S.of(context).color,
      S.of(context).gradient,
      S.of(context).background,
      S.of(context).texture,
      S.of(context).image,
    ];
    return Material(
      // elevation: 10,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 30,
              color: Colors.grey.shade200,
              child: Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: widget.onClose,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(9),
                        topRight: Radius.circular(9),
                      ),
                    ),
                    child: Icon(
                      Icons.keyboard_double_arrow_down_sharp,
                      size: 25,
                      color: ThemeColors.purple,
                    ),
                  ),
                ),
              ),
            ),

            Container(
              color: Colors.grey.shade100,
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TopOption(
                    label: options[0],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ColorScreen()),
                      );
                      // Save state after returning and trigger UI update
                      widget.onSaveState?.call();
                    },
                  ),
                  _TopOption(
                    label: options[1],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GradientPickerScreen(),
                        ),
                      );
                      // Save state after returning and trigger UI update
                      widget.onSaveState?.call();
                    },
                  ),
                  _TopOption(
                    label: options[2],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectBgImages(),
                        ),
                      );
                      // Save state after returning and trigger UI update
                      widget.onSaveState?.call();
                    },
                  ),
                  _TopOption(
                    label: options[3],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectTextureImages(),
                        ),
                      );
                      // Save state after returning and trigger UI update
                      widget.onSaveState?.call();
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
            ),

            const SizedBox(height: 8),

            // Opacity slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Icon(Icons.opacity, color: Colors.grey),
                  const SizedBox(width: 5),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                      ),
                      child: Slider(
                        activeColor: Colors.yellow,
                        value: _opacityValue,
                        min: 0,
                        max: 1,
                        onChanged: (val) {
                          setState(() {
                            _opacityValue = val;
                          });
                          widget.onOpacityChanged(_opacityValue);
                        },
                        onChangeEnd: (val) {
                          widget.onSaveState?.call();
                        },
                      ),
                    ),
                  ),
                  Text(
                    "${(_opacityValue * 100).round()}%",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 10),

            // Shape selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                height: 50,
                child: ShapeSelectorWidget(
                  onShapeSelected: (shapeName) {
                    if (shapeName == "Transparent") {
                      widget.onToggleCheckerboard(true);
                    } else if (shapeName == "TransparentOff") {
                      widget.onToggleCheckerboard(false);
                    } else {
                      widget.onToggleCheckerboard(true);
                      widget.onShapeSelected(shapeName);
                    }

                    widget.onSaveState?.call(); // Save AFTER shape change
                  },
                ),
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
        style: const TextStyle(
          fontSize: 12,
          color: ThemeColors.purple,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
