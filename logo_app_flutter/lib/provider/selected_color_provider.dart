// import 'dart:io';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';

// class SelectedColorProvider extends ChangeNotifier {
//   Color _selectedColor = Colors.white;
//   Gradient? _selectedGradient;
//   ui.Image? _backgroundImage;
//   File? _imageFile;
//   Color _companyTextColor = Colors.black;
//   Color _sloganColor = Colors.black;
//   Color _shapeColor = Colors.white;
//  bool _isColorManuallySelected = false;

//     bool get isColorOverrideActive =>
//     _selectedGradient != null ||
//     _backgroundImage != null ||
//     _isColorManuallySelected;
      

//     // ✅ default black


//   // bool get shouldApplyShapeColor =>
//   //   _selectedGradient != null ||
//   //   _backgroundImage != null ||
//   //   _shapeColor != Colors.white;



//   Color get companyTextColor => _companyTextColor;
//   Color get sloganColor => _sloganColor;
//   Color get shapeColor => _shapeColor;
//   int _rotateIndex = 0;

//   Color _baseColor = Colors.black; // real color without brightness
//   double _brightness = 0.5;

//   Color get baseColor => _baseColor;
//   double get brightness => _brightness;

//   Color get selectedColor => _selectedColor;
//   Gradient? get selectedGradient => _selectedGradient;
//   ui.Image? get backgroundImage => _backgroundImage;
//   File? get imageFile => _imageFile;
//   int get rotateIndex => _rotateIndex;

//   void setColor(Color color) {
//     _selectedColor = color;
//     _selectedGradient = null;
//     _backgroundImage = null;
//      _isColorManuallySelected = true;
//     notifyListeners();
//   }

//   void setGradient(Gradient gradient) {
//     _selectedGradient = gradient;
//     _backgroundImage = null;
//     notifyListeners();
//   }

//   void setBackgroundImage(ui.Image image, File? file) {
//     _backgroundImage = image;
//     _selectedGradient = null;
//     _selectedColor = Colors.transparent;
//     _imageFile = file;
//     notifyListeners();
//   }

//   void clearAll() {
//     _backgroundImage = null;
//     _imageFile = null;
//     _selectedGradient = null;
//     _selectedColor = Colors.white;
//     notifyListeners();
//   }

//   void setColorWithBrightness(Color baseColor, double brightnessFactor) {
//     // Clamp value between 0 and 1
//     brightnessFactor = brightnessFactor.clamp(0.0, 1.0);

//     final hsl = HSLColor.fromColor(baseColor);
//     final adjustedColor = hsl.withLightness(brightnessFactor).toColor();

//     _selectedColor = adjustedColor;
//     _selectedGradient = null;
//     _backgroundImage = null;
//      _isColorManuallySelected = true;
//     notifyListeners();
//   }

//   void setCompanyTextColor(Color color) {
//     _companyTextColor = color;
//     notifyListeners();
//   }

//   void setSloganColor(Color color) {
//     _sloganColor = color;
//     notifyListeners();
//   }

//   void setShapeColor(Color color) {
//     _shapeColor = color;
//     notifyListeners();
//   }

//   void setAllColors(Color company, Color slogan, Color shape) {
//     _companyTextColor = company;
//     _sloganColor = slogan;
//     _shapeColor = shape;
//      _isColorManuallySelected = true;
//     notifyListeners();
//   }

//   void setAllColorsWithBrightness(Color baseColor, double brightnessFactor) {
//     brightnessFactor = brightnessFactor.clamp(0.0, 1.0);

//     final hsl = HSLColor.fromColor(baseColor);
//     final adjusted = hsl.withLightness(brightnessFactor).toColor();

//     _shapeColor = adjusted;
//     _companyTextColor = adjusted;
//     _sloganColor = adjusted;

//     _selectedGradient = null;
//     _backgroundImage = null;
//     notifyListeners();
//   }

//   void setColorsRotated(List<Color> paletteColors) {
//     _companyTextColor = paletteColors[(_rotateIndex + 1) % 3];
//     _sloganColor = paletteColors[(_rotateIndex + 2) % 3];
//     _shapeColor = paletteColors[_rotateIndex % 3];

//     _rotateIndex = (_rotateIndex + 1) % 3;
//       _isColorManuallySelected = true;
//     notifyListeners();
//   }

//   void resetRotation() {
//     _rotateIndex = 0;
//     notifyListeners();
//   } 

//   void updateBrightness(double value) {
//     _brightness = value.clamp(0.0, 1.0);
//     _applyBrightnessToAll();
//   }

//   void setBaseColor(Color color) {
//     _baseColor = color;
//     _applyBrightnessToAll();
//   }

