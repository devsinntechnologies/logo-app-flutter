import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';

class SelectedColorProvider extends ChangeNotifier {
  Color? _selectedColor = null;
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
  Color? _shapeColor;
  Color _customTextColor = Colors.black;
  Color _logoColor = Colors.black;

  bool _isColorManuallySelected = false;
  // new map to track if user manually changed color
  Map<int, bool> _isElementColorOverridden = {};

// updated getColorForElement
// Color getColorForElement(int id, {required Color originalColor}) {
//   if (_isElementColorOverridden[id] == true) {
//     return _overrideColors[id] ?? originalColor;
//   }
//   return originalColor; // first-time original color
// }

// when user changes color manually
// void setOverrideColorForElement(int id, Color color) {
//   _overrideColors[id] = color;
//   _isElementColorOverridden[id] = true; // mark as overridden
//   notifyListeners();
// }

// optional: reset element to original

  void resetAllColors({required Map<int, Color> defaultColors}) {
    _overrideColors.clear(); // user overrides remove ho jaye
    _isElementColorOverridden.clear(); // manual flags reset
    _logoColor = defaultColors[0] ?? Colors.black;
    _companyTextColor = defaultColors[1] ?? Colors.black;
    _sloganColor = defaultColors[2] ?? Colors.black;
    _shapeColor = defaultColors[3] ?? null;
    _isLogoColorOverridden = false;
    notifyListeners();
  }
//  void resetAllColors() {
//     // reset company, slogan, shape to default
//     _companyTextColor = _defaultCompanyColor;
//     _sloganColor = _defaultSloganColor;
//     _shapeColor = _defaultShapeColor;

//     // reset all element overrides
//     _overrideColors.clear();
//     _isElementColorOverridden.clear();

//     _selectedColor = Colors.white;
//     _selectedGradient = null;
//     _backgroundImage = null;
//     _isColorManuallySelected = false;

//     notifyListeners();
//   }

  bool _isCheckerboardVisible = true; // default

  bool get isCheckerboardVisible => _isCheckerboardVisible;

  void setCheckerboardVisibility(bool value) {
    _isCheckerboardVisible = value;
    notifyListeners();
  }

  bool get isColorOverrideActive =>
      _selectedGradient != null ||
      _backgroundImage != null ||
      _isColorManuallySelected;

  Color get companyTextColor => _companyTextColor;
  Color get sloganColor => _sloganColor;
  Color? get shapeColor => _shapeColor;
  Color get customTextColor => _customTextColor;
  Color get logoColor => _logoColor;
  int _rotateIndex = 0;

  Color _baseColor = Colors.black;
  double _brightness = 0.5;
  bool isColorApplied = false;

  Color get baseColor => _baseColor;
  double get brightness => _brightness;

  Color? get selectedColor => _selectedColor;
  Gradient? get selectedGradient => _selectedGradient;
  ui.Image? get backgroundImage => _backgroundImage;
  File? get imageFile => _imageFile;
  int get rotateIndex => _rotateIndex;

  int? _selectedElementId;

  int? get selectedElementId => _selectedElementId;
  bool _isSvgColorOverridden = false;
  bool _isLogoColorOverridden = false;

  bool get isSvgColorOverridden => _isSvgColorOverridden;
  bool get isLogoColorOverridden => _isLogoColorOverridden;

  void setSvgColorOverridden(bool value) {
    _isSvgColorOverridden = value;
    notifyListeners();
  }

  set selectedElementId(int? id) {
    _selectedElementId = id;
    notifyListeners();
  }

  TextAlign _companyNameAlign = TextAlign.center;
  TextAlign _sloganAlign = TextAlign.center;
  TextAlign _customTextAlign = TextAlign.center;

// GETTERS
  TextAlign get companyNameAlign => _companyNameAlign;
  TextAlign get sloganAlign => _sloganAlign;
  TextAlign get customTextAlign => _customTextAlign;

// SETTERS
  void setCompanyNameAlign(TextAlign align) {
    _companyNameAlign = align;
    notifyListeners();
  }

  void setSloganAlign(TextAlign align) {
    _sloganAlign = align;
    notifyListeners();
  }

  void setCustomTextAlign(TextAlign align) {
    _customTextAlign = align;
    notifyListeners();
  }

  ui.Image? canvasImage;

  void setImage(ui.Image image) {
    canvasImage = image;
    notifyListeners();
  }

  void resetImage() {
    canvasImage = null;
    notifyListeners();
  }

