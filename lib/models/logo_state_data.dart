// import 'dart:ui';

// class LogoStateData {
//   final List<LogoElement> textElements;
//   final List<LogoElement> imageElements;
//   final BackgroundState backgroundState;
//   final double opacityValue;
//   final int selectedFontIndex;
//   final String selectedShapeName;
//   final String selectedBackgroundShape;
//   final bool isCheckerboardActive;
//   final bool isCheckerboardVisible;
//   final double checkerboardOpacity;
//   final String? svgLogo;
//   final String companyName;
//   final String sloganName;
//   final String? designId;
//   final String? imagePath;

//   LogoStateData({
//     required this.textElements,
//     required this.imageElements,
//     required this.backgroundState,
//     required this.opacityValue,
//     required this.selectedFontIndex,
//     required this.selectedShapeName,
//     required this.selectedBackgroundShape,
//     required this.isCheckerboardActive,
//     required this.isCheckerboardVisible,
//     required this.checkerboardOpacity,
//     this.svgLogo,
//     required this.companyName,
//     required this.sloganName,
//     this.designId,
//     this.imagePath,
//   });

//   // Create a copy of the current state
//   LogoStateData copyWith({
//     List<LogoElement>? textElements,
//     List<LogoElement>? imageElements,
//     BackgroundState? backgroundState,
//     double? opacityValue,
//     int? selectedFontIndex,
//     String? selectedShapeName,
//     String? selectedBackgroundShape,
//     bool? isCheckerboardActive,
//     bool? isCheckerboardVisible,
//     double? checkerboardOpacity,
//     String? svgLogo,
//     String? companyName,
//     String? sloganName,
//     String? designId,
//     String? imagePath,
//   }) {
//     return LogoStateData(
//       textElements: textElements ?? this.textElements,
//       imageElements: imageElements ?? this.imageElements,
//       backgroundState: backgroundState ?? this.backgroundState,
//       opacityValue: opacityValue ?? this.opacityValue,
//       selectedFontIndex: selectedFontIndex ?? this.selectedFontIndex,
//       selectedShapeName: selectedShapeName ?? this.selectedShapeName,
//       selectedBackgroundShape:
//           selectedBackgroundShape ?? this.selectedBackgroundShape,
//       isCheckerboardActive: isCheckerboardActive ?? this.isCheckerboardActive,
//       isCheckerboardVisible:
//           isCheckerboardVisible ?? this.isCheckerboardVisible,
//       checkerboardOpacity: checkerboardOpacity ?? this.checkerboardOpacity,
//       svgLogo: svgLogo ?? this.svgLogo,
//       companyName: companyName ?? this.companyName,
//       sloganName: sloganName ?? this.sloganName,
//       designId: designId ?? this.designId,
//       imagePath: imagePath ?? this.imagePath,
//     );
//   }
// }

// class LogoElement {
//   final int id;
//   final String text;
//   final double fontSize;
//   final Color color;
//   final double x;
//   final double y;
//   final double width;
//   final double height;
//   final double rotation;
//   final bool isBold;
//   final bool isItalic;
//   final String fontFamily;
//   final String? imagePath;
//   final double opacity;
//   final bool isShadowEnabled;
//   final Color shadowColor;
//   final Offset shadowOffset;
//   final double shadowBlurRadius;

//   LogoElement({
//     required this.id,
//     required this.text,
//     required this.fontSize,
//     required this.color,
//     required this.x,
//     required this.y,
//     required this.width,
//     required this.height,
//     required this.rotation,
//     required this.isBold,
//     required this.isItalic,
//     required this.fontFamily,
//     this.imagePath,
//     required this.opacity,
//     required this.isShadowEnabled,
//     required this.shadowColor,
//     required this.shadowOffset,
//     required this.shadowBlurRadius,
//   });

//   LogoElement copyWith({
//     int? id,
//     String? text,
//     double? fontSize,
//     Color? color,
//     double? x,
//     double? y,
//     double? width,
//     double? height,
//     double? rotation,
//     bool? isBold,
//     bool? isItalic,
//     String? fontFamily,
//     String? imagePath,
//     double? opacity,
//     bool? isShadowEnabled,
//     Color? shadowColor,
//     Offset? shadowOffset,
//     double? shadowBlurRadius,
//   }) {
//     return LogoElement(
//       id: id ?? this.id,
//       text: text ?? this.text,
//       fontSize: fontSize ?? this.fontSize,
//       color: color ?? this.color,
//       x: x ?? this.x,
//       y: y ?? this.y,
//       width: width ?? this.width,
//       height: height ?? this.height,
//       rotation: rotation ?? this.rotation,
//       isBold: isBold ?? this.isBold,
//       isItalic: isItalic ?? this.isItalic,
//       fontFamily: fontFamily ?? this.fontFamily,
//       imagePath: imagePath ?? this.imagePath,
//       opacity: opacity ?? this.opacity,
//       isShadowEnabled: isShadowEnabled ?? this.isShadowEnabled,
//       shadowColor: shadowColor ?? this.shadowColor,
//       shadowOffset: shadowOffset ?? this.shadowOffset,
//       shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
//     );
//   }
// }