//   void _applyBrightnessToAll() {
//     final hsl = HSLColor.fromColor(_baseColor);
//     final adjusted = hsl.withLightness(_brightness).toColor();

//     _selectedColor = adjusted;
//     _shapeColor = adjusted;
//     _companyTextColor = adjusted;
//     _sloganColor = adjusted;
//          _isColorManuallySelected = true;

//     notifyListeners();
//   }
// }

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SelectedColorProvider extends ChangeNotifier {
  Color _selectedColor = Colors.white;
  Gradient? _selectedGradient;
  ui.Image? _backgroundImage;
  File? _imageFile;
  Color _companyTextColor = Colors.black;
  Color _sloganColor = Colors.black;
  Color _shapeColor = Colors.white;

  bool _isColorManuallySelected = false;

  bool get isColorOverrideActive =>
      _selectedGradient != null ||
      _backgroundImage != null ||
      _isColorManuallySelected;

  Color get companyTextColor => _companyTextColor;
  Color get sloganColor => _sloganColor;
  Color get shapeColor => _shapeColor;
  int _rotateIndex = 0;

  Color _baseColor = Colors.black;
  double _brightness = 0.5;

  Color get baseColor => _baseColor;
  double get brightness => _brightness;

  Color get selectedColor => _selectedColor;
  Gradient? get selectedGradient => _selectedGradient;
  ui.Image? get backgroundImage => _backgroundImage;
  File? get imageFile => _imageFile;
  int get rotateIndex => _rotateIndex;

  /// 🔹 Called when user manually picks a solid color
  void setColor(Color color) {
    _selectedColor = color;
    _selectedGradient = null;
    _backgroundImage = null;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  /// 🔹 Called when user picks a gradient
  void setGradient(Gradient gradient) {
    _selectedGradient = gradient;
    _backgroundImage = null;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  /// 🔹 Called when user picks a background image
  void setBackgroundImage(ui.Image image, File? file) {
    _backgroundImage = image;
    _selectedGradient = null;
    _selectedColor = Colors.transparent;
    _imageFile = file;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  /// ✅ Call this when user selects a new logo template (to reset colors)
  void clearOverrides() {
    _selectedColor = Colors.white;
    _selectedGradient = null;
    _backgroundImage = null;
    _imageFile = null;
    _companyTextColor = Colors.black;
    _sloganColor = Colors.black;
    _shapeColor = Colors.white;
    _rotateIndex = 0;
    _isColorManuallySelected = false;
    notifyListeners();
  }

  void setColorWithBrightness(Color baseColor, double brightnessFactor) {
    brightnessFactor = brightnessFactor.clamp(0.0, 1.0);
    final hsl = HSLColor.fromColor(baseColor);
    final adjustedColor = hsl.withLightness(brightnessFactor).toColor();

    _selectedColor = adjustedColor;
    _selectedGradient = null;
    _backgroundImage = null;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void setCompanyTextColor(Color color) {
    _companyTextColor = color;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void setSloganColor(Color color) {
    _sloganColor = color;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void setShapeColor(Color color) {
    _shapeColor = color;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void setAllColors(Color company, Color slogan, Color shape) {
    _companyTextColor = company;
    _sloganColor = slogan;
    _shapeColor = shape;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void setAllColorsWithBrightness(Color baseColor, double brightnessFactor) {
    brightnessFactor = brightnessFactor.clamp(0.0, 1.0);
    final hsl = HSLColor.fromColor(baseColor);
    final adjusted = hsl.withLightness(brightnessFactor).toColor();

    _shapeColor = adjusted;
    _companyTextColor = adjusted;
    _sloganColor = adjusted;

    _selectedGradient = null;
    _backgroundImage = null;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void setColorsRotated(List<Color> paletteColors) {
    _companyTextColor = paletteColors[(_rotateIndex + 1) % 3];
    _sloganColor = paletteColors[(_rotateIndex + 2) % 3];
    _shapeColor = paletteColors[_rotateIndex % 3];

    _rotateIndex = (_rotateIndex + 1) % 3;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void resetRotation() {
    _rotateIndex = 0;
    notifyListeners();
  }

  void updateBrightness(double value) {
    _brightness = value.clamp(0.0, 1.0);
    _applyBrightnessToAll();
  }

  void setBaseColor(Color color) {
    _baseColor = color;
    _applyBrightnessToAll();
  }

  void _applyBrightnessToAll() {
    final hsl = HSLColor.fromColor(_baseColor);
    final adjusted = hsl.withLightness(_brightness).toColor();

    _selectedColor = adjusted;
    _shapeColor = adjusted;
    _companyTextColor = adjusted;
    _sloganColor = adjusted;
    _isColorManuallySelected = true;
    notifyListeners();
  }
}
