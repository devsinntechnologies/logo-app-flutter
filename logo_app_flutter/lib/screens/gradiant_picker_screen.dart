// ignore_for_file: prefer_const_constructors
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
  Color startColor = Colors.blue;
  Color endColor = Colors.purple;
  double angle = 0;
  bool isLinear = true;

  void pickColor(bool isStartColor) async {
    Color? picked = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Color"),
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
    final gradient = isLinear
        ? LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [startColor, endColor],
            transform: GradientRotation(angle),
          )
        : RadialGradient(
            colors: [startColor, endColor],
          );

    return Scaffold(
      appBar: AppBar(
        title: Text('Gradient Picker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Box
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: gradient,
              ),
            ),
            SizedBox(height: 20),
            // Start & End Color Pickers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: ()=>pickColor(true),
                  child: Text('Start Color'),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      final temp = startColor;
                      startColor = endColor;
                      endColor = temp;
                    });
                  },
                  icon: Icon(Icons.swap_horiz),
                ),
                ElevatedButton(
                  onPressed: () => pickColor(false),
                  child: Text('End Color'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Gradient Type
            Column(
              children: [
                Text('Gradient Type:'),
                SizedBox(height: 10),
                ChoiceChip(
                  label: Text('Linear'),
                  selected: isLinear,
                  onSelected: (val) => setState(() => isLinear = true),
                ),
                SizedBox(height: 10),
                ChoiceChip(
                  label: Text('Radial'),
                  selected: !isLinear,
                  onSelected: (val) => setState(() => isLinear = false),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Angle Slider
            Text('Gradient Angle: ${angle.toStringAsFixed(2)} rad'),
            Slider(
              min: 0,
              max: 6.28,
              value: angle,
              onChanged: (val) => setState(() => angle = val),
            ),
            Spacer(),
            // Apply Button
            GestureDetector(
  onTap: () {
    Provider.of<SelectedColorProvider>(context, listen: false)
        .setGradient(gradient);
    Navigator.pop(context); 
  },
  child: Ink(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Text(
        'Apply',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
)


          ],
        ),
      ),
    );
  }
}


