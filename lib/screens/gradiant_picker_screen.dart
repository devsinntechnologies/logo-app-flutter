import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';
import 'package:logo_app_flutter/components/undo_redo_widget.dart';
import 'package:provider/provider.dart';

class GradientPickerScreen extends StatefulWidget {
  const GradientPickerScreen({super.key});

  @override
  State<GradientPickerScreen> createState() => _GradientPickerScreenState();
}

class _GradientPickerScreenState extends State<GradientPickerScreen> {
  Color startColor = Colors.pink.shade200;
  Color endColor = Colors.white;
  double angle = 0;
  bool isLinear = true;

  // Enhanced undo/redo management
  Timer? _undoDebounceTimer;
  bool _isSliderBeingDragged = false;
  Map<String, dynamic>? _sliderStartState;
  bool _hasUnsavedChanges = false;

  // Initial state capture for comparison
  Map<String, dynamic>? _initialGradientState;

  @override
  void initState() {
    super.initState();
    _captureInitialState();
    _loadCurrentGradientIfExists();
  }

  void _captureInitialState() {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    _initialGradientState = colorProvider.captureCurrentState();
  }

  void _loadCurrentGradientIfExists() {
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    final currentGradient = colorProvider.selectedGradient;

    if (currentGradient != null) {
      setState(() {
        if (currentGradient is LinearGradient) {
          isLinear = true;
          if (currentGradient.colors.isNotEmpty) {
            startColor = currentGradient.colors.first;
            if (currentGradient.colors.length > 1) {
              endColor = currentGradient.colors.last;
            }
          }
          // Extract angle from transform if available
          if (currentGradient.transform is GradientRotation) {
            final rotation = currentGradient.transform as GradientRotation;
            angle = rotation.radians;
          }
        } else if (currentGradient is RadialGradient) {
          isLinear = false;
          if (currentGradient.colors.isNotEmpty) {
            startColor = currentGradient.colors.first;
            if (currentGradient.colors.length > 1) {
              endColor = currentGradient.colors.last;
            }
          }
          // Extract center position as angle equivalent
          final center = currentGradient.center as Alignment;
          angle = math.atan2(center.y, center.x);
        }
      });
    }
  }

  void _saveUndoState(String action) {
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    if (!undoProvider.isUndoRedoInProgress) {
      final currentState = colorProvider.captureCurrentState();

      // Add gradient-specific state information
      currentState['gradientPickerState'] = {
        'startColor': startColor.value,
        'endColor': endColor.value,
        'angle': angle,
        'isLinear': isLinear,
      };

      undoProvider.saveState(action: action, state: currentState);
      _hasUnsavedChanges = true;

      print('✅ Saved gradient undo state: $action');
    }
  }

  void _saveUndoStateDebounced(String action, {int delayMs = 500}) {
    _undoDebounceTimer?.cancel();
    _undoDebounceTimer = Timer(Duration(milliseconds: delayMs), () {
      _saveUndoState(action);
    });
  }

  void _captureSliderStartState(String sliderType) {
    if (!_isSliderBeingDragged) {
      final colorProvider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      _sliderStartState = colorProvider.captureCurrentState();
      _sliderStartState!['gradientPickerState'] = {
        'startColor': startColor.value,
        'endColor': endColor.value,
        'angle': angle,
        'isLinear': isLinear,
      };
      _isSliderBeingDragged = true;
    }
  }

  void _handleSliderEnd(String action) {
    _isSliderBeingDragged = false;
    _undoDebounceTimer?.cancel();
    _saveUndoState(action);
    _sliderStartState = null;
  }

