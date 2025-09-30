// ignore_for_file: unnecessary_null_comparison, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logo_app_flutter/components/logoBottomNavbarItems/shape_selector_widget.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:provider/provider.dart';

import '../models/logo_state_data.dart';
import 'editable_element_wrapper.dart';
import 'grid_painter.dart';

class LogoCanvas extends StatefulWidget {
  final String selectedShapeName;
  final LogoStateData logoState;
  final double gridOpacity;
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
  final List<int> elementOrder; // <- already passed from DownloadLogo
  final Set<int> lockedElements; // <- already passed

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
    required this.gridOpacity,
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
  });

  @override
  State<LogoCanvas> createState() => _LogoCanvasState();
}

class _LogoCanvasState extends State<LogoCanvas> {
  List<Widget> _buildChildrenInOrder(Size canvasSize) {
    // last in the list paints on top in a Stack
    final ids =
        widget.elementOrder.isNotEmpty
            ? widget.elementOrder
            : widget.logoState.visibleElementIds;

    final out = <Widget>[];
    for (final id in ids) {
      final w = _buildElementById(id, canvasSize);
      if (w != null) out.add(w);
    }
    return out;
  }

  TextStyle _applyFont(String? family, TextStyle base) {
    if (family == null || family.isEmpty) return base;
    try {
      return GoogleFonts.getFont(family, textStyle: base);
    } catch (e) {
      debugPrint('Unknown font family "$family": $e');
      return base.copyWith(fontFamily: family);
    }
  }

  Widget wrap(
    Widget child, {
    required Offset position,
    required double rotation,
    required Size childSize,
    required int elementId,
  }) {
    final provider = Provider.of<SelectedColorProvider>(context, listen: false);
    final rotationX = provider.getRotationXForElement(elementId) ?? 0.0;
    final rotationY = provider.getRotationYForElement(elementId) ?? 0.0;
    final rotationZ = provider.getRotationZForElement(elementId) ?? 0.0;

    return _buildEditableWrapper(
      id: elementId,
      position: position,
      rotation: rotation,
      isLocked: (provider.getCurrentLogoState() ?? widget.logoState)
          .lockedElements
          .contains(elementId),
      child: Transform(
        alignment: Alignment.center,
        transform:
            Matrix4.identity()
              ..rotateX(rotationX * pi / 180)
              ..rotateY(rotationY * pi / 180)
              ..rotateZ(rotationZ * pi / 180),
        child: child,
      ),
      canvasSize: _lastCanvasSize ?? const Size(0, 0),
    );
  }

  Offset _centerTopLeft(Size canvasSize, Size childSize) {
    return Offset(
      (canvasSize.width - childSize.width) / 2,
      (canvasSize.height - childSize.height) / 2,
    );
  }

  Size? _lastCanvasSize;

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
        final canvasSize = constraints.biggest;

  
        print('Canvas elementOrder: ${widget.elementOrder}');

