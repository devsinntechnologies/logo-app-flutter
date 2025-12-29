import 'dart:math';
import 'package:flutter/material.dart';
import 'corner_action_icon.dart';

typedef ElementTapCallback = void Function(int id);
typedef ElementPanUpdateCallback = void Function(int id, Offset delta);
typedef ElementPanStartCallback = void Function(
int id, DragStartDetails details);
typedef ElementPanEndCallback = void Function(int id);
typedef ElementActionCallback = void Function(int id);
typedef ElementDragUpdateCallback = void Function(
int id, DragUpdateDetails details);

class EditableElementWrapper extends StatelessWidget {
  final int id;
  final Offset position;
  final double rotation;
  final Widget child;
  final Size canvasSize;
  final bool isSelected;
  final bool isEditingMode;
  final bool isLocked;
  final bool isExporting;

  final ElementTapCallback onTap;
  final ElementPanStartCallback onPanStart;
  final ElementPanUpdateCallback onPanUpdate;
  final ElementPanEndCallback onPanEnd;
  final ElementActionCallback onDelete;
  final ElementActionCallback onSplit;
  final ElementActionCallback onRotateTap;
  final ElementPanStartCallback onRotatePanStart;
  final ElementDragUpdateCallback onRotatePanUpdate;
  final ElementPanEndCallback onRotatePanEnd;
  final ElementActionCallback onResizeTap;
  final ElementPanStartCallback onResizePanStart;
  final ElementDragUpdateCallback onResizePanUpdate;
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
    required this.isLocked,
    required this.isExporting,
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
    final bool canInteract =
        !isLocked && isEditingMode && isSelected && !isExporting;
    final double clampedX = position.dx.clamp(
      0.0,
      canvasSize.width,
    );

    final double clampedY = position.dy.clamp(
      0.0,
      canvasSize.height,
    );

    return Positioned(
       left: position.dx,
      top: position.dy,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main content
          Listener(
            behavior: HitTestBehavior.translucent,
            child: GestureDetector(
              onTap: !isLocked && !isExporting ? () => onTap(id) : null,
              onPanStart:
                  canInteract ? (details) => onPanStart(id, details) : null,
              onPanUpdate: canInteract
                  ? (details) => onPanUpdate(id, details.delta)
                  : null,
              onPanEnd: canInteract ? (details) => onPanEnd(id) : null,
              child: Container(
                decoration: (!isExporting && isSelected && isEditingMode)
                    ? BoxDecoration(
                      color: Color(0xffCDCDCD),
                        border: Border.all(
                          color:
                              isLocked ? Colors.red.shade300 : Colors.black,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      )
                    :  
                null,
                // padding: const EdgeInsets.all(2),
                child: Transform.rotate(
                  angle: rotation * pi / 180,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 5
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),

          // Corner actions with larger hit area
          if (!isExporting && canInteract) ..._buildCornerActions(),

          if (isLocked && !isExporting) ...[
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 32,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCornerActions() {
    // Increased hit area size
    const double hitAreaSize = 40.0;
    const double iconOffset = 15.0;

    return [
      // Delete (top-left)
      Positioned(
        top: -iconOffset,
        left: -iconOffset,
        child: _CornerActionWrapper(
          size: hitAreaSize,
          onTap: () => onDelete(id),
          child: CornerActionIcon(icon: Icons.close, onTap: () => onDelete(id)),
        ),
      ),
      // Split (top-right) - ADDED DRAG CALLBACKS FOR ELEMENT MOVEMENT
      Positioned(
        top: -iconOffset,
        right: -iconOffset,
        child: _CornerActionWrapper(
          size: hitAreaSize,
          onTap: () => onSplit(id),
          // These drag callbacks allow moving the element when dragging the split icon
          onPanStart: (details) => onPanStart(id, details),
          onPanUpdate: (details) => onPanUpdate(id, details.delta),
          onPanEnd: (details) => onPanEnd(id),
          child: CornerActionIcon(
            icon: Icons.call_split,
            onTap: () => onSplit(id),
            // Also add drag callbacks to the CornerActionIcon itself
            onPanStart: (details) => onPanStart(id, details),
            onPanUpdate: (details) => onPanUpdate(id, details.delta),
            onPanEnd: (details) => onPanEnd(id),
          ),
        ),
      ),
      // Rotate (bottom-left)
      Positioned(
        bottom: -iconOffset,
        left: -iconOffset,
        child: _CornerActionWrapper(
          size: hitAreaSize,
          onTap: () => onRotateTap(id),
          onPanStart: (details) => onRotatePanStart(id, details),
          onPanUpdate: (details) => onRotatePanUpdate(id, details),
          onPanEnd: (details) => onRotatePanEnd(id),
          child: CornerActionIcon(
            icon: Icons.rotate_right,
            onTap: () => onRotateTap(id),
            onPanStart: (details) => onRotatePanStart(id, details),
            onPanUpdate: (details) => onRotatePanUpdate(id, details),
            onPanEnd: (details) => onRotatePanEnd(id),
          ),
        ),
      ),
      // Resize (bottom-right)
      Positioned(
        bottom: -iconOffset,
        right: -iconOffset,
        child: _CornerActionWrapper(
          size: hitAreaSize,
          onTap: () => onResizeTap(id),
          onPanStart: (details) => onResizePanStart(id, details),
          onPanUpdate: (details) => onResizePanUpdate(id, details),
          onPanEnd: (details) => onResizePanEnd(id),
          child: CornerActionIcon(
            icon: Icons.open_in_full,
            onTap: () => onResizeTap(id),
            onPanStart: (details) => onResizePanStart(id, details),
            onPanUpdate: (details) => onResizePanUpdate(id, details),
            onPanEnd: (details) => onResizePanEnd(id),
          ),
        ),
      ),
    ];
  }
}

class _CornerActionWrapper extends StatelessWidget {
  final VoidCallback? onTap;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final Widget child;
  final double size;

  const _CornerActionWrapper({
    this.onTap,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    required this.child,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: Center(child: child),
        ),
      ),
    );
  }
}
