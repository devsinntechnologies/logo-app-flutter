// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:provider/provider.dart';
// / import 'selected_color_provider.dart'; // <-- import your provider

class MovementPanel extends StatefulWidget {
  final Function(String) onDirectionPressed;
  final VoidCallback onDuplicatePressed;
  final bool isVisible;
  final VoidCallback onBringToFrontPressed; // Up Layer
  final VoidCallback onSendToBackPressed; // Down Layer

  final int? selectedElementId; // 🔹 Added for element targeting

  const MovementPanel({
    Key? key,
    required this.onDirectionPressed,
    required this.onDuplicatePressed,
    required this.isVisible,
    required this.onBringToFrontPressed,
    required this.onSendToBackPressed,
    this.selectedElementId,
  }) : super(key: key);

  @override
  State<MovementPanel> createState() => _MovementPanelState();
}

class _MovementPanelState extends State<MovementPanel>
    with SingleTickerProviderStateMixin {
  Timer? _timer;

  void _startMoving(String direction) {
    _stopMoving(); // Pehle koi purana timer stop karo
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      widget.onDirectionPressed(direction);
    });
  }

  void _stopMoving() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DefaultTabController(
            length: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  indicatorColor: Colors.black45,
                  labelColor: Colors.black45,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Controls'),
                    Tab(text: 'Colors'),
                    Tab(text: 'Outlines'),
                    Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Tab(text: '3D'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 180,
                  child: TabBarView(
                    children: [
                      _buildControlsTab(),
                      _buildColorsTab(context), // 🔹 context added
                      _buildOutlinesTab(),
                      _build3DTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  _buildDirectionButton(
                    icon: Icons.keyboard_arrow_up,
                    direction: 'up',
                    tooltip: 'Up',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDirectionButton(
                        icon: Icons.keyboard_arrow_left,
                        direction: 'left',
                        tooltip: 'Left',
                      ),
                      const SizedBox(width: 16),
                      _buildDirectionButton(
                        icon: Icons.keyboard_arrow_right,
                        direction: 'right',
                        tooltip: 'Right',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDirectionButton(
                    icon: Icons.keyboard_arrow_down,
                    direction: 'down',
                    tooltip: 'Down',
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: widget.onBringToFrontPressed,

                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.layers_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Text(
                    "Up Layer",
                    style: TextStyle(color: Colors.black45),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                      onTap: widget.onSendToBackPressed,

                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.layers_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Text(
                    "Down Layer",
                    style: TextStyle(color: Colors.black45),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    print(
                      'Duplicate button pressed for element ${widget.selectedElementId}',
                    );
                    widget.onDuplicatePressed();
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Duplicate",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildColorBox(context, Colors.red),
          _buildColorBox(context, Colors.green),
          _buildColorBox(context, Colors.blue),
          _buildColorBox(context, Colors.yellow),
          _buildColorBox(context, Colors.purple),
          _buildColorBox(context, Colors.orange),
          _buildColorBox(context, Colors.pink),
          _buildColorBox(context, Colors.teal),
          _buildColorBox(context, Colors.brown),
          _buildColorBox(context, Colors.grey),
        ],
      ),
    );
  }
  Widget _buildOutlinesTab() {
  return Consumer<SelectedColorProvider>(
    builder: (context, provider, _) {
      if (widget.selectedElementId == null) {
        return const Center(child: Text("Select an element first"));
      }

      final elementId = widget.selectedElementId!;
      double outlineThickness = provider.getOutlineWidth(elementId);
      Color outlineColor = provider.getOutlineColor(elementId);

      final colors = [
        Colors.orange,
        Colors.black,
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.yellow,
        Colors.lightBlue,
        Colors.pink,
        Colors.grey,
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Slider for outline thickness
            Row(
              children: [
                const Text("Outline",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.orange,
                      thumbColor: Colors.orange,
                    ),
                    child: Slider(
                      min: 0,
                      max: 10,
                      divisions: 10,
                      value: outlineThickness,
                      onChanged: (value) {
                        provider.setOutlineWidth(elementId, value);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    outlineThickness.toStringAsFixed(0),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Outline colors
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      provider.setOutlineColor(elementId, color);
                      print("Outline color for $elementId: $color");
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: outlineColor == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  // Widget _buildOutlinesTab() {
  //   Color outlineColor = Colors.black;
  //   double outlineThickness = 0.0;

  //   return StatefulBuilder(
  //     builder: (context, setState) {
  //       final colors = [
  //         Colors.orange,
  //         Colors.black,
  //         Colors.red,
  //         Colors.green,
  //         Colors.blue,
  //         Colors.yellow,
  //         Colors.lightBlue,
  //         Colors.pink,
  //         Colors.grey,
  //       ];

  //       return Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             // Slider on top
  //             Padding(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 12.0,
  //                 vertical: 10,
  //               ),
  //               child: Row(
  //                 children: [
  //                   const Text(
  //                     "Outline",
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                   SliderTheme(
  //                     data: SliderTheme.of(context).copyWith(
  //                       activeTrackColor: Colors.orange,
  //                       // inactiveTrackColor: Colors.orange.withOpacity(0.3),
  //                       thumbColor: Colors.orange,
  //                       // overlayColor: Colors.orange.withOpacity(0.2),
  //                     ),
  //                     child: Expanded(
  //                       child: Slider(
  //                         min: 0,
  //                         max: 10,
  //                         divisions: 10,
  //                         value: outlineThickness,
  //                         onChanged: (value) {
  //                           setState(() {
  //                             outlineThickness = value;
  //                           });
  //                           print('Outline thickness: $outlineThickness');
  //                         },
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     width: 35,
  //                     child: Text(
  //                       outlineThickness.toStringAsFixed(0),
  //                       textAlign: TextAlign.center,
  //                       style: const TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             const SizedBox(height: 15),

  //             // Colors + Icons in one horizontal line
  //             SizedBox(
  //               height: 50,

  //               child: ListView(
  //                 scrollDirection: Axis.horizontal,
  //                 children: [
  //                   Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.orange,
  //                       shape: BoxShape.circle,
  //                     ),
  //                     child: const Icon(
  //                       Icons.edit,
  //                       size: 30,
  //                       color: Colors.white,
  //                     ),
  //                   ),

  //                   SizedBox(width: 10),
  //                   Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.orange,
  //                       shape: BoxShape.circle,
  //                     ),
  //                     child: Icon(
  //                       Icons.color_lens,
  //                       size: 30,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                   // Colors
  //                   ...colors.map((color) {
  //                     return GestureDetector(
  //                       onTap: () {
  //                         setState(() {
  //                           outlineColor = color;
  //                         });
  //                         print('Selected outline color: $outlineColor');
  //                       },
  //                       child: Container(
  //                         margin: const EdgeInsets.symmetric(horizontal: 6),
  //                         width: 30,
  //                         height: 30,
  //                         decoration: BoxDecoration(
  //                           color: color,
  //                           shape: BoxShape.circle,
  //                           border: Border.all(
  //                             color:
  //                                 outlineColor == color
  //                                     ? Colors.black
  //                                     : Colors.transparent,
  //                             width: 2,
  //                           ),
  //                         ),
  //                       ),
  //                     );
  //                   }).toList(),

  //                   const SizedBox(width: 12),

  //                   // Icons
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _build3DTab() {
    double slider1 = 0;
    double slider2 = 0;
    double slider3 = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        Widget buildSlider(
          String label,
          double value,
          ValueChanged<double> onChanged,
        ) {
          return Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  "$label°",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.orange,
                    inactiveTrackColor: Colors.orange.withOpacity(0.3),
                    thumbColor: Colors.orange,
                    overlayColor: Colors.orange.withOpacity(0.2),
                  ),
                  child: Slider(
                    min: 0,
                    max: 360,
                    divisions: 360,
                    value: value,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSlider(slider1.toStringAsFixed(0), slider1, (v) {
                setState(() => slider1 = v);
                print("Slider 1: $slider1");
              }),
              buildSlider(slider2.toStringAsFixed(0), slider2, (v) {
                setState(() => slider2 = v);
                print("Slider 2: $slider2");
              }),
              buildSlider(slider3.toStringAsFixed(0), slider3, (v) {
                setState(() => slider3 = v);
                print("Slider 3: $slider3");
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorBox(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        if (widget.selectedElementId != null) {
          final provider = Provider.of<SelectedColorProvider>(
            context,
            listen: false,
          );

          final elementId = widget.selectedElementId!;

          // Har element ka color uske type ke hisaab se set karo
          if (elementId == 0) {
            provider.setShapeColor(color);
            provider.setSvgColorOverridden(true);
          } else if (elementId == 1) {
            provider.setCompanyTextColor(color);
          } else if (elementId == 2) {
            provider.setSloganColor(color);
          } else {
            // Baaki sab custom elements
            provider.setOverrideColorForElement(elementId, color);
          }

          print("Changing color of element $elementId to $color");
        }
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required String direction,
    required String tooltip,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) => _startMoving(direction),
      onLongPressEnd: (_) => _stopMoving(),
      onTap: () => widget.onDirectionPressed(direction), // single step move
      child: Tooltip(
        message: tooltip,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopMoving();
    super.dispose();
  }
}
