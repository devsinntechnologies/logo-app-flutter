import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class EditorState {
  final LogoStateData logo;
  final BackgroundState background;

  EditorState({required this.logo, required this.background});

  EditorState clone() => EditorState(
        logo: logo.clone(),
        background: background.clone(),
      );
}

class BackgroundState {
  final Color? color;
  final Gradient? gradient;
  final String? imagePath; // file path for image
  final bool checkerboardVisible;

  BackgroundState({
    required this.color,
    required this.gradient,
    required this.imagePath,
    required this.checkerboardVisible,
  });

  BackgroundState clone() => BackgroundState(
        color: color,
        gradient: gradient,
        imagePath: imagePath,
        checkerboardVisible: checkerboardVisible,
      );
}


class CustomTextElement {
  final TextAlign textAlign;
  final String text;
  final Offset position;
  final double size;
  final double rotation;
  final double opacity;
  final bool isVisible;
  final int? layerIndex;
  final Color color;
  final FontWeight fontWeight;

  final bool isOutlined;
  final Color outlineColor;
  final double strokeWidth;

  const CustomTextElement({
    this.textAlign = TextAlign.center,
    required this.text,
    required this.position,
    required this.size,
    required this.rotation,
    this.opacity = 1.0,
    this.isVisible = true,
    this.layerIndex,
    this.color = const Color(0xFF000000),
    this.isOutlined = false,
    this.outlineColor = Colors.black,
    this.strokeWidth = 1.0,
    this.fontWeight = FontWeight.normal,
  });

  CustomTextElement copyWith({
    TextAlign? textAlign,
    String? text,
    Offset? position,
    double? size,
    double? rotation,
    double? opacity,
    bool? isVisible,
    int? layerIndex,
    Color? color,
    bool? isOutlined,
    Color? outlineColor,
    double? strokeWidth,
    FontWeight? fontWeight,
  }) {
    return CustomTextElement(
      textAlign: textAlign ?? this.textAlign,
      text: text ?? this.text,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      layerIndex: layerIndex ?? this.layerIndex,
      color: color ?? this.color,
      isOutlined: isOutlined ?? this.isOutlined,
      outlineColor: outlineColor ?? this.outlineColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      fontWeight: fontWeight ?? this.fontWeight,
    );
  }

  CustomTextElement clone() {
    return CustomTextElement(
      textAlign: textAlign,
      text: text,
      position: Offset(position.dx, position.dy),
      size: size,
      rotation: rotation,
      opacity: opacity,
      isVisible: isVisible,
      layerIndex: layerIndex,
      color: Color(color.value),
      fontWeight: fontWeight,
      isOutlined: isOutlined,
      outlineColor: Color(outlineColor.value),
      strokeWidth: strokeWidth,
    );
  }
}

class CustomImageElement {
  final String path;
  final Offset position;
  final double rotation;
  final double? size;
  final double opacity;
  final bool isVisible;
  final int? layerIndex;

  const CustomImageElement({
    required this.path,
    required this.position,
    required this.rotation,
    this.size,
    this.opacity = 1.0,
    this.isVisible = true,
    this.layerIndex,
  });

  CustomImageElement copyWith({
    String? path,
    Offset? position,
    double? rotation,
    double? size,
    double? opacity,
    bool? isVisible,
    int? layerIndex,
  }) {
    return CustomImageElement(
      path: path ?? this.path,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      layerIndex: layerIndex ?? this.layerIndex,
    );
  }

  CustomImageElement clone() {
    return CustomImageElement(
      path: path,
      position: Offset(position.dx, position.dy),
      rotation: rotation,
      size: size,
      opacity: opacity,
      isVisible: isVisible,
      layerIndex: layerIndex,
    );
  }
}

class CustomSvgElement {
  final String svgString;
  final Offset position;
  final Color? color; //
  final double size;
  final double rotation;
  final double opacity;
  final bool isVisible;
  final int? layerIndex;

  const CustomSvgElement({
    required this.svgString,
    required this.position,
    this.color,
    required this.size,
    required this.rotation,
    this.opacity = 1.0,
    this.isVisible = true,
    this.layerIndex,
  });

  CustomSvgElement copyWith({
    String? svgString,
    Offset? position,
    Color? color,
    double? size,
    double? rotation,
    double? opacity,
    bool? isVisible,
    int? layerIndex,
  }) {
    return CustomSvgElement(
      svgString: svgString ?? this.svgString,
      position: position ?? this.position,
      color: color ?? this.color,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      layerIndex: layerIndex ?? this.layerIndex,
    );
  }