  void pickColor(bool isStartColor) async {
    // Save state before opening color picker
    final colorType = isStartColor ? 'start' : 'end';
    _saveUndoState('Open $colorType color picker');

    Color tempColor = isStartColor ? startColor : endColor;

    Color? picked = await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text("Select ${isStartColor ? 'Start' : 'End'} Color"),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BlockPicker(
                          pickerColor: tempColor,
                          onColorChanged: (color) {
                            setState(() => tempColor = color);
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Color? customPicked = await showDialog<Color>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Custom Color Picker"),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: tempColor,
                                    onColorChanged: (color) {
                                      tempColor = color;
                                    },
                                    showLabel: true,
                                    pickerAreaHeightPercent: 0.8,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(
                                          context,
                                        ).pop(tempColor),
                                    child: const Text("Done"),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text("Cancel"),
                                  ),
                                ],
                              ),
                        );
                        if (customPicked != null) {
                          setState(() => tempColor = customPicked);
                        }
                      },
                      child: const Text("Custom"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(tempColor),
                      child: const Text("Select"),
                    ),
                  ],
                ),
          ),
    );

    if (picked != null) {
      final colorName = isStartColor ? 'start' : 'end';
      _saveUndoState('Change gradient $colorName color');

      setState(() {
        if (isStartColor) {
          startColor = picked;
        } else {
          endColor = picked;
        }
        _hasUnsavedChanges = true;
      });

      // Show immediate feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gradient $colorName color updated'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.blue.withOpacity(0.8),
        ),
      );
    }
  }

  void _changeGradientType(bool linear) {
    if (linear != isLinear) {
      final typeName = linear ? 'linear' : 'radial';
      _saveUndoState('Change gradient type to $typeName');

      setState(() {
        isLinear = linear;
        _hasUnsavedChanges = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changed to $typeName gradient'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.green.withOpacity(0.8),
        ),
      );
    }
  }

  void _changeGradientAngle(double newAngle) {
    setState(() {
      angle = newAngle;
      _hasUnsavedChanges = true;
    });
  }

  void _handleAngleSliderEnd(double finalAngle) {
    _saveUndoState(
      'Change gradient angle to ${(finalAngle * 180 / math.pi).toInt()}°',
    );
  }

  void _handleAngleButtonPress(double newAngle, String direction) {
    _saveUndoState('Set gradient direction to $direction');

    setState(() {
      angle = newAngle;
      _hasUnsavedChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gradient direction: $direction'),
        duration: const Duration(milliseconds: 600),
        backgroundColor: Colors.orange.withOpacity(0.8),
      ),
    );
  }

  String _getGradientType(Gradient gradient) {
    if (gradient is LinearGradient) return 'linear';
    if (gradient is RadialGradient) return 'radial';
    if (gradient is SweepGradient) return 'sweep';
    return 'gradient';
  }

  void _applyGradient() {
    final gradient =
        isLinear
            ? LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              transform: GradientRotation(angle),
            )
            : RadialGradient(
              colors: [startColor, endColor],
              center: Alignment(math.cos(angle), math.sin(angle)),
              radius: 1.0,
            );

    _saveUndoState('Apply ${_getGradientType(gradient)} gradient');

    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    colorProvider.setGradient(gradient);

    setState(() {
      _hasUnsavedChanges = false;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_getGradientType(gradient).capitalize()} gradient applied',
        ),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: Colors.green.withOpacity(0.8),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: _performUndo,
          textColor: Colors.white,
        ),
      ),
    );
  }

  void _removeGradient() {
    _saveUndoState('Remove background gradient');

    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );
    colorProvider.removeGradient();

    setState(() {
      _hasUnsavedChanges = false;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Gradient removed'),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: Colors.orange.withOpacity(0.8),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: _performUndo,
          textColor: Colors.white,
        ),
      ),
    );
  }

  void _performUndo() async {
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    final previousState = undoProvider.undo();
    if (previousState != null) {
      try {
        await colorProvider.restoreFromStateAsync(previousState.data);
      } catch (_) {
        colorProvider.restoreFromState(previousState.data);
      }

      // Restore gradient picker UI state if available
      if (previousState.data.containsKey('gradientPickerState')) {
        final gradientState =
            previousState.data['gradientPickerState'] as Map<String, dynamic>;
        setState(() {
          startColor = Color(gradientState['startColor'] as int);
          endColor = Color(gradientState['endColor'] as int);
          angle = gradientState['angle'] as double;
          isLinear = gradientState['isLinear'] as bool;
        });
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Undid: ${previousState.action}'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _performRedo() async {
    final undoProvider = Provider.of<UndoProvider>(context, listen: false);
    final colorProvider = Provider.of<SelectedColorProvider>(
      context,
      listen: false,
    );

    final redoState = undoProvider.redo();
    if (redoState != null) {
      try {
        await colorProvider.restoreFromStateAsync(redoState.data);
      } catch (_) {
        colorProvider.restoreFromState(redoState.data);
      }

      // Restore gradient picker UI state if available
      if (redoState.data.containsKey('gradientPickerState')) {
        final gradientState =
            redoState.data['gradientPickerState'] as Map<String, dynamic>;
        setState(() {
          startColor = Color(gradientState['startColor'] as int);
          endColor = Color(gradientState['endColor'] as int);
          angle = gradientState['angle'] as double;
          isLinear = gradientState['isLinear'] as bool;
        });
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redid: ${redoState.action}'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _handleWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Discard Changes?'),
              content: const Text(
                'You have unsaved gradient changes. Do you want to discard them?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
      );
      return shouldDiscard ?? false;
    }
    return true;
  }

  @override
  void dispose() {
    _undoDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final gradient =
        isLinear
            ? LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              transform: GradientRotation(angle),
            )
            : RadialGradient(
              colors: [startColor, endColor],
              center: Alignment(math.cos(angle), math.sin(angle)),
              radius: 1.0,
            );

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gradient Picker'),
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.textTheme.bodyLarge?.color,
          elevation: 0,
          actions: [
            // Undo/Redo Widget
            UndoRedoWidget(
              isCompact: true,
              iconSize: 20,
              iconColor: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview box with change indicator
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: gradient,
                  border: Border.all(
                    color:
                        _hasUnsavedChanges ? Colors.orange : theme.dividerColor,
                    width: _hasUnsavedChanges ? 2 : 1,
                  ),
                ),
                child:
                    _hasUnsavedChanges
                        ? Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Modified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        : null,
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _colorCircle("Start", startColor, () => pickColor(true)),
                  const Icon(Icons.swap_horiz, size: 28),
                  _colorCircle("End", endColor, () => pickColor(false)),
                ],
              ),

              const SizedBox(height: 15),

              // Gradient Type
              _themedSection(
                title: "Gradient Type",
                child: Column(
                  children: [
                    _radioOption("Linear", isLinear, () {
                      _changeGradientType(true);
                    }),
                    const SizedBox(height: 12),
                    _radioOption("Radial", !isLinear, () {
                      _changeGradientType(false);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Gradient Angle/Direction
              isLinear
                  ? _themedSection(
                    title: "Gradient Direction",
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _angleButton(
                            Icons.arrow_downward,
                            0,
                            "Top to Bottom",
                            () => _handleAngleButtonPress(0, "Top to Bottom"),
                          ),
                          _angleButton(
                            Icons.arrow_forward,
                            1.57,
                            "Left to Right",
                            () =>
                                _handleAngleButtonPress(1.57, "Left to Right"),
                          ),
                          _angleButton(
                            Icons.arrow_upward,
                            3.14,
                            "Bottom to Top",
                            () =>
                                _handleAngleButtonPress(3.14, "Bottom to Top"),
                          ),
                          _angleButton(
                            Icons.arrow_back,
                            4.71,
                            "Right to Left",
                            () =>
                                _handleAngleButtonPress(4.71, "Right to Left"),
                          ),
                        ],
                      ),
                    ),
                  )
                  : _themedSection(
                    title: "Gradient Center",
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, color: Colors.orange),
                        Expanded(
                          child: Slider(
                            value: angle,
                            min: 0,
                            max: 6.28,
                            activeColor: Colors.orange,
                            onChangeStart: (value) {
                              _captureSliderStartState('radial_center');
                            },
                            onChanged: (val) {
                              _changeGradientAngle(val);
                            },
                            onChangeEnd: (val) {
                              _handleSliderEnd(
                                'Change gradient center to ${(val * 180 / math.pi).toInt()}°',
                              );
                            },
                          ),
                        ),
                        Text(
                          '${(angle * 180 / math.pi).toInt()}°',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  // Remove Gradient Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _removeGradient,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "REMOVE",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Apply Button
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _applyGradient,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "APPLY GRADIENT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themedSection({required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _colorCircle(String label, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: theme.dividerColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _radioOption(String text, bool selected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? Colors.orange : theme.iconTheme.color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color:
                  selected ? Colors.orange : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _angleButton(
    IconData icon,
    double val,
    String tooltip,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isSelected =
        (angle - val).abs() < 0.1; // Allow for small floating point differences

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor:
              isSelected ? Colors.orange : theme.colorScheme.surface,
          child: Icon(
            icon,
            color: isSelected ? Colors.white : theme.iconTheme.color,
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
