// ignore_for_file: unnecessary_null_comparison, avoid_print, no_leading_underscores_for_local_identifiers

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

    final String selectedShape =
        (widget.selectedShapeName.isEmpty)
            ? "Square"
            : widget.selectedShapeName;

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size canvasSize = constraints.biggest;
        return Stack(
          children: [
            if (widget.showGrid)
              CustomPaint(
                painter: GridPainter(
                  gridColor: Colors.blue,
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

            // ✅ Square show only if selected
            if (widget.isCheckerboardVisible && selectedShape == "Square")
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: SquarePainter(shapeColor, gradient, bgImage),
                ),
              ),

            if (widget.isCheckerboardVisible && selectedShape == "Rounded Rect")
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: Center(
                  child: CustomPaint(
                    size: const Size(280, 100),
                    painter: SquarePainter(shapeColor, gradient, bgImage),
                  ),
                ),
              ),

            if (widget.isCheckerboardVisible && selectedShape == "Diamond")
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: DiamondPainter(shapeColor, gradient, bgImage),
                ),
              ),

            if (widget.isCheckerboardVisible && selectedShape == "Triangle")
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: TrianglePainter(shapeColor, gradient, bgImage),
                ),
              ),

            if (widget.isCheckerboardVisible && selectedShape == "Pentagon")
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: PentagonPainter(shapeColor, gradient, bgImage),
                ),
              ),

            if (widget.isCheckerboardVisible && selectedShape == "Hexagon")
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: HexagonPainter(shapeColor, gradient, bgImage),
                ),
              ),

            if (widget.isCheckerboardVisible && selectedShape == "Star")
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: StarPainter(shapeColor, gradient, bgImage),
                ),
              ),

            if (widget.isCheckerboardVisible && selectedShape == "Arrow")
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: ArrowPainter(shapeColor, gradient, bgImage),
                ),
              ),

            if (widget.isCheckerboardVisible && selectedShape == "Heart")
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: HeartPainter(shapeColor, gradient, bgImage),
                ),
              ),
            if (widget.isCheckerboardActive == false ||
                widget.isCheckerboardVisible == false ||
                selectedShape.isEmpty)
              Opacity(
                opacity: widget.checkerboardOpacity,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: SquarePainter(shapeColor, gradient, bgImage),
                ),
              ),

            ...(widget.elementOrder.isNotEmpty
                    ? widget.elementOrder
                    : widget.logoState.visibleElementIds)
                .map((id) => _buildElementById(id, canvasSize))
                .whereType<Widget>(),
          ],
        );
      },
    );
  }

  Widget? _buildElementById(int id, Size canvasSize) {
    final provider = Provider.of<SelectedColorProvider>(context, listen: true);

    final bool isSelected = provider.selectedElementId == id;
    final outlineColor = provider.getOutlineColor(id);
    final outlineWidth = provider.getOutlineWidth(id);

    const Color highlightColor = Colors.red;

    final Color shapeColor =
        (isSelected && id == 0) ? provider.selectedColor : provider.shapeColor;
    final Color companyColor =
        (isSelected && id == 1) ? highlightColor : provider.companyTextColor;
    final Color sloganColor =
        (isSelected && id == 2) ? highlightColor : provider.sloganColor;

    final scaleFactor = 0.2;

    Size _calculateTextSize(String text, TextStyle style) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      return textPainter.size;
    }

    Widget wrap(
      Widget child, {
      required Offset centerPosition,
      required double rotation,
      required Size childSize,
    }) {
      final topLeftPosition = Offset(
        centerPosition.dx - childSize.width / 3,
        centerPosition.dy - childSize.height / 2.5,
      );

      return _buildEditableWrapper(
        id: id,
        position: topLeftPosition,
        rotation: rotation,
        isLocked: widget.lockedElements.contains(id),
        child: child,
        canvasSize: canvasSize,
      );
    }

    Offset _centerAlign(Size canvasSize, Size childSize) {
      return Offset(canvasSize.width / 2, canvasSize.height / 2);
    }

    // ✅ Custom Text (100–199)
    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index < 0 || index >= widget.logoState.customTexts.length)
        return null;
      final customText = widget.logoState.customTexts[index];
      if (!customText.isVisible) return null;

      final textStyle = TextStyle(
        fontSize: customText.size,
        color: companyColor,
        fontWeight: FontWeight.w500,
      );

      final measuredSize = _calculateTextSize(customText.text, textStyle);
      final textSize = Size(
        measuredSize.width * scaleFactor,
        measuredSize.height * scaleFactor,
      );

      return wrap(
        Center(
          child: Opacity(
            opacity: customText.opacity.clamp(0.0, 1.0),
            child: StrokedText(
              text: customText.text,
              style: textStyle,
              strokeColor: outlineColor,
              strokeWidth: outlineWidth,
            ),
          ),
        ),
        centerPosition: customText.position,
        rotation: customText.rotation,
        childSize: textSize,
      );
    }

    // ✅ Custom Images (200–299)
    if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index < 0 || index >= widget.logoState.customImages.length)
        return null;
      final image = widget.logoState.customImages[index];
      if (!image.isVisible) return null;

      final imageSize = Size(image.size ?? 100, image.size ?? 100);

      return wrap(
        Center(
          child: Opacity(
            opacity: image.opacity?.clamp(0.0, 1.0) ?? 1.0,
            child:
                image.path.startsWith('assets/')
                    ? Image.asset(
                      image.path,
                      height: imageSize.height,
                      width: imageSize.width,
                      fit: BoxFit.contain,
                    )
                    : Image.file(
                      File(image.path),
                      height: imageSize.height,
                      width: imageSize.width,
                      fit: BoxFit.contain,
                    ),
          ),
        ),
        centerPosition: image.position,
        rotation: image.rotation,
        childSize: imageSize,
      );
    }

    // ✅ Custom SVG (300–399) + Outline
    if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index < 0 || index >= widget.logoState.customSVGs.length) return null;
      final svgElement = widget.logoState.customSVGs[index];
      if (!svgElement.isVisible) return null;

      final svgSize = Size(svgElement.size, svgElement.size);

      

      return wrap(
  StrokedSvg(
    svgString: svgElement.svgString,
    width: svgElement.size,
    height: svgElement.size,
    strokeColor: outlineColor,
    strokeWidth: outlineWidth,
    fillColor: null, // ya agar fill color dena ho to pass kar do
  ),
  centerPosition: svgElement.position,
  rotation: svgElement.rotation,
  childSize: svgSize,
);

    }

    // ✅ Main Logo / Company Name / Slogan
    switch (id) {
    
      case 0: // Shape (Main Logo SVG)
  final logoSize = widget.logoState.logoSize;
  final shapeSize = Size(logoSize, logoSize) * 0.9;
  final centerPosition =
      (widget.logoState.logoPosition == Offset.zero ||
              widget.logoState.logoPosition == null)
          ? _centerAlign(canvasSize, shapeSize)
          : widget.logoState.logoPosition;

  return widget.logoState.isLogoVisible
      ? wrap(
          StrokedSvg(
            svgString: widget.svgLogo,
            width: logoSize,
            height: logoSize,
            strokeColor: outlineColor,
            strokeWidth: outlineWidth,
            fillColor: provider.isColorOverrideActive || isSelected
                ? (isSelected ? highlightColor : shapeColor)
                : null,
          ),
          centerPosition: centerPosition,
          rotation: widget.logoState.logoRotation,
          childSize: shapeSize,
        )
      : null;


      case 1: // Company Name
        final nameText = widget.logoState.companyName ?? '';
        final nameSize = widget.logoState.companyNameSize;
        final textStyle = TextStyle(
          fontSize: nameSize,
          fontWeight: FontWeight.bold,
          color: companyColor,
        );
        final textSize = _calculateTextSize(nameText, textStyle) * 1.09;
        final centerPosition =
            (widget.logoState.companyNamePosition == Offset.zero ||
                    widget.logoState.companyNamePosition == null)
                ? _centerAlign(canvasSize, textSize)
                : widget.logoState.companyNamePosition;

        return widget.logoState.isCompanyNameVisible
            ? wrap(
              StrokedText(
                text: nameText,
                style: textStyle,
                strokeColor: outlineColor,
                strokeWidth: outlineWidth,
              ),
              centerPosition: centerPosition,
              rotation: widget.logoState.companyNameRotation,
              childSize: textSize,
            )
            : null;

      case 2: // Slogan
        final sloganText = widget.logoState.sloganName ?? '';
        final sloganSize = widget.logoState.sloganSize;
        final sloganStyle = TextStyle(fontSize: sloganSize, color: sloganColor);
        final sloganMeasured =
            _calculateTextSize(sloganText, sloganStyle) * scaleFactor;
        final centerPosition =
            (widget.logoState.sloganPosition == Offset.zero ||
                    widget.logoState.sloganPosition == null)
                ? _centerAlign(canvasSize, sloganMeasured)
                : widget.logoState.sloganPosition;

        return widget.logoState.isSloganVisible
            ? wrap(
              Center(
                child: StrokedText(
                  text: sloganText,
                  style: sloganStyle,
                  strokeColor: outlineColor,
                  strokeWidth: outlineWidth,
                ),
              ),
              centerPosition: centerPosition,
              rotation: widget.logoState.sloganRotation,
              childSize: sloganMeasured,
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
}

class StrokedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color strokeColor;
  final double strokeWidth;

  const StrokedText({
    super.key,
    required this.text,
    required this.style,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stroke
        Text(
          text,
          style: style.copyWith(
            foreground:
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = strokeColor,
          ),
        ),
        // Fill
        Text(text, style: style),
      ],
    );
  }
}


class StrokedSvg extends StatelessWidget {
  final String svgString;
  final double width;
  final double height;
  final Color strokeColor;
  final double strokeWidth;
  final Color? fillColor;

  const StrokedSvg({
    super.key,
    required this.svgString,
    required this.width,
    required this.height,
    required this.strokeColor,
    required this.strokeWidth,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Stroke layer: draw multiple slightly offset copies
        for (final offset in [
          Offset(-strokeWidth, 0),
          Offset(strokeWidth, 0),
          Offset(0, -strokeWidth),
          Offset(0, strokeWidth),
          Offset(-strokeWidth, -strokeWidth),
          Offset(-strokeWidth, strokeWidth),
          Offset(strokeWidth, -strokeWidth),
          Offset(strokeWidth, strokeWidth),
        ])
          Transform.translate(
            offset: offset,
            child: SvgPicture.string(
              svgString,
              width: width,
              height: height,
              colorFilter: ColorFilter.mode(strokeColor, BlendMode.srcIn),
            ),
          ),

        // Fill layer
        SvgPicture.string(
          svgString,
          width: width,
          height: height,
          colorFilter:
              fillColor != null ? ColorFilter.mode(fillColor!, BlendMode.srcIn) : null,
        ),
      ],
    );
  }
}









