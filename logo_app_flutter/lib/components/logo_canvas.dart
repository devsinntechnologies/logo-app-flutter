// ✅ logo_canvas.dart
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
                opacity: checkerboardOpacity,
                child: Image.asset(
                  'lib/assets/icons/checkerboard.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            // --- Logo SVG ---
            if (logoState.isLogoVisible)
              _buildEditableWrapper(
                id: 0,
                position: logoState.logoPosition,
                rotation: logoState.logoRotation,
                child: SvgPicture.string(
                  svgLogo,
                  height: logoState.logoSize,
                  width: logoState.logoSize,
                ),
                canvasSize: canvasSize,
              ),

            // --- Company Name ---
            if (logoState.isCompanyNameVisible && logoState.companyName != null)
              _buildEditableWrapper(
                id: 1,
                position: logoState.companyNamePosition,
                rotation: logoState.companyNameRotation,
                child: Text(
                  logoState.companyName!,
                  style: TextStyle(
                    fontSize: logoState.companyNameSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                canvasSize: canvasSize,
              ),

            // --- Slogan ---
            if (logoState.isSloganVisible && logoState.sloganName != null)
              _buildEditableWrapper(
                id: 2,
                position: logoState.sloganPosition,
                rotation: logoState.sloganRotation,
                child: Text(
                  logoState.sloganName!,
                  style: TextStyle(
                    fontSize: logoState.sloganSize,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                canvasSize: canvasSize,
              ),

            // --- Custom Texts (Newly Added by User) ---
            for (int i = 0; i < logoState.customTexts.length; i++)
              _buildEditableWrapper(
                id: 100 + i,
                position: logoState.customTexts[i].position,
                rotation: logoState.customTexts[i].rotation,
                child: Text(
                  logoState.customTexts[i].text,
                  style: TextStyle(
                    fontSize: logoState.customTexts[i].size,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                canvasSize: canvasSize,
              ),
          ],
        );
      },
    );
  }

  Widget _buildEditableWrapper({
    required int id,
    required Offset position,
    required double rotation,
    required Widget child,
    required Size canvasSize,
  }) {
    return EditableElementWrapper(
      id: id,
      position: position,
      rotation: rotation,
      isSelected: selectedElementId == id,
      isEditingMode: isEditingMode,
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
