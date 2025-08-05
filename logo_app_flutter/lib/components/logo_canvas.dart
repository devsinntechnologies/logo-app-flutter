// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logo_app_flutter/components/logoBottomNavbarItems/shape_selector_widget.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:provider/provider.dart';

import '../models/logo_state_data.dart';
import 'editable_element_wrapper.dart';
import 'grid_painter.dart';

class LogoCanvas extends StatefulWidget {
  // final GlobalKey canvasKey;
  final String selectedShapeName;
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
  final List<int> elementOrder;
  final Set<int> lockedElements;

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
    Key? key,

    required this.selectedShapeName,
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
    required this.isCheckerboardActive,
    required this.isCheckerboardVisible,
    required this.checkerboardOpacity,
    this.elementOrder = const [],
    this.lockedElements = const {},
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
  }) : super(key: key);

  @override
  State<LogoCanvas> createState() => _LogoCanvasState();
}

class _LogoCanvasState extends State<LogoCanvas> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SelectedColorProvider>(context);
    final gradient = provider.selectedGradient;
    final providers = Provider.of<SelectedColorProvider>(context);
    final bgImage = providers.backgroundImage;
    final shapeColor =
        Provider.of<SelectedColorProvider>(context).selectedColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size canvasSize = constraints.biggest;
        return Stack(
          // key: widget.key,
          children: [
            if (widget.showGrid)
              CustomPaint(
                painter: GridPainter(
                  gridColor: Colors.black,
                  highlightedHorizontalLine:
                      widget.highlightedHorizontalGridLineIndex,
                  highlightedVerticalLine:
                      widget.highlightedVerticalGridLineIndex,
                ),
                size: Size.infinite,
              ),

            if (widget.isCheckerboardVisible)
              Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/icons/checkerboard.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            if (widget.isCheckerboardVisible &&
                widget.selectedShapeName == "Rounded Rect")
              Opacity(
                opacity: 1 * widget.checkerboardOpacity,
                child: Center(
                  child: CustomPaint(
                    size: const Size(280, 100),
                    painter: SquarePainter(shapeColor, gradient, bgImage),
                  ),
                ),
              ),

            if (widget.isCheckerboardVisible &&
                widget.selectedShapeName == "Diamond")
              Opacity(
                opacity: 1 * widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: DiamondPainter(shapeColor, gradient, bgImage),
                ),
              ),

            if (widget.isCheckerboardVisible &&
                widget.selectedShapeName == "Triangle")
              Opacity(
                opacity: 1 * widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: TrianglePainter(shapeColor, gradient, bgImage),
                ),
              ),
            if (widget.isCheckerboardVisible &&
                widget.selectedShapeName == "Pentagon")
              Opacity(
                opacity: 1 * widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: PentagonPainter(shapeColor, gradient, bgImage),
                ),
              ),
            if (widget.isCheckerboardVisible &&
                widget.selectedShapeName == "Hexagon")
              Opacity(
                opacity: 1 * widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: HexagonPainter(shapeColor, gradient, bgImage),
                ),
              ),
            if (widget.isCheckerboardVisible &&
                widget.selectedShapeName == "Star")
              Opacity(
                opacity: 1 * widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: StarPainter(shapeColor, gradient, bgImage),
                ),
              ),
            if (widget.isCheckerboardVisible &&
                widget.selectedShapeName == "Arrow")
              Opacity(
                opacity: 1 * widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: ArrowPainter(shapeColor, gradient, bgImage),
                ),
              ),
            if (widget.isCheckerboardVisible &&
                widget.selectedShapeName == "Heart")
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(200, 200),

                  painter: HeartPainter(shapeColor, gradient, bgImage),
                ),
              ),

            if (widget.isCheckerboardVisible &&
                widget.selectedShapeName == "Square")
              Opacity(
                opacity: 1 * widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: SquarePainter(shapeColor, gradient, bgImage),
                ),
              ),

            ...widget.elementOrder
                .map((id) => _buildElementById(id, canvasSize))
                .whereType<Widget>(),
          ],
        );
      },
    );
  }

  Widget? _buildElementById(int id, Size canvasSize) {
    final provider = Provider.of<SelectedColorProvider>(context);
    final shapeColor = provider.shapeColor;
    final companyColor = provider.companyTextColor;
    final sloganColor = provider.sloganColor;

    Widget wrap(
      Widget child, {
      required Offset position,
      required double rotation,
    }) {
      return _buildEditableWrapper(
        id: id,
        position: position,
        rotation: rotation,
        isLocked: widget.lockedElements.contains(id),
        child: child,
        canvasSize: canvasSize,
      );
    }

    // ✅ Custom Text Element with isVisible and opacity
    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index < widget.logoState.customTexts.length) {
        final customText = widget.logoState.customTexts[index];

        if (!(customText.isVisible)) return null;

        return wrap(
          Center(
            child: Opacity(
              opacity: customText.opacity?.clamp(0.0, 1.0) ?? 1.0,
              child: Text(
                customText.text,
                style: TextStyle(
                  fontSize: customText.size,
                  color: companyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          position: customText.position,
          rotation: customText.rotation,
        );
      }
      return null;
    }

    // ✅ Custom Image Element with isVisible and opacity
    if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index < widget.logoState.customImages.length) {
        final image = widget.logoState.customImages[index];

        if (!(image.isVisible)) return null;

        return wrap(
          Center(
            child: Opacity(
              opacity: image.opacity?.clamp(0.0, 1.0) ?? 1.0,
              child: Image.file(
                File(image.path),
                height: image.size ?? 100,
                width: image.size ?? 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          position: image.position,
          rotation: image.rotation,
        );
      }
      return null;
    }

    // 🔁 Your remaining switch-case block remains unchanged:
    switch (id) {
      case 0:
        final logoSize = widget.logoState.logoSize;
        final logoPosition =
            (widget.logoState.logoPosition == Offset.zero ||
                        widget.logoState.logoPosition == null) &&
                    widget.isEditingMode
                ? Offset(
                  canvasSize.width / 2 - logoSize / 2,
                  canvasSize.height / 2 - 150,
                )
                : widget.logoState.logoPosition;

        return widget.logoState.isLogoVisible
            ? wrap(
              SvgPicture.string(
                widget.svgLogo,
                height: logoSize,
                width: logoSize,
                colorFilter:
                    provider.isColorOverrideActive
                        ? ColorFilter.mode(shapeColor, BlendMode.srcIn)
                        : null,
              ),
              position: logoPosition,
              rotation: widget.logoState.logoRotation,
            )
            : null;

      case 1:
        final nameText = widget.logoState.companyName ?? '';
        final nameSize = widget.logoState.companyNameSize;
        final nameWidth = nameText.length * nameSize * 0.6;
        final namePosition =
            (widget.logoState.companyNamePosition == Offset.zero ||
                        widget.logoState.companyNamePosition == null) &&
                    widget.isEditingMode
                ? Offset(
                  canvasSize.width / 2 - nameWidth / 2,
                  canvasSize.height / 2 - 60,
                )
                : widget.logoState.companyNamePosition;

        return widget.logoState.isCompanyNameVisible
            ? wrap(
              Text(
                nameText,
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.bold,
                  color: companyColor,
                ),
              ),
              position: namePosition!,
              rotation: widget.logoState.companyNameRotation,
            )
            : null;

      case 2:
        final sloganText = widget.logoState.sloganName ?? '';
        final sloganSize = widget.logoState.sloganSize;
        final sloganWidth = sloganText.length * sloganSize * 0.6;
        final sloganPosition =
            (widget.logoState.sloganPosition == Offset.zero ||
                        widget.logoState.sloganPosition == null) &&
                    widget.isEditingMode
                ? Offset(
                  canvasSize.width / 2 - sloganWidth / 2,
                  canvasSize.height / 2 + 20,
                )
                : widget.logoState.sloganPosition;

        return widget.logoState.isSloganVisible
            ? wrap(
              Center(
                child: Text(
                  sloganText,
                  style: TextStyle(
                    fontSize: sloganSize,
                    fontStyle: FontStyle.italic,
                    color: sloganColor,
                  ),
                ),
              ),
              position: sloganPosition,
              rotation: widget.logoState.sloganRotation,
            )
            : null;

      case 3:
        final logo2Size = widget.logoState.logo2Size ?? 100;
        final logo2Position =
            (widget.logoState.logo2Position == null ||
                        widget.logoState.logo2Position == Offset.zero) &&
                    widget.isEditingMode
                ? Offset(
                  canvasSize.width / 2 - logo2Size / 2,
                  canvasSize.height / 2 - 150,
                )
                : widget.logoState.logo2Position ?? Offset.zero;

        return widget.logoState.isLogo2Visible
            ? wrap(
              SvgPicture.string(
                widget.svgLogo,
                height: logo2Size,
                width: logo2Size,
                colorFilter:
                    provider.isColorOverrideActive
                        ? ColorFilter.mode(shapeColor, BlendMode.srcIn)
                        : null,
              ),
              position: logo2Position,
              rotation: widget.logoState.logo2Rotation ?? 0,
            )
            : null;

      case 4:
        final name2Text = widget.logoState.companyName ?? '';
        final name2Size = widget.logoState.companyName2Size ?? 20;
        final name2Width = _calculateTextWidth(name2Text, name2Size);
        final name2Position =
            (widget.logoState.companyName2Position == null ||
                        widget.logoState.companyName2Position == Offset.zero) &&
                    widget.isEditingMode
                ? Offset(
                  canvasSize.width / 2 - name2Width / 2,
                  canvasSize.height / 2 - 60,
                )
                : widget.logoState.companyName2Position ?? Offset.zero;

        return widget.logoState.isCompanyName2Visible
            ? wrap(
              Text(
                name2Text,
                style: TextStyle(
                  fontSize: name2Size,
                  fontWeight: FontWeight.bold,
                  color: companyColor,
                ),
              ),
              position: name2Position,
              rotation: widget.logoState.companyName2Rotation ?? 0,
            )
            : null;

      case 5:
        final slogan2Text = widget.logoState.sloganName ?? '';
        final slogan2Size = widget.logoState.slogan2Size ?? 18;
        final slogan2Width = _calculateTextWidth(slogan2Text, slogan2Size);
        final slogan2Position =
            (widget.logoState.slogan2Position == null ||
                        widget.logoState.slogan2Position == Offset.zero) &&
                    widget.isEditingMode
                ? Offset(
                  canvasSize.width / 2 - slogan2Width / 2,
                  canvasSize.height / 2 + 20,
                )
                : widget.logoState.slogan2Position ?? Offset.zero;

        return widget.logoState.isSlogan2Visible
            ? wrap(
              Text(
                slogan2Text,
                style: TextStyle(
                  fontSize: slogan2Size,
                  fontStyle: FontStyle.italic,
                  color: sloganColor,
                ),
              ),
              position: slogan2Position,
              rotation: widget.logoState.slogan2Rotation ?? 0,
            )
            : null;

      default:
        return null;
    }
  }

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
      isSelected: widget.selectedElementId == id,
      isEditingMode: widget.isEditingMode,
      isLocked: isLocked,
      canvasSize: canvasSize,
      onTap: widget.onElementTap,
      onPanStart: widget.onElementPanStart,
      onPanUpdate: widget.onElementPanUpdate,
      onPanEnd: widget.onElementPanEnd,
      onDelete: widget.onElementDelete,
      onSplit: widget.onElementSplit,
      onRotateTap: widget.onElementRotateTap,
      onRotatePanStart: widget.onElementRotatePanStart,
      onRotatePanUpdate: widget.onElementRotatePanUpdate,
      onRotatePanEnd: widget.onElementRotatePanEnd,
      onResizeTap: widget.onElementResizeTap,
      onResizePanStart: widget.onElementResizePanStart,
      onResizePanUpdate: widget.onElementResizePanUpdate,
      onResizePanEnd: widget.onElementResizePanEnd,
      child: child,
    );
  }

  double _calculateTextWidth(String text, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}
