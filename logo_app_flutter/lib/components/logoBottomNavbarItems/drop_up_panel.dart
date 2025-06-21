import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/logoBottomNavbarItems/shape_selector_widget.dart';

class DropUpPanel extends StatefulWidget {
  final VoidCallback onClose;
  final Function(bool) onToggleCheckerboard;
  final Function(double) onOpacityChanged;

  const DropUpPanel({
    super.key,
    required this.onClose,
    required this.onToggleCheckerboard,
    required this.onOpacityChanged,
  });

  @override
  State<DropUpPanel> createState() => _DropUpPanelState();
}

class _DropUpPanelState extends State<DropUpPanel> {
  double _opacityValue = 1.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 70,
      left: 0,
      right: 0,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row of options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _TopOption(label: 'Color'),
                  _TopOption(label: 'Gradient'),
                  _TopOption(label: 'Background'),
                  _TopOption(label: 'Texture'),
                  _TopOption(label: 'Image'),
                ],
              ),
              const SizedBox(height: 13),

              // Opacity slider
              Row(
                children: [
                  const Icon(Icons.opacity, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      activeColor: Colors.yellow,
                      value: _opacityValue,
                      min: 0,
                      max: 1,
                      onChanged: (val) {
                        setState(() {
                          _opacityValue = val;
                        });
                        widget.onOpacityChanged(_opacityValue); // notify parent
                      },
                    ),
                  ),
                  Text(
                    "${(_opacityValue * 100).round()}%",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Shape selector with Transparent option
              SizedBox(
                height: 50,
                child: ShapeSelectorWidget(
                  onShapeSelected: (shapeName) {
                    if (shapeName == "Transparent") {
                      widget.onToggleCheckerboard(true); // Turn ON
                    } else if (shapeName == "TransparentOff") {
                      widget.onToggleCheckerboard(false); // Turn OFF
                    }
                    // You can also handle other shapes here if needed
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopOption extends StatelessWidget {
  final String label;
  const _TopOption({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
