// ✅ PASTE THIS ENTIRE CODE BLOCK INTO lib/widgets/logo_canvas.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/logo_state_data.dart';
import 'editable_element_wrapper.dart';
import 'grid_painter.dart';

class LogoCanvas extends StatelessWidget {
  final GlobalKey canvasKey;
  final LogoStateData logoState;
  final String svgLogo;
  final String companyName;
  final String sloganName;
  final bool showGrid;
  final bool isEditingMode;
  final int? selectedElementId;
  final int? highlightedHorizontalGridLineIndex;
  final int? highlightedVerticalGridLineIndex;
  final bool isLayersRibbonExtended;
  final bool isCheckerboardActive;
  final bool isCheckerboardVisible;
  final double checkerboardOpacity;

  // ✅ NEW: State for layer ordering and locking
  final List<int> elementOrder;
  final Set<int> lockedElements;

  // Callbacks
  final VoidCallback onToggleGrid;
  final VoidCallback onToggleLayersRibbon;
  final ElementTapCallback onElementTap;
  final ElementPanStartCallback onElementPanStart;
  final ElementPanUpdateCallback onElementPanUpdate;
  final ElementPanEndCallback onElementPanEnd;
  final ElementActionCallback onElementDelete;
  final ElementActionCallback onElementSplit;
  final ElementActionCallback onElementRotateTap;
  final ElementPanStartCallback onElementRotatePanStart;
  final ElementDragUpdateCallback onElementRotatePanUpdate;
  final ElementPanEndCallback onElementRotatePanEnd;
  final ElementActionCallback onElementResizeTap;
  final ElementPanStartCallback onElementResizePanStart;
  final ElementDragUpdateCallback onElementResizePanUpdate;
  final ElementPanEndCallback onElementResizePanEnd;

