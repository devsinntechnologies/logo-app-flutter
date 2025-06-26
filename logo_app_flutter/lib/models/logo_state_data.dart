// ✅ logo_state_data.dart
import 'dart:ui';

class CustomTextElement {
  final String text;
  final Offset position;
  final double size;
  final double rotation;

  const CustomTextElement({
    required this.text,
    required this.position,
    required this.size,
    required this.rotation,
  });

  CustomTextElement copyWith({
    String? text,
    Offset? position,
    double? size,
    double? rotation,
  }) {
    return CustomTextElement(
      text: text ?? this.text,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
    );
  }
}

class LogoStateData {
  // Existing fields...
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

  // Optional second elements...
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

  // ✅ New custom text elements
  final List<CustomTextElement> customTexts;

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
    this.customTexts = const [],
  });

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
      customTexts: customTexts ?? this.customTexts,
    );
  }
}
