import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:provider/provider.dart';

typedef Element3DRotationCallback = void Function(
    int id, double rotationX, double rotationY, double rotationZ);
typedef ElementActionCallback = void Function(int id);

class MovementPanel extends StatefulWidget {
  final VoidCallback? onEditPressed;
  final Function(TextAlign)? onTextAlignChanged;
  final LogoStateData logoState;
  final VoidCallback? onClose;
  final Function(String) onDirectionPressed;
  final VoidCallback onDuplicatePressed;
  final bool isVisible;
  final VoidCallback onBringForwardPressed;
  final VoidCallback onSendBackwardPressed;
  final VoidCallback onBringToFrontPressed;
  final VoidCallback onSendToBackPressed;
  final VoidCallback? onSaveState;

  final int? selectedElementId;

  /// Callback to notify parent about updated logoState
  final Function(LogoStateData)? onLogoStateChanged;
  final Element3DRotationCallback? onElement3DRotationUpdate;
  final ElementActionCallback? onElement3DReset;

  const MovementPanel({
    Key? key,
    this.onTextAlignChanged,
    this.onEditPressed,
    required this.onDirectionPressed,
    required this.onDuplicatePressed,
    required this.isVisible,
    required this.onBringToFrontPressed,
    required this.onSendToBackPressed,
    required this.logoState,
    this.selectedElementId,
    this.onClose,
    this.onLogoStateChanged,
    this.onSaveState,
    this.onElement3DRotationUpdate,
    this.onElement3DReset,
    required this.onBringForwardPressed,
    required this.onSendBackwardPressed,
  }) : super(key: key);

  @override
  State<MovementPanel> createState() => _MovementPanelState();
}

