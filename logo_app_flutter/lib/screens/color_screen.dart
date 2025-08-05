import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:provider/provider.dart';
// adjust path as needed

class ColorScreen extends StatefulWidget {
  const ColorScreen({super.key});

  @override
  State<ColorScreen> createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  Color selectedColor = Colors.purple; 

  final List<Color> colorGrid = [
    Colors.white,
    Colors.red,
    Colors.pinkAccent,
    Colors.purple,
    Colors.deepPurple,
    Colors.pink,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.deepOrange,
    Colors.purple,
    Colors.indigo,
    Colors.orange,
    Colors.pinkAccent,
    Colors.deepPurple,
    Colors.blue,
    Colors.blueAccent,
    Colors.cyan,
    Colors.teal,
    Colors.lightBlueAccent,
  ];

  void _openColorPickerDialog() {
    Color tempColor = selectedColor;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
      
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                setState(() {
                  tempColor = color;
                });
              },
              
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('SELECT'),
              onPressed: () {
                Provider.of<SelectedColorProvider>(
                  context,
                  listen: false,
                ).setColor(tempColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedProviderColor =
        Provider.of<SelectedColorProvider>(context).selectedColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Color"),
        leading: const BackButton(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(colorGrid.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = colorGrid[index];
                  });
                  Provider.of<SelectedColorProvider>(
                    context,
                    listen: false,
                  ).setColor(colorGrid[index]);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  color: colorGrid[index],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openColorPickerDialog,
            icon: const Icon(Icons.palette),
            label: const Text("PICK ANOTHER"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Container(height: 80, width: 80, color: selectedProviderColor),
              const SizedBox(height: 18),
              const Text(
                "Current Color",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
