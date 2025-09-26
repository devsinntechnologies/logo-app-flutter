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

  void pickColor(bool isStartColor) async {
    Color tempColor = isStartColor ? startColor : endColor;

    Color? picked = await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                  builder: (context) => AlertDialog(
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
                        onPressed: () =>
                            Navigator.of(context).pop(tempColor),
                        child: const Text("Done"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
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
      setState(() {
        if (isStartColor) {
          startColor = picked;
        } else {
          endColor = picked;
        }
      });
    }
  }

  void _onGradientSelectedWithUndo(Gradient gradient) {
    final colorProvider =
        Provider.of<SelectedColorProvider>(context, listen: false);
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    final currentState = colorProvider.captureCurrentState();
    undoProvider.saveState(
      action: 'Apply ${_getGradientType(gradient)} gradient',
      state: currentState,
    );

    colorProvider.setGradient(gradient);
  }

  void _onGradientRemovedWithUndo() {
    final colorProvider =
        Provider.of<SelectedColorProvider>(context, listen: false);
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    final currentState = colorProvider.captureCurrentState();
    undoProvider.saveState(
      action: 'Remove gradient background',
      state: currentState,
    );

    colorProvider.removeGradient();
  }

  void _onGradientColorsChangedWithUndo(List<Color> colors) {
    final colorProvider =
        Provider.of<SelectedColorProvider>(context, listen: false);
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    final currentState = colorProvider.captureCurrentState();
    undoProvider.saveState(
      action: 'Change gradient colors',
      state: currentState,
    );

    final newGradient = LinearGradient(colors: colors);
    colorProvider.setGradient(newGradient);
  }

  String _getGradientType(Gradient gradient) {
    if (gradient is LinearGradient) return 'linear';
    if (gradient is RadialGradient) return 'radial';
    if (gradient is SweepGradient) return 'sweep';
    return 'gradient';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradient = isLinear
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
                    setState(() => isLinear = true);
                  }),
                  const SizedBox(height: 12),
                  _radioOption("Radial", !isLinear, () {
                    setState(() => isLinear = false);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Gradient Angle
            isLinear
                ? _themedSection(
                    title: "Gradient Angle",
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _angleButton(Icons.arrow_downward, 0),
                          _angleButton(Icons.arrow_forward, 1.57),
                          _angleButton(Icons.arrow_upward, 3.14),
                          _angleButton(Icons.arrow_back, 4.71),
                        ],
                      ),
                    ),
                  )
                : _themedSection(
                    title: "Gradient Angle",
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
                          ),
                        ),
                      ],
                    ),
                  ),

            const Spacer(),

            // Apply Button
            GestureDetector(
              onTap: () {
                Provider.of<SelectedColorProvider>(
                  context,
                  listen: false,
                ).setGradient(gradient);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "APPLY",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _colorCircle(String label, Color color, VoidCallback onTap) {
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
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _radioOption(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? Colors.orange : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _angleButton(IconData icon, double val) {
    return GestureDetector(
      onTap: () => setState(() => angle = val),
      child: CircleAvatar(
        backgroundColor: angle == val ? Colors.orange : Colors.orange.shade100,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
