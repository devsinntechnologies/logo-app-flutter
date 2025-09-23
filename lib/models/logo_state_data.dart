import 'dart:ui';

import 'package:flutter/material.dart';

class CustomTextElement {
  final String text;
  final Offset position;
  final double size;
  final double rotation;
  final Color? color;
  final String? fontFamily;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final Color? outlineColor;
  final double? outlineWidth;
  final Color? shadowColor;
  final double? shadowOffsetX;
  final double? shadowOffsetY;
  final double? opacity;
  final bool isVisible;

  CustomTextElement({
    required this.text,
    required this.position,
    required this.size,
    required this.rotation,
    this.color,
    this.fontFamily,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.outlineColor,
    this.outlineWidth,
    this.shadowColor,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.opacity,
    this.isVisible = true,
  });

  CustomTextElement copyWith({
    String? text,
    Offset? position,
    double? size,
    double? rotation,
    Color? color,
    String? fontFamily,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    Color? outlineColor,
    double? outlineWidth,
    Color? shadowColor,
    double? shadowOffsetX,
    double? shadowOffsetY,
    double? opacity,
    bool? isVisible,
  }) {
    return CustomTextElement(
      text: text ?? this.text,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOffsetX: shadowOffsetX ?? this.shadowOffsetX,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'position': {'dx': position.dx, 'dy': position.dy},
      'size': size,
      'rotation': rotation,
      'color': color?.value,
      'fontFamily': fontFamily,
      'isBold': isBold,
      'isItalic': isItalic,
      'isUnderline': isUnderline,
      'outlineColor': outlineColor?.value,
      'outlineWidth': outlineWidth,
      'shadowColor': shadowColor?.value,
      'shadowOffsetX': shadowOffsetX,
      'shadowOffsetY': shadowOffsetY,
      'opacity': opacity,
      'isVisible': isVisible,
    };
  }

  factory CustomTextElement.fromJson(Map<String, dynamic> json) {
    return CustomTextElement(
      text: json['text'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: (json['size'] as num?)?.toDouble() ?? 16.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] != null ? Color(json['color']) : null,
      fontFamily: json['fontFamily'],
      isBold: json['isBold'] ?? false,
      isItalic: json['isItalic'] ?? false,
      isUnderline: json['isUnderline'] ?? false,
      outlineColor:
          json['outlineColor'] != null ? Color(json['outlineColor']) : null,
      outlineWidth: (json['outlineWidth'] as num?)?.toDouble(),
      shadowColor:
          json['shadowColor'] != null ? Color(json['shadowColor']) : null,
      shadowOffsetX: (json['shadowOffsetX'] as num?)?.toDouble(),
      shadowOffsetY: (json['shadowOffsetY'] as num?)?.toDouble(),
      opacity: (json['opacity'] as num?)?.toDouble(),
      isVisible: json['isVisible'] ?? true,
    );
  }
}

class CustomImageElement {
  final String path;
  final Offset position;
  final double size;
  final double rotation;
  final bool isAsset;
  final bool isVisible;
  final double opacity;

  const CustomImageElement({
    required this.path,
    required this.position,
    required this.size,
    required this.rotation,
    this.isAsset = false,
    this.isVisible = true,
    this.opacity = 1.0,
  });

  CustomImageElement copyWith({
    String? path,
    Offset? position,
    double? size,
    double? rotation,
    bool? isAsset,
    bool? isVisible,
    double? opacity, 
  }) {
    return CustomImageElement(
      path: path ?? this.path,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      isAsset: isAsset ?? this.isAsset,
      isVisible: isVisible ?? this.isVisible,
      opacity: opacity ?? this.opacity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'position': {'dx': position.dx, 'dy': position.dy},
      'size': size,
      'rotation': rotation,
      'isAsset': isAsset,
      'isVisible': isVisible,
      'opacity': opacity,
    };
  }

