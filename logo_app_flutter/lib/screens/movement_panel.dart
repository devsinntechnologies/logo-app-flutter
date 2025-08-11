

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:provider/provider.dart';
// import 'selected_color_provider.dart'; // <-- import your provider

class MovementPanel extends StatefulWidget {
  final Function(String) onDirectionPressed;
  final VoidCallback onDuplicatePressed;
  final bool isVisible;

  final int? selectedElementId; // 🔹 Added for element targeting

  const MovementPanel({
    Key? key,
    required this.onDirectionPressed,
    required this.onDuplicatePressed,
    required this.isVisible,
    this.selectedElementId, // 🔹 New param
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.layers_outlined, color: Colors.black),
                  ),
                  const Text("Up Layer", style: TextStyle(color: Colors.black45)),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.layers_outlined, color: Colors.black),
                  ),
                  const Text("Down Layer", style: TextStyle(color: Colors.black45)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: widget.onDuplicatePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Duplicate", style: TextStyle(color: Colors.white)),
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
    return const Center(child: Text("Outline"));
  }

  Widget _build3DTab() {
    return const Center(child: Text("3D"));
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