  CustomSvgElement clone() {
    return CustomSvgElement(
      svgString: svgString,
      position: Offset(position.dx, position.dy),
      color: color == null ? null : Color(color!.value),
      size: size,
      rotation: rotation,
      opacity: opacity,
      isVisible: isVisible,
      layerIndex: layerIndex,
    );
  }
}

class LogoStateData {
  final Map<String, Color> elementColors;
  final Map<String, double> outlineWidths;
  final Map<String, Color> outlineColors;
  final Map<int, double> rotationXMap;
  final Map<int, double> rotationYMap;
  final Map<int, double> rotationZMap;
  final double perspective;
  final Color companyNameColor;
  final Color sloganColor;
  final Color companyNameOutlineColor;
  final double companyNameOutlineWidth;
  final Color sloganOutlineColor;
  final double sloganOutlineWidth;

  final Offset logoPosition;
  final double logoSize;
  final double logoRotation;
  final bool isLogoVisible;
  final String? svgLogo;

  final Offset companyNamePosition;
  final double companyNameSize;
  final double companyNameRotation;
  final bool isCompanyNameVisible;
  final String? companyName;

  final Offset sloganPosition;
  final double sloganSize;
  final double sloganRotation;
  final bool isSloganVisible;
  final String? sloganName;

  final Offset? logo2Position;
  final double? logo2Size;
  final double? logo2Rotation;
  final bool isLogo2Visible;

  final Offset? companyName2Position;
  final double? companyName2Size;
  final double? companyName2Rotation;
  final bool isCompanyName2Visible;

  final Offset? slogan2Position;
  final double? slogan2Size;
  final double? slogan2Rotation;
  final bool isSlogan2Visible;

  final List<CustomTextElement> customTexts;
  final List<CustomImageElement> customImages;
  final List<CustomSvgElement> customSVGs;

  final Set<int> lockedElements;
  final List<int> elementOrder;
  final TextAlign companyNameTextAlign; // ← add this
  final TextAlign sloganTextAlign;

  LogoStateData({
    this.elementColors = const {},

    this.outlineWidths = const {},
    this.outlineColors = const {},
    this.rotationXMap = const {},
    this.rotationYMap = const {},
    this.rotationZMap = const {},

    this.perspective = 0.001,
    List<CustomTextElement>? customTexts,
    List<CustomImageElement>? customImages,
    List<CustomSvgElement>? customSVGs,
    Set<int>? lockedElements,
    List<int>? elementOrder,
    this.companyNameColor = Colors.black,
    this.sloganColor = Colors.black,
    this.companyNameOutlineColor = Colors.transparent,
    this.companyNameOutlineWidth = 0.0,
    this.sloganOutlineColor = Colors.transparent,
    this.sloganOutlineWidth = 0.0,

    required this.logoPosition,
    required this.logoSize,
    required this.logoRotation,
    required this.isLogoVisible,
    this.svgLogo,
    required this.companyNamePosition,
    required this.companyNameSize,
    required this.companyNameRotation,
    required this.isCompanyNameVisible,
    this.companyName,
    required this.sloganPosition,
    required this.sloganSize,
    required this.sloganRotation,
    required this.isSloganVisible,
    this.sloganName,
    this.logo2Position,
    this.logo2Size,
    this.logo2Rotation,
    required this.isLogo2Visible,
    this.companyName2Position,
    this.companyName2Size,
    this.companyName2Rotation,
    required this.isCompanyName2Visible,
    this.slogan2Position,
    this.slogan2Size,
    this.slogan2Rotation,
    required this.isSlogan2Visible,
    this.companyNameTextAlign = TextAlign.center,
    this.sloganTextAlign = TextAlign.center,
  }) : customTexts = customTexts ?? [],
       customImages = customImages ?? [],
       customSVGs = customSVGs ?? [],
       lockedElements = lockedElements ?? {},
       elementOrder = elementOrder ?? [];

  Set<int> get visibleElementIds {
    final ids = <int>{};
    if (isLogoVisible) ids.add(0);
    if (isCompanyNameVisible) ids.add(1);
    if (isSloganVisible) ids.add(2);
    if (isLogo2Visible) ids.add(3);
    if (isCompanyName2Visible) ids.add(4);
    if (isSlogan2Visible) ids.add(5);
    for (int i = 0; i < customTexts.length; i++) {
      if (customTexts[i].isVisible) ids.add(100 + i);
    }
    for (int i = 0; i < customImages.length; i++) {
      if (customImages[i].isVisible) ids.add(200 + i);
    }
    for (int i = 0; i < customSVGs.length; i++) {
      if (customSVGs[i].isVisible) ids.add(300 + i);
    }
    return ids;
  }

