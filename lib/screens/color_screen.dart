import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:logo_app_flutter/generated/l10n.dart';

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
            List<Color> generateShades(Color base) {
              final hsl = HSLColor.fromColor(base);
              return List.generate(9, (i) {
                final t = (i) / 8.0;
                final lightness = (0.08 + t * 0.84).clamp(0.0, 1.0);
                return hsl.withLightness(lightness).toColor();
              });
            }

            final shades = generateShades(tempColor);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                S.of(context).selectColor,
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
                      children: colorList.map((color) {
                        final isSelected = tempColor == color;
                        return Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              setState(() {
                                tempColor = color;
                              });
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: color,
                              child: isSelected
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Shades lane
                    SizedBox(
                      height: 46,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (ctx, idx) {
                          final c = shades[idx];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => setState(() => tempColor = c),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1.5),
                                    ),
                                  ),
                                  if (tempColor.value == c.value)
                                    Icon(
                                      Icons.check,
                                      color: c.computeLuminance() > 0.6
                                          ? Colors.black
                                          : Colors.white,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemCount: shades.length,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    S.of(context).custom,
                  ),
                  onPressed: () async {
                    final Color? custom = await showDialog(
                      context: context,
                      builder: (ctx2) {
                        Color current = tempColor;
                        final controller = TextEditingController(
                            text:
                                '#${current.value.toRadixString(16).padLeft(8, '0').toUpperCase()}');
                        return StatefulBuilder(builder: (c3, setState3) {
                          return AlertDialog(
                            title: Text(
                              S.of(context).custom,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ColorPicker(
                                  pickerColor: current,
                                  onColorChanged: (col) {
                                    setState3(() {
                                      current = col;
                                      controller.text =
                                          '#${current.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                                    });
                                  },
                                  showLabel: false,
                                  pickerAreaHeightPercent: 0.6,
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                      labelText: 'Hex (eg. #FF00FF)'),
                                  onChanged: (val) {
                                    final v = val.replaceAll('#', '').trim();
                                    if (v.length == 6 || v.length == 8) {
                                      try {
                                        final parsed = int.parse(v, radix: 16);
                                        setState3(() {
                                          current = Color(v.length == 6
                                              ? 0xFF000000 | parsed
                                              : parsed);
                                        });
                                      } catch (_) {}
                                    }
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(ctx2).pop(),
                                  child: Text(
                                    S.of(context).cancel,
                                  )),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx2).pop(current),
                                  child: Text(
                                    S.of(context).select,
                                  )),
                            ],
                          );
                        });
                      },
                    );
                    if (custom != null) setState(() => tempColor = custom);
                  },
                ),
                TextButton(
                  child: Text(
                    S.of(context).cancel,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    S.of(context).select,
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
        title: Text(
          S.of(context).selectColor,
        ),
        leading: const BackButton(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(colorGrid.length, (index) {
              final c = colorGrid[index];
              final isSelected = selectedProviderColor != null &&
                  c.value == selectedProviderColor.value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = c;
                  });
                  Provider.of<SelectedColorProvider>(
                    context,
                    listen: false,
                  ).setColor(c);

                  Navigator.of(context).pop();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(width: 50, height: 50, color: c),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: c.computeLuminance() > 0.6
                            ? Colors.black
                            : Colors.white,
                        size: 26,
                      ),
                  ],
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
            label: Text(S.of(context).pickAnother),
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
              Text(
                S.of(context).currentColor,
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
