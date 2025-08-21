

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SelectedColorProvider extends ChangeNotifier {
  Color _selectedColor = Colors.white;
  Gradient? _selectedGradient;
  ui.Image? _backgroundImage;
  double get intensity => _brightness;
  final Map<int, Color> _overrideColors = {};
  final Map<int, Color> _individualElementColors = {};
 int _selectedIndex = 0;
int get selectedIndex => _selectedIndex;
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

    int? _selectedElementId;

  int? get selectedElementId => _selectedElementId;
   bool _isSvgColorOverridden = false;

  bool get isSvgColorOverridden => _isSvgColorOverridden;

  void setSvgColorOverridden(bool value) {
    _isSvgColorOverridden = value;
    notifyListeners();
  }

  set selectedElementId(int? id) {
    _selectedElementId = id;
    notifyListeners();
  }


 
  void setColor(Color color) {
    _selectedColor = color;
     _baseColor = color;
    _selectedGradient = null;
    _backgroundImage = null;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void setGradient(Gradient gradient) {
    _selectedGradient = gradient;
    _backgroundImage = null;
    _isColorManuallySelected = true;
    notifyListeners();
  }
  Color getEffectiveColorForElement({
  required int id,
  required Color defaultColor,
}) {
  return _overrideColors[id] ?? defaultColor;
}

 void setPaletteIndex(int index) {
    _selectedIndex = index;
    notifyListeners(); // UI ko update karne k liye
  }

  void setBackgroundImage(ui.Image image, File? file) {
    _backgroundImage = image;
    _selectedGradient = null;
    _selectedColor = Colors.transparent;
    _imageFile = file;
    _isColorManuallySelected = true;
    notifyListeners();
  }

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
  void resetColor() {
  _selectedColor = Colors.white;
  _selectedGradient = null;
  _backgroundImage = null;
  _isColorManuallySelected = false;
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
  // Color? _selectedColor;
  double _opacity = 1.0; // 👈 default 100%

  



  double get opacity => _opacity;

  void setOpacity(double value) {
    _opacity = value;
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

  // void setColorsRotated(List<Color> paletteColors) {
  //   _companyTextColor = paletteColors[(_rotateIndex + 1) % 3];
  //   _sloganColor = paletteColors[(_rotateIndex + 2) % 3];
  //   _shapeColor = paletteColors[_rotateIndex % 3];

  //   _rotateIndex = (_rotateIndex + 1) % 3;
  //   _isColorManuallySelected = true;
  //   notifyListeners();
  // }

//   void setColorsRotated(List<Color> paletteColors, {List<int>? allElementIds}) {
//   // Company, Slogan, Shape ke colors rotate karo
//   _companyTextColor = paletteColors[(_rotateIndex + 1) % paletteColors.length];
//   _sloganColor = paletteColors[(_rotateIndex + 2) % paletteColors.length];
//   _shapeColor = paletteColors[_rotateIndex % paletteColors.length];

//   // Agar tumhare paas sab element IDs ka list hai to unko bhi color set karo
//   if (allElementIds != null) {
//     int index = 0;
//     for (var elementId in allElementIds) {
//       // Images ko skip karna ho to yahan condition lagao
//       _overrideColors[elementId] =
//           paletteColors[index % paletteColors.length];
//       index++;
//     }
//   }

//   _rotateIndex = (_rotateIndex + 1) % paletteColors.length;
//   _isColorManuallySelected = true;
//   notifyListeners();
// }


// void setColorsRotated(List<Color> paletteColors, {List<int>? allElementIds}) {
//   // 1. Company, Slogan, Shape ke liye rotate karo
//   _companyTextColor = paletteColors[(_rotateIndex + 1) % paletteColors.length];
//   _sloganColor = paletteColors[(_rotateIndex + 2) % paletteColors.length];
//   _shapeColor = paletteColors[_rotateIndex % paletteColors.length];

//   // 2. Agar element IDs diye gaye hain
//   if (allElementIds != null) {
//     int index = 0;
//     for (var elementId in allElementIds) {
//       // Image ko skip karna hai
//       if (elementId >= 200 && elementId < 300) {
//         continue; 
//       }

//       _overrideColors[elementId] =
//           paletteColors[index % paletteColors.length];
//       index++;
//     }
//   }

//   // 3. Rotation index update
//   _rotateIndex = (_rotateIndex + 1) % paletteColors.length;

//   // 4. Notify
//   _isColorManuallySelected = true;
//   notifyListeners();
// }
 Map<int, Color> _elementColors = {};
  Map<int, Color> _elementOutlineColors = {};
  Map<int, double> _elementOutlineWidths = {};

  // ========== Outline Setters ==========
  void setOutlineColor(int elementId, Color color) {
    _elementOutlineColors[elementId] = color;
    notifyListeners();
  }

  void setOutlineWidth(int elementId, double width) {
    _elementOutlineWidths[elementId] = width;
    notifyListeners();
  }
  

  // ========== Outline Getters ==========
  Color getOutlineColor(int elementId) {
    return _elementOutlineColors[elementId] ?? Colors.transparent;
  }
   double getOutlineWidth(int elementId) {
    return _elementOutlineWidths[elementId] ?? 0.0;
  }
    /// Remove any active selection (editing handles/icons hide ho jaye)
  void clearSelection() {
    _selectedElementId = null;
    notifyListeners();
  }

  /// Restore selection if needed
  void setSelectedElement(int id) {
    _selectedElementId = id;
    notifyListeners();
  }


void setInitialColorsFromPalette(List<Color> paletteColors, List<int> allElementIds) {
  _rotateIndex = 0;

  // Company / Slogan / Shape ke liye
  _companyTextColor = paletteColors[1 % paletteColors.length];
  _sloganColor = paletteColors[2 % paletteColors.length];
  _shapeColor = paletteColors[0 % paletteColors.length];

  // Baaki elements ke liye
  int index = 0;
  for (var elementId in allElementIds) {
    if (elementId >= 200 && elementId < 300) continue; // images skip
    _overrideColors[elementId] = paletteColors[index % paletteColors.length];
    index++;
  }

  _isColorManuallySelected = true;
  notifyListeners();
}

void setColorsRotated(List<Color> paletteColors, {List<int>? allElementIds}) {
  _companyTextColor = paletteColors[(_rotateIndex + 1) % paletteColors.length];
  _sloganColor = paletteColors[(_rotateIndex + 2) % paletteColors.length];
  _shapeColor = paletteColors[_rotateIndex % paletteColors.length];

  if (allElementIds != null) {
    int index = 0;
    for (var elementId in allElementIds) {
      if (elementId >= 200 && elementId < 300) continue; // images skip
      _overrideColors[elementId] = paletteColors[(index + _rotateIndex) % paletteColors.length];
      index++;
    }
  }

  _rotateIndex = (_rotateIndex + 1) % paletteColors.length;
  _isColorManuallySelected = true;
  notifyListeners();
}


  void resetRotation() {
    _rotateIndex = 0;
    notifyListeners();
  }

  void updateBrightness(double value) {
    _brightness = value.clamp(0.0, 1.0);
    _applyBrightnessToShapeOnly();
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

  void _applyBrightnessToShapeOnly() {
  final hsl = HSLColor.fromColor(_baseColor);
  final adjusted = hsl.withLightness(_brightness).toColor();

  _shapeColor = adjusted;
  _isColorManuallySelected = true;
  notifyListeners();
}

void setOverrideColorForElement(int id, Color color) {
  _overrideColors[id] = color;
  notifyListeners();
}
void clearOverrideForElement(int id) {
  if (_overrideColors.containsKey(id)) {
    _overrideColors.remove(id);
    notifyListeners();
  }
}
Color getColorForElement(int id, {required Color fallback}) {
  return _overrideColors[id] ?? fallback;
  
}


void setColorForElement(int id, Color color) {
  _individualElementColors[id] = color;
  notifyListeners();
}
}