// class BackgroundState {
//   final Color? backgroundColor;
//   final Gradient? backgroundGradient;
//   final String? backgroundImagePath;

//   BackgroundState({
//     this.backgroundColor,
//     this.backgroundGradient,
//     this.backgroundImagePath,
//   });

//   BackgroundState copyWith({
//     Color? backgroundColor,
//     Gradient? backgroundGradient,
//     String? backgroundImagePath,
//   }) {
//     return BackgroundState(
//       backgroundColor: backgroundColor ?? this.backgroundColor,
//       backgroundGradient: backgroundGradient ?? this.backgroundGradient,
//       backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
//     );
//   }
// }

import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// class EditorState {
//   final LogoStateData logo;
//   final BackgroundState background;

//   EditorState({required this.logo, required this.background});

//   EditorState clone() => EditorState(
//         logo: logo.clone(),
//         background: background.clone(),
//       );
// }

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
  final int fontIndex;

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
    this.fontIndex = 0,
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
    int? fontIndex,
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
      fontIndex: fontIndex ?? this.fontIndex,
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
      fontIndex: fontIndex,
      isOutlined: isOutlined,
      outlineColor: Color(outlineColor.value),
      strokeWidth: strokeWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomTextElement &&
          runtimeType == other.runtimeType &&
          textAlign == other.textAlign &&
          text == other.text &&
          position == other.position &&
          size == other.size &&
          rotation == other.rotation &&
          opacity == other.opacity &&
          isVisible == other.isVisible &&
          layerIndex == other.layerIndex &&
          color == other.color &&
          fontWeight == other.fontWeight &&
          fontIndex == other.fontIndex &&
          isOutlined == other.isOutlined &&
          outlineColor == other.outlineColor &&
          strokeWidth == other.strokeWidth;

  @override
  int get hashCode => Object.hash(
        textAlign,
        text,
        position,
        size,
        rotation,
        opacity,
        isVisible,
        layerIndex,
        color,
        fontWeight,
        fontIndex,
        isOutlined,
        outlineColor,
        strokeWidth,
      );
}

class CustomImageElement {
  final String path;
  final Offset position;
  final double rotation;
  final double? size;
  final double opacity;
  final bool isVisible;
  final int? layerIndex;
  final Color? color; // optional tint color for the image
  final Color? outlineColor;
  final double outlineWidth;
  final BoxFit fit;
  final double?
      aspectRatio; // width / height, nullable to keep square by default

  const CustomImageElement({
    required this.path,
    required this.position,
    required this.rotation,
    this.size,
    this.opacity = 1.0,
    this.isVisible = true,
    this.layerIndex,
    this.color,
    this.outlineColor,
    this.outlineWidth = 0,
    this.fit = BoxFit.contain,
    this.aspectRatio,
  });