  const LogoCanvas({
    super.key,
    required this.canvasKey,
    required this.logoState,
    required this.svgLogo,
    required this.companyName,
    required this.sloganName,
    required this.showGrid,
    required this.isEditingMode,
    required this.selectedElementId,
    this.highlightedHorizontalGridLineIndex,
    this.highlightedVerticalGridLineIndex,
    required this.isLayersRibbonExtended,
    required this.onToggleGrid,
    required this.onToggleLayersRibbon,
    required this.onElementTap,
    required this.onElementPanStart,
    required this.onElementPanUpdate,
    required this.onElementPanEnd,
    required this.onElementDelete,
    required this.onElementSplit,
    required this.onElementRotateTap,
    required this.onElementRotatePanStart,
    required this.onElementRotatePanUpdate,
    required this.onElementRotatePanEnd,
    required this.onElementResizeTap,
    required this.onElementResizePanStart,
    required this.onElementResizePanUpdate,
    required this.onElementResizePanEnd,
    required this.isCheckerboardActive,
    required this.checkerboardOpacity,
    required this.isCheckerboardVisible,
    // ✅ NEW: Initialize new properties
    this.elementOrder = const [],
    this.lockedElements = const {},
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size canvasSize = constraints.biggest;
        return Stack(
          key: canvasKey,
          children: [
            if (showGrid)
              CustomPaint(
                painter: GridPainter(
                  gridColor: Colors.black,
                  highlightedHorizontalLine: highlightedHorizontalGridLineIndex,
                  highlightedVerticalLine: highlightedVerticalGridLineIndex,
                ),
                size: Size.infinite,
              ),

            if (isCheckerboardVisible)
              Opacity(
                opacity: 0.5 * checkerboardOpacity,
                child: Image.asset(
                  'lib/assets/icons/checkerboard.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            // ✅ NEW: Build elements based on the specified order
            ...elementOrder
                .map((id) => _buildElementById(id, canvasSize))
                .whereType<Widget>(), // Filter out nulls for non-visible elements
          ],
        );
      },
    );
  }

  // ✅ NEW: Helper method to create a widget based on its ID
  Widget? _buildElementById(int id, Size canvasSize) {
    // Helper to reduce boilerplate
    Widget wrap(Widget child, {required Offset position, required double rotation}) {
      return _buildEditableWrapper(
        id: id,
        position: position,
        rotation: rotation,
        isLocked: lockedElements.contains(id), // Pass lock status
        child: child,
        canvasSize: canvasSize,
      );
    }

    if (id >= 100) {
      final index = id - 100;
      if (index < logoState.customTexts.length) {
        final customText = logoState.customTexts[index];
        return wrap(
          Text(
            customText.text,
            style: TextStyle(
              fontSize: customText.size,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          position: customText.position,
          rotation: customText.rotation,
        );
      }
      return null; // Should not happen if state is consistent
    }

    switch (id) {
      case 0:
        return logoState.isLogoVisible
            ? wrap(
          SvgPicture.string(
            svgLogo,
            height: logoState.logoSize,
            width: logoState.logoSize,
          ),
          position: logoState.logoPosition,
          rotation: logoState.logoRotation,
        )
            : null;
      case 1:
        return logoState.isCompanyNameVisible && logoState.companyName != null
            ? wrap(
          Text(
            logoState.companyName!,
            style: TextStyle(
              fontSize: logoState.companyNameSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          position: logoState.companyNamePosition,
          rotation: logoState.companyNameRotation,
        )
            : null;
      case 2:
        return logoState.isSloganVisible && logoState.sloganName != null
            ? wrap(
          Text(
            logoState.sloganName!,
            style: TextStyle(
              fontSize: logoState.sloganSize,
              fontStyle: FontStyle.italic,
            ),
          ),
          position: logoState.sloganPosition,
          rotation: logoState.sloganRotation,
        )
            : null;
      case 3: // Logo 2 (Split)
        return logoState.isLogo2Visible
            ? wrap(
          SvgPicture.string(
            svgLogo,
            height: logoState.logo2Size ?? 100,
            width: logoState.logo2Size ?? 100,
          ),
          position: logoState.logo2Position ?? Offset.zero,
          rotation: logoState.logo2Rotation ?? 0,
        )
            : null;
      case 4: // Company Name 2 (Split)
        return logoState.isCompanyName2Visible && logoState.companyName != null
            ? wrap(
          Text(
            logoState.companyName!,
            style: TextStyle(
              fontSize: logoState.companyName2Size ?? 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          position: logoState.companyName2Position ?? Offset.zero,
          rotation: logoState.companyName2Rotation ?? 0,
        )
            : null;
      case 5: // Slogan 2 (Split)
        return logoState.isSlogan2Visible && logoState.sloganName != null
            ? wrap(
          Text(
            logoState.sloganName!,
            style: TextStyle(
              fontSize: logoState.slogan2Size ?? 18,
              fontStyle: FontStyle.italic,
            ),
          ),
          position: logoState.slogan2Position ?? Offset.zero,
          rotation: logoState.slogan2Rotation ?? 0,
        )
            : null;
      default:
        return null;
    }
  }

  // ✅ UPDATED: Helper now accepts `isLocked`
  Widget _buildEditableWrapper({
    required int id,
    required Offset position,
    required double rotation,
    required Widget child,
    required Size canvasSize,
    required bool isLocked,
  }) {
    return EditableElementWrapper(
      id: id,
      position: position,
      rotation: rotation,
      isSelected: selectedElementId == id,
      isEditingMode: isEditingMode,
      isLocked: isLocked,
      canvasSize: canvasSize,
      onTap: onElementTap,
      onPanStart: onElementPanStart,
      onPanUpdate: onElementPanUpdate,
      onPanEnd: onElementPanEnd,
      onDelete: onElementDelete,
      onSplit: onElementSplit,
      onRotateTap: onElementRotateTap,
      onRotatePanStart: onElementRotatePanStart,
      onRotatePanUpdate: onElementRotatePanUpdate,
      onRotatePanEnd: onElementRotatePanEnd,
      onResizeTap: onElementResizeTap,
      onResizePanStart: onElementResizePanStart,
      onResizePanUpdate: onElementResizePanUpdate,
      onResizePanEnd: onElementResizePanEnd,
      child: child,
    );
  }
}