  LogoStateData copyWith({
    Map<String, Color>? elementColors,
    Map<String, double>? outlineWidths,
    Map<String, Color>? outlineColors,
    Map<int, double>? rotationXMap,
    Map<int, double>? rotationYMap,
    Map<int, double>? rotationZMap,

    double? perspective,
    Color? companyNameColor,
    Color? companyNameOutlineColor,
    double? companyNameOutlineWidth,

    Color? sloganColor,
    Color? sloganOutlineColor,
    double? sloganOutlineWidth,

    TextAlign? companyNameTextAlign,
    TextAlign? sloganTextAlign,
    Offset? logoPosition,
    double? logoSize,
    double? logoRotation,
    bool? isLogoVisible,
    String? svgLogo,
    Offset? companyNamePosition,
    double? companyNameSize,
    double? companyNameRotation,
    bool? isCompanyNameVisible,
    String? companyName,
    Offset? sloganPosition,
    double? sloganSize,
    double? sloganRotation,
    bool? isSloganVisible,
    String? sloganName,
    Offset? logo2Position,
    double? logo2Size,
    double? logo2Rotation,
    bool? isLogo2Visible,
    Offset? companyName2Position,
    double? companyName2Size,
    double? companyName2Rotation,
    bool? isCompanyName2Visible,
    Offset? slogan2Position,
    double? slogan2Size,
    double? slogan2Rotation,
    bool? isSlogan2Visible,
    List<CustomTextElement>? customTexts,
    List<CustomImageElement>? customImages,
    List<CustomSvgElement>? customSVGs,
    Set<int>? lockedElements,
    List<int>? elementOrder,
  }) {
    return LogoStateData(
      elementColors: elementColors ?? this.elementColors,
      outlineWidths: outlineWidths ?? this.outlineWidths,
      outlineColors: outlineColors ?? this.outlineColors,
      rotationXMap: rotationXMap ?? this.rotationXMap,
      rotationYMap: rotationYMap ?? this.rotationYMap,
      rotationZMap: rotationZMap ?? this.rotationZMap,

      perspective: perspective ?? this.perspective,

      companyNameColor: companyNameColor ?? this.companyNameColor,
      companyNameOutlineColor:
          companyNameOutlineColor ?? this.companyNameOutlineColor,
      companyNameOutlineWidth:
          companyNameOutlineWidth ?? this.companyNameOutlineWidth,

      sloganColor: sloganColor ?? this.sloganColor,
      sloganOutlineColor: sloganOutlineColor ?? this.sloganOutlineColor,
      sloganOutlineWidth: sloganOutlineWidth ?? this.sloganOutlineWidth,

      logoPosition: logoPosition ?? this.logoPosition,
      logoSize: logoSize ?? this.logoSize,
      logoRotation: logoRotation ?? this.logoRotation,
      isLogoVisible: isLogoVisible ?? this.isLogoVisible,
      svgLogo: svgLogo ?? this.svgLogo,
      companyNamePosition: companyNamePosition ?? this.companyNamePosition,
      companyNameSize: companyNameSize ?? this.companyNameSize,
      companyNameRotation: companyNameRotation ?? this.companyNameRotation,
      isCompanyNameVisible: isCompanyNameVisible ?? this.isCompanyNameVisible,
      companyName: companyName ?? this.companyName,
      sloganPosition: sloganPosition ?? this.sloganPosition,
      sloganSize: sloganSize ?? this.sloganSize,
      sloganRotation: sloganRotation ?? this.sloganRotation,
      isSloganVisible: isSloganVisible ?? this.isSloganVisible,
      sloganName: sloganName ?? this.sloganName,
      logo2Position: logo2Position ?? this.logo2Position,
      logo2Size: logo2Size ?? this.logo2Size,
      logo2Rotation: logo2Rotation ?? this.logo2Rotation,
      isLogo2Visible: isLogo2Visible ?? this.isLogo2Visible,
      companyName2Position: companyName2Position ?? this.companyName2Position,
      companyName2Size: companyName2Size ?? this.companyName2Size,
      companyName2Rotation: companyName2Rotation ?? this.companyName2Rotation,
      isCompanyName2Visible:
          isCompanyName2Visible ?? this.isCompanyName2Visible,
      slogan2Position: slogan2Position ?? this.slogan2Position,
      slogan2Size: slogan2Size ?? this.slogan2Size,
      slogan2Rotation: slogan2Rotation ?? this.slogan2Rotation,
      isSlogan2Visible: isSlogan2Visible ?? this.isSlogan2Visible,
      customTexts:
          customTexts ?? this.customTexts.map((e) => e.clone()).toList(),
      customImages:
          customImages ?? this.customImages.map((e) => e.clone()).toList(),
      customSVGs: customSVGs ?? this.customSVGs.map((e) => e.clone()).toList(),
      lockedElements: lockedElements ?? Set<int>.from(this.lockedElements),
      elementOrder: elementOrder ?? List<int>.from(this.elementOrder),

      companyNameTextAlign: companyNameTextAlign ?? this.companyNameTextAlign,
      sloganTextAlign: sloganTextAlign ?? this.sloganTextAlign,
    );
  }

