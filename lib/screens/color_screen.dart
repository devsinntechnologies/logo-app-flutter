import 'package:flutter/material.dart';
import 'package:logo_app_flutter/fragments/theme_toggle_widget.dart';
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
  final List<Color> colorList = [
    Colors.white,
    Colors.red,
    Colors.pinkAccent,
    Colors.purple,
    Colors.orangeAccent,
    Colors.teal,
    Colors.lightBlueAccent,
    Colors.black,
    Colors.grey,
    Colors.yellow,
    Colors.cyanAccent,
  ];
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
  void _openColorPickerDialog(BuildContext context) {
    Color tempColor = selectedColor; // Pehle se selected color

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Select a Color',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Grid of colors
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          colorList.map((color) {
                            final isSelected = tempColor == color;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  tempColor = color;
                                });
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: color,
                                child:
                                    isSelected
                                        ? const Icon(
                                          Icons.done,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // ),
                  // ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'SELECT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
        actions: [const ThemeToggleWidget(), const SizedBox(width: 8)],
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

                  Navigator.of(context).pop();
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
            onPressed: () {
              _openColorPickerDialog(context);
            },
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
