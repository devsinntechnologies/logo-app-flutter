// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
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
  final VoidCallback? onClose;
  final int? selectedElementId;

  const MovementPanel({
    super.key,
    required this.onDirectionPressed,
    this.onLogoColorChanged,
    required this.onDuplicatePressed,
    required this.isVisible,
    required this.onBringToFrontPressed,
    required this.onSendToBackPressed,
    required this.onClose,
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Sans Serif':
        return Colors.blue;
      case 'Serif':
        return Colors.green;
      case 'Display':
        return Colors.orange;
      case 'Handwriting':
        return Colors.purple;
      case 'Monospace':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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

    if (!undoProvider.isUndoRedoInProgress) {
      final currentState = colorProvider.captureCurrentState();
      undoProvider.saveState(action: action, state: currentState);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (!widget.isVisible) return const SizedBox.shrink();

      final theme = Theme.of(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Material(
            elevation: 10,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.25,
              width: MediaQuery.sizeOf(context).width * 1,
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.95),
              ),
              child:
                  _isMoreSelected
                      ? _buildMoreTab(context)
                      : _isArtElement
                      ? _buildArtMainView()
                      : _buildMainView(),
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error in Movement Panel: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildMainView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            indicatorColor: Theme.of(context).indicatorColor,
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            unselectedLabelColor: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
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
            indicatorColor: Theme.of(context).indicatorColor,
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            unselectedLabelColor: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
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
    final theme = Theme.of(context);
    return Consumer<SelectedColorProvider>(
      builder: (context, provider, _) {
        if (widget.selectedElementId == null) {
          return const Center(child: Text("Select an element first"));
        }

        final int elementId = widget.selectedElementId!;
        double actualSize = provider.getSizeForElementWithInit(elementId);
        double uiValue = provider.mapActualToUI(actualSize, elementId);

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Resize Element",
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Slider(
                  value: uiValue,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  activeColor: theme.colorScheme.primary,
                  onChangeStart: (value) {
                    _saveUndoState('Start resizing element $elementId');
                  },
                  onChanged: (uiValue) {
                    double actualValue = provider.mapUIToActual(
                      uiValue,
                      elementId,
                    );
                    provider.setSizeForElement(elementId, actualValue);
                  },
                  onChangeEnd: (uiValue) {
                    _saveUndoState(
                      'Resize element $elementId to ${uiValue.toInt()}%',
                    );
                  },
                ),
                Text(
                  "${uiValue.toInt()}%",
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _saveUndoState('Reset size of element $elementId');
                        provider.setSizeForElement(
                          elementId,
                          50.0,
                        ); // Default size
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      label: Text(
                        'Reset',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _saveUndoState('Maximize element $elementId');
                        provider.setSizeForElement(elementId, 100.0);
                      },
                      icon: Icon(
                        Icons.fullscreen,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      label: Text(
                        'Max',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlsTab() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).width * 0.05),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Movement Controls
              Column(
                children: [
                  _buildDirectionButton(
                    icon: Icons.keyboard_arrow_up,
                    direction: 'up',
                    tooltip: 'Move Up',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDirectionButton(
                        icon: Icons.keyboard_arrow_left,
                        direction: 'left',
                        tooltip: 'Move Left',
                      ),
                      const SizedBox(width: 16),
                      _buildDirectionButton(
                        icon: Icons.keyboard_arrow_right,
                        direction: 'right',
                        tooltip: 'Move Right',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDirectionButton(
                    icon: Icons.keyboard_arrow_down,
                    direction: 'down',
                    tooltip: 'Move Down',
                  ),
                ],
              ),

              Column(
                children: [
                  GestureDetector(
                    onTap: () => _handleLayerAction('bring_to_front'),
                    child: _buildControlButton(
                      icon: Icons.layers_outlined,
                      label: "Up Layer",
                      theme: theme,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _handleLayerAction('send_to_back'),
                    child: _buildControlButton(
                      icon: Icons.layers_outlined,
                      label: "Down Layer",
                      theme: theme,
                    ),
                  ),
                ],
              ),

              // Action Buttons
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _handleAction('duplicate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Duplicate",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleLayerAction(String action) {
    if (widget.selectedElementId == null) return;

    final elementId = widget.selectedElementId!;

    switch (action) {
      case 'bring_to_front':
        _saveUndoState('Bring element $elementId to front');
        widget.onBringToFrontPressed();
        break;
      case 'send_to_back':
        _saveUndoState('Send element $elementId to back');
        widget.onSendToBackPressed();
        break;
    }
  }

  void _handleAction(String action) {
    if (widget.selectedElementId == null) return;

    final elementId = widget.selectedElementId!;

    switch (action) {
      case 'duplicate':
        _saveUndoState('Duplicate element $elementId');
        _trackButtonClick('duplicate');
        widget.onDuplicatePressed();
        break;
      case 'delete':
        _saveUndoState('Delete element $elementId');
        break;
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icon, color: theme.iconTheme.color),
          Text(
            label,
            style: TextStyle(color: theme.textTheme.bodySmall?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericMoreView() {
    if (!mounted) return const SizedBox.shrink();
    final theme = Theme.of(context);
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
                icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
              ),
              Expanded(
                child: TabBar(
                  labelColor: theme.textTheme.bodyLarge?.color,
                  indicatorColor: theme.indicatorColor,
                  unselectedLabelColor: theme.textTheme.bodyMedium?.color
                      ?.withOpacity(0.7),
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
    final List<List<Gradient>> gradientRows = [
      [
        LinearGradient(
          colors: [Colors.red, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        LinearGradient(
          colors: [Colors.green, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        LinearGradient(
          colors: [Colors.yellow, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ],
      [
        LinearGradient(
          colors: [Colors.purple, Colors.pink, Colors.red],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        LinearGradient(
          colors: [Colors.cyan, Colors.blue, Colors.indigo],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        LinearGradient(
          colors: [Colors.lime, Colors.green, Colors.teal],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        LinearGradient(
          colors: [Colors.deepOrange, Colors.red, Colors.pink],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ],
      [
        RadialGradient(
          colors: [Colors.yellow, Colors.orange, Colors.red],
          stops: [0.0, 0.5, 1.0],
        ),
        RadialGradient(
          colors: [Colors.white, Colors.blue, Colors.indigo],
          stops: [0.0, 0.5, 1.0],
        ),
        RadialGradient(
          colors: [Colors.lightGreen, Colors.green, Colors.black],
          stops: [0.0, 0.5, 1.0],
        ),
        SweepGradient(
          colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.purple,
          ],
        ),
      ],
    ];

    final List<Color> solidColors = [
      Color(0xFFFF0000),
      Color(0xFFB71C1C),
      Color(0xFFE57373),
      Color(0xFF880000),
      Color(0xFFFF9800),
      Color(0xFFFF5722),
      Color(0xFFFFCC80),
      Color(0xFFFFFF00),
      Color(0xFFFDD835),
      Color(0xFFFFF176),
      Color(0xFF4CAF50),
      Color(0xFF1B5E20),
      Color(0xFF81C784),
      Color(0xFF00E676),
      Color(0xFF8BC34A),
      Color(0xFF9E9D24),
      Color(0xFF00BCD4),
      Color(0xFFB2EBF2),
      Color(0xFF0097A7),
      Color(0xFF008080),
      Color(0xFF80CBC4),
      Color(0xFF2196F3),
      Color(0xFF0D47A1),
      Color(0xFF64B5F6),
      Color(0xFF001F54),
      Color(0xFF9C27B0),
      Color(0xFF4A148C),
      Color(0xFF673AB7),
      Color(0xFFE1BEE7),
      Color(0xFFE91E63),
      Color(0xFFF48FB1),
      Color(0xFFAD1457),
      Color(0xFFFF80AB),
      Color(0xFFFFC0CB),
      Colors.brown,
      Colors.amber,
      Colors.grey,
      Colors.black,
      Colors.white,
      Colors.blueGrey,
    ];

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            unselectedLabelColor: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            indicatorColor: Colors.orange,
            tabs: [Tab(text: 'Colors'), Tab(text: 'Gradients')],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            solidColors.map((color) {
                              return _buildColorBox(context, color);
                            }).toList(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      children:
                          gradientRows.map((gradientRow) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children:
                                    gradientRow.map((gradient) {
                                      return _buildGradientBox(
                                        context,
                                        gradient,
                                      );
                                    }).toList(),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientToggle(int elementId) {
    return Consumer<SelectedColorProvider>(
      builder: (context, provider, _) {
        final hasGradient = provider.hasGradientForElement(elementId);

        return IconButton(
          onPressed: () {
            if (hasGradient) {
              provider.clearGradientForElement(elementId);
            }
          },
          icon: Icon(
            hasGradient ? Icons.gradient : Icons.color_lens,
            color: hasGradient ? Colors.orange : Colors.white,
          ),
          tooltip: hasGradient ? 'Remove Gradient' : 'Apply Gradient',
        );
      },
    );
  }

  Widget _buildGradientBox(BuildContext context, Gradient gradient) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (widget.selectedElementId != null) {
          _saveUndoState(
            'Apply gradient to element ${widget.selectedElementId}',
          );

          _trackButtonClick('gradient_selection');
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

          provider.setGradientForElement(elementId, gradient);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gradient applied to element $elementId'),
              duration: Duration(milliseconds: 1000),
            ),
          );
        }
      },
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.2),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientClearButton() {
    return Consumer<SelectedColorProvider>(
      builder: (context, provider, child) {
        final hasGradient =
            widget.selectedElementId != null &&
            provider.hasGradientForElement(widget.selectedElementId!);

        if (!hasGradient) return SizedBox.shrink();

        return IconButton(
          onPressed: () {
            if (widget.selectedElementId != null) {
              provider.clearGradientForElement(widget.selectedElementId!);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Gradient removed')));
            }
          },
          icon: Icon(Icons.clear, color: Colors.red),
          tooltip: 'Remove Gradient',
        );
      },
    );
  }

  Color _extractPrimaryColorFromGradient(Gradient gradient) {
    if (gradient is LinearGradient && gradient.colors.isNotEmpty) {
      return gradient.colors.first;
    } else if (gradient is RadialGradient && gradient.colors.isNotEmpty) {
      return gradient.colors.first;
    }
    return Colors.blue;
  }

  Color _extractSecondaryColorFromGradient(Gradient gradient) {
    if (gradient is LinearGradient && gradient.colors.length > 1) {
      return gradient.colors.last;
    } else if (gradient is RadialGradient && gradient.colors.length > 1) {
      return gradient.colors.last;
    }
    return Colors.red;
  }

  Widget _buildMoreTab(BuildContext context) {
    final theme = Theme.of(context);
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
                  icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                ),
                Expanded(
                  child: TabBar(
                    labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                    indicatorColor: Theme.of(context).indicatorColor,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (widget.selectedElementId != null) {
          _saveUndoState(
            'Change color of element ${widget.selectedElementId} to $color',
          );

          _trackButtonClick('color_selection');
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

          // Apply color based on element type
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
        }
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: theme.dividerColor),
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
    final theme = Theme.of(context);

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
          Colors.white,
          Colors.purple,
          Colors.brown,
        ];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Outline Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "Width",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: theme.colorScheme.primary,
                          thumbColor: theme.colorScheme.primary,
                        ),
                        child: Slider(
                          min: 0,
                          max: 10,
                          divisions: 10,
                          value: outlineThickness,
                          onChangeStart: (value) {
                            _saveUndoState(
                              'Start changing outline width for element $elementId',
                            );
                          },
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Color",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: colors.length,
                    itemBuilder: (context, index) {
                      final color = colors[index];
                      return GestureDetector(
                        onTap: () {
                          _saveUndoState(
                            'Change outline color of element $elementId',
                          );
                          provider.setOutlineColor(elementId, color);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  outlineColor == color
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontTab(BuildContext context) {
    final provider = Provider.of<SelectedColorProvider>(context);
    final int id = widget.selectedElementId!;
    final styleState = provider.getFontStyleForElement(id);
    final theme = Theme.of(context);

    Widget fontStyleBar = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.format_bold,
            color:
                styleState.isBold
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color,
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
            color:
                styleState.isItalic
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color,
          ),
          onPressed: () {
            _saveUndoState('Toggle italic for element $id');
            provider.toggleItalic(id);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.format_underline,
            color:
                styleState.isUnderline
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color,
          ),
          onPressed: () {
            _saveUndoState('Toggle underline for element $id');
            provider.toggleUnderline(id);
          },
        ),
      ],
    );

    final fonts = [
      {'name': 'Roboto', 'preview': 'AaBbYyZz'},
      {'name': 'Montserrat', 'preview': 'AaBbYyZz'},
      {'name': 'Open Sans', 'preview': 'AaBbYyZz'},
      {'name': 'Poppins', 'preview': 'AaBbYyZz'},
      {'name': 'Raleway', 'preview': 'AaBbYyZz'},
      {'name': 'Lato', 'preview': 'AaBbYyZz'},
      {'name': 'Nunito', 'preview': 'AaBbYyZz'},
      {'name': 'Inter', 'preview': 'AaBbYyZz'},
      {'name': 'Ubuntu', 'preview': 'AaBbYyZz'},
      {'name': 'Work Sans', 'preview': 'AaBbYyZz'},
      {'name': 'Hind', 'preview': 'AaBbYyZz'},
      {'name': 'Karla', 'preview': 'AaBbYyZz'},
      {'name': 'Exo 2', 'preview': 'AaBbYyZz'},
      {'name': 'Barlow', 'preview': 'AaBbYyZz'},
      {'name': 'Merriweather', 'preview': 'AaBbYyZz'},
      {'name': 'Lora', 'preview': 'AaBbYyZz'},
      {'name': 'PT Serif', 'preview': 'AaBbYyZz'},
      {'name': 'Crimson Text', 'preview': 'AaBbYyZz'},
      {'name': 'Spectral', 'preview': 'AaBbYyZz'},
      {'name': 'Cormorant Garamond', 'preview': 'AaBbYyZz'},
      {'name': 'Bitter', 'preview': 'AaBbYyZz'},
      {'name': 'Noto Serif', 'preview': 'AaBbYyZz'},
      {'name': 'Bebas Neue', 'preview': 'SAMPLE TEXT'},
      {'name': 'Anton', 'preview': 'SAMPLE TEXT'},
      {'name': 'Oswald', 'preview': 'SAMPLE TEXT'},
      {'name': 'Righteous', 'preview': 'AaBbYyZz'},
      {'name': 'Comfortaa', 'preview': 'AaBbYyZz'},
      {'name': 'Alfa Slab One', 'preview': 'SAMPLE'},
      {'name': 'Abril Fatface', 'preview': 'Sample'},
      {'name': 'Chewy', 'preview': 'Sample'},
      {'name': 'Luckiest Guy', 'preview': 'Sample'},
      {'name': 'Lobster', 'preview': 'Sample Text'},
      {'name': 'Dancing Script', 'preview': 'Sample Text'},
      {'name': 'Pacifico', 'preview': 'Sample Text'},
      {'name': 'Great Vibes', 'preview': 'Sample Text'},
      {'name': 'Sacramento', 'preview': 'Sample Text'},
      {'name': 'Shadows Into Light', 'preview': 'Sample Text'},
      {'name': 'Cookie', 'preview': 'Sample Text'},
      {'name': 'Amatic SC', 'preview': 'Sample Text'},
      {'name': 'Handlee', 'preview': 'Sample Text'},
      {'name': 'Caveat', 'preview': 'Sample Text'},
      {'name': 'Fira Code', 'preview': 'Code 123'},
      {'name': 'Source Code Pro', 'preview': 'Code 123'},
      {'name': 'JetBrains Mono', 'preview': 'Code 123'},
      {'name': 'Inconsolata', 'preview': 'Code 123'},
      {'name': 'Cousine', 'preview': 'Code 123'},
      {'name': 'Titillium Web', 'preview': 'AaBbYyZz'},
      {'name': 'Asap', 'preview': 'AaBbYyZz'},
      {'name': 'Mulish', 'preview': 'AaBbYyZz'},
      {'name': 'Overpass', 'preview': 'AaBbYyZz'},
      {'name': 'Prompt', 'preview': 'AaBbYyZz'},
      {'name': 'Questrial', 'preview': 'AaBbYyZz'},
      {'name': 'Archivo', 'preview': 'AaBbYyZz'},
      {'name': 'Signika', 'preview': 'AaBbYyZz'},
      {'name': 'Rubik', 'preview': 'AaBbYyZz'},
      {'name': 'Heebo', 'preview': 'AaBbYyZz'},
      {'name': 'Teko', 'preview': 'AaBbYyZz'},
      {'name': 'Chivo', 'preview': 'AaBbYyZz'},
      {'name': 'Encode Sans', 'preview': 'AaBbYyZz'},
      {'name': 'Manrope', 'preview': 'AaBbYyZz'},
      {'name': 'Urbanist', 'preview': 'AaBbYyZz'},
      {'name': 'DM Serif Display', 'preview': 'AaBbYyZz'},
      {'name': 'Prata', 'preview': 'AaBbYyZz'},
      {'name': 'Rozha One', 'preview': 'AaBbYyZz'},
      {'name': 'Slabo 27px', 'preview': 'AaBbYyZz'},
      {'name': 'Alegreya', 'preview': 'AaBbYyZz'},
      {'name': 'Domine', 'preview': 'AaBbYyZz'},
      {'name': 'Nanum Myeongjo', 'preview': 'AaBbYyZz'},
      {'name': 'Tinos', 'preview': 'AaBbYyZz'},
      {'name': 'Volkhov', 'preview': 'AaBbYyZz'},
      {'name': 'Zilla Slab', 'preview': 'AaBbYyZz'},
      {'name': 'Staatliches', 'preview': 'SAMPLE TEXT'},
      {'name': 'Kanit', 'preview': 'SAMPLE TEXT'},
      {'name': 'Patua One', 'preview': 'SAMPLE TEXT'},
      {'name': 'Bangers', 'preview': 'SAMPLE TEXT'},
      {'name': 'Changa One', 'preview': 'SAMPLE TEXT'},
      {'name': 'Passion One', 'preview': 'SAMPLE TEXT'},
      {'name': 'Kaushan Script', 'preview': 'Sample Text'},
      {'name': 'Yellowtail', 'preview': 'Sample Text'},
      {'name': 'Allura', 'preview': 'Sample Text'},
      {'name': 'Satisfy', 'preview': 'Sample Text'},
      {'name': 'Marck Script', 'preview': 'Sample Text'},
      {'name': 'Gloria Hallelujah', 'preview': 'Sample Text'},
      {'name': 'Courgette', 'preview': 'Sample Text'},
      {'name': 'Patrick Hand', 'preview': 'Sample Text'},
      {'name': 'Covered By Your Grace', 'preview': 'Sample Text'},
      {'name': 'Anonymous Pro', 'preview': 'Code 123'},
      {'name': 'PT Mono', 'preview': 'Code 123'},
      {'name': 'Oxygen Mono', 'preview': 'Code 123'},
      {'name': 'Share Tech Mono', 'preview': 'Code 123'},
      {'name': 'Major Mono Display', 'preview': 'Code 123'},
    ];

    String? currentFont = provider.getFontForElement(id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fontStyleBar,
        const SizedBox(height: 4),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
            ),
            itemCount: fonts.length,
            itemBuilder: (context, index) {
              final font = fonts[index];
              final fontName = font['name']!;
              final previewText = font['preview']!;

              return GestureDetector(
                onTap: () {
                  _saveUndoState('Change font of element $id to $fontName');
                  _trackButtonClick('font_selection');
                  provider.setFontForElement(id, fontName);

                  final adManager = Provider.of<SmartInterstitialManager>(
                    context,
                    listen: false,
                  );
                  adManager.onFontChanged();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      previewText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont(fontName, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fontName,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRotateTab() {
    if (!mounted) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Consumer<SelectedColorProvider>(
      builder: (context, provider, _) {
        if (widget.selectedElementId == null) {
          return const Center(child: Text("Select an element first"));
        }

        final int elementId = widget.selectedElementId!;

        if (_lastElementId != elementId) {
          _lastElementId = elementId;
          _localRotation =
              (provider.getRotationForElement(elementId) ?? 0).toDouble();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Rotate Element",
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _localRotation.clamp(0.0, 360.0),
                  min: 0,
                  max: 360,
                  divisions: 360,
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.dividerColor,
                  onChangeStart: (value) {
                    _saveUndoState('Start rotating element $elementId');
                  },
                  onChanged: (value) {
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
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _saveUndoState('Reset rotation of element $elementId');
                        setState(() {
                          _localRotation = 0.0;
                        });
                        provider.setRotationForElement(elementId, 0.0);
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      label: Text(
                        "Reset",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _saveUndoState('Rotate element $elementId by 90°');
                        setState(() {
                          _localRotation = (_localRotation + 90) % 360;
                        });
                        provider.setRotationForElement(
                          elementId,
                          _localRotation,
                        );
                      },
                      icon: Icon(
                        Icons.rotate_90_degrees_ccw,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      label: Text(
                        "90°",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShadowTab(BuildContext context) {
    final provider = Provider.of<SelectedColorProvider>(context);
    final int id = widget.selectedElementId!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Shadow Settings',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Shadow Offset X',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            Slider(
              value: provider.getShadowOffsetXForElement(id),
              min: -10,
              max: 10,
              onChangeStart: (value) {
                _saveUndoState(
                  'Start changing shadow X offset for element $id',
                );
              },
              onChanged: (v) {
                provider.setShadowOffsetXForElement(id, v);
              },
              onChangeEnd: (v) {
                _saveUndoState(
                  'Change shadow X offset of element $id to ${v.toInt()}',
                );
              },
            ),
            Text(
              'Shadow Offset Y',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            Slider(
              value: provider.getShadowOffsetYForElement(id),
              min: -10,
              max: 10,
              onChangeStart: (value) {
                _saveUndoState(
                  'Start changing shadow Y offset for element $id',
                );
              },
              onChanged: (v) {
                provider.setShadowOffsetYForElement(id, v);
              },
              onChangeEnd: (v) {
                _saveUndoState(
                  'Change shadow Y offset of element $id to ${v.toInt()}',
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Shadow Color',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final color in [
                  Colors.black,
                  Colors.grey,
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.white,
                  Colors.yellow,
                  Colors.purple,
                ])
                  GestureDetector(
                    onTap: () {
                      _saveUndoState('Change shadow color of element $id');
                      provider.setShadowColorForElement(id, color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
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
    final theme = Theme.of(context);
    return Consumer<SelectedColorProvider>(
      builder: (context, provider, _) {
        if (widget.selectedElementId == null) {
          return const Center(
            child: Text(
              "Select an element first",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        final int elementId = widget.selectedElementId!;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        double rotationX = provider.getRotationXForElement(elementId) ?? 0.0;
        double rotationY = provider.getRotationYForElement(elementId) ?? 0.0;
        double rotationZ = provider.getRotationZForElement(elementId) ?? 0.0;

        Widget buildRotationSlider(
          String label,
          double value,
          ValueChanged<double> onChanged,
          VoidCallback onReset,
        ) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$label Axis",
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: theme.colorScheme.primary,
                          inactiveTrackColor: theme.dividerColor,
                          thumbColor: theme.colorScheme.primary,
                          overlayColor: theme.colorScheme.primary.withOpacity(
                            0.2,
                          ),
                          valueIndicatorColor: theme.colorScheme.primary,
                          valueIndicatorTextStyle: TextStyle(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        child: Slider(
                          value: value,
                          min: -180.0,
                          max: 180.0,
                          divisions: 360,
                          label: '${value.toStringAsFixed(1)}°',
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                    Text(
                      "${value.toStringAsFixed(1)}°",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onReset,
                      icon: Icon(Icons.refresh, color: Colors.orange, size: 18),
                      tooltip: 'Reset $label',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildRotationSlider(
                  "X",
                  rotationX,
                  (value) {
                    provider.setRotationXForElement(elementId, value);
                  },
                  () {
                    _saveUndoState('Reset X rotation for element $elementId');
                    provider.setRotationXForElement(elementId, 0.0);
                  },
                ),

                buildRotationSlider(
                  "Y",
                  rotationY,
                  (value) {
                    provider.setRotationYForElement(elementId, value);
                  },
                  () {
                    _saveUndoState('Reset Y rotation for element $elementId');
                    provider.setRotationYForElement(elementId, 0.0);
                  },
                ),

                buildRotationSlider(
                  "Z",
                  rotationZ,
                  (value) {
                    provider.setRotationZForElement(elementId, value);
                  },
                  () {
                    _saveUndoState('Reset Z rotation for element $elementId');
                    provider.setRotationZForElement(elementId, 0.0);
                  },
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    _saveUndoState(
                      'Reset all 3D rotations for element $elementId',
                    );
                    provider.setRotationXForElement(elementId, 0.0);
                    provider.setRotationYForElement(elementId, 0.0);
                    provider.setRotationZForElement(elementId, 0.0);
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    "Reset All",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Tip: Combine X, Y, Z rotations for complex 3D effects",
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.black, size: 20),
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
