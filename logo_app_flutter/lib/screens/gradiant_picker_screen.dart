import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
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
    Color? picked = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Select Color"),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: isStartColor ? startColor : endColor,
                onColorChanged: (color) {
                  Navigator.of(context).pop(color);
                },
              ),
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

  @override
  Widget build(BuildContext context) {
    // ✅ Linear → use GradientRotation(angle)
    // ✅ Radial → use Alignment from angle
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
              center: Alignment(
                math.cos(angle), // X direction
                math.sin(angle), // Y direction
              ),
              radius: 1.0,
            );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Custom Gradient",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gradient Type",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isLinear = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isLinear
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isLinear ? Colors.orange : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Linear",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => setState(() => isLinear = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            // color: !isLinear ? Colors.orange.shade50 : Colors.white,
                            // border: Border.all(
                            //   color: !isLinear ? Colors.orange : Colors.grey.shade300,
                            //   width: 2,
                            // ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                !isLinear
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: !isLinear ? Colors.orange : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Radial",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Angle controls
            if (isLinear)
              // 👉 Linear → show angle buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gradient Angle",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Padding(
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
                  ],
                ),
              )
            else
              // 👉 Radial → show slider (angle rotates gradient center)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gradient Angle",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.my_location, color: Colors.orange),
                        Expanded(
                          child: Slider(
                            value: angle,
                            min: 0,
                            max: 6.28, // 2π radian full circle
                            activeColor: Colors.orange,
                            onChanged: (val) {
                              setState(() => angle = val);
                            },
                          ),
                        ),
                      ],
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

  Widget _choiceChip(String text, bool selected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      selectedColor: Colors.orange.shade200,
      onSelected: (_) => onSelected(),
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