  CustomImageElement copyWith({
    String? path,
    Offset? position,
    double? rotation,
    double? size,
    double? opacity,
    bool? isVisible,
    int? layerIndex,
    Color? color,
    Color? outlineColor,
    double? outlineWidth,
    BoxFit? fit,
    double? aspectRatio,
  }) {
    return CustomImageElement(
      path: path ?? this.path,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      layerIndex: layerIndex ?? this.layerIndex,
      color: color ?? this.color,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      fit: fit ?? this.fit,
      aspectRatio: aspectRatio ?? this.aspectRatio,
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
      color: color,
      outlineColor: outlineColor,
      outlineWidth: outlineWidth,
      fit: fit,
      aspectRatio: aspectRatio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomImageElement &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          position == other.position &&
          rotation == other.rotation &&
          size == other.size &&
          opacity == other.opacity &&
          isVisible == other.isVisible &&
          layerIndex == other.layerIndex &&
          color == other.color &&
          outlineColor == other.outlineColor &&
          outlineWidth == other.outlineWidth &&
          fit == other.fit &&
          aspectRatio == other.aspectRatio;

  @override
  int get hashCode => Object.hash(
        path,
        position,
        rotation,
        size,
        opacity,
        isVisible,
        layerIndex,
        color,
        outlineColor,
        outlineWidth,
        fit,
        aspectRatio,
      );
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomSvgElement &&
          runtimeType == other.runtimeType &&
          svgString == other.svgString &&
          position == other.position &&
          color == other.color &&
          size == other.size &&
          rotation == other.rotation &&
          opacity == other.opacity &&
          isVisible == other.isVisible &&
          layerIndex == other.layerIndex;

  @override
  int get hashCode => Object.hash(
        svgString,
        position,
        color,
        size,
        rotation,
        opacity,
        isVisible,
        layerIndex,
      );
}

class LogoStateData {
  final Map<String, Color> elementColors;
  final Map<String, double> outlineWidths;
  final Map<String, Color> outlineColors;
  final Map<int, double> rotationXMap;
  final Map<int, double> rotationYMap;
  final Map<int, double> rotationZMap;
  final double perspective;
  final Color logoColor;
  final bool isLogoColorOverridden;
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
  final int companyFontIndex;
  final int sloganFontIndex;

  // Background state fields
  final String? selectedShapeName;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final String? backgroundImagePath;

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
    this.logoColor = Colors.black,
    this.isLogoColorOverridden = false,
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
    this.companyFontIndex = 0,
    this.sloganFontIndex = 0,
    this.selectedShapeName,
    this.backgroundColor,
    this.backgroundGradient,
    this.backgroundImagePath,
  })  : customTexts = customTexts ?? [],
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
    Color? logoColor,
    bool? isLogoColorOverridden,
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
    int? companyFontIndex,
    int? sloganFontIndex,
    String? selectedShapeName,
    Color? backgroundColor,
    Gradient? backgroundGradient,
    String? backgroundImagePath,
    bool clearBackgroundColor = false,
    bool clearBackgroundGradient = false,
    bool clearBackgroundImagePath = false,
  }) {
    return LogoStateData(
      elementColors: elementColors ?? this.elementColors,
      outlineWidths: outlineWidths ?? this.outlineWidths,
      outlineColors: outlineColors ?? this.outlineColors,
      rotationXMap: rotationXMap ?? this.rotationXMap,
      rotationYMap: rotationYMap ?? this.rotationYMap,
      rotationZMap: rotationZMap ?? this.rotationZMap,
      perspective: perspective ?? this.perspective,
      logoColor: logoColor ?? this.logoColor,
      isLogoColorOverridden:
          isLogoColorOverridden ?? this.isLogoColorOverridden,
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
      companyFontIndex: companyFontIndex ?? this.companyFontIndex,
      sloganFontIndex: sloganFontIndex ?? this.sloganFontIndex,
      selectedShapeName: selectedShapeName ?? this.selectedShapeName,
      backgroundColor: clearBackgroundColor
          ? null
          : (backgroundColor ?? this.backgroundColor),
      backgroundGradient: clearBackgroundGradient
          ? null
          : (backgroundGradient ?? this.backgroundGradient),
      backgroundImagePath: clearBackgroundImagePath
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
    );
  }

  // LogoStateData clone() {
  //   return LogoStateData(
  //     backgroundColor:
  //         backgroundColor != null ? Color(backgroundColor!.value) : null,
  //     // backgroundColor:
  //     //     backgroundColor != null ? Color(backgroundColor!.value) : null,

  //     // ✅ FIX: Deep clone the gradient
  //     backgroundGradient: _cloneGradient(backgroundGradient),

  //     backgroundImagePath: backgroundImagePath,
  //     elementColors: Map<String, Color>.from(elementColors),
  //     outlineWidths: Map<String, double>.from(outlineWidths),
  //     outlineColors: Map<String, Color>.from(outlineColors),
  //     rotationXMap: Map<int, double>.from(rotationXMap),
  //     rotationYMap: Map<int, double>.from(rotationYMap),
  //     rotationZMap: Map<int, double>.from(rotationZMap),

  //     perspective: perspective ?? this.perspective,

  //     logoColor: Color(logoColor.value),
  //     isLogoColorOverridden: isLogoColorOverridden,
  //     companyNameColor: Color(companyNameColor.value),
  //     companyNameOutlineColor: Color(companyNameOutlineColor.value),
  //     companyNameOutlineWidth: companyNameOutlineWidth,

  //     sloganColor: Color(sloganColor.value),
  //     sloganOutlineColor: Color(sloganOutlineColor.value),
  //     sloganOutlineWidth: sloganOutlineWidth,

  //     logoPosition: Offset(logoPosition.dx, logoPosition.dy),
  //     logoSize: logoSize,
  //     logoRotation: logoRotation,
  //     isLogoVisible: isLogoVisible,
  //     svgLogo: svgLogo,

  //     companyNamePosition: Offset(
  //       companyNamePosition.dx,
  //       companyNamePosition.dy,
  //     ),
  //     companyNameSize: companyNameSize,
  //     companyNameRotation: companyNameRotation,
  //     isCompanyNameVisible: isCompanyNameVisible,
  //     companyName: companyName,

  //     sloganPosition: Offset(sloganPosition.dx, sloganPosition.dy),
  //     sloganSize: sloganSize,
  //     sloganRotation: sloganRotation,
  //     isSloganVisible: isSloganVisible,
  //     sloganName: sloganName,

  //     logo2Position: logo2Position == null
  //         ? null
  //         : Offset(logo2Position!.dx, logo2Position!.dy),
  //     logo2Size: logo2Size,
  //     logo2Rotation: logo2Rotation,
  //     isLogo2Visible: isLogo2Visible,

  //     companyName2Position: companyName2Position == null
  //         ? null
  //         : Offset(companyName2Position!.dx, companyName2Position!.dy),
  //     companyName2Size: companyName2Size,
  //     companyName2Rotation: companyName2Rotation,
  //     isCompanyName2Visible: isCompanyName2Visible,

  //     slogan2Position: slogan2Position == null
  //         ? null
  //         : Offset(slogan2Position!.dx, slogan2Position!.dy),
  //     slogan2Size: slogan2Size,
  //     slogan2Rotation: slogan2Rotation,
  //     isSlogan2Visible: isSlogan2Visible,

  //     /// 🔥 Deep clone lists (VERY IMPORTANT)
  //     customTexts: customTexts
  //         .map((e) => e.clone()) // requires clone() in CustomTextElement
  //         .toList(),
  //     customImages: customImages
  //         .map((e) => e.clone()) // requires clone() in CustomImageElement
  //         .toList(),
  //     customSVGs: customSVGs
  //         .map((e) => e.clone()) // requires clone() in CustomSvgElement
  //         .toList(),

  //     /// 🔥 Deep clone sets and lists
  //     lockedElements: Set<int>.from(lockedElements),
  //     elementOrder: List<int>.from(elementOrder),

  //     companyNameTextAlign: companyNameTextAlign,
  //     sloganTextAlign: sloganTextAlign,
  //     companyFontIndex: companyFontIndex,
  //     sloganFontIndex: sloganFontIndex,
  //     selectedShapeName: selectedShapeName,
  //     // backgroundColor:
  //     //     backgroundColor != null ? Color(backgroundColor!.value) : null,
  //     // backgroundGradient: backgroundGradient,
  //     // backgroundImagePath: backgroundImagePath,
  //   );
  // }

  LogoStateData clone() {
    return LogoStateData(
      backgroundColor:
          backgroundColor != null ? Color(backgroundColor!.value) : null,

      // ✅ FIX: Deep clone the gradient
      backgroundGradient: _cloneGradient(backgroundGradient),

      backgroundImagePath: backgroundImagePath,
      elementColors: Map<String, Color>.from(elementColors),
      outlineWidths: Map<String, double>.from(outlineWidths),
      outlineColors: Map<String, Color>.from(outlineColors),
      rotationXMap: Map<int, double>.from(rotationXMap),
      rotationYMap: Map<int, double>.from(rotationYMap),
      rotationZMap: Map<int, double>.from(rotationZMap),

      perspective: perspective ?? this.perspective,

      logoColor: Color(logoColor.value),
      isLogoColorOverridden: isLogoColorOverridden,
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

      logo2Position: logo2Position == null
          ? null
          : Offset(logo2Position!.dx, logo2Position!.dy),
      logo2Size: logo2Size,
      logo2Rotation: logo2Rotation,
      isLogo2Visible: isLogo2Visible,

      companyName2Position: companyName2Position == null
          ? null
          : Offset(companyName2Position!.dx, companyName2Position!.dy),
      companyName2Size: companyName2Size,
      companyName2Rotation: companyName2Rotation,
      isCompanyName2Visible: isCompanyName2Visible,

      slogan2Position: slogan2Position == null
          ? null
          : Offset(slogan2Position!.dx, slogan2Position!.dy),
      slogan2Size: slogan2Size,
      slogan2Rotation: slogan2Rotation,
      isSlogan2Visible: isSlogan2Visible,

      /// 🔥 Deep clone lists (VERY IMPORTANT)
      customTexts: customTexts
          .map((e) => e.clone()) // requires clone() in CustomTextElement
          .toList(),
      customImages: customImages
          .map((e) => e.clone()) // requires clone() in CustomImageElement
          .toList(),
      customSVGs: customSVGs
          .map((e) => e.clone()) // requires clone() in CustomSvgElement
          .toList(),

      /// 🔥 Deep clone sets and lists
      lockedElements: Set<int>.from(lockedElements),
      elementOrder: List<int>.from(elementOrder),

      companyNameTextAlign: companyNameTextAlign,
      sloganTextAlign: sloganTextAlign,
      companyFontIndex: companyFontIndex,
      sloganFontIndex: sloganFontIndex,
      selectedShapeName: selectedShapeName,
      // backgroundColor:
      //     backgroundColor != null ? Color(backgroundColor!.value) : null,
      // backgroundGradient: backgroundGradient,
      // backgroundImagePath: backgroundImagePath,
    );
  }

  Gradient? _cloneGradient(Gradient? gradient) {
    // Gradients are immutable in Flutter, so returning the reference is safe.
    return gradient;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LogoStateData) return false;

    return companyNamePosition == other.companyNamePosition &&
        companyNameSize == other.companyNameSize &&
        companyNameRotation == other.companyNameRotation &&
        isCompanyNameVisible == other.isCompanyNameVisible &&
        companyName == other.companyName &&
        sloganPosition == other.sloganPosition &&
        sloganSize == other.sloganSize &&
        sloganRotation == other.sloganRotation &&
        isSloganVisible == other.isSloganVisible &&
        sloganName == other.sloganName &&
        logoPosition == other.logoPosition &&
        logoSize == other.logoSize &&
        logoRotation == other.logoRotation &&
        isLogoVisible == other.isLogoVisible &&
        svgLogo == other.svgLogo &&
        logoColor == other.logoColor &&
        isLogoColorOverridden == other.isLogoColorOverridden &&
        companyNameColor == other.companyNameColor &&
        sloganColor == other.sloganColor &&
        backgroundColor == other.backgroundColor &&
        backgroundGradient == other.backgroundGradient &&
        backgroundImagePath == other.backgroundImagePath &&
        selectedShapeName == other.selectedShapeName &&
        companyFontIndex == other.companyFontIndex &&
        sloganFontIndex == other.sloganFontIndex &&
        companyNameTextAlign == other.companyNameTextAlign &&
        sloganTextAlign == other.sloganTextAlign &&
        perspective == other.perspective &&
        companyNameOutlineColor == other.companyNameOutlineColor &&
        companyNameOutlineWidth == other.companyNameOutlineWidth &&
        sloganOutlineColor == other.sloganOutlineColor &&
        sloganOutlineWidth == other.sloganOutlineWidth &&
        isLogo2Visible == other.isLogo2Visible &&
        logo2Position == other.logo2Position &&
        logo2Size == other.logo2Size &&
        logo2Rotation == other.logo2Rotation &&
        isCompanyName2Visible == other.isCompanyName2Visible &&
        companyName2Position == other.companyName2Position &&
        companyName2Size == other.companyName2Size &&
        companyName2Rotation == other.companyName2Rotation &&
        isSlogan2Visible == other.isSlogan2Visible &&
        slogan2Position == other.slogan2Position &&
        slogan2Size == other.slogan2Size &&
        slogan2Rotation == other.slogan2Rotation &&
        listEquals(customTexts, other.customTexts) &&
        listEquals(customImages, other.customImages) &&
        listEquals(customSVGs, other.customSVGs) &&
        setEquals(lockedElements, other.lockedElements) &&
        listEquals(elementOrder, other.elementOrder) &&
        mapEquals(elementColors, other.elementColors) &&
        mapEquals(outlineWidths, other.outlineWidths) &&
        mapEquals(outlineColors, other.outlineColors) &&
        mapEquals(rotationXMap, other.rotationXMap) &&
        mapEquals(rotationYMap, other.rotationYMap) &&
        mapEquals(rotationZMap, other.rotationZMap);
  }

  @override
  int get hashCode {
    return Object.hashAll([
      companyNamePosition,
      companyNameSize,
      companyNameRotation,
      isCompanyNameVisible,
      companyName,
      sloganPosition,
      sloganSize,
      sloganRotation,
      isSloganVisible,
      sloganName,
      logoPosition,
      logoSize,
      logoRotation,
      isLogoVisible,
      svgLogo,
      logoColor,
      isLogoColorOverridden,
      companyNameColor,
      sloganColor,
      backgroundColor,
    ]);
  }

  /// Serialize to JSON-friendly map
  Map<String, dynamic> toJson() {
    Map<String, dynamic> mapColor(Map<String, Color> m) =>
        m.map((k, v) => MapEntry(k, v.value));

    return {
      'elementColors': mapColor(elementColors),
      'outlineWidths': outlineWidths,
      'outlineColors': outlineColors.map((k, v) => MapEntry(k, v.value)),
      'rotationXMap': rotationXMap.map((k, v) => MapEntry(k.toString(), v)),
      'rotationYMap': rotationYMap.map((k, v) => MapEntry(k.toString(), v)),
      'rotationZMap': rotationZMap.map((k, v) => MapEntry(k.toString(), v)),
      'perspective': perspective,
      'logoColor': logoColor.value,
      'isLogoColorOverridden': isLogoColorOverridden,
      'companyNameColor': companyNameColor.value,
      'sloganColor': sloganColor.value,
      'companyNameOutlineColor': companyNameOutlineColor.value,
      'companyNameOutlineWidth': companyNameOutlineWidth,
      'sloganOutlineColor': sloganOutlineColor.value,
      'sloganOutlineWidth': sloganOutlineWidth,
      'logoPosition': {'dx': logoPosition.dx, 'dy': logoPosition.dy},
      'logoSize': logoSize,
      'logoRotation': logoRotation,
      'isLogoVisible': isLogoVisible,
      'svgLogo': svgLogo,
      'companyNamePosition': {
        'dx': companyNamePosition.dx,
        'dy': companyNamePosition.dy
      },
      'companyNameSize': companyNameSize,
      'companyNameRotation': companyNameRotation,
      'isCompanyNameVisible': isCompanyNameVisible,
      'companyName': companyName,
      'sloganPosition': {'dx': sloganPosition.dx, 'dy': sloganPosition.dy},
      'sloganSize': sloganSize,
      'sloganRotation': sloganRotation,
      'isSloganVisible': isSloganVisible,
      'sloganName': sloganName,
      'customTexts': customTexts
          .map((t) => {
                'textAlign': t.textAlign.toString(),
                'text': t.text,
                'position': {'dx': t.position.dx, 'dy': t.position.dy},
                'size': t.size,
                'rotation': t.rotation,
                'opacity': t.opacity,
                'isVisible': t.isVisible,
                'layerIndex': t.layerIndex,
                'color': t.color.value,
                'isOutlined': t.isOutlined,
                'outlineColor': t.outlineColor.value,
                'strokeWidth': t.strokeWidth,
                'fontWeight': t.fontWeight.index,
                'fontIndex': t.fontIndex,
              })
          .toList(),
      'customImages': customImages
          .map((i) => {
                'path': i.path,
                'position': {'dx': i.position.dx, 'dy': i.position.dy},
                'rotation': i.rotation,
                'size': i.size,
                'opacity': i.opacity,
                'isVisible': i.isVisible,
                'layerIndex': i.layerIndex,
              })
          .toList(),
      'customSVGs': customSVGs
          .map((s) => {
                'svgString': s.svgString,
                'position': {'dx': s.position.dx, 'dy': s.position.dy},
                'color': s.color?.value,
                'size': s.size,
                'rotation': s.rotation,
                'opacity': s.opacity,
                'isVisible': s.isVisible,
                'layerIndex': s.layerIndex,
              })
          .toList(),
      'lockedElements': lockedElements.toList(),
      'elementOrder': elementOrder,
      'companyNameTextAlign': companyNameTextAlign.toString(),
      'sloganTextAlign': sloganTextAlign.toString(),
      'companyFontIndex': companyFontIndex,
      'sloganFontIndex': sloganFontIndex,
      'selectedShapeName': selectedShapeName,
      'backgroundColor': backgroundColor?.value,
      'backgroundImagePath': backgroundImagePath,
    };
  }

  /// Create LogoStateData from JSON map (robust / tolerant)
  factory LogoStateData.fromJson(Map<String, dynamic> json) {
    Color parseColor(dynamic v, [Color fallback = Colors.black]) {
      if (v == null) return fallback;
      if (v is int) return Color(v);
      if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null) return Color(parsed);
        // hex string like #FF00FF
        try {
          final hex = v.replaceAll('#', '');
          return Color(int.parse(hex, radix: 16));
        } catch (_) {}
      }
      if (v is Map && v.containsKey('value')) return Color(v['value']);
      return fallback;
    }

    int parseInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    Offset parseOffset(dynamic o, [Offset fallback = Offset.zero]) {
      if (o == null) return fallback;
      if (o is Map && o.containsKey('dx') && o.containsKey('dy')) {
        return Offset((o['dx'] as num).toDouble(), (o['dy'] as num).toDouble());
      }
      if (o is List && o.length >= 2)
        return Offset((o[0] as num).toDouble(), (o[1] as num).toDouble());
      return fallback;
    }

    Map<String, Color> elementColors = {};
    if (json['elementColors'] is Map) {
      (json['elementColors'] as Map).forEach((k, v) {
        elementColors[k.toString()] = parseColor(v);
      });
    }

    Map<String, double> outlineWidths = {};
    if (json['outlineWidths'] is Map) {
      (json['outlineWidths'] as Map).forEach((k, v) {
        outlineWidths[k.toString()] = (v as num).toDouble();
      });
    }

    Map<String, Color> outlineColors = {};
    if (json['outlineColors'] is Map) {
      (json['outlineColors'] as Map).forEach((k, v) {
        outlineColors[k.toString()] = parseColor(v, Colors.transparent);
      });
    }

    Map<int, double> rotationXMap = {};
    if (json['rotationXMap'] is Map) {
      (json['rotationXMap'] as Map).forEach((k, v) {
        final key = int.tryParse(k.toString());
        if (key != null) rotationXMap[key] = (v as num).toDouble();
      });
    }

    Map<int, double> rotationYMap = {};
    if (json['rotationYMap'] is Map) {
      (json['rotationYMap'] as Map).forEach((k, v) {
        final key = int.tryParse(k.toString());
        if (key != null) rotationYMap[key] = (v as num).toDouble();
      });
    }

    Map<int, double> rotationZMap = {};
    if (json['rotationZMap'] is Map) {
      (json['rotationZMap'] as Map).forEach((k, v) {
        final key = int.tryParse(k.toString());
        if (key != null) rotationZMap[key] = (v as num).toDouble();
      });
    }

    final customTexts = <CustomTextElement>[];
    if (json['customTexts'] is List) {
      for (final t in json['customTexts']) {
        try {
          FontWeight parseFontWeight(dynamic v) {
            if (v is int) {
              switch (v) {
                case 0:
                  return FontWeight.w100;
                case 1:
                  return FontWeight.w200;
                case 2:
                  return FontWeight.w300;
                case 3:
                  return FontWeight.normal;
                case 4:
                  return FontWeight.w500;
                case 5:
                  return FontWeight.w600;
                case 6:
                  return FontWeight.w700;
                case 7:
                  return FontWeight.w800;
                case 8:
                  return FontWeight.w900;
                default:
                  return FontWeight.normal;
              }
            }
            return FontWeight.normal;
          }

          customTexts.add(CustomTextElement(
            text: t['text'] ?? '',
            position: parseOffset(t['position'], Offset.zero),
            size: (t['size'] as num?)?.toDouble() ?? 14.0,
            rotation: (t['rotation'] as num?)?.toDouble() ?? 0.0,
            opacity: (t['opacity'] as num?)?.toDouble() ?? 1.0,
            isVisible: t['isVisible'] ?? true,
            layerIndex: t['layerIndex'] as int?,
            color: parseColor(t['color'], Colors.black),
            isOutlined: t['isOutlined'] ?? false,
            outlineColor: parseColor(t['outlineColor'], Colors.black),
            strokeWidth: (t['strokeWidth'] as num?)?.toDouble() ?? 1.0,
            fontWeight: parseFontWeight(t['fontWeight']),
            fontIndex: (t['fontIndex'] as int?) ?? 0,
          ));
        } catch (_) {}
      }
    }

    final customImages = <CustomImageElement>[];
    if (json['customImages'] is List) {
      for (final i in json['customImages']) {
        try {
          customImages.add(CustomImageElement(
            path: i['path'] ?? '',
            position: parseOffset(i['position'], Offset.zero),
            rotation: (i['rotation'] as num?)?.toDouble() ?? 0.0,
            size: (i['size'] as num?)?.toDouble(),
            opacity: (i['opacity'] as num?)?.toDouble() ?? 1.0,
            isVisible: i['isVisible'] ?? true,
            layerIndex: i['layerIndex'] as int?,
          ));
        } catch (_) {}
      }
    }

    final customSVGs = <CustomSvgElement>[];
    if (json['customSVGs'] is List) {
      for (final s in json['customSVGs']) {
        try {
          customSVGs.add(CustomSvgElement(
            svgString: s['svgString'] ?? '',
            position: parseOffset(s['position'], Offset.zero),
            color: s['color'] == null
                ? null
                : parseColor(s['color'], Colors.black),
            size: (s['size'] as num?)?.toDouble() ?? 64.0,
            rotation: (s['rotation'] as num?)?.toDouble() ?? 0.0,
            opacity: (s['opacity'] as num?)?.toDouble() ?? 1.0,
            isVisible: s['isVisible'] ?? true,
            layerIndex: s['layerIndex'] as int?,
          ));
        } catch (_) {}
      }
    }

    final locked = <int>{};
    if (json['lockedElements'] is List) {
      for (final li in json['lockedElements']) {
        final val = (li as num).toInt();
        locked.add(val);
      }
    }

    final elementOrder = <int>[];
    if (json['elementOrder'] is List) {
      for (final el in json['elementOrder']) {
        elementOrder.add((el as num).toInt());
      }
    }

    return LogoStateData(
      elementColors: elementColors,
      outlineWidths: outlineWidths,
      outlineColors: outlineColors,
      rotationXMap: rotationXMap,
      rotationYMap: rotationYMap,
      rotationZMap: rotationZMap,
      perspective: (json['perspective'] as num?)?.toDouble() ?? 0.001,
      customTexts: customTexts,
      customImages: customImages,
      customSVGs: customSVGs,
      lockedElements: locked,
      elementOrder: elementOrder,
      logoColor: parseColor(json['logoColor'], Colors.black),
      isLogoColorOverridden: json['isLogoColorOverridden'] ?? false,
      companyNameColor: parseColor(json['companyNameColor'], Colors.black),
      sloganColor: parseColor(json['sloganColor'], Colors.black),
      companyNameOutlineColor:
          parseColor(json['companyNameOutlineColor'], Colors.transparent),
      companyNameOutlineWidth:
          (json['companyNameOutlineWidth'] as num?)?.toDouble() ?? 0.0,
      sloganOutlineColor:
          parseColor(json['sloganOutlineColor'], Colors.transparent),
      sloganOutlineWidth:
          (json['sloganOutlineWidth'] as num?)?.toDouble() ?? 0.0,
      logoPosition: parseOffset(json['logoPosition'], const Offset(150, 100)),
      logoSize: (json['logoSize'] as num?)?.toDouble() ?? 150.0,
      logoRotation: (json['logoRotation'] as num?)?.toDouble() ?? 0.0,
      isLogoVisible: json['isLogoVisible'] ?? true,
      svgLogo: json['svgLogo'] as String?,
      companyNamePosition:
          parseOffset(json['companyNamePosition'], const Offset(0, 0)),
      companyNameSize: (json['companyNameSize'] as num?)?.toDouble() ?? 20.0,
      companyNameRotation:
          (json['companyNameRotation'] as num?)?.toDouble() ?? 0.0,
      isCompanyNameVisible: json['isCompanyNameVisible'] ?? true,
      companyName: json['companyName'] as String?,
      sloganPosition: parseOffset(json['sloganPosition'], const Offset(0, 0)),
      // restore saved font indices if present (robust parsing)
      companyFontIndex: parseInt(json['companyFontIndex'], 0),
      sloganFontIndex: parseInt(json['sloganFontIndex'], 0),
      sloganSize: (json['sloganSize'] as num?)?.toDouble() ?? 16.0,
      sloganRotation: (json['sloganRotation'] as num?)?.toDouble() ?? 0.0,
      isSloganVisible: json['isSloganVisible'] ?? true,
      sloganName: json['sloganName'] as String?,
      logo2Position: json['logo2Position'] == null
          ? null
          : parseOffset(json['logo2Position']),
      logo2Size: (json['logo2Size'] as num?)?.toDouble(),
      logo2Rotation: (json['logo2Rotation'] as num?)?.toDouble(),
      isLogo2Visible: json['isLogo2Visible'] ?? false,
      companyName2Position: json['companyName2Position'] == null
          ? null
          : parseOffset(json['companyName2Position']),
      companyName2Size: (json['companyName2Size'] as num?)?.toDouble(),
      companyName2Rotation: (json['companyName2Rotation'] as num?)?.toDouble(),
      isCompanyName2Visible: json['isCompanyName2Visible'] ?? false,
      slogan2Position: json['slogan2Position'] == null
          ? null
          : parseOffset(json['slogan2Position']),
      slogan2Size: (json['slogan2Size'] as num?)?.toDouble(),
      slogan2Rotation: (json['slogan2Rotation'] as num?)?.toDouble(),
      isSlogan2Visible: json['isSlogan2Visible'] ?? false,
      companyNameTextAlign: TextAlign.center,
      sloganTextAlign: TextAlign.center,
      selectedShapeName: json['selectedShapeName'] as String?,
      backgroundColor: json['backgroundColor'] == null
          ? null
          : parseColor(json['backgroundColor'], Colors.white),
      backgroundImagePath: json['backgroundImagePath'] as String?,
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