class _MovementPanelState extends State<MovementPanel>
    with SingleTickerProviderStateMixin {
  TextAlign _selectedTextAlign = TextAlign.left;
  Timer? _timer;
  String activeLayerButton = "";
  @override
  void dispose() {
    _stopMoving();
    super.dispose();
  }

  void _startMoving(String direction) {
    _stopMoving();
    // Save state when movement starts
    widget.onSaveState?.call();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      widget.onDirectionPressed(direction);
    });
  }

  void _stopMoving() {
    _timer?.cancel();
    _timer = null;
  }

  // Helper method to save state and update UI
  void _saveStateAndUpdate(VoidCallback updateFunction) {
    widget.onSaveState?.call();
    updateFunction();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          // height: 25,
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: widget.onClose,
              child: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: const Icon(
                  Icons.keyboard_double_arrow_down_sharp,
                  size: 25,
                  color: ThemeColors.purple,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: DefaultTabController(
                length: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 9.0),
                        child: SizedBox(
                          height: 40,
                          child: TabBar(
                            indicatorColor: ThemeColors.purple,
                            labelColor: ThemeColors.purple,
                            unselectedLabelColor: Theme.of(context).hintColor,
                            labelPadding: EdgeInsets.symmetric(vertical: 0),
                            tabs: [
                              Tab(
                                text: S.of(context).controls,
                              ),
                              Tab(
                                text: S.of(context).colors,
                              ),
                              Tab(
                                text: S.of(context).outlines,
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 0),
                                child: Tab(text: '3D'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 190,
                      child: TabBarView(
                        children: [
                          _buildControlsTab(),
                          _buildColorsTab(context),
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
        ),
      ],
    );
  }

  Widget _buildControlsTab() {
    return Consumer<SelectedColorProvider>(
      builder: (context, provider, _) {
        final int selectedElement = widget.selectedElementId ?? 0;
        final order = widget.logoState.elementOrder;

        final int index = widget.selectedElementId == null
            ? -1
            : order.indexOf(widget.selectedElementId!);

        final bool canForward = index != -1 && index < order.length - 1;

        final bool canBackward = index != -1 && index > 0;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // movement arrows column
                  Column(
                    children: [
                      _buildDirectionButton(
                        icon: Icons.arrow_upward,
                        direction: 'up',
                        tooltip: 'Up',
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDirectionButton(
                            icon: Icons.arrow_back,
                            direction: 'left',
                            tooltip: 'Left',
                          ),
                          const SizedBox(width: 40),
                          _buildDirectionButton(
                            icon: Icons.arrow_forward,
                            direction: 'right',
                            tooltip: 'Right',
                          ),
                        ],
                      ),
                      _buildDirectionButton(
                        icon: Icons.arrow_downward,
                        direction: 'down',
                        tooltip: 'Down',
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  // layer controls
                  Row(
                    children: [
                      Column(
                        children: [
                          // Layer Up (Front)
                          layerButton(
                            id: "up",
                            icon: Icons.keyboard_double_arrow_up,
                            label: S.of(context).up,
                            enabled: canForward,
                            onTap: widget.onBringToFrontPressed,
                          ),

                          const SizedBox(height: 10),

                          // Layer Forward (one step)
                          layerButton(
                            id: "down",
                            icon: Icons.keyboard_double_arrow_down,
                            label: S.of(context).down,
                            enabled: canBackward,
                            onTap: widget.onSendToBackPressed,
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // Layer Backward (one step)
                      Column(
                        children: [
                          layerButton(
                            id: "forward",
                            icon: Icons.keyboard_arrow_up,
                            label: S.of(context).forward,
                            enabled: canForward,
                            onTap: widget.onBringForwardPressed,
                          ),
                          const SizedBox(height: 10),

                          // Layer Down (Back)
                          layerButton(
                            id: "backward",
                            icon: Icons.keyboard_arrow_down,
                            label: S.of(context).backward,
                            enabled: canBackward,
                            onTap: widget.onSendBackwardPressed,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      // if (widget.selectedElementId != 0)
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       IconButton(
                      //         icon: Icon(
                      //           Icons.format_align_left,
                      //           color:
                      //               _selectedTextAlign == TextAlign.left
                      //                   ? Colors.orange
                      //                   : Colors.grey,
                      //         ),
                      //         onPressed: () {
                      //           _saveStateAndUpdate(() {
                      //             _selectedTextAlign = TextAlign.left;
                      //             if (selectedElement == 1) {
                      //               provider.setCompanyNameAlign(
                      //                 TextAlign.left,
                      //               );
                      //             } else if (selectedElement == 2) {
                      //               provider.setSloganAlign(TextAlign.left);
                      //             } else {
                      //               provider.setCustomTextAlign(TextAlign.left);
                      //             }
                      //             widget.onTextAlignChanged?.call(
                      //               TextAlign.left,
                      //             );
                      //           });
                      //         },
                      //       ),
                      //       IconButton(
                      //         icon: Icon(
                      //           Icons.format_align_center,
                      //           color:
                      //               _selectedTextAlign == TextAlign.center
                      //                   ? Colors.orange
                      //                   : Colors.grey,
                      //         ),
                      //         onPressed: () {
                      //           _saveStateAndUpdate(() {
                      //             _selectedTextAlign = TextAlign.center;
                      //             if (selectedElement == 1) {
                      //               provider.setCompanyNameAlign(
                      //                 TextAlign.center,
                      //               );
                      //             } else if (selectedElement == 2) {
                      //               provider.setSloganAlign(TextAlign.center);
                      //             } else {
                      //               provider.setCustomTextAlign(
                      //                 TextAlign.center,
                      //               );
                      //             }
                      //             widget.onTextAlignChanged?.call(
                      //               TextAlign.center,
                      //             );
                      //           });
                      //         },
                      //       ),
                      //       IconButton(
                      //         icon: Icon(
                      //           Icons.format_align_right,
                      //           color:
                      //               _selectedTextAlign == TextAlign.right
                      //                   ? Colors.orange
                      //                   : Colors.grey,
                      //         ),
                      //         onPressed: () {
                      //           _saveStateAndUpdate(() {
                      //             _selectedTextAlign = TextAlign.right;
                      //             if (selectedElement == 1) {
                      //               provider.setCompanyNameAlign(
                      //                 TextAlign.right,
                      //               );
                      //             } else if (selectedElement == 2) {
                      //               provider.setSloganAlign(TextAlign.right);
                      //             } else {
                      //               provider.setCustomTextAlign(
                      //                 TextAlign.right,
                      //               );
                      //             }
                      //             widget.onTextAlignChanged?.call(
                      //               TextAlign.right,
                      //             );
                      //           });
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      if (selectedElement != 0) const SizedBox(height: 15),

                      // Duplicate & Edit buttons
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              widget.onSaveState?.call();
                              widget.onDuplicatePressed();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              minimumSize: const Size(70, 30),
                            ),
                            child: Text(
                              S.of(context).duplicate,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (selectedElement != 0)
                            ElevatedButton(
                              onPressed: () {
                                widget.onSaveState?.call();
                                widget.onEditPressed?.call();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeColors.purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                minimumSize: const Size(55, 30),
                              ),
                              child: Text(
                                S.of(context).edit,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool canBringForward(int id, dynamic logoState) {
    final i = logoState.elementOrder.indexOf(id);
    return i != -1 && i < logoState.elementOrder.length - 1;
  }

  bool canSendBackward(int id, dynamic logoState) {
    final i = logoState.elementOrder.indexOf(id);
    return i != -1 && i > 0;
  }

  Widget layerButton({
    required String id,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: enabled
              ? () {
                  setState(() => activeLayerButton = id);
                  widget.onSaveState?.call();
                  onTap();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: enabled
                    ? (activeLayerButton == id
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor)
                    : Theme.of(context).disabledColor,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: enabled
                  ? Theme.of(context).iconTheme.color
                  : Theme.of(context).disabledColor,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: enabled
                ? Theme.of(context).textTheme.bodyMedium?.color
                : Theme.of(context).disabledColor,
          ),
        ),
      ],
    );
  }

  Widget _buildColorsTab(BuildContext context) {
    return Consumer<SelectedColorProvider>(
      builder: (context, provider, _) {
        if (widget.selectedElementId == null)
          return const Center(child: Text("Select an element first"));

        final elementId = widget.selectedElementId!;

        // Get current color for the selected element
        Color currentColor = _getCurrentColorForElement(provider, elementId);

        final colors = [
          Colors.black,
          Colors.orange,
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow,
          Colors.purple,
          Colors.pink,
          Colors.teal,
          Colors.brown,
          Colors.grey,
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: colors
                      .map(
                        (color) => GestureDetector(
                          onTap: () {
                            _setColorForElement(provider, elementId, color);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: currentColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Helper method to get current color for an element
  Color _getCurrentColorForElement(
    SelectedColorProvider provider,
    int elementId,
  ) {
    if (elementId == 0) {
      return provider.logoColor;
    } else if (elementId == 1) {
      return provider.companyTextColor;
    } else if (elementId == 2) {
      return provider.sloganColor;
    } else if (elementId >= 100 && elementId < 200) {
      // Custom text
      return provider.getColorForElement(
        elementId,
        fallback: provider.customTextColor,
      );
    } else if (elementId >= 300 && elementId < 400) {
      // Custom SVG
      return provider.getColorForElement(elementId, fallback: Colors.black);
    } else {
      return provider.getColorForElement(elementId, fallback: Colors.black);
    }
  }

  void _setColorForElement(
    SelectedColorProvider provider,
    int elementId,
    Color color,
  ) {
    if (elementId == 0) {
      provider.setLogoColor(color);
    } else if (elementId == 1) {
      provider.setCompanyTextColor(color);
    } else if (elementId == 2) {
      provider.setSloganColor(color);
    } else {
      provider.setOverrideColorForElement(elementId, color);
    }

    // ✅ Save state after the change
    widget.onSaveState?.call();
  }

  Widget _buildOutlinesTab() {
    return Consumer<SelectedColorProvider>(
      builder: (context, provider, _) {
        if (widget.selectedElementId == null)
          return const Center(child: Text("Select an element first"));

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
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    "Outline",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: ThemeColors.lightPurple,
                        thumbColor: ThemeColors.purple,
                      ),
                      child: Slider(
                        min: 0,
                        max: 10,
                        divisions: 10,
                        value: outlineThickness,
                        onChanged: (value) {
                          widget.onSaveState?.call();
                          provider.setOutlineWidth(elementId, value);
                          if (widget.onLogoStateChanged != null) {
                            widget.onLogoStateChanged!(
                              widget.logoState.copyWith(
                                outlineWidths:
                                    Map.from(widget.logoState.outlineWidths)
                                      ..['$elementId'] = value,
                              ),
                            );
                          }
                        },
                        onChangeEnd: (value) {
                          // Save state only when user stops sliding
                          // widget.onSaveState?.call();
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
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: colors
                      .map(
                        (color) => GestureDetector(
                          onTap: () {
                            widget.onSaveState?.call();
                            provider.setOutlineColor(elementId, color);

                            if (widget.onLogoStateChanged != null) {
                              widget.onLogoStateChanged!(
                                widget.logoState.copyWith(
                                  outlineColors:
                                      Map.from(widget.logoState.outlineColors)
                                        ..['$elementId'] = color,
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
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
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build3DTab() {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        final int elementId = widget.selectedElementId ?? -1;
        if (elementId == -1) return const SizedBox();

        // Directly read from logoState
        double rotationX = widget.logoState.rotationXMap[elementId] ?? 0.0;
        double rotationY = widget.logoState.rotationYMap[elementId] ?? 0.0;
        double rotationZ = widget.logoState.rotationZMap[elementId] ?? 0.0;

        Widget buildSlider(
            String label, double value, ValueChanged<double> onChanged) {
          return SizedBox(
            height: 28,
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    "${value.round()}°", // Show current value
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 360,
                    divisions: 360,
                    value: value,
                    activeColor: ThemeColors.purple,
                    inactiveColor: Colors.pink.shade100,
                    onChanged: (v) {
                      onChanged(v);
                      // Immediate feedback
                      setLocalState(() {});
                    },
                    onChangeEnd: (_) {
                      // Save state for undo/redo ONLY on change end
                      widget.onSaveState?.call();
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSlider("X", rotationX, (v) {
                widget.onLogoStateChanged!(
                  widget.logoState.copyWith(
                    rotationXMap: {
                      ...widget.logoState.rotationXMap,
                      elementId: v,
                    },
                  ),
                );
              }),
              const SizedBox(height: 8),
              buildSlider("Y", rotationY, (v) {
                widget.onLogoStateChanged!(
                  widget.logoState.copyWith(
                    rotationYMap: {
                      ...widget.logoState.rotationYMap,
                      elementId: v,
                    },
                  ),
                );
              }),
              const SizedBox(height: 8),
              buildSlider("Z", rotationZ, (v) {
                widget.onLogoStateChanged!(
                  widget.logoState.copyWith(
                    rotationZMap: {
                      ...widget.logoState.rotationZMap,
                      elementId: v,
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
  // Widget _build3DTab() {
  //   return StatefulBuilder(
  //     builder: (context, setLocalState) {
  //       final int elementId = widget.selectedElementId ?? -1;

  //       double rotationX = widget.logoState.rotationXMap[elementId] ?? 0.0;
  //       double rotationY = widget.logoState.rotationYMap[elementId] ?? 0.0;
  //       double rotationZ = widget.logoState.rotationZMap[elementId] ?? 0.0;

  //       Widget buildSlider(
  //         String label,
  //         double value,
  //         ValueChanged<double> onChanged,
  //       ) {
  //         return SizedBox(
  //           height: 28,
  //           child: Row(
  //             children: [
  //               SizedBox(
  //                 width: 40,
  //                 child: Text(
  //                   "$label°",
  //                   style: const TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Slider(
  //                   min: 0,
  //                   max: 360,
  //                   divisions: 360,
  //                   value: value,
  //                   activeColor: ThemeColors.purple,
  //                   inactiveColor: Colors.pink.shade100,
  //                   onChanged: onChanged,
  //                   onChangeEnd: (v) => widget.onSaveState?.call(),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       }

  //       return Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             buildSlider("X", rotationX, (v) {
  //               int id = widget.selectedElementId ?? -1;
  //               if (id != -1) {
  //                 final newMap = Map<int, double>.from(
  //                   widget.logoState.rotationXMap,
  //                 );
  //                 newMap[id] = v;

  //                 widget.onLogoStateChanged!(
  //                   widget.logoState.copyWith(rotationXMap: newMap),
  //                 );
  //               }

  //               setLocalState(() {});
  //             }),
  //             const SizedBox(height: 8),
  //             buildSlider("Y", rotationY, (v) {
  //               int id = widget.selectedElementId ?? -1;
  //               if (id != -1) {
  //                 final newMap = Map<int, double>.from(
  //                   widget.logoState.rotationYMap,
  //                 );
  //                 newMap[id] = v;

  //                 widget.onLogoStateChanged!(
  //                   widget.logoState.copyWith(rotationYMap: newMap),
  //                 );
  //               }

  //               setLocalState(() {});
  //             }),
  //             const SizedBox(height: 8),
  //             buildSlider("Z", rotationZ, (v) {
  //               int id = widget.selectedElementId ?? -1;
  //               if (id != -1) {
  //                 final newMap = Map<int, double>.from(
  //                   widget.logoState.rotationZMap,
  //                 );
  //                 newMap[id] = v;

  //                 widget.onLogoStateChanged!(
  //                   widget.logoState.copyWith(rotationZMap: newMap),
  //                 );
  //               }

  //               setLocalState(() {});
  //             }),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildColorBox(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        if (widget.selectedElementId != null) {
          final provider = Provider.of<SelectedColorProvider>(
            context,
            listen: false,
          );
          final elementId = widget.selectedElementId!;
          _setColorForElement(provider, elementId, color);
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
      onTap: () {
        widget.onSaveState?.call(); // Save state for single tap
        widget.onDirectionPressed(direction);
      },
      child: Tooltip(
        message: tooltip,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 1),
          ),
          padding: const EdgeInsets.all(5),
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }
}
