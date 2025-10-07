import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:provider/provider.dart';

class GradientPickerScreen extends StatefulWidget {
  const GradientPickerScreen({super.key});

  @override
  State<GradientPickerScreen> createState() => _GradientPickerScreenState();
}

class _GradientPickerScreenState extends State<GradientPickerScreen> {
  Color startColor = Colors.pink.shade200;
  Color endColor = Colors.white;
  double angle = 0;
  bool isLinear = true;

  void _saveUndoState(String action) {
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

  void pickColor(bool isStartColor) async {
    Color tempColor = isStartColor ? startColor : endColor;

    Color? picked = await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Select Color"),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BlockPicker(
                          pickerColor: tempColor,
                          onColorChanged: (color) {
                            setState(() => tempColor = color);
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Color? customPicked = await showDialog<Color>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Custom Color Picker"),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: tempColor,
                                    onColorChanged: (color) {
                                      tempColor = color;
                                    },
                                    showLabel: true,
                                    pickerAreaHeightPercent: 0.8,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(
                                          context,
                                        ).pop(tempColor),
                                    child: const Text("Done"),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text("Cancel"),
                                  ),
                                ],
                              ),
                        );
                        if (customPicked != null) {
                          setState(() => tempColor = customPicked);
                        }
                      },
                      child: const Text("Custom"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(tempColor),
                      child: const Text("Select"),
                    ),
                  ],
                ),
          ),
    );

    if (picked != null) {
      final colorName = isStartColor ? 'start' : 'end';
      _saveUndoState('Change gradient $colorName color');

      setState(() {
        if (isStartColor) {
          startColor = picked;
        } else {
          endColor = picked;
        }
      });
    }
  }

  void _changeGradientType(bool linear) {
    if (linear != isLinear) {
      final typeName = linear ? 'linear' : 'radial';
      _saveUndoState('Change gradient type to $typeName');

      setState(() {
        isLinear = linear;
      });
    }
  }

  void _changeGradientAngle(double newAngle) {
    _saveUndoState(
      'Change gradient angle to ${(newAngle * 180 / math.pi).toInt()}°',
    );

    setState(() {
      angle = newAngle;
    });
  }

  String _getGradientType(Gradient gradient) {
    if (gradient is LinearGradient) return 'linear';
    if (gradient is RadialGradient) return 'radial';
    if (gradient is SweepGradient) return 'sweep';
    return 'gradient';
  }

  void _applyGradient() {
    final gradient =
        isLinear
            ? LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              transform: GradientRotation(angle),
            )
            : RadialGradient(
              colors: [startColor, endColor],
              center: Alignment(math.cos(angle), math.sin(angle)),
              radius: 1.0,
            );

    _saveUndoState('Apply ${_getGradientType(gradient)} gradient');

    Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    ).setGradient(gradient);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_getGradientType(gradient).capitalize()} gradient applied',
        ),
        duration: const Duration(milliseconds: 1000),
        backgroundColor: Colors.green.withOpacity(0.8),
      ),
    );
  }

  void _removeGradient() {
    _saveUndoState('Remove background gradient');

    Provider.of<SelectedColorProvider>(context, listen: false).removeGradient();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gradient removed'),
        duration: Duration(milliseconds: 1000),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final gradient =
        isLinear
            ? LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              transform: GradientRotation(angle),
            )
            : RadialGradient(
              colors: [startColor, endColor],
              center: Alignment(math.cos(angle), math.sin(angle)),
              radius: 1.0,
            );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gradient Picker'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview box
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: gradient,
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _colorCircle("Start", startColor, () => pickColor(true)),
                const Icon(Icons.swap_horiz, size: 28),
                _colorCircle("End", endColor, () => pickColor(false)),
              ],
            ),

            const SizedBox(height: 15),

            // Gradient Type
            _themedSection(
              title: "Gradient Type",
              child: Column(
                children: [
                  _radioOption("Linear", isLinear, () {
                    _changeGradientType(true);
                  }),
                  const SizedBox(height: 12),
                  _radioOption("Radial", !isLinear, () {
                    _changeGradientType(false);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Gradient Angle
            isLinear
                ? _themedSection(
                  title: "Gradient Direction",
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _angleButton(Icons.arrow_downward, 0, "Top to Bottom"),
                        _angleButton(
                          Icons.arrow_forward,
                          1.57,
                          "Left to Right",
                        ),
                        _angleButton(Icons.arrow_upward, 3.14, "Bottom to Top"),
                        _angleButton(Icons.arrow_back, 4.71, "Right to Left"),
                      ],
                    ),
                  ),
                )
                : _themedSection(
                  title: "Gradient Center",
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.orange),
                      Expanded(
                        child: Slider(
                          value: angle,
                          min: 0,
                          max: 6.28,
                          activeColor: Colors.orange,
                          onChanged: (val) {
                            setState(() => angle = val);
                          },
                          onChangeEnd: (val) {
                            _changeGradientAngle(val);
                          },
                        ),
                      ),
                      Text(
                        '${(angle * 180 / math.pi).toInt()}°',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

            const Spacer(),

            // Action Buttons
            Row(
              children: [
                // Remove Gradient Button
                Expanded(
                  child: GestureDetector(
                    onTap: _removeGradient,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "REMOVE",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Apply Button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _applyGradient,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "APPLY GRADIENT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _themedSection({required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _colorCircle(String label, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: theme.dividerColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _radioOption(String text, bool selected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? Colors.orange : theme.iconTheme.color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color:
                  selected ? Colors.orange : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _angleButton(IconData icon, double val, String tooltip) {
    final theme = Theme.of(context);
    final isSelected = angle == val;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => _changeGradientAngle(val),
        child: CircleAvatar(
          backgroundColor:
              isSelected ? Colors.orange : theme.colorScheme.surface,
          child: Icon(
            icon,
            color: isSelected ? Colors.white : theme.iconTheme.color,
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
