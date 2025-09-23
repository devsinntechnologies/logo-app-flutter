// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/smart_interstitial_manager.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:provider/provider.dart';
// / import 'selected_color_provider.dart'; // <-- import your provider

class MovementPanel extends StatefulWidget {
  final Function(String) onDirectionPressed;
  final Function(Color)? onLogoColorChanged;
  final VoidCallback onDuplicatePressed;
  final bool isVisible;

  final VoidCallback onBringToFrontPressed;
  final VoidCallback onSendToBackPressed;

  final int? selectedElementId;

  const MovementPanel({
    super.key,
    required this.onDirectionPressed,
    this.onLogoColorChanged, // Add this
    required this.onDuplicatePressed,
    required this.isVisible,
    required this.onBringToFrontPressed,
    required this.onSendToBackPressed,
    this.selectedElementId,
  });

  @override
  State<MovementPanel> createState() => _MovementPanelState();
}

class _MovementPanelState extends State<MovementPanel>
    with SingleTickerProviderStateMixin {
  Timer? _moveTimer;
  bool _isMoreSelected = false;
  double _localRotation = 0.0;
  int? _lastElementId;

  void _startMoving(String direction) {
    _moveTimer?.cancel(); // Pehle koi purana timer stop karo
    widget.onDirectionPressed(direction);
    _moveTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      widget.onDirectionPressed(direction);
    });
  }

  void _stopMoving() {
    _moveTimer?.cancel();
    _moveTimer = null;
  }

  bool get _isArtElement {
    final id = widget.selectedElementId;
    return id != null && id >= 200 && id < 300;
  }

  bool get _isTextElement {
    final id = widget.selectedElementId;
    return id == 1 || id == 2 || (id != null && id >= 100 && id < 200);
  }

  void _trackButtonClick(String buttonName) {
    final adManager = Provider.of<SmartInterstitialManager>(
      context,
      listen: false,
    );
    adManager.onButtonClick(buttonName);
  }

  

  void _saveUndoState(String action) {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);

    final currentState = colorProvider.captureCurrentState();
    undoProvider.saveState(action: action, state: currentState);
  }

  void _saveMovementState(BuildContext context, String action) {
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    if (!undoProvider.isUndoRedoInProgress) {
      final currentState = colorProvider.captureCurrentState();
      undoProvider.saveState(action: action, state: currentState);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (!widget.isVisible) return const SizedBox.shrink();

      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 107),
          child: Container(
            height: MediaQuery.sizeOf(context).width * 0.69,
            width: MediaQuery.sizeOf(context).width * 1,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 72, 70, 70),
            ),
            child:
                _isMoreSelected
                    ? _buildMoreTab(context)
                    : _isArtElement
                    ? _buildArtMainView()
                    : _buildMainView(),
          ),
        ),
      );
    } catch (e) {
      print('Error in Movement Panel: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildMainView() {
    return DefaultTabController(
      length: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            indicatorColor: Color.fromARGB(255, 255, 255, 255),
            labelColor: Color.fromARGB(115, 255, 255, 255),
            unselectedLabelColor: Color.fromARGB(255, 255, 255, 255),
            onTap: (index) {
              if (index == 3) {
                setState(() {
                  _isMoreSelected = true;
                });
              }
            },
            tabs: [
              Tab(text: 'Controls'),
              Tab(text: 'Colors'),
              Tab(text: 'Size'),
              Tab(
                child: GestureDetector(
                  onTap: () => setState(() => _isMoreSelected = true),
                  child: const Text("More"),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildControlsTab(),
                _buildColorsTab(context),
                _buildSizeTab(),
                const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtMainView() {
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.grey,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Controls'),
              Tab(text: 'Size'),
              Tab(text: 'Rotate'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildControlsTab(),
                _buildSizeTab(),
                _buildRotateTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeTab() {
    return Consumer<SelectedColorProvider>(
      builder: (context, provider, _) {
        if (widget.selectedElementId == null) {
          return const Center(
            child: Text(
              "Select an element first",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final int elementId = widget.selectedElementId!;

        double actualSize = provider.getSizeForElementWithInit(elementId);
        double uiValue = provider.mapActualToUI(actualSize, elementId);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Resize",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: uiValue,
                min: 1,
                max: 100,
                divisions: 99,
                onChanged: (uiValue) {
                  double actualValue = provider.mapUIToActual(
                    uiValue,
                    elementId,
                  );
                  provider.setSizeForElement(elementId, actualValue);
                },
                onChangeEnd: (uiValue) {
                  _saveUndoState(
                    'Change size of element $elementId to ${uiValue.toInt()}',
                  );
                },
              ),
              Text(
                uiValue.toInt().toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlsTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).width * 0.08),
        Row(
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
                  onTap: () {
                    _saveUndoState(
                      'Bring element ${widget.selectedElementId} to front',
                    );
                    widget.onBringToFrontPressed();
                  },
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
                  style: TextStyle(color: Color.fromARGB(255, 251, 251, 251)),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _saveUndoState(
                      'Send element ${widget.selectedElementId} to back',
                    );
                    widget.onSendToBackPressed();
                  },
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
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  _saveUndoState(
                    'Duplicate element ${widget.selectedElementId}',
                  );
                  _trackButtonClick('duplicate');
                  debugPrint(
                    'Duplicate button pressed for element ${widget.selectedElementId ?? "null"}',
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
      ],
    );
  }

  Widget _buildGenericMoreView() {
    if (!mounted) return const SizedBox.shrink();
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed:
                    () => setState(() {
                      _isMoreSelected = false;
                    }),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: TabBar(
                  labelColor: Colors.grey,
                  indicatorColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                  tabs: [
                    Tab(text: 'Outlines'),
                    Tab(text: 'Rotate'),
                    Tab(text: '3D'),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [_buildOutlinesTab(), _buildRotateTab(), _build3DTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsTab(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).width * 0.2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
      ),
    );
  }

  Widget _buildMoreTab(BuildContext context) {
    final int? selectedId = widget.selectedElementId;
    // print('DEBUG: selectedId in _buildMoreTab: $selectedId');
    print('DEBUG: selectedElementId = ${widget.selectedElementId}');

    final bool isTextElement =
        widget.selectedElementId == 1 ||
        widget.selectedElementId == 2 ||
        (widget.selectedElementId != null &&
            widget.selectedElementId! >= 100 &&
            widget.selectedElementId! < 200);

    if (isTextElement) {
      return DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _isMoreSelected = false),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: TabBar(
                    labelColor: Colors.grey,
                    indicatorColor: Colors.white,
                    unselectedLabelColor: Colors.white,
                    onTap: (index) {
                      if (index == 3) {
                        setState(() {
                          _isMoreSelected = true;
                        });
                      }
                    },
                    tabs: [
                      Tab(text: 'Fonts'),
                      Tab(text: 'Shadow'),
                      Tab(text: 'Outlines'),
                      Tab(text: 'Rotate'),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFontTab(context),
                  _buildShadowTab(context),
                  _buildOutlinesTab(),
                  _buildRotateTab(),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return _buildGenericMoreView();
    }
  }

  // Widget _buildOutlinesr() {
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

  Widget _buildColorBox(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        _trackButtonClick('color_selection');

        if (widget.selectedElementId != null) {
          // ✅ Add undo tracking BEFORE making changes:
          _saveUndoState(
            'Change color of element ${widget.selectedElementId} to $color',
          );

          final provider = Provider.of<SelectedColorProvider>(
            context,
            listen: false,
          );
          final elementId = widget.selectedElementId!;

          final adManager = Provider.of<SmartInterstitialManager>(
            context,
            listen: false,
          );
          adManager.onColorChanged();

          if (elementId == 0) {
            provider.setShapeColor(color);
            provider.setSvgColorOverridden(true);
            widget.onLogoColorChanged?.call(color);
          } else if (elementId == 1) {
            provider.setCompanyTextColor(color);
          } else if (elementId == 2) {
            provider.setSloganColor(color);
          } else if (elementId >= 100) {
            provider.setColorForElement(elementId, color);
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

  Widget _buildColorTab(BuildContext context) {
    final provider = Provider.of<SelectedColorProvider>(context);
    final id = provider.selectedElementId;

    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
      Colors.grey,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ), // Changed to const
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Text Color",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      _saveUndoState(
                        'Change text color of element $id to $color',
                      );
                      provider.setColorForElement(id!, color);
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
                }).toList(),
          ),
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
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    "Outline",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
                        onChangeEnd: (value) {
                          _saveUndoState(
                            'Change outline width of element $elementId to ${value.toInt()}',
                          );
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

              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      colors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            _saveUndoState(
                              'Change outline color of element $elementId',
                            );
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
                                color:
                                    outlineColor == color
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

  Widget _buildFontTab(BuildContext context) {
    final provider = Provider.of<SelectedColorProvider>(context);
    final int id = widget.selectedElementId!;
    final styleState = provider.getFontStyleForElement(id);

    Widget fontStyleBar = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.format_bold,
            color: styleState.isBold ? Colors.orange : Colors.white,
          ),
          onPressed: () {
            _saveUndoState('Toggle bold for element $id');
            _trackButtonClick('bold_toggle');
            final adManager = Provider.of<SmartInterstitialManager>(
              context,
              listen: false,
            );
            adManager.onFontChanged();
            provider.toggleBold(id);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.format_italic,
            color: styleState.isItalic ? Colors.orange : Colors.white,
          ),
          onPressed: () {
            _saveUndoState('Toggle italic for element $id');
            provider.toggleItalic(id);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.format_underline,
            color: styleState.isUnderline ? Colors.orange : Colors.white,
          ),
          onPressed: () {
            _saveUndoState('Toggle underline for element $id');
            provider.toggleUnderline(id);
          },
        ),
      ],
    );

    final fonts = [
      {'name': 'Roboto', 'display': 'Roboto'},
      {'name': 'Montserrat', 'display': 'Montserrat'},
      {'name': 'Lobster', 'display': 'Lobster'},
    ];

    Widget fontList = ListView(
      scrollDirection: Axis.horizontal,
      children:
          fonts.map((font) {
            return GestureDetector(
              onTap: () {
                _saveUndoState('Change font of element $id to ${font['name']}');
                provider.setFontForElement(id, font['name']!);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Aa',
                  style: TextStyle(
                    fontFamily: font['name'],
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fontStyleBar,
        SizedBox(height: 10),
        SizedBox(height: 50, child: fontList),
      ],
    );
  }

  Widget _buildRotateTab() {
    if (!mounted) return const SizedBox.shrink();

    return Consumer<SelectedColorProvider>(
      builder: (context, provider, _) {
        if (widget.selectedElementId == null) {
          return const Center(
            child: Text(
              "Select an element first",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final int elementId = widget.selectedElementId!;

        if (_lastElementId != elementId) {
          _lastElementId = elementId;
          _localRotation =
              (provider.getRotationForElement(elementId) ?? 0).toDouble();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Rotate",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: _localRotation.clamp(0.0, 360.0),
                min: 0,
                max: 360,
                divisions: 360,
                activeColor: Colors.orange,
                inactiveColor: Colors.grey,
                onChanged: (value) {
                  _trackButtonClick(
                    'size_adjustment',
                  ); 
                  if (mounted) {
                    setState(() {
                      _localRotation = value;
                    });
                  }
                },
                onChangeEnd: (value) {
                  _saveUndoState(
                    'Rotate element $elementId to ${value.toInt()}°',
                  );
                  provider.setRotationForElement(elementId, value);
                },
              ),
              const SizedBox(height: 8),
              Text(
                "${_localRotation.toInt()}°",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _saveUndoState('Reset rotation of element $elementId');
                  setState(() {
                    _localRotation = 0.0;
                  });
                  provider.setRotationForElement(elementId, 0.0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Reset Rotation"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShadowTab(BuildContext context) {
    final provider = Provider.of<SelectedColorProvider>(context);
    final int id = widget.selectedElementId!;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Shadow Offset X', style: TextStyle(color: Colors.white)),
            Slider(
              value: provider.getShadowOffsetXForElement(id),
              min: -10,
              max: 10,
              onChanged: (v) {
                provider.setShadowOffsetXForElement(id, v);
              },
              onChangeEnd: (v) {
                _saveUndoState(
                  'Change shadow X offset of element $id to ${v.toInt()}',
                );
              },
            ),

            Text('Shadow Offset Y', style: TextStyle(color: Colors.white)),
            Slider(
              value: provider.getShadowOffsetYForElement(id),
              min: -10,
              max: 10,
              onChanged: (v) {
                provider.setShadowOffsetYForElement(id, v);
              },
              onChangeEnd: (v) {
                _saveUndoState(
                  'Change shadow Y offset of element $id to ${v.toInt()}',
                );
              },
            ),
            Text('Shadow Color', style: TextStyle(color: Colors.white)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final color in [
                  Colors.black,
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.white,
                ])
                  GestureDetector(
                    onTap: () {
                      _saveUndoState('Change shadow color of element $id');
                      provider.setShadowColorForElement(id, color);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
                    onChangeEnd: (value) {
                      _saveUndoState('Change 3D $label to ${value.toInt()}°');
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _buildDirectionButton({
    required IconData icon,
    required String direction,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          _saveUndoState('Move element ${widget.selectedElementId} $direction');
          widget.onDirectionPressed(direction);
        },
        onLongPress: () => _startMoving(direction),
        onLongPressUp: () => _stopMoving(),
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