  factory CustomImageElement.fromJson(Map<String, dynamic> json) {
    return CustomImageElement(
      path: json['path'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: json['size'],
      rotation: json['rotation'],
      isAsset: json['isAsset'] ?? false,
      isVisible: json['isVisible'] ?? true,
      opacity: json['opacity'] ?? 1.0,
    );
  }
}

class CustomSvgElement {
  final String svgString;
  final Offset position;
  final double size;
  final double rotation;
  final Color? color;
  final double? opacity;
  final bool isVisible;
  final Color? outlineColor;
  final double? outlineWidth;

  CustomSvgElement({
    required this.svgString,
    required this.position,
    required this.size,
    required this.rotation,
    this.color,
    this.opacity,
    this.isVisible = true,
    this.outlineColor,
    this.outlineWidth,
  });

  CustomSvgElement copyWith({
    String? svgString,
    Offset? position,
    double? size,
    double? rotation,
    Color? color,
    double? opacity,
    bool? isVisible,
    Color? outlineColor,
    double? outlineWidth,
  }) {
    return CustomSvgElement(
      svgString: svgString ?? this.svgString,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineWidth: outlineWidth ?? this.outlineWidth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'svgString': svgString,
      'position': {'dx': position.dx, 'dy': position.dy},
      'color': color?.value,
      'size': size,
      'rotation': rotation,
      'isVisible': isVisible,
      'opacity': opacity,
      'outlineColor': outlineColor?.value,
      'outlineWidth': outlineWidth,
    };
  }

  factory CustomSvgElement.fromJson(Map<String, dynamic> json) {
    return CustomSvgElement(
      svgString: json['svgString'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: json['size']?.toDouble() ?? 16.0,
      rotation: json['rotation']?.toDouble() ?? 0.0,
      color: json['color'] != null ? Color(json['color']) : null,
      isVisible: json['isVisible'] ?? true,
      opacity: json['opacity']?.toDouble() ?? 1.0,
      outlineColor:
          json['outlineColor'] != null ? Color(json['outlineColor']) : null,
      outlineWidth: (json['outlineWidth'] as num?)?.toDouble(),
    );
  }
}

class LogoStateData {
  final Color backgroundColor;
  final Color? logoColor;
  final Gradient? backgroundGradient;
  final String? backgroundTexture;
  final String? backgroundImage;
  final List<Color>? palette;
  final double opacity;
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

  String companyNameFont; // <-- Add this
  String sloganFont; // <-- Add this

  LogoStateData({
    List<CustomTextElement>? customTexts,
    List<CustomImageElement>? customImages,
    List<CustomSvgElement>? customSVGs,
    Set<int>? lockedElements,
    List<int>? elementOrder,
    this.backgroundColor = Colors.white,
    this.logoColor,
    this.backgroundGradient,
    this.backgroundTexture,
    this.backgroundImage,
    this.palette,
    this.opacity = 1.0,
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
    this.companyNameFont = 'Roboto', 
    this.sloganFont = 'Roboto',
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
    Offset? logoPosition,
    double? logoSize,
    double? logoRotation,
    bool? isLogoVisible,
    String? svgLogo,
    Color? logoColor,
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
      logoColor: logoColor ?? this.logoColor,
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
      customTexts: customTexts ?? this.customTexts,
      customImages: customImages ?? this.customImages,
      customSVGs: customSVGs ?? this.customSVGs,
      lockedElements: lockedElements ?? this.lockedElements,
      elementOrder: elementOrder ?? this.elementOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logoPosition': {'dx': logoPosition.dx, 'dy': logoPosition.dy},
      'companyNamePosition': {
        'dx': companyNamePosition.dx,
        'dy': companyNamePosition.dy,
      },
      'sloganPosition': {'dx': sloganPosition.dx, 'dy': sloganPosition.dy},
      'logoSize': logoSize,
      'companyNameSize': companyNameSize,
      'sloganSize': sloganSize,
      'logoRotation': logoRotation,
      'companyNameRotation': companyNameRotation,
      'sloganRotation': sloganRotation,
      'isLogoVisible': isLogoVisible,
      'isCompanyNameVisible': isCompanyNameVisible,
      'isSloganVisible': isSloganVisible,
      'companyName': companyName,
      'sloganName': sloganName,
      'svgLogo': svgLogo,
      'elementOrder': elementOrder,
      'lockedElements': lockedElements.toList(),
      'customTexts': customTexts.map((e) => e.toJson()).toList(),
      'customImages': customImages.map((e) => e.toJson()).toList(),
      'customSVGs': customSVGs.map((e) => e.toJson()).toList(),
    };
  }

