import 'dart:io';
import 'dart:math' as math;

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
  final ValueNotifier<bool> isExportingNotifier;
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
  final VoidCallback? onCanvasTap;
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
    required this.isExportingNotifier,
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
    this.onCanvasTap,
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
  bool isExporting = false;

  bool hasTextOnCanvas() {
    if (widget.logoState.customTexts.any(
      (t) => t.isVisible && t.text.isNotEmpty,
    )) return true;

    if (widget.logoState.isCompanyNameVisible &&
        (widget.logoState.companyName?.isNotEmpty ?? false)) return true;

    if (widget.logoState.isSloganVisible &&
        (widget.logoState.sloganName?.isNotEmpty ?? false)) return true;

    return false;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SelectedColorProvider>(context);
    final gradient = provider.selectedGradient;
    final providers = Provider.of<SelectedColorProvider>(context);
    final shapeColor =
        Provider.of<SelectedColorProvider>(context).selectedColor;
    final logoColor = provider.logoColor;

    final String selectedShape = (widget.selectedShapeName.isEmpty)
        ? "Square"
        : widget.selectedShapeName;

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isExportingNotifier,
      builder: (context, isExporting, child) {
        print('🎨 LogoCanvas rebuilding with isExporting: $isExporting');
        return LayoutBuilder(
          builder: (context, constraints) {
            final bgImage = providers.canvasImage ?? providers.backgroundImage;
            final Size canvasSize = constraints.biggest;
            return GestureDetector(
              onTap: widget.onCanvasTap,
              behavior: HitTestBehavior.translucent,
              child: Stack(
                // clipBehavior: Clip.hardEdge,
                clipBehavior: Clip.none,
                children: [
                  if (widget.showGrid)
                    ClipRect(
                      child: RepaintBoundary(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: CustomPaint(
                            painter: GridPainter(
                              gridColor: Colors.blue,
                              highlightedHorizontalLine:
                                  widget.highlightedHorizontalGridLineIndex,
                              highlightedVerticalLine:
                                  widget.highlightedVerticalGridLineIndex,
                            ),
                            size: Size.infinite,
                          ),
                        ),
                      ),
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

                  if (widget.isCheckerboardVisible && selectedShape == "Square")
                    Opacity(
                      opacity: widget.checkerboardOpacity,
                      child: CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: SquarePainter(shapeColor, gradient, bgImage),
                      ),
                    ),

                  if (widget.isCheckerboardVisible &&
                      selectedShape == "Rounded Rect")
                    Opacity(
                      opacity: widget.checkerboardOpacity,
                      child: Center(
                        child: CustomPaint(
                          size: const Size(280, 100),
                          painter: SquarePainter(shapeColor, gradient, bgImage),
                        ),
                      ),
                    ),

                  if (widget.isCheckerboardVisible &&
                      selectedShape == "Diamond")
                    Opacity(
                      opacity: widget.checkerboardOpacity,
                      child: CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: DiamondPainter(shapeColor, gradient, bgImage),
                      ),
                    ),

                  if (widget.isCheckerboardVisible &&
                      selectedShape == "Triangle")
                    Opacity(
                      opacity: widget.checkerboardOpacity,
                      child: CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: TrianglePainter(shapeColor, gradient, bgImage),
                      ),
                    ),

                  if (widget.isCheckerboardVisible &&
                      selectedShape == "Pentagon")
                    Opacity(
                      opacity: widget.checkerboardOpacity,
                      child: CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: PentagonPainter(shapeColor, gradient, bgImage),
                      ),
                    ),

                  if (widget.isCheckerboardVisible &&
                      selectedShape == "Hexagon")
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

                  // NOTE: Removed the big Transform around the whole stack.
                  // Build elements individually — rotation will be applied per-selected-element
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ...(widget.elementOrder.isNotEmpty
                              ? widget.elementOrder
                              : widget.logoState.visibleElementIds)
                          .map(
                            (id) => _buildElementById(
                              id,
                              canvasSize,
                              isExporting: isExporting,
                            ),
                          )
                          .whereType<Widget>(),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
// Widget build(BuildContext context) {
//   final provider = Provider.of<SelectedColorProvider>(context);
//   final gradient = provider.selectedGradient;
//   final shapeColor = provider.selectedColor ?? Colors.white;
//   final bgImage = provider.canvasImage ?? provider.backgroundImage;

//   // Use provider opacity and checkerboard visibility
//   final checkerboardVisible = provider.isCheckerboardVisible;
//   final opacity = provider.opacity;

//   final String selectedShape =
//       (widget.selectedShapeName.isEmpty) ? "Square" : widget.selectedShapeName;

//   return ValueListenableBuilder<bool>(
//     valueListenable: widget.isExportingNotifier,
//     builder: (context, isExporting, child) {
//       return LayoutBuilder(
//         builder: (context, constraints) {
//           final Size canvasSize = constraints.biggest;

//           Widget? getPainterForShape(String shape) {
//             switch (shape) {
//               case "Square":
//               case "Rounded Rect":
//                 return CustomPaint(
//                   size: shape == "Square"
//                       ? Size(double.infinity, double.infinity)
//                       : const Size(280, 100),
//                   painter: SquarePainter(shapeColor, gradient, bgImage),
//                 );
//               case "Diamond":
//                 return CustomPaint(
//                   size: const Size(double.infinity, double.infinity),
//                   painter: DiamondPainter(shapeColor, gradient, bgImage),
//                 );
//               case "Triangle":
//                 return CustomPaint(
//                   size: const Size(double.infinity, double.infinity),
//                   painter: TrianglePainter(shapeColor, gradient, bgImage),
//                 );
//               case "Pentagon":
//                 return CustomPaint(
//                   size: const Size(double.infinity, double.infinity),
//                   painter: PentagonPainter(shapeColor, gradient, bgImage),
//                 );
//               case "Hexagon":
//                 return CustomPaint(
//                   size: const Size(double.infinity, double.infinity),
//                   painter: HexagonPainter(shapeColor, gradient, bgImage),
//                 );
//               case "Star":
//                 return CustomPaint(
//                   size: const Size(double.infinity, double.infinity),
//                   painter: StarPainter(shapeColor, gradient, bgImage),
//                 );
//               case "Arrow":
//                 return CustomPaint(
//                   size: const Size(double.infinity, double.infinity),
//                   painter: ArrowPainter(shapeColor, gradient, bgImage),
//                 );
//               case "Heart":
//                 return CustomPaint(
//                   size: const Size(200, 200),
//                   painter: HeartPainter(shapeColor, gradient, bgImage),
//                 );
//               default:
//                 return CustomPaint(
//                   size: const Size(double.infinity, double.infinity),
//                   painter: SquarePainter(shapeColor, gradient, bgImage),
//                 );
//             }
//           }

//           return Stack(
//             children: [
//               if (widget.showGrid)
//                 CustomPaint(
//                   painter: GridPainter(
//                     gridColor: Colors.blue,
//                     highlightedHorizontalLine:
//                         widget.highlightedHorizontalGridLineIndex,
//                     highlightedVerticalLine:
//                         widget.highlightedVerticalGridLineIndex,
//                   ),
//                   size: Size.infinite,
//                 ),

//               // Checkerboard
//               if (checkerboardVisible)
//                 Opacity(
//                   opacity: 0.1,
//                   child: Image.asset(
//                     'assets/icons/checkerboard.png',
//                     width: double.infinity,
//                     height: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//               if (checkerboardVisible)
//                 Opacity(
//                   opacity: opacity,
//                   child: Center(child: getPainterForShape(selectedShape)),
//                 ),

//               // Individual elements stack
//               Stack(
//                 children: [
//                   ...(widget.elementOrder.isNotEmpty
//                           ? widget.elementOrder
//                           : widget.logoState.visibleElementIds)
//                       .map(
//                         (id) => _buildElementById(
//                           id,
//                           canvasSize,
//                           isExporting: isExporting,
//                         ),
//                       )
//                       .whereType<Widget>(),
//                 ],
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }

  Widget? _buildElementById(
    int id,
    Size canvasSize, {
    required bool isExporting,
  }) {
    final provider = Provider.of<SelectedColorProvider>(context, listen: true);
    final bool isSelected = widget.selectedElementId == id;
    final outlineColor = provider.getOutlineColor(id);
    final outlineWidth = provider.getOutlineWidth(id);
    // const Color highlightColor = Colors.red;
    final Color? shapeColor = provider.shapeColor;

    final Color companyColor = provider.companyTextColor;
    final Color customTextColor = provider.customTextColor;

    final Color sloganColor = provider.sloganColor;

    final scaleFactor = 0.2;

    Size _calculateTextSize(
      String text,
      TextStyle style, {
      FontWeight? fontWeight,
    }) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: style.copyWith(fontWeight: fontWeight ?? style.fontWeight),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      return tp.size;
    }

    Offset _centerAlign(Size canvasSize, Size childSize) {
      return Offset(
        (canvasSize.width - childSize.width) / 2,
        (canvasSize.height - childSize.height) / 2,
      );
    }

    // wrap() now applies the 3D transform only when this element is selected
    Widget wrap(
      Widget child, {
      required Offset centerPosition,
      required double rotation,
      required Size childSize,
      required bool isExporting,
    }) {
      // final topLeftPosition = centerPosition;
      final topLeftPosition = Offset(
        centerPosition.dx - childSize.width / 2,
        centerPosition.dy - childSize.height / 2,
      );

      // Apply 3D only for the currently selected element (widget.selectedElementId)

      final elementId = id; // keep id local
      final double rotationX = widget.logoState.rotationXMap[elementId] ?? 0.0;
      final double rotationY = widget.logoState.rotationYMap[elementId] ?? 0.0;
      final double rotationZ = widget.logoState.rotationZMap[elementId] ?? 0.0;

      Widget rotatedChild = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateX(rotationX * (math.pi / 180))
          ..rotateY(rotationY * (math.pi / 180))
          ..rotateZ(rotationZ * (math.pi / 180)),
        child: child,
      );

      return _buildEditableWrapper(
        id: id,
        position: topLeftPosition,
        rotation: rotation,
        isLocked: widget.lockedElements.contains(id),
        child: rotatedChild,
        canvasSize: canvasSize,
        isExporting: isExporting,
      );
    }

    // Custom Texts
    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= widget.logoState.customTexts.length) return null;
      final customText = widget.logoState.customTexts[index];
      if (!customText.isVisible) return null;
      final elementColor = provider.getColorForElement(
        id,
        fallback: provider.customTextColor,
      );
          final textStyle = TextStyle(
        fontSize: customText.size,
        color: elementColor,
        fontWeight: FontWeight.w500,
      );
      // TextStyle textStyle;
      // if (customText.fontFamily != null) {
      //   switch (customText.fontFamily) {
      //     case 'Roboto':
      //       textStyle = GoogleFonts.roboto(fontSize: customText.size, color: elementColor, fontWeight: customText.fontWeight);
      //       break;
      //     case 'Pacifico':
      //       textStyle = GoogleFonts.pacifico(fontSize: customText.size, color: elementColor);
      //       break;
      //     case 'Poppins':
      //       textStyle = GoogleFonts.poppins(fontSize: customText.size, color: elementColor, fontWeight: customText.fontWeight);
      //       break;
      //     case 'DancingScript':
      //       textStyle = GoogleFonts.dancingScript(fontSize: customText.size, color: elementColor);
      //       break;
      //     case 'Satisfy':
      //       textStyle = GoogleFonts.satisfy(fontSize: customText.size, color: elementColor);
      //       break;
      //     case 'Lato':
      //       textStyle = GoogleFonts.lato(fontSize: customText.size, color: elementColor, fontWeight: customText.fontWeight);
      //       break;
      //     case 'Orbitron':
      //       textStyle = GoogleFonts.orbitron(fontSize: customText.size, color: elementColor, fontWeight: customText.fontWeight);
      //       break;
      //     case 'OpenSans':
      //       textStyle = GoogleFonts.openSans(fontSize: customText.size, color: elementColor, fontWeight: customText.fontWeight);
      //       break;
      //     case 'BebasNeue':
      //       textStyle = GoogleFonts.bebasNeue(fontSize: customText.size, color: elementColor);
      //       break;
      //     case 'PressStart2P':
      //       textStyle = GoogleFonts.pressStart2p(fontSize: customText.size, color: elementColor);
      //       break;
      //     default:
      //       textStyle = TextStyle(fontSize: customText.size, color: elementColor, fontWeight: customText.fontWeight);
      //   }
      // } else {
      //   textStyle = TextStyle(fontSize: customText.size, color: elementColor, fontWeight: customText.fontWeight);
      // }
      final measuredSize = _calculateTextSize(customText.text, textStyle);
      final textSize = Size(
        measuredSize.width * scaleFactor,
        measuredSize.height * scaleFactor,
      );

      final centerPosition = (customText.position == Offset.zero)
          ? _centerAlign(canvasSize, textSize)
          : customText.position;

      return wrap(
        Center(
          child: Opacity(
            opacity: customText.opacity.clamp(0.0, 1.0),
            child: StrokedText(
              text: customText.text,
              style: textStyle,
              strokeColor: outlineColor,
              strokeWidth: outlineWidth,
              textAlign: provider.customTextAlign,
            ),
          ),
        ),
        centerPosition: centerPosition,
        rotation: customText.rotation,
        childSize: textSize,
        isExporting: isExporting,
      );
    }

    // Custom Images
    if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= widget.logoState.customImages.length) return null;
      final image = widget.logoState.customImages[index];
      if (!image.isVisible) return null;

      final imageSize = Size(image.size ?? 100, image.size ?? 100);
      final centerPosition = (image.position == Offset.zero)
          ? _centerAlign(canvasSize, imageSize)
          : image.position;

      return wrap(
        Center(
          child: Opacity(
            opacity: image.opacity?.clamp(0.0, 1.0) ?? 1.0,
            child: image.path.startsWith('assets/')
                ? Image.asset(
                    image.path,
                    width: imageSize.width,
                    height: imageSize.height,
                    fit: BoxFit.contain,
                  )
                : Image.file(
                    File(image.path),
                    width: imageSize.width,
                    height: imageSize.height,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
        centerPosition: centerPosition,
        rotation: image.rotation,
        childSize: imageSize,
        isExporting: isExporting,
      );
    }

    // Custom SVGs
    if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= widget.logoState.customSVGs.length) return null;
      final svgElement = widget.logoState.customSVGs[index];
      if (!svgElement.isVisible) return null;

      // Check if there's a color override in provider, otherwise use the SVG element's stored color
      final hasOverride = provider.hasColorOverride(id);
      final Color? elementColor = hasOverride
          ? provider.getColorForElement(id, fallback: Colors.black)
          : svgElement.color;

      final svgSize = Size(svgElement.size, svgElement.size);
      final centerPosition = (svgElement.position == Offset.zero)
          ? _centerAlign(canvasSize, svgSize)
          : svgElement.position;

      return wrap(
        StrokedSvg(
          svgString: svgElement.svgString,
          width: svgElement.size,
          height: svgElement.size,
          strokeColor: outlineColor,
          strokeWidth: outlineWidth,
          fillColor: elementColor,
        ),
        centerPosition: centerPosition,
        rotation: svgElement.rotation,
        childSize: svgSize,
        isExporting: isExporting,
      );
    }
    // bool overlap(Offset aPos, Size aSize, Offset bPos, Size bSize) {
    //   return Rect.fromCenter(
    //     center: aPos,
    //     width: aSize.width,
    //     height: aSize.height,
    //   ).overlaps(
    //     Rect.fromCenter(
    //       center: bPos,
    //       width: bSize.width,
    //       height: bSize.height,
    //     ),
    //   );
    // }

    // final companySize = _calculateTextSize(
    //       widget.logoState.companyName ?? '',
    //       TextStyle(
    //         fontSize: widget.logoState.companyNameSize,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ) *
    //     1.09;

    // final companyCenter = widget.logoState.companyNamePosition == Offset.zero
    //     ? _centerAlign(canvasSize, companySize)
    //     : widget.logoState.companyNamePosition;

    // final sloganSize = _calculateTextSize(
    //   widget.logoState.sloganName ?? '',
    //   TextStyle(fontSize: widget.logoState.sloganSize),
    // );

    // final sloganCenter = widget.logoState.sloganPosition == Offset.zero
    //     ? _centerAlign(canvasSize, sloganSize)
    //     : widget.logoState.sloganPosition;

    // final isOverlap =
    //     overlap(companyCenter, companySize, sloganCenter, sloganSize);

    // Main Logo, Company Name, Slogan
    switch (id) {
      case 0: // Logo
        final logoSize = widget.logoState.logoSize;
        final shapeSize = Size(logoSize, logoSize) * 0.9;
        final centerPosition = (widget.logoState.logoPosition == Offset.zero ||
                widget.logoState.logoPosition == null)
            ? _centerAlign(canvasSize, shapeSize)
            : widget.logoState.logoPosition;
        // Only apply color if it has been manually overridden
        final Color? appliedLogoColor =
            provider.isLogoColorOverridden ? provider.logoColor : null;
        return widget.logoState.isLogoVisible
            ? wrap(
                StrokedSvg(
                  svgString: widget.svgLogo,
                  width: logoSize,
                  height: logoSize,
                  strokeColor: outlineColor,
                  strokeWidth: outlineWidth,
                  fillColor: appliedLogoColor,
                ),
                centerPosition: centerPosition,
                rotation: widget.logoState.logoRotation,
                childSize: shapeSize,
                isExporting: isExporting,
              )
            : null;
      // case 1: // Company

      //   final hideCompany = isOverlap && widget.selectedElementId == 2;

      //   return (widget.logoState.isCompanyNameVisible && !hideCompany)
      //       ? wrap(
      //           StrokedText(
      //             text: widget.logoState.companyName ?? '',
      //             style: TextStyle(
      //               fontSize: widget.logoState.companyNameSize,
      //               fontWeight: FontWeight.bold,
      //               color: companyColor,
      //             ),
      //             strokeColor: outlineColor,
      //             strokeWidth: outlineWidth,
      //             textAlign: provider.companyNameAlign,
      //           ),
      //           centerPosition: companyCenter,
      //           rotation: widget.logoState.companyNameRotation,
      //           childSize: companySize,
      //           isExporting: isExporting,
      //         )
      //       : null;

      // case 2: // Slogan
      //   final hideSlogan = isOverlap && widget.selectedElementId == 1;

      //   return (widget.logoState.isSloganVisible && !hideSlogan)
      //       ? wrap(
      //           StrokedText(
      //             text: widget.logoState.sloganName ?? '',
      //             style: TextStyle(
      //               fontSize: widget.logoState.sloganSize,
      //               color: sloganColor,
      //             ),
      //             strokeColor: outlineColor,
      //             strokeWidth: outlineWidth,
      //             textAlign: provider.sloganAlign,
      //           ),
      //           centerPosition: sloganCenter,
      //           rotation: widget.logoState.sloganRotation,
      //           childSize: sloganSize,
      //           isExporting: isExporting,
      //         )
      //       : null;
     
     
      case 1: // Company Name
        final nameText = widget.logoState.companyName ?? '';
        final nameSize = widget.logoState.companyNameSize;
             final textStyle = TextStyle(
          fontSize: nameSize,
          fontWeight: FontWeight.bold,
          color: companyColor,
        );
        // TextStyle textStyle;
        // final fontFamily = provider.companyFontFamily;
        // if (fontFamily != null) {
        //   switch (fontFamily) {
        //     case 'Roboto':
        //       textStyle = GoogleFonts.roboto(fontSize: nameSize, color: companyColor, fontWeight: FontWeight.bold);
        //       break;
        //     case 'Pacifico':
        //       textStyle = GoogleFonts.pacifico(fontSize: nameSize, color: companyColor);
        //       break;
        //     case 'Poppins':
        //       textStyle = GoogleFonts.poppins(fontSize: nameSize, color: companyColor, fontWeight: FontWeight.bold);
        //       break;
        //     case 'DancingScript':
        //       textStyle = GoogleFonts.dancingScript(fontSize: nameSize, color: companyColor);
        //       break;
        //     case 'Satisfy':
        //       textStyle = GoogleFonts.satisfy(fontSize: nameSize, color: companyColor);
        //       break;
        //     case 'Lato':
        //       textStyle = GoogleFonts.lato(fontSize: nameSize, color: companyColor, fontWeight: FontWeight.bold);
        //       break;
        //     case 'Orbitron':
        //       textStyle = GoogleFonts.orbitron(fontSize: nameSize, color: companyColor, fontWeight: FontWeight.bold);
        //       break;
        //     case 'OpenSans':
        //       textStyle = GoogleFonts.openSans(fontSize: nameSize, color: companyColor, fontWeight: FontWeight.bold);
        //       break;
        //     case 'BebasNeue':
        //       textStyle = GoogleFonts.bebasNeue(fontSize: nameSize, color: companyColor);
        //       break;
        //     case 'PressStart2P':
        //       textStyle = GoogleFonts.pressStart2p(fontSize: nameSize, color: companyColor);
        //       break;
        //     default:
        //       textStyle = TextStyle(fontSize: nameSize, color: companyColor, fontWeight: FontWeight.bold);
        //   }
        // } else {
        //   textStyle = TextStyle(fontSize: nameSize, color: companyColor, fontWeight: FontWeight.bold);
        // }
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
                  textAlign: provider.companyNameAlign,
                ),
                centerPosition: centerPosition,
                rotation: widget.logoState.companyNameRotation,
                childSize: textSize,
                isExporting: isExporting,
              )
            : null;

      case 2: // Slogan
        final sloganText = widget.logoState.sloganName ?? '';
        final sloganSize = widget.logoState.sloganSize;
         final sloganStyle = TextStyle(fontSize: sloganSize, color: sloganColor);
        // TextStyle sloganStyle;
        // final fontFamily = provider.sloganFontFamily;
        // if (fontFamily != null) {
        //   switch (fontFamily) {
        //     case 'Roboto':
        //       sloganStyle = GoogleFonts.roboto(fontSize: sloganSize, color: sloganColor, fontWeight: FontWeight.w500);
        //       break;
        //     case 'Pacifico':
        //       sloganStyle = GoogleFonts.pacifico(fontSize: sloganSize, color: sloganColor);
        //       break;
        //     case 'Poppins':
        //       sloganStyle = GoogleFonts.poppins(fontSize: sloganSize, color: sloganColor, fontWeight: FontWeight.w500);
        //       break;
        //     case 'DancingScript':
        //       sloganStyle = GoogleFonts.dancingScript(fontSize: sloganSize, color: sloganColor);
        //       break;
        //     case 'Satisfy':
        //       sloganStyle = GoogleFonts.satisfy(fontSize: sloganSize, color: sloganColor);
        //       break;
        //     case 'Lato':
        //       sloganStyle = GoogleFonts.lato(fontSize: sloganSize, color: sloganColor, fontWeight: FontWeight.w500);
        //       break;
        //     case 'Orbitron':
        //       sloganStyle = GoogleFonts.orbitron(fontSize: sloganSize, color: sloganColor, fontWeight: FontWeight.w500);
        //       break;
        //     case 'OpenSans':
        //       sloganStyle = GoogleFonts.openSans(fontSize: sloganSize, color: sloganColor, fontWeight: FontWeight.w500);
        //       break;
        //     case 'BebasNeue':
        //       sloganStyle = GoogleFonts.bebasNeue(fontSize: sloganSize, color: sloganColor);
        //       break;
        //     case 'PressStart2P':
        //       sloganStyle = GoogleFonts.pressStart2p(fontSize: sloganSize, color: sloganColor);
        //       break;
        //     default:
        //       sloganStyle = TextStyle(fontSize: sloganSize, color: sloganColor, fontWeight: FontWeight.w500);
        //   }
        // } else {
        //   sloganStyle = TextStyle(fontSize: sloganSize, color: sloganColor, fontWeight: FontWeight.w500);
        // }
        final sloganMeasured = _calculateTextSize(sloganText, sloganStyle);
        final centerPosition =
            (widget.logoState.sloganPosition == Offset.zero ||
                    widget.logoState.sloganPosition == null)
                ? _centerAlign(canvasSize, sloganMeasured)
                : widget.logoState.sloganPosition;

        return widget.logoState.isSloganVisible
            ? wrap(
                StrokedText(
                  text: sloganText,
                  style: sloganStyle,
                  strokeColor: outlineColor,
                  strokeWidth: outlineWidth,
                  textAlign: provider.sloganAlign,
                ),
                centerPosition: centerPosition,
                rotation: widget.logoState.sloganRotation,
                childSize: sloganMeasured,
                isExporting: isExporting,
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
    required bool isExporting,
  }) {
    print(
      '🔧 Building EditableElementWrapper for id: $id, isExporting: $isExporting',
    );
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
      isExporting: isExporting,
      child: child,
    );
  }
}

class StrokedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color strokeColor;
  final double strokeWidth;
  final TextAlign textAlign;

  const StrokedText({
    super.key,
    required this.text,
    required this.style,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stroke
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
            fontWeight: style.fontWeight,
          ),
          textAlign: textAlign,
        ),
        Text(
          text,
          style: style.copyWith(fontWeight: style.fontWeight),
          textAlign: textAlign,
        ),
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
        // Stroke effect (only if strokeWidth > 0)
        if (strokeWidth > 0)
          ...[
            Offset(-strokeWidth, 0),
            Offset(strokeWidth, 0),
            Offset(0, -strokeWidth),
            Offset(0, strokeWidth),
            Offset(-strokeWidth, -strokeWidth),
            Offset(-strokeWidth, strokeWidth),
            Offset(strokeWidth, -strokeWidth),
            Offset(strokeWidth, strokeWidth),
          ].map(
            (offset) => Transform.translate(
              offset: offset,
              child: SvgPicture.string(
                svgString,
                width: width,
                height: height,
                colorFilter: ColorFilter.mode(strokeColor, BlendMode.srcIn),
              ),
            ),
          ),

        // Main SVG with optional fill color
        SvgPicture.string(
          svgString,
          width: width,
          height: height,
          colorFilter: fillColor != null
              ? ColorFilter.mode(fillColor!, BlendMode.srcIn)
              : null,
        ),
      ],
    );
  }
}
