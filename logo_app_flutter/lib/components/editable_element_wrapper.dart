// lib/widgets/editable_element_wrapper.dart
import 'dart:math'; // Required for math.pi and atan2
import 'package:flutter/material.dart';

import 'corner_action_icon.dart'; // Import the widget from Step 4

// Define callbacks for element interactions
typedef ElementTapCallback = void Function(int id);
typedef ElementPanUpdateCallback = void Function(int id, Offset delta); // For position change
typedef ElementPanStartCallback = void Function(int id, DragStartDetails details);
typedef ElementPanEndCallback = void Function(int id);

// For actions like delete, split, and tap-to-rotate/resize
typedef ElementActionCallback = void Function(int id);

// For pan-based rotate/resize, which need DragUpdateDetails for gesture info
typedef ElementDragUpdateCallback = void Function(int id, DragUpdateDetails details);


class EditableElementWrapper extends StatelessWidget {
  final int id;
  final Offset position;
  final double rotation;
  final Widget child;
  final Size canvasSize; // Needed for resize/rotate calculations relative to canvas
  final bool isSelected;
  final bool isEditingMode;

  // Callbacks from _DownloadLogoState
  final ElementTapCallback onTap;
  final ElementPanStartCallback onPanStart; // For position drag
  final ElementPanUpdateCallback onPanUpdate; // For position drag
  final ElementPanEndCallback onPanEnd; // For position drag

  final ElementActionCallback onDelete;
  final ElementActionCallback onSplit;

  final ElementActionCallback onRotateTap;
  final ElementPanStartCallback onRotatePanStart;
  final ElementDragUpdateCallback onRotatePanUpdate; // Changed type for details
  final ElementPanEndCallback onRotatePanEnd;

  final ElementActionCallback onResizeTap;
  final ElementPanStartCallback onResizePanStart;
  final ElementDragUpdateCallback onResizePanUpdate; // Changed type for details
  final ElementPanEndCallback onResizePanEnd;

  const EditableElementWrapper({
    super.key,
    required this.id,
    required this.position,
    required this.rotation,
    required this.child,
    required this.canvasSize,
    required this.isSelected,
    required this.isEditingMode,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onDelete,
    required this.onSplit,
    required this.onRotateTap,
    required this.onRotatePanStart,
    required this.onRotatePanUpdate,
    required this.onRotatePanEnd,
    required this.onResizeTap,
    required this.onResizePanStart,
    required this.onResizePanUpdate,
    required this.onResizePanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => onTap(id),
        // Pass the element ID to the pan callbacks
        onPanStart: isEditingMode && isSelected ? (details) => onPanStart(id, details) : null,
        onPanUpdate: isEditingMode && isSelected ? (details) => onPanUpdate(id, details.delta) : null,
        onPanEnd: isEditingMode && isSelected ? (details) => onPanEnd(id) : null,
        child: Container(
          decoration: isSelected && isEditingMode
              ? BoxDecoration(
            border: Border.all(
              color: Colors.black38,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(6),
          )
              : null,
          padding: const EdgeInsets.all(2),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Transform.rotate(
                angle: rotation * pi / 180,
                child: child,
              ),
              if (isSelected && isEditingMode) ...[
                // These use the CornerActionIcon extracted in Step 4
                CornerActionIcon(
                  icon: Icons.close,
                  onTap: () => onDelete(id),
                  alignment: Alignment.topLeft,
                ),
                CornerActionIcon(
                  icon: Icons.call_split,
                  onTap: () => onSplit(id),
                  alignment: Alignment.topRight,
                ),
                CornerActionIcon(
                  icon: Icons.rotate_right,
                  onTap: () => onRotateTap(id),
                  onPanStart: (details) => onRotatePanStart(id, details),
                  onPanUpdate: (details) => onRotatePanUpdate(id, details),
                  onPanEnd: (details) => onRotatePanEnd(id),
                  alignment: Alignment.bottomLeft,
                ),
                CornerActionIcon(
                  icon: Icons.open_in_full,
                  onTap: () => onResizeTap(id),
                  onPanStart: (details) => onResizePanStart(id, details),
                  onPanUpdate: (details) => onResizePanUpdate(id, details),
                  onPanEnd: (details) => onResizePanEnd(id),
                  alignment: Alignment.bottomRight,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}