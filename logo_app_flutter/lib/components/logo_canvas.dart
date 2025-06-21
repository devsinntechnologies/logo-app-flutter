// lib/widgets/logo_canvas.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart'; // Needed for SvgPicture.string
import 'dart:math'; // Needed for math.pi

import '../models/logo_state_data.dart';
import '../utils/text_size_util.dart';
import 'editable_element_wrapper.dart';
import 'grid_painter.dart';

class LogoCanvas extends StatelessWidget {
  final GlobalKey canvasKey; // Keep the key here for render box access
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
  // Callbacks for toggling UI elements
  final VoidCallback onToggleGrid;
  final VoidCallback onToggleLayersRibbon;

  // Element interaction callbacks (passed from DownloadLogoState)
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
          key: canvasKey, // Use the passed-in canvasKey

          children: [
            if (showGrid)
              CustomPaint(
                painter: GridPainter(
                  // Use the extracted GridPainter
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
            Positioned(
              // Grid Toggle button
              top: 20,
              right: 0,
              child: GestureDetector(
                onTap: onToggleGrid, // Use callback
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
            Positioned(
              // Layers Ribbon Toggle button
              top: 20,
              left: 0,
              child: GestureDetector(
                onTap: onToggleLayersRibbon, // Use callback
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
                          isLayersRibbonExtended
                              ? Icons.arrow_back_ios
                              : Icons.layers,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      if (isLayersRibbonExtended)
                        const Expanded(
                          // Changed to const for optimization
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 16.0),
                            child: Text(
                              'No Layers Found',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
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
            // Replaced all _buildEditableElement calls with EditableElementWrapper
            // Logo 1
            if (logoState.isLogoVisible)
              EditableElementWrapper(
                id: 0,
                position: logoState.logoPosition,
                rotation: logoState.logoRotation,
                isSelected: selectedElementId == 0,
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
                child: SvgPicture.string(
                  svgLogo,
                  height: logoState.logoSize,
                  width: logoState.logoSize,
                ),
              ),
            // Company Name 1
            if (logoState.isCompanyNameVisible)
              EditableElementWrapper(
                id: 1,
                position: logoState.companyNamePosition,
                rotation: logoState.companyNameRotation,
                isSelected: selectedElementId == 1,
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
                child: Text(
                  companyName,
                  style: TextStyle(
                    fontSize: logoState.companyNameSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Slogan 1
            if (logoState.isSloganVisible)
              EditableElementWrapper(
                id: 2,
                position: logoState.sloganPosition,
                rotation: logoState.sloganRotation,
                isSelected: selectedElementId == 2,
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
                child: Text(
                  sloganName,
                  style: TextStyle(
                    fontSize: logoState.sloganSize,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            // Logo 2
            if (logoState.isLogo2Visible)
              EditableElementWrapper(
                id: 3,
                position: logoState.logo2Position!,
                rotation: logoState.logo2Rotation!,
                isSelected: selectedElementId == 3,
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
                child: SvgPicture.string(
                  svgLogo,
                  height: logoState.logo2Size!,
                  width: logoState.logo2Size!,
                ),
              ),
            // Company Name 2
            if (logoState.isCompanyName2Visible)
              EditableElementWrapper(
                id: 4,
                position: logoState.companyName2Position!,
                rotation: logoState.companyName2Rotation!,
                isSelected: selectedElementId == 4,
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
                child: Text(
                  companyName,
                  style: TextStyle(
                    fontSize: logoState.companyName2Size!,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Slogan 2
            if (logoState.isSlogan2Visible)
              EditableElementWrapper(
                id: 5,
                position: logoState.slogan2Position!,
                rotation: logoState.slogan2Rotation!,
                isSelected: selectedElementId == 5,
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
                child: Text(
                  sloganName,
                  style: TextStyle(
                    fontSize: logoState.slogan2Size!,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