  LogoStateData clone() {
    return LogoStateData(
      elementColors: Map<String, Color>.from(elementColors),
      outlineWidths: Map<String, double>.from(outlineWidths),
      outlineColors: Map<String, Color>.from(outlineColors),
      rotationXMap: Map<int, double>.from(rotationXMap),
      rotationYMap: Map<int, double>.from(rotationYMap),
      rotationZMap: Map<int, double>.from(rotationZMap),

      perspective: perspective ?? this.perspective,

      companyNameColor: Color(companyNameColor.value),
      companyNameOutlineColor: Color(companyNameOutlineColor.value),
      companyNameOutlineWidth: companyNameOutlineWidth,

      sloganColor: Color(sloganColor.value),
      sloganOutlineColor: Color(sloganOutlineColor.value),
      sloganOutlineWidth: sloganOutlineWidth,

      logoPosition: Offset(logoPosition.dx, logoPosition.dy),
      logoSize: logoSize,
      logoRotation: logoRotation,
      isLogoVisible: isLogoVisible,
      svgLogo: svgLogo,

      companyNamePosition: Offset(
        companyNamePosition.dx,
        companyNamePosition.dy,
      ),
      companyNameSize: companyNameSize,
      companyNameRotation: companyNameRotation,
      isCompanyNameVisible: isCompanyNameVisible,
      companyName: companyName,

      sloganPosition: Offset(sloganPosition.dx, sloganPosition.dy),
      sloganSize: sloganSize,
      sloganRotation: sloganRotation,
      isSloganVisible: isSloganVisible,
      sloganName: sloganName,

      logo2Position:
          logo2Position == null
              ? null
              : Offset(logo2Position!.dx, logo2Position!.dy),
      logo2Size: logo2Size,
      logo2Rotation: logo2Rotation,
      isLogo2Visible: isLogo2Visible,

      companyName2Position:
          companyName2Position == null
              ? null
              : Offset(companyName2Position!.dx, companyName2Position!.dy),
      companyName2Size: companyName2Size,
      companyName2Rotation: companyName2Rotation,
      isCompanyName2Visible: isCompanyName2Visible,

      slogan2Position:
          slogan2Position == null
              ? null
              : Offset(slogan2Position!.dx, slogan2Position!.dy),
      slogan2Size: slogan2Size,
      slogan2Rotation: slogan2Rotation,
      isSlogan2Visible: isSlogan2Visible,

      /// 🔥 Deep clone lists (VERY IMPORTANT)
      customTexts:
          customTexts
              .map((e) => e.clone()) // requires clone() in CustomTextElement
              .toList(),
      customImages:
          customImages
              .map((e) => e.clone()) // requires clone() in CustomImageElement
              .toList(),
      customSVGs:
          customSVGs
              .map((e) => e.clone()) // requires clone() in CustomSvgElement
              .toList(),

      /// 🔥 Deep clone sets and lists
      lockedElements: Set<int>.from(lockedElements),
      elementOrder: List<int>.from(elementOrder),

      companyNameTextAlign: companyNameTextAlign,
      sloganTextAlign: sloganTextAlign,
    );
  }
}


// void _updateTextAlignment(TextAlign align) {
//   final id = widget.selectedElementId;
//   if (id == null) return;

//   if (id == 1) {
//     widget.logoState.companyNameAlign = align;
//   } else if (id == 2) {
//     widget.logoState.sloganAlign = align;
//   } else if (id >= 100 && id <= 199) {
//     final index = id - 100;
//     widget.logoState.customTexts[index] =
//         widget.logoState.customTexts[index].copyWith(align: align);
//   }
// }

class CanvasState {
  String? selectedShapeName;
  Color backgroundColor;
  Gradient? backgroundGradient;
  ui.Image? backgroundImage;
  double checkerboardOpacity;
  bool isCheckerboardActive;
  // ... add all other properties

  CanvasState({
    this.selectedShapeName,
    required this.backgroundColor,
    this.backgroundGradient,
    this.backgroundImage,
    this.checkerboardOpacity = 1.0,
    this.isCheckerboardActive = false,
    // ... other fields
  });

  CanvasState copy() {
    return CanvasState(
      selectedShapeName: selectedShapeName,
      backgroundColor: backgroundColor,
      backgroundGradient: backgroundGradient,
      backgroundImage: backgroundImage,
      checkerboardOpacity: checkerboardOpacity,
      isCheckerboardActive: isCheckerboardActive,
      // ... copy other fields
    );
  }
}