        return Stack(
          clipBehavior: Clip.none,
          children: [
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

            if (widget.isCheckerboardVisible && selectedShape == "Square")
              Opacity(
                opacity: widget.checkerboardOpacity, // Controlled by slider
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

            if (widget.showGrid)
              CustomPaint(
                painter: GridPainter(
                  gridColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(widget.gridOpacity)
                          : Colors.black.withOpacity(widget.gridOpacity),
                  highlightedHorizontalLine:
                      widget.highlightedHorizontalGridLineIndex,
                  highlightedVerticalLine:
                      widget.highlightedVerticalGridLineIndex,
                ),
                size: constraints.biggest,
              ),
            ..._buildChildrenInOrder(canvasSize),
          ],
        );
      },
    );
  }

  Widget _buildSvgWithGradient({
    required String svgString,
    required double width,
    required double height,
    required Color strokeColor,
    required double strokeWidth,
    required Color? fillColor,
    required int elementId,
    required SelectedColorProvider provider,
  }) {
    final hasGradient = provider.hasGradientForElement(elementId);

    if (hasGradient) {
      final gradient = provider.getGradientForElement(elementId);

      return ShaderMask(
        shaderCallback: (bounds) {
          if (gradient is LinearGradient) {
            return gradient.createShader(bounds);
          } else if (gradient is RadialGradient) {
            return gradient.createShader(bounds);
          } else if (gradient is SweepGradient) {
            return gradient.createShader(bounds);
          }
          return LinearGradient(
            colors: gradient!.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: StrokedSvg(
          svgString: svgString,
          width: width,
          height: height,
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
          fillColor: Colors.white,
        ),
      );
    }

    return StrokedSvg(
      svgString: svgString,
      width: width,
      height: height,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      fillColor: fillColor,
    );
  }

  Widget? _buildElementById(int id, Size canvasSize) {
    final provider = Provider.of<SelectedColorProvider>(context, listen: true);

    final currentLogoState = provider.getCurrentLogoState() ?? widget.logoState;
    final isElementLocked = currentLogoState.lockedElements.contains(id);
    final bool isSelected = provider.selectedElementId == id;
    final outlineColor = provider.getOutlineColor(id) ?? Colors.transparent;
    final outlineWidth = provider.getOutlineWidth(id) ?? 0.0;

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
      required Offset position,
      required double rotation,
      required Size childSize,
      required int elementId,
    }) {
      final provider = Provider.of<SelectedColorProvider>(
        context,
        listen: false,
      );
      final rotationX = provider.getRotationXForElement(elementId) ?? 0.0;
      final rotationY = provider.getRotationYForElement(elementId) ?? 0.0;
      final rotationZ = provider.getRotationZForElement(elementId) ?? 0.0;

      return _buildEditableWrapper(
        id: elementId,
        position: position,
        rotation: rotation,
        isLocked: (provider.getCurrentLogoState() ?? widget.logoState)
            .lockedElements
            .contains(elementId),
        child: Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()
                ..rotateX(rotationX * pi / 180)
                ..rotateY(rotationY * pi / 180)
                ..rotateZ(rotationZ * pi / 180),
          child: child,
        ),
        canvasSize: _lastCanvasSize ?? const Size(0, 0),
      );
    }

    Offset _centerAlign(Size canvasSize, Size childSize) {
      return Offset(canvasSize.width / 2, canvasSize.height / 2);
    }

    // ✅ Custom Text (100–199)
    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index < widget.logoState.customTexts.length) {
        final customText = widget.logoState.customTexts[index];

        final provider = Provider.of<SelectedColorProvider>(
          context,
          listen: false,
        );

        final String? family =
            provider.getFontForElement(id) ??
            customText.fontFamily ??
            provider.getFontForElement(1) ??
            widget.logoState.companyNameFont ??
            'Roboto';

        final styleState = provider.getFontStyleForElement(id);
        final textStyle = _applyFont(
          family,
          TextStyle(
            fontSize: provider.getSizeForElement(id) ?? customText.size,
            color:
                provider.getElementColor(id) ??
                customText.color ??
                Colors.black,
            fontWeight: styleState.isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle:
                styleState.isItalic ? FontStyle.italic : FontStyle.normal,
            decoration:
                styleState.isUnderline
                    ? TextDecoration.underline
                    : TextDecoration.none,
          ),
        );

        final measuredSize = _calculateTextSize(customText.text, textStyle);
        final topLeft =
            customText.position == Offset.zero
                ? _centerTopLeft(canvasSize, measuredSize)
                : customText.position;

        return wrap(
          Center(
            child: Opacity(
              opacity: (customText.opacity ?? 1.0).clamp(0.0, 1.0),
              child: _buildTextWithGradient(
                text: customText.text,
                style: textStyle,
                elementId: id,
                provider: provider,
              ),
            ),
          ),
          position: topLeft,
          rotation: customText.rotation,
          childSize: measuredSize,
          elementId: id,
        );
      }
    }
    // ✅ Custom Images (200–299)
    if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index < 0 || index >= widget.logoState.customImages.length) {
        return null;
      }
      final image = widget.logoState.customImages[index];
      if (!image.isVisible) return null;

      final double size = provider.getSizeForElement(id) ?? image.size ?? 100;
      final imageSize = Size(size, size);
      final topLeft =
          image.position == Offset.zero
              ? _centerTopLeft(canvasSize, imageSize)
              : image.position;

      Widget imageWidget;

      try {
        if (image.isAsset || image.path.startsWith('assets/')) {
          // For asset images
          imageWidget = Image.asset(
            image.path,
            height: imageSize.height,
            width: imageSize.width,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('Asset loading error for ${image.path}: $error');
              return Container(
                height: imageSize.height,
                width: imageSize.width,
                color: Colors.red.withOpacity(0.3),
                child: const Icon(Icons.broken_image, color: Colors.red),
              );
            },
          );
        } else {
          // For file images
          imageWidget = Image.file(
            File(image.path),
            height: imageSize.height,
            width: imageSize.width,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('File loading error for ${image.path}: $error');
              return Container(
                height: imageSize.height,
                width: imageSize.width,
                color: Colors.red.withOpacity(0.3),
                child: const Icon(Icons.broken_image, color: Colors.red),
              );
            },
          );
        }
      } catch (e) {
        print('Image loading exception for ${image.path}: $e');
        imageWidget = Container(
          height: imageSize.height,
          width: imageSize.width,
          color: Colors.grey.withOpacity(0.3),
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
      }

      // Then apply opacity and return the widget:
      return wrap(
        Center(
          child: Opacity(
            opacity: image.opacity.clamp(0.0, 1.0),
            child: imageWidget,
          ),
        ),
        position: topLeft,
        rotation: image.rotation,
        childSize: imageSize,
        elementId: id,
      );
    }

    // ✅ Custom SVG (300–399)
    if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index < 0 || index >= widget.logoState.customSVGs.length) return null;
      final svgElement = widget.logoState.customSVGs[index];
      if (!svgElement.isVisible) return null;

      final double size = provider.getSizeForElement(id) ?? svgElement.size;
      final svgSize = Size(size, size);
      final topLeft =
          svgElement.position == Offset.zero
              ? _centerTopLeft(canvasSize, svgSize)
              : svgElement.position;

      return wrap(
        Consumer<SelectedColorProvider>(
          builder: (context, provider, _) {
            return Opacity(
              opacity: provider.opacity,
              child: StrokedSvg(
                svgString: svgElement.svgString,
                width: size,
                height: size,
                strokeColor: svgElement.outlineColor ?? Colors.transparent,
                strokeWidth: svgElement.outlineWidth ?? 0.0,
                fillColor: svgElement.color,
              ),
            );
          },
        ),
        position: topLeft,
        rotation: svgElement.rotation,
        childSize: svgSize,
        elementId: id,
      );
    }

    // ✅ Main Logo / Company Name / Slogan
    switch (id) {
      // Replace case 0 in your _buildElementById method:

      case 0: // Shape (Main Logo SVG)
        final logoSize =
            provider.getSizeForElement(0) ?? widget.logoState.logoSize;
        final shapeSize = Size(logoSize, logoSize); // no 0.9 shrink
        final topLeft =
            (widget.logoState.logoPosition == Offset.zero)
                ? _centerTopLeft(canvasSize, shapeSize)
                : widget.logoState.logoPosition;

        return widget.logoState.isLogoVisible
            ? wrap(
              Consumer<SelectedColorProvider>(
                builder: (context, provider, _) {
                  return Opacity(
                    opacity: provider.opacity,
                    child: _buildSvgWithGradient(
                      svgString: widget.svgLogo,
                      width: logoSize,
                      height: logoSize,
                      strokeColor: outlineColor,
                      strokeWidth: outlineWidth,
                      fillColor:
                          isSelected
                              ? highlightColor
                              : (provider.isSvgColorOverridden
                                  ? shapeColor
                                  : null),
                      elementId: 0,
                      provider: provider,
                    ),
                  );
                },
              ),
              position: topLeft,
              rotation:
                  provider.getRotationForElement(id) ??
                  widget.logoState.logoRotation,
              childSize: shapeSize,
              elementId: id,
            )
            : null;

      case 1:
        final nameText = widget.logoState.companyName ?? '';
        final nameSize =
            provider.getSizeForElement(id) ?? widget.logoState.companyNameSize;
        final styleState = provider.getFontStyleForElement(id);

        final String? family =
            provider.getFontForElement(id) ?? widget.logoState.companyNameFont;

        final textStyle = _applyFont(
          family,
          TextStyle(
            fontSize: nameSize,
            fontWeight: styleState.isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle:
                styleState.isItalic ? FontStyle.italic : FontStyle.normal,
            decoration:
                styleState.isUnderline
                    ? TextDecoration.underline
                    : TextDecoration.none,
            color: provider.getElementColor(id) ?? companyColor,
          ),
        );
        final textSize = _calculateTextSize(nameText, textStyle); // no 1.09
        final topLeft =
            (widget.logoState.companyNamePosition == Offset.zero)
                ? _centerTopLeft(canvasSize, textSize)
                : widget.logoState.companyNamePosition;

        return widget.logoState.isCompanyNameVisible
            ? wrap(
              Consumer<SelectedColorProvider>(
                builder: (context, provider, _) {
                  return Opacity(
                    opacity: provider.opacity,
                    child: _buildTextWithGradient(
                      text: nameText,
                      style: textStyle,
                      elementId: 1,
                      provider: provider,
                    ),
                  );
                },
              ),
              position: topLeft,
              rotation:
                  provider.getRotationForElement(id) ??
                  widget.logoState.companyNameRotation,
              childSize: textSize,
              elementId: id,
            )
            : null;

      case 2: // Slogan
        final sloganText = widget.logoState.sloganName ?? '';
        final sloganSize =
            provider.getSizeForElement(id) ?? widget.logoState.sloganSize;
        final styleState = provider.getFontStyleForElement(id);

        final String? family =
            provider.getFontForElement(id) ?? widget.logoState.sloganFont;

        final sloganStyle = _applyFont(
          family,
          TextStyle(
            fontSize: sloganSize,
            fontWeight: styleState.isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle:
                styleState.isItalic ? FontStyle.italic : FontStyle.normal,
            decoration:
                styleState.isUnderline
                    ? TextDecoration.underline
                    : TextDecoration.none,
            color: provider.getElementColor(id) ?? sloganColor,
          ),
        );
        final sloganMeasured = _calculateTextSize(sloganText, sloganStyle);
        final topLeft =
            (widget.logoState.sloganPosition == Offset.zero)
                ? _centerTopLeft(canvasSize, sloganMeasured)
                : widget.logoState.sloganPosition;

        return widget.logoState.isSloganVisible
            ? wrap(
              Consumer<SelectedColorProvider>(
                builder: (context, provider, _) {
                  return Opacity(
                    opacity: provider.opacity,
                    child: _buildTextWithGradient(
                      text: sloganText,
                      style: sloganStyle,
                      elementId: 2,
                      provider: provider,
                    ),
                  );
                },
              ),
              position: topLeft,
              rotation:
                  provider.getRotationForElement(id) ??
                  widget.logoState.sloganRotation,
              childSize: sloganMeasured,
              elementId: id,
            )
            : null;
    }
  }

  Widget _buildTextWithGradient({
    required String text,
    required TextStyle style,
    required int elementId,
    required SelectedColorProvider provider,
  }) {
    final double outlineWidth = provider.getOutlineWidth(elementId);
    final Color outlineColor = provider.getOutlineColor(elementId);
    final double sx = provider.getShadowOffsetXForElement(elementId);
    final double sy = provider.getShadowOffsetYForElement(elementId);
    final Color shadowColor = provider.getShadowColorForElement(elementId);
    final bool hasShadow = (sx != 0 || sy != 0);

    final gradient = provider.getGradientForElement(elementId);

    if (gradient == null) {
      return StrokedText(
        text: text,
        style: style,
        strokeColor: outlineColor,
        strokeWidth: outlineWidth,
        showShadow: hasShadow,
        shadowOffset: Offset(sx, sy),
        shadowColor: shadowColor,
        shadowBlur: 8,
      );
    }

    final strokeAndShadow = StrokedText(
      text: text,
      style: style.copyWith(color: Colors.transparent),
      strokeColor: outlineColor,
      strokeWidth: outlineWidth,
      showShadow: hasShadow,
      shadowOffset: Offset(sx, sy),
      shadowColor: shadowColor,
      shadowBlur: 8,
    );

    final gradientFill = ShaderMask(
      shaderCallback: (bounds) {
        if (gradient is LinearGradient) return gradient.createShader(bounds);
        if (gradient is RadialGradient) return gradient.createShader(bounds);
        if (gradient is SweepGradient) return gradient.createShader(bounds);
        return LinearGradient(
          colors: gradient.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: style.copyWith(color: Colors.white, foreground: null),
      ),
    );

    return Stack(
      alignment: Alignment.topLeft,
      children: [strokeAndShadow, gradientFill],
    );
  }

  Widget _buildElementWithGradient(int elementId, Widget child) {
    return Consumer<SelectedColorProvider>(
      builder: (context, provider, _) {
        final hasGradient = provider.hasGradientForElement(elementId);

        if (hasGradient) {
          final gradient = provider.getGradientForElement(elementId);

          return ShaderMask(
            shaderCallback: (bounds) {
              if (gradient is LinearGradient) {
                return LinearGradient(
                  colors: gradient.colors,
                  stops: gradient.stops,
                  begin: gradient.begin,
                  end: gradient.end,
                ).createShader(bounds);
              } else if (gradient is RadialGradient) {
                return RadialGradient(
                  colors: gradient.colors,
                  stops: gradient.stops,
                  center: gradient.center,
                  radius: gradient.radius,
                ).createShader(bounds);
              }
              return LinearGradient(
                colors: gradient!.colors,
              ).createShader(bounds);
            },
            child: child,
          );
        }

        return child;
      },
    );
  }

  Widget _buildCustomImage(CustomImageElement imageElement, int id) {
    return Positioned(
      left: imageElement.position.dx,
      top: imageElement.position.dy,
      child: Transform.rotate(
        angle: imageElement.rotation * pi / 180,
        child: Container(
          width: imageElement.size,
          height: imageElement.size,
          child:
              imageElement.isAsset
                  ? Image.asset(
                    imageElement.path,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.red.withOpacity(0.3),
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  )
                  : Image.file(
                    File(imageElement.path),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.red.withOpacity(0.3),
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
        ),
      ),
    );
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
      child: Transform.rotate(angle: rotation * pi / 180, child: child),
    );
  }
}

class StrokedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color strokeColor;
  final double strokeWidth;
  final bool showShadow;
  final Offset shadowOffset;
  final double shadowBlur;
  final Color shadowColor;

  const StrokedText({
    super.key,
    required this.text,
    required this.style,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2,
    this.showShadow = false,
    this.shadowOffset = const Offset(4, 4),
    this.shadowBlur = 8,
    this.shadowColor = const Color(0x80000000),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showShadow)
          Positioned(
            left: shadowOffset.dx,
            top: shadowOffset.dy,
            child: Text(
              text,
              style: style.copyWith(
                color: shadowColor,
                foreground: null,
                shadows: [
                  Shadow(
                    color: shadowColor,
                    offset: Offset.zero,
                    blurRadius: shadowBlur,
                  ),
                ],
              ),
            ),
          ),
        // Stroke
        if (strokeWidth > 0)
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
        if (strokeWidth > 0)
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
              fillColor != null
                  ? ColorFilter.mode(fillColor!, BlendMode.srcIn)
                  : null,
        ),
      ],
    );
  }
}