  void setColor(Color color) {
    _selectedColor = color;
    _baseColor = color;
    _selectedGradient = null;
    _backgroundImage = null;
    canvasImage = null;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void setGradient(Gradient gradient) {
    _selectedGradient = gradient;
    _backgroundImage = null;
    _selectedColor = null;
    canvasImage = null;
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
  void clearOverrides() {
    canvasImage = null;
    _selectedColor = Colors.white;
    _selectedGradient = null;
    _backgroundImage = null;
    _imageFile = null;
    _companyTextColor = Colors.black;
    _sloganColor = Colors.black;
    _logoColor = Colors.black;
    _isLogoColorOverridden = false;
    // _shapeColor = Colors.white;
    _rotateIndex = 0;
    _isColorManuallySelected = false;
    notifyListeners();
  }


  void setBackgroundImage(ui.Image image, File? file) {
    canvasImage = image;
    _backgroundImage = image;
    _selectedGradient = null;
    _selectedColor = null;
    _imageFile = file;
    _isColorManuallySelected = true;
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

  void setLogoColor(Color color) {
    _logoColor = color;
    _isLogoColorOverridden = true;
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

  void resetAllOutlines() {
    _elementOutlineColors.clear();
    _elementOutlineWidths.clear();
    notifyListeners();
  }
// final LogoState logoState;

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

  void setInitialColorsFromPalette(
      List<Color> paletteColors, List<int> allElementIds) {
    _rotateIndex = 0;

    // Logo / Company / Slogan / Shape ke liye
    _logoColor = paletteColors[0 % paletteColors.length];
    _isLogoColorOverridden = true;
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
    _logoColor = paletteColors[_rotateIndex % paletteColors.length];
    _isLogoColorOverridden = true;
    _companyTextColor =
        paletteColors[(_rotateIndex + 1) % paletteColors.length];
    _sloganColor = paletteColors[(_rotateIndex + 2) % paletteColors.length];
    _shapeColor = paletteColors[_rotateIndex % paletteColors.length];

    if (allElementIds != null) {
      int index = 0;
      for (var elementId in allElementIds) {
        if (elementId >= 200 && elementId < 300) continue; // images skip
        _overrideColors[elementId] =
            paletteColors[(index + _rotateIndex) % paletteColors.length];
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
    _elementColors[id] = color;
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

  Map<int, double> _rotationXMap = {};
  Map<int, double> _rotationYMap = {};
  Map<int, double> _rotationZMap = {};
  double getRotationX(int id) => _rotationXMap[id] ?? 0.0;
  double getRotationY(int id) => _rotationYMap[id] ?? 0.0;
  double getRotationZ(int id) => _rotationZMap[id] ?? 0.0;

  void applyLogoState(LogoStateData state) {
    // Clear old data
    _elementOutlineColors.clear();
    _elementOutlineWidths.clear();
    _elementColors.clear();
    _rotationXMap.clear();
    _rotationYMap.clear();
    _rotationZMap.clear();
    _overrideColors.clear(); // important: reset overrides to reflect new state

    // 1) outlines (convert string keys to int)
    state.outlineColors.forEach((key, color) {
      final id = int.tryParse(key);
      if (id != null) _elementOutlineColors[id] = color;
    });

    state.outlineWidths.forEach((key, width) {
      final id = int.tryParse(key);
      if (id != null) _elementOutlineWidths[id] = width;
    });

    state.elementColors.forEach((key, color) {
      final id = int.tryParse(key);
      if (id != null) {
        _elementColors[id] = color;
        _overrideColors[id] = color;
      } else {
        final lower = key.toLowerCase();
        if (lower == 'shape' || lower == 'logo' || lower == 'mainshape') {
          _shapeColor = color;
        } else if (lower == 'company' || lower == 'companyname') {
          _companyTextColor = color;
        } else if (lower == 'slogan' || lower == 'sloganname') {
          _sloganColor = color;
        }
      }
    });

    // ✅ FIX: restore shapeColor from top-level state
    // _shapeColor = state.shapeColor;

    // 2) logo color and override flag
    _logoColor = state.logoColor;
    _isLogoColorOverridden = state.isLogoColorOverridden;

    // 3) company/slogan top-level fields (explicit)
    _companyTextColor = state.companyNameColor;
    _sloganColor = state.sloganColor;

    // 4) custom texts -> map to ids 100 + index (and mark override)
    for (int i = 0; i < state.customTexts.length; i++) {
      final id = 100 + i;
      final c = state.customTexts[i].color;
      _overrideColors[id] = c;
      _elementColors[id] = c;
    }

    // 5) custom SVGs -> map to ids 300 + index (and mark override)
    for (int i = 0; i < state.customSVGs.length; i++) {
      final id = 300 + i;
      final c = state.customSVGs[i].color ?? Colors.black;
      _overrideColors[id] = c;
      _elementColors[id] = c;
    }

    // 6) any elementColors already parsed into _elementColors used above

    // 7) rotations
    _rotationXMap.addAll(state.rotationXMap);
    _rotationYMap.addAll(state.rotationYMap);
    _rotationZMap.addAll(state.rotationZMap);

    // 8) restore background state
    // Reset all background states first
    _selectedColor = state.backgroundColor;
    _selectedGradient = state.backgroundGradient;
    
    // Handle image restoration
    if (state.backgroundImagePath != null && state.backgroundImagePath!.isNotEmpty) {
      _imageFile = File(state.backgroundImagePath!);
      _isColorManuallySelected = true;
      // Load image asynchronously but don't wait
      _loadImageFromPath(state.backgroundImagePath!);
    } else {
      _backgroundImage = null;
      canvasImage = null;
      _imageFile = null;
      if (state.backgroundColor != null || state.backgroundGradient != null) {
        _isColorManuallySelected = true;
      } else {
        _isColorManuallySelected = false;
      }
    }

    notifyListeners();
  }

  Future<void> _loadImageFromPath(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        _backgroundImage = frame.image;
        canvasImage = frame.image;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading image from path: $e');
    }
  }
}