  factory LogoStateData.fromJson(Map<String, dynamic> json) {
    return LogoStateData(
      logoPosition: Offset(
        (json['logoPosition']['dx'] as num).toDouble(),
        (json['logoPosition']['dy'] as num).toDouble(),
      ),
      companyNamePosition: Offset(
        (json['companyNamePosition']['dx'] as num).toDouble(),
        (json['companyNamePosition']['dy'] as num).toDouble(),
      ),
      sloganPosition: Offset(
        (json['sloganPosition']['dx'] as num).toDouble(),
        (json['sloganPosition']['dy'] as num).toDouble(),
      ),
      elementOrder: List<int>.from(json['elementsOrder'] ?? [0, 1, 2]),
      logoSize: json['logoSize']?.toDouble() ?? 100.0,
      companyNameSize: json['companyNameSize']?.toDouble() ?? 28.0,
      sloganSize: json['sloganSize']?.toDouble() ?? 16.0,
      logoRotation: json['logoRotation']?.toDouble() ?? 0.0,
      companyNameRotation: json['companyNameRotation']?.toDouble() ?? 0.0,
      sloganRotation: json['sloganRotation']?.toDouble() ?? 0.0,
      isLogoVisible: json['isLogoVisible'] ?? true,
      isCompanyNameVisible: json['isCompanyNameVisible'] ?? true,
      isSloganVisible: json['isSloganVisible'] ?? true,
      companyName: json['companyName'],
      sloganName: json['sloganName'],
      svgLogo: json['svgLogo'],
      lockedElements: Set<int>.from(json['lockedElements'] ?? []),
      customTexts:
          (json['customTexts'] as List?)
              ?.map((e) => CustomTextElement.fromJson(e))
              .toList() ??
          [],
      customImages:
          (json['customImages'] as List?)
              ?.map((e) => CustomImageElement.fromJson(e))
              .toList() ??
          [],
      customSVGs:
          (json['customSVGs'] as List?)
              ?.map((e) => CustomSvgElement.fromJson(e))
              .toList() ??
          [],
      isLogo2Visible: json['isLogo2Visible'] ?? false,
      isCompanyName2Visible: json['isCompanyName2Visible'] ?? false,
      isSlogan2Visible: json['isSlogan2Visible'] ?? false,
      logo2Position:
          json['logo2Position'] != null
              ? Offset(json['logo2Position']['dx'], json['logo2Position']['dy'])
              : null,
      logo2Size: json['logo2Size']?.toDouble(),
      logo2Rotation: json['logo2Rotation']?.toDouble(),
      companyName2Position:
          json['companyName2Position'] != null
              ? Offset(
                json['companyName2Position']['dx'],
                json['companyName2Position']['dy'],
              )
              : null,
      companyName2Size: json['companyName2Size']?.toDouble(),
      companyName2Rotation: json['companyName2Rotation']?.toDouble(),
      slogan2Position:
          json['slogan2Position'] != null
              ? Offset(
                json['slogan2Position']['dx'],
                json['slogan2Position']['dy'],
              )
              : null,
      slogan2Size: json['slogan2Size']?.toDouble(),
      slogan2Rotation: json['slogan2Rotation']?.toDouble(),
      companyNameFont: json['companyNameFont'] ?? 'Roboto',
      sloganFont: json['sloganFont'] ?? 'Roboto',
    );
  }
}
