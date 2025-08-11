import 'dart:ui';


class CustomTextElement {
  final String text;
  final Offset position;
  final double size;
  final double rotation;
  final double opacity;
  final bool isVisible;
  final int? layerIndex;
  final Color color; // ✅ ADD THIS LINE

  const CustomTextElement({
    required this.text,
    required this.position,
    required this.size,
    required this.rotation,
    this.opacity = 1.0,
    this.isVisible = true,
    this.layerIndex,
    this.color = const Color(0xFF000000), // ✅ default black color
  });

  CustomTextElement copyWith({
    String? text,
    Offset? position,
    double? size,
    double? rotation,
    double? opacity,
    bool? isVisible,
    int? layerIndex,
    Color? color, // ✅ ADD THIS
  }) {
    return CustomTextElement(
      text: text ?? this.text,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      layerIndex: layerIndex ?? this.layerIndex,
      color: color ?? this.color, // ✅ ADD THIS
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
}


class LogoElement {
  final int id;
  final Offset position;
  final double size;
  final double rotation;
  final double opacity;
  final bool isVisible;
  final int? layerIndex;
  final String text;
  final Color color; // ✅ NEW

  LogoElement({
    required this.id,
    required this.position,
    required this.size,
    required this.rotation,
    required this.opacity,
    required this.isVisible,
    this.layerIndex,
    required this.text,
    this.color = const Color(0xFF000000), // default black
  });

  LogoElement copyWith({
    int? id,
    Offset? position,
    double? size,
    double? rotation,
    double? opacity,
    bool? isVisible,
    int? layerIndex,
    String? text,
    Color? color, // ✅ NEW
  }) {
    return LogoElement(
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      layerIndex: layerIndex ?? this.layerIndex,
      text: text ?? this.text,
      color: color ?? this.color, // ✅ assign
    );
  }
}



class LogoStateData {
  final Offset logoPosition;
  final double logoSize;
  final double logoRotation;
  final bool isLogoVisible;

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

  final Set<int> lockedElements;
  final List<int> elementOrder;

  LogoStateData({
    required this.logoPosition,
    required this.logoSize,
    required this.logoRotation,
    required this.isLogoVisible,
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
    List<CustomTextElement>? customTexts,
    List<CustomImageElement>? customImages,
    Set<int>? lockedElements,
    List<int>? elementOrder,
  })  : customTexts = customTexts ?? [],
        customImages = customImages ?? [],
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
  return ids;
}


  LogoStateData copyWith({
    Offset? logoPosition,
    double? logoSize,
    double? logoRotation,
    bool? isLogoVisible,
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
    Set<int>? lockedElements,
    List<int>? elementOrder,
  }) {
    return LogoStateData(
      logoPosition: logoPosition ?? this.logoPosition,
      logoSize: logoSize ?? this.logoSize,
      logoRotation: logoRotation ?? this.logoRotation,
      isLogoVisible: isLogoVisible ?? this.isLogoVisible,
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
      customTexts: customTexts ?? [...this.customTexts],
      customImages: customImages ?? [...this.customImages],
      lockedElements: lockedElements ?? {...this.lockedElements},
      elementOrder: elementOrder ?? [...this.elementOrder],
    );
  }
}
