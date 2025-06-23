import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

            // --- Grid Toggle ---
            Positioned(
              top: 20,
              right: 0,
              child: GestureDetector(
                onTap: onToggleGrid,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      bottomLeft: Radius.circular(25.0),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(-2, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    showGrid ? Icons.grid_off : Icons.grid_on,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

            // --- Layers Ribbon Toggle ---
            Positioned(
              top: 20,
              left: 0,
              child: GestureDetector(
                onTap: onToggleLayersRibbon,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isLayersRibbonExtended ? 180.0 : 60.0,
                  height: 44.0,
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(25.0),
                      bottomRight: Radius.circular(25.0),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Icon(
                          isLayersRibbonExtended ? Icons.arrow_back_ios : Icons.layers,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      if (isLayersRibbonExtended)
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 16.0),
                            child: Text(
                              'No Layers Found',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Logo SVG ---
            if (logoState.isLogoVisible)
              _buildEditableWrapper(
                id: 0,
                position: logoState.logoPosition,
                rotation: logoState.logoRotation,
                child: SvgPicture.string(svgLogo,
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

            // --- Optional: Second Slogan ---
            if (logoState.isSlogan2Visible && logoState.sloganName != null)
              _buildEditableWrapper(
                id: 5,
                position: logoState.slogan2Position ?? const Offset(50, 50),
                rotation: logoState.slogan2Rotation ?? 0,
                child: Text(
                  logoState.sloganName!,
                  style: TextStyle(
                    fontSize: logoState.slogan2Size ?? 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
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
