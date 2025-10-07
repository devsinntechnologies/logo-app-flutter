import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart';

class FontStyleState {
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;

  FontStyleState({
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
  });

  FontStyleState copyWith({bool? isBold, bool? isItalic, bool? isUnderline}) {
    return FontStyleState(
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
    );
  }

  Map<String, dynamic> toJson() {
    return {'isBold': isBold, 'isItalic': isItalic, 'isUnderline': isUnderline};
  }

  factory FontStyleState.fromJson(Map<String, dynamic> json) {
    return FontStyleState(
      isBold: json['isBold'] ?? false,
      isItalic: json['isItalic'] ?? false,
      isUnderline: json['isUnderline'] ?? false,
    );
  }
}

class SelectedColorProvider extends ChangeNotifier {
  UndoProvider? _undoProvider;

  bool _isUndoRedoInProgress = false;

  dynamic _backgroundTexture;

  Color? _backgroundColor;

  Gradient? _companyTextGradient;
  Gradient? _sloganGradient;

  String? _selectedShape;
  String? _selectedShapeName;
  bool get isUndoRedoInProgress => _isUndoRedoInProgress;

  final Map<int, double> _elementTextSizes = {};
  double _companyTextSize = 28.0;
  double _sloganTextSize = 16.0;

  Color _selectedColor = Colors.white;
  Gradient? _selectedGradient;
  ui.Image? _backgroundImage;
  double get intensity => _brightness;
  final Map<int, Color> _overrideColors = {};
  final Map<int, Color> _individualElementColors = {};
  final Map<int, String> _elementFonts = {};
  final Map<int, double> _elementShadowOffsets = {};
  final Map<int, Color> _elementShadowColors = {};
  final Map<int, Color> _elementColors = {};
  final Map<int, Color> _elementOutlineColors = {};
  final Map<int, double> _elementOutlineWidths = {};
  final Map<int, double> _elementShadowOffsetsX = {};
  final Map<int, double> _elementShadowOffsetsY = {};
  final Map<int, FontStyleState> _fontStyles = {};
  final Map<int, FontStyleState> _elementFontStyles = {};

  int _selectedIndex = 0;
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

  final Map<int, double> _elementRotationX = {};
  final Map<int, double> _elementRotationY = {};
  final Map<int, double> _elementRotationZ = {};

  String? getFontForElement(int id) => _elementFonts[id];

  LogoStateData? _currentLogoState;

  LogoStateData? getCurrentLogoState() => _currentLogoState;

  double _backgroundOpacity = 1.0;

  double get backgroundOpacity => _backgroundOpacity;

  void setBackgroundOpacity(double value) {
    _backgroundOpacity = value;
    notifyListeners();
  }

  void setBackgroundOpacityWithUndo(double value) {
    _saveUndoState('Change background opacity to ${(value * 100).round()}%');
    _backgroundOpacity = value;
    notifyListeners();
  }

  void updateLogoState(LogoStateData state) {
    _currentLogoState = state;
    notifyListeners();
  }

  void _applyOrder(List<int> order) {
    if (_currentLogoState == null) return;
    _currentLogoState = _currentLogoState!.copyWith(elementOrder: order);
    notifyListeners();
  }

  void moveElementUp(int id) {
    if (_currentLogoState == null) return;
    final order = List<int>.from(_currentLogoState!.elementOrder);
    final i = order.indexOf(id);
    if (i == -1 || i == order.length - 1) return;
    order.removeAt(i);
    order.insert(i + 1, id);
    _applyOrder(order);
  }

  void moveElementDown(int id) {
    if (_currentLogoState == null) return;
    final order = List<int>.from(_currentLogoState!.elementOrder);
    final i = order.indexOf(id);
    if (i <= 0) return;
    order.removeAt(i);
    order.insert(i - 1, id);
    _applyOrder(order);
  }

  void bringToFront(int id) {
    if (_currentLogoState == null) return;
    final order = List<int>.from(_currentLogoState!.elementOrder);
    if (!order.remove(id)) return;
    order.add(id);
    _applyOrder(order);
  }

  void sendToBack(int id) {
    if (_currentLogoState == null) return;
    final order = List<int>.from(_currentLogoState!.elementOrder);
    if (!order.remove(id)) return;
    order.insert(0, id);
    _applyOrder(order);
  }

  void debugPrintOrder([String tag = '']) {
    if (_currentLogoState == null) return;
    print('$tag elementOrder: ${_currentLogoState!.elementOrder}');
  }

  void setFontForElement(int id, String family) {
    _elementFonts[id] = family;
    notifyListeners();
  }

  void cloneElementStyles(int fromId, int toId) {
    if (_elementColors.containsKey(fromId)) {
      _elementColors[toId] = _elementColors[fromId]!;
    }
    if (_overrideColors.containsKey(fromId)) {
      _overrideColors[toId] = _overrideColors[fromId]!;
    }

    if (_elementSizes.containsKey(fromId)) {
      _elementSizes[toId] = _elementSizes[fromId]!;
    }

    if (_elementRotations.containsKey(fromId)) {
      _elementRotations[toId] = _elementRotations[fromId]!;
    }

    if (_elementRotationX.containsKey(fromId)) {
      _elementRotationX[toId] = _elementRotationX[fromId]!;
    }
    if (_elementRotationY.containsKey(fromId)) {
      _elementRotationY[toId] = _elementRotationY[fromId]!;
    }
    if (_elementRotationZ.containsKey(fromId)) {
      _elementRotationZ[toId] = _elementRotationZ[fromId]!;
    }

    if (_elementFonts.containsKey(fromId)) {
      _elementFonts[toId] = _elementFonts[fromId]!;
    }
    if (_fontStyles.containsKey(fromId)) {
      _fontStyles[toId] = _fontStyles[fromId]!;
    }
    if (_elementFontStyles.containsKey(fromId)) {
      _elementFontStyles[toId] = _elementFontStyles[fromId]!;
    }

    if (_elementOutlineColors.containsKey(fromId)) {
      _elementOutlineColors[toId] = _elementOutlineColors[fromId]!;
    }
    if (_elementOutlineWidths.containsKey(fromId)) {
      _elementOutlineWidths[toId] = _elementOutlineWidths[fromId]!;
    }

    if (_elementShadowColors.containsKey(fromId)) {
      _elementShadowColors[toId] = _elementShadowColors[fromId]!;
    }
    if (_elementShadowOffsetsX.containsKey(fromId)) {
      _elementShadowOffsetsX[toId] = _elementShadowOffsetsX[fromId]!;
    }
    if (_elementShadowOffsetsY.containsKey(fromId)) {
      _elementShadowOffsetsY[toId] = _elementShadowOffsetsY[fromId]!;
    }

    _cloneGradient(fromId, toId);

    notifyListeners();
  }

  void _cloneGradient(int fromId, int toId) {
    final g = getGradientForElement(fromId);
    if (g == null) return;
    if (toId == 1) {
      _companyTextGradient = g;
    } else if (toId == 2) {
      _sloganGradient = g;
    } else {
      _elementGradients[toId] = g;
    }
  }

  void seedInitialFonts({String? company, String? slogan}) {
    bool changed = false;
    if (company != null &&
        (_elementFonts[1] == null || _elementFonts[1]!.isEmpty)) {
      _elementFonts[1] = company;
      changed = true;
    }
    if (slogan != null &&
        (_elementFonts[2] == null || _elementFonts[2]!.isEmpty)) {
      _elementFonts[2] = slogan;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  double? getRotationXForElement(int id) => _elementRotationX[id] ?? 0.0;
  void setRotationXForElement(int id, double value) {
    _saveUndoState('Set X rotation for element $id to ${value.toInt()}°');
    _elementRotationX[id] = value;
    notifyListeners();
  }

  Future<void> restoreFromStateAsync(Map<String, dynamic> state) async {
    _isUndoRedoInProgress = true;
    print('Restoring state asynchronously for text operations...');

    try {
      restoreFromState(state);

      await Future.delayed(const Duration(milliseconds: 10));
    } catch (e) {
      print('Error in async restore: $e');
    } finally {
      _isUndoRedoInProgress = false;
      notifyListeners();
    }
  }

  double? getRotationYForElement(int id) => _elementRotationY[id] ?? 0.0;
  void setRotationYForElement(int id, double value) {
    _saveUndoState('Set Y rotation for element $id to ${value.toInt()}°');
    _elementRotationY[id] = value;
    notifyListeners();
  }

  double? getRotationZForElement(int id) => _elementRotationZ[id] ?? 0.0;
  void setRotationZForElement(int id, double value) {
    _saveUndoState('Set Z rotation for element $id to ${value.toInt()}°');
    _elementRotationZ[id] = value;
    notifyListeners();
  }

  Timer? _notifyTimer;
  void _throttledNotify() {
    _notifyTimer?.cancel();
    _notifyTimer = Timer(const Duration(milliseconds: 100), () {
      notifyListeners();
    });
  }

  void setSvgColorOverridden(bool value) {
    _isSvgColorOverridden = value;
    _throttledNotify();
  }

  dynamic _logoStateRef;

  void setLogoStateReference(dynamic logoState) {
    _logoStateRef = logoState;
  }

  set selectedElementId(int? id) {
    _selectedElementId = id;

    if (id != null && !_elementSizes.containsKey(id)) {
      double defaultSize = _getDefaultSizeForElement(id);
      _elementSizes[id] = defaultSize;
    }

    notifyListeners();
  }

  double _getDefaultSizeForElement(int elementId) {
    switch (elementId) {
      case 0:
        return _logoStateRef?.logoSize ?? 100.0;
      case 1:
        return _logoStateRef?.companyNameSize ?? 26.0;
      case 2:
        return _logoStateRef?.sloganSize ?? 18.0;
      default:
        if (elementId >= 100 && elementId < 200) {
          final index = elementId - 100;
          if (_logoStateRef?.customTexts != null &&
              index < _logoStateRef.customTexts.length) {
            return _logoStateRef.customTexts[index].size ?? 26.0;
          }
          return 26.0;
        } else if (elementId >= 200 && elementId < 300) {
          final index = elementId - 200;
          if (_logoStateRef?.customImages != null &&
              index < _logoStateRef.customImages.length) {
            return _logoStateRef.customImages[index].size ?? 100.0;
          }
          return 100.0;
        } else if (elementId >= 300 && elementId < 400) {
          final index = elementId - 300;
          if (_logoStateRef?.customSVGs != null &&
              index < _logoStateRef.customSVGs.length) {
            return _logoStateRef.customSVGs[index].size ?? 100.0;
          }
          return 100.0;
        }
        return 100.0;
    }
  }

  double getSizeForElementWithInit(int elementId) {
    if (!_elementSizes.containsKey(elementId)) {
      double defaultSize = _getDefaultSizeForElement(elementId);
      _elementSizes[elementId] = defaultSize;
    }
    return _elementSizes[elementId]!;
  }

  Map<int, Gradient> _elementGradients = {};

  void setGradientForElement(int elementId, Gradient gradient) {
    _saveUndoState('Apply gradient to element $elementId');
    _elementGradients[elementId] = gradient;

    if (elementId == 1) {
      _companyTextGradient = gradient;
    } else if (elementId == 2) {
      _sloganGradient = gradient;
    } else if (elementId >= 100) {
      _elementGradients[elementId] = gradient;
    }

    print('✅ Gradient applied to element $elementId');
    notifyListeners();
  }

  Gradient? getGradientForElement(int elementId) {
    if (elementId == 1 && _companyTextGradient != null) {
      return _companyTextGradient;
    }
    if (elementId == 2 && _sloganGradient != null) {
      return _sloganGradient;
    }

    return _elementGradients[elementId];
  }

  void resetElementGradients() {
    _elementGradients.clear();
    _companyTextGradient = null;
    _sloganGradient = null;
    _selectedGradient = null;
    print('✅ All gradients reset');
    notifyListeners();
  }

  void discardChanges() {
    _elementColors.clear();
    _elementFonts.clear();
    _elementSizes.clear();
    _elementRotations.clear();
    _elementFontStyles.clear();
    resetElementGradients();
    _selectedElementId = null;
    _companyTextColor = Colors.black;
    _sloganColor = Colors.black;
    _selectedColor = Colors.blue;
    notifyListeners();
  }

  bool hasGradientForElement(int elementId) {
    if (elementId == 1 && _companyTextGradient != null) return true;
    if (elementId == 2 && _sloganGradient != null) return true;
    return _elementGradients.containsKey(elementId) &&
        _elementGradients[elementId] != null;
  }

  void clearGradientForElement(int elementId) {
    _elementGradients.remove(elementId);
    notifyListeners();
  }

  double mapActualToUI(double actualSize, int elementId) {
    double actualMin, actualMax;

    if (elementId == 0) {
      actualMin = 50.0;
      actualMax = 300.0;
    } else if (elementId == 1 ||
        elementId == 2 ||
        (elementId >= 100 && elementId < 200)) {
      actualMin = 8.0;
      actualMax = 72.0;
    } else if (elementId >= 200 && elementId < 300) {
      actualMin = 20.0;
      actualMax = 200.0;
    } else if (elementId >= 300 && elementId < 400) {
      actualMin = 20.0;
      actualMax = 200.0;
    } else {
      actualMin = 10.0;
      actualMax = 200.0;
    }

    const double uiMin = 1.0;
    const double uiMax = 100.0;

    actualSize = actualSize.clamp(actualMin, actualMax);

    double normalizedValue = (actualSize - actualMin) / (actualMax - actualMin);
    return uiMin + (normalizedValue * (uiMax - uiMin));
  }

  double mapUIToActual(double uiValue, int elementId) {
    double actualMin, actualMax;

    if (elementId == 0) {
      actualMin = 50.0;
      actualMax = 300.0;
    } else if (elementId == 1 ||
        elementId == 2 ||
        (elementId >= 100 && elementId < 200)) {
      actualMin = 8.0;
      actualMax = 72.0;
    } else if (elementId >= 200 && elementId < 300) {
      actualMin = 20.0;
      actualMax = 200.0;
    } else if (elementId >= 300 && elementId < 400) {
      actualMin = 20.0;
      actualMax = 200.0;
    } else {
      actualMin = 10.0;
      actualMax = 200.0;
    }

    const double uiMin = 1.0;
    const double uiMax = 100.0;

    uiValue = uiValue.clamp(uiMin, uiMax);

    double normalizedValue = (uiValue - uiMin) / (uiMax - uiMin);
    return actualMin + (normalizedValue * (actualMax - actualMin));
  }

  double getRotationForElement(int? id) {
    if (id == null) return 0.0;

    if (_elementRotations.containsKey(id)) {
      return _elementRotations[id]!;
    }

    if (_currentLogoState != null) {
      if (id >= 100 && id < 200) {
        final index = id - 100;
        if (index >= 0 && index < _currentLogoState!.customTexts.length) {
          return _currentLogoState!.customTexts[index].rotation;
        }
      } else if (id >= 200 && id < 300) {
        final index = id - 200;
        if (index >= 0 && index < _currentLogoState!.customImages.length) {
          return _currentLogoState!.customImages[index].rotation;
        }
      } else if (id >= 300 && id < 400) {
        final index = id - 300;
        if (index >= 0 && index < _currentLogoState!.customSVGs.length) {
          return _currentLogoState!.customSVGs[index].rotation;
        }
      } else {
        switch (id) {
          case 0:
            return _currentLogoState!.logoRotation;
          case 1:
            return _currentLogoState!.companyNameRotation;
          case 2:
            return _currentLogoState!.sloganRotation;
          case 3:
            return _currentLogoState!.logo2Rotation ?? 0;
          case 4:
            return _currentLogoState!.companyName2Rotation ?? 0;
          case 5:
            return _currentLogoState!.slogan2Rotation ?? 0;
        }
      }
    }

    return 0.0;
  }

  void setRotationForElement(int id, double rotation) {
    if (_currentLogoState == null) return;

    if (id >= 100 && id < 200) {
      final index = id - 100;
      if (index >= 0 && index < _currentLogoState!.customTexts.length) {
        final updatedTexts = List<CustomTextElement>.from(
          _currentLogoState!.customTexts,
        );
        updatedTexts[index] = updatedTexts[index].copyWith(rotation: rotation);
        _currentLogoState = _currentLogoState!.copyWith(
          customTexts: updatedTexts,
        );
      }
    } else if (id >= 200 && id < 300) {
      final index = id - 200;
      if (index >= 0 && index < _currentLogoState!.customImages.length) {
        final updatedImages = List<CustomImageElement>.from(
          _currentLogoState!.customImages,
        );
        updatedImages[index] = updatedImages[index].copyWith(
          rotation: rotation,
        );
        _currentLogoState = _currentLogoState!.copyWith(
          customImages: updatedImages,
        );
      }
    } else if (id >= 300 && id < 400) {
      final index = id - 300;
      if (index >= 0 && index < _currentLogoState!.customSVGs.length) {
        final updatedSVGs = List<CustomSvgElement>.from(
          _currentLogoState!.customSVGs,
        );
        updatedSVGs[index] = updatedSVGs[index].copyWith(rotation: rotation);
        _currentLogoState = _currentLogoState!.copyWith(
          customSVGs: updatedSVGs,
        );
      }
    } else {
      switch (id) {
        case 0:
          _currentLogoState = _currentLogoState!.copyWith(
            logoRotation: rotation,
          );
          break;
        case 1:
          _currentLogoState = _currentLogoState!.copyWith(
            companyNameRotation: rotation,
          );
          break;
        case 2:
          _currentLogoState = _currentLogoState!.copyWith(
            sloganRotation: rotation,
          );
          break;
        case 3:
          _currentLogoState = _currentLogoState!.copyWith(
            logo2Rotation: rotation,
          );
          break;
        case 4:
          _currentLogoState = _currentLogoState!.copyWith(
            companyName2Rotation: rotation,
          );
          break;
        case 5:
          _currentLogoState = _currentLogoState!.copyWith(
            slogan2Rotation: rotation,
          );
          break;
      }
    }

    notifyListeners();
  }

  void setColor(Color color) {
    _saveUndoState('Change background color');
    _selectedColor = color;
    _baseColor = color;
    _selectedGradient = null;
    _backgroundImage = null;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void setGradient(Gradient gradient) {
    _saveUndoState('Remove background gradient');
    _selectedGradient = gradient;
    _backgroundImage = null;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  void removeGradient() {
    _saveUndoState('Remove background gradient');
    _selectedGradient = null;
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
    notifyListeners();
  }

  void setBackgroundImage(ui.Image? image, File? file) {
    _saveUndoState(
      image != null ? 'Set background image' : 'Remove background image',
    );
    _backgroundImage = image;
    _selectedGradient = null;
    _imageFile = file;
    _isColorManuallySelected = true;
    //! Updated
    if (file != null && file.existsSync()) {
      file.delete();
    }
    //!
    notifyListeners();
  }

  void setElementTextureFromAsset(int elementId, String assetPath) {
    _elementTextures[elementId] = assetPath;
    notifyListeners();
  }

  void resetElementColor(int elementId) {
    _elementColors.remove(elementId);
    _elementTextures.remove(elementId);
    _elementGradients.remove(elementId);
    notifyListeners();
  }

  Map<int, String> _elementTextures = {};

  String? getElementTexture(int elementId) {
    return _elementTextures[elementId];
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
    _backgroundColor = Colors.white;
    notifyListeners();
  }

  // void resetGradient() {
  //   _backgroundGradient = null;
  //   notifyListeners();
  // }

  void resetTexture() {
    _backgroundTexture = null;
    notifyListeners();
  }

  void resetBackgroundImage() {
    _backgroundImage = null;
  }

  List<Color>? _palette;

  void resetPalette() {
    _palette = null;
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
  double _opacity = 1.0; // Default opacity (100%)

  double get opacity => _opacity;

  void setOpacity(double value) {
    _opacity = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setOpacityWithUndo(double opacity) {
    _saveUndoState('Change opacity to ${(opacity * 100).round()}%');
    _opacity = opacity;
    notifyListeners();
  }

  void setAllColors(Color company, Color slogan, Color shape) {
    _companyTextColor = company;
    _sloganColor = slogan;
    _shapeColor = shape;
    _isColorManuallySelected = true;
    notifyListeners();
  }

  final Map<int, double> _elementSizes = {};
  double? getSizeForElement(int? id) => id == null ? null : _elementSizes[id];
  void setSizeForElementWithUndo(int id, double size) {
    _saveUndoState('Resize element $id');
    _elementSizes[id] = size;
    notifyListeners();
  }

  Map<int, double> _elementRotations = {};
  // double? getRotationForElement(int? id) =>
  //     id == null ? null : _elementRotations[id];

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

  // ========== Outline Setters ==========
  void setOutlineColorWithUndo(int elementId, Color color) {
    _saveUndoState('Change outline color of element $elementId');
    _elementOutlineColors[elementId] = color;
    _throttledNotify();
  }

  void setOutlineWidthWithUndo(int elementId, double width) {
    _saveUndoState('Change outline width of element $elementId');
    _elementOutlineWidths[elementId] = width;
    _throttledNotify();
  }

  double getShadowOffsetYForElement(int id, {double fallback = 0.0}) {
    return _elementShadowOffsetsY[id] ?? fallback;
  }

  double getShadowOffsetXForElement(int id, {double fallback = 0.0}) {
    return _elementShadowOffsetsX[id] ?? fallback;
  }

  Color getShadowColorForElement(int id, {Color fallback = Colors.black}) {
    return _elementShadowColors[id] ?? fallback;
  }

  // ========== Outline Getters ==========
  Color getOutlineColor(int elementId) {
    return _elementOutlineColors[elementId] ?? Colors.transparent;
  }

  double getOutlineWidth(int elementId) {
    return _elementOutlineWidths[elementId] ?? 0.0;
  }

  void clearSelection() {
    _selectedElementId = null;
    notifyListeners();
  }

  void setSelectedElement(int id) {
    _selectedElementId = id;
    _throttledNotify();
  }

  void setInitialFonts({String? companyFontFamily, String? sloganFontFamily}) {
    if (companyFontFamily != null && companyFontFamily.isNotEmpty) {
      _elementFonts[1] = companyFontFamily;
    }
    if (sloganFontFamily != null && sloganFontFamily.isNotEmpty) {
      _elementFonts[2] = sloganFontFamily;
    }
    notifyListeners();
  }

  void setInitialColorsFromPalette(
    List<Color> paletteColors,
    List<int> allElementIds,
  ) {
    _rotateIndex = 0;

    _companyTextColor = paletteColors[1 % paletteColors.length];
    _sloganColor = paletteColors[2 % paletteColors.length];
    _shapeColor = paletteColors[0 % paletteColors.length];

    int index = 0;
    for (var elementId in allElementIds) {
      if (elementId >= 200 && elementId < 300) continue;
      _overrideColors[elementId] = paletteColors[index % paletteColors.length];
      index++;
    }

    _isColorManuallySelected = true;
    notifyListeners();
  }

  void setColorsRotated(List<Color> paletteColors, {List<int>? allElementIds}) {
    _companyTextColor =
        paletteColors[(_rotateIndex + 1) % paletteColors.length];
    _sloganColor = paletteColors[(_rotateIndex + 2) % paletteColors.length];
    _shapeColor = paletteColors[_rotateIndex % paletteColors.length];

    if (allElementIds != null) {
      int index = 0;
      for (var elementId in allElementIds) {
        if (elementId >= 200 && elementId < 300) continue;
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

  void setUndoProvider(UndoProvider undoProvider) {
    _undoProvider = undoProvider;
  }

  Map<String, dynamic> captureCurrentState() {
    return {
      'logoState': _currentLogoState?.toJson() ?? {},
      'selectedColor': _selectedColor.value,
      'backgroundColor': _backgroundColor?.value,
      'selectedGradient': _selectedGradient?.toString(),
      'backgroundImage': _backgroundImage?.toString(),
      'backgroundOpacity': _backgroundOpacity,
      'elementColors': _elementColors.map(
        (k, v) => MapEntry(k.toString(), v.value),
      ),
      'overrideColors': _overrideColors.map(
        (k, v) => MapEntry(k.toString(), v.value),
      ),
      'individualElementColors': _individualElementColors.map(
        (k, v) => MapEntry(k.toString(), v.value),
      ),
      'opacity': _opacity,
      'selectedElementId': _selectedElementId,
      'selectedShapeName': _selectedShapeName,
      'elementRotationX': _elementRotationX.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'elementRotationY': _elementRotationY.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'elementRotationZ': _elementRotationZ.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'elementSizes': _elementSizes.map((k, v) => MapEntry(k.toString(), v)),
      'elementRotations': _elementRotations.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'elementFonts': Map<String, String>.from(
        _elementFonts.map((k, v) => MapEntry(k.toString(), v)),
      ),
      'fontStyles': _fontStyles.map(
        (k, v) => MapEntry(k.toString(), v.toJson()),
      ),
      'elementFontStyles': _elementFontStyles.map(
        (k, v) => MapEntry(k.toString(), v.toJson()),
      ),
      'elementOutlineColors': _elementOutlineColors.map(
        (k, v) => MapEntry(k.toString(), v.value),
      ),
      'elementOutlineWidths': _elementOutlineWidths.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'elementShadowColors': _elementShadowColors.map(
        (k, v) => MapEntry(k.toString(), v.value),
      ),
      'elementShadowOffsetsX': _elementShadowOffsetsX.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'elementShadowOffsetsY': _elementShadowOffsetsY.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'elementTextures': Map<String, String>.from(
        _elementTextures.map((k, v) => MapEntry(k.toString(), v)),
      ),
      'elementGradients': _elementGradients.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      ),
      'companyTextGradient': _companyTextGradient?.toString(),
      'sloganGradient': _sloganGradient?.toString(),
      'elementTextSizes': _elementTextSizes.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'companyTextSize': _companyTextSize,
      'sloganTextSize': _sloganTextSize,
      'companyTextColor': _companyTextColor.value,
      'sloganColor': _sloganColor.value,
      'shapeColor': _shapeColor.value,
      'rotateIndex': _rotateIndex,
      'isColorManuallySelected': _isColorManuallySelected,
      'isSvgColorOverridden': _isSvgColorOverridden,
      'baseColor': _baseColor.value,
      'brightness': _brightness,
      'logoPosition':
          _currentLogoState?.logoPosition != null
              ? {
                'dx': _currentLogoState!.logoPosition.dx,
                'dy': _currentLogoState!.logoPosition.dy,
              }
              : null,
      'companyNamePosition':
          _currentLogoState?.companyNamePosition != null
              ? {
                'dx': _currentLogoState!.companyNamePosition.dx,
                'dy': _currentLogoState!.companyNamePosition.dy,
              }
              : null,
      'sloganPosition':
          _currentLogoState?.sloganPosition != null
              ? {
                'dx': _currentLogoState!.sloganPosition.dx,
                'dy': _currentLogoState!.sloganPosition.dy,
              }
              : null,
      'elementGradients': _elementGradients.map(
        (k, v) => MapEntry(k.toString(), _gradientToMap(v)),
      ),
      'companyTextGradient':
          _companyTextGradient != null
              ? _gradientToMap(_companyTextGradient!)
              : null,
      'sloganGradient':
          _sloganGradient != null ? _gradientToMap(_sloganGradient!) : null,

      'customImagesCount': _currentLogoState?.customImages.length ?? 0,
      'customSVGsCount': _currentLogoState?.customSVGs.length ?? 0,
      'customTextsCount': _currentLogoState?.customTexts.length ?? 0,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> _gradientToMap(Gradient gradient) {
    if (gradient is LinearGradient) {
      return {
        'type': 'linear',
        'colors': gradient.colors.map((c) => c.value).toList(),
        'begin':
            '${(gradient.begin as Alignment).x},${(gradient.begin as Alignment).y}',
        'end':
            '${(gradient.end as Alignment).x},${(gradient.end as Alignment).y}',
      };
    } else if (gradient is RadialGradient) {
      return {
        'type': 'radial',
        'colors': gradient.colors.map((c) => c.value).toList(),
        'stops': gradient.stops?.toList() ?? [],
      };
    } else if (gradient is SweepGradient) {
      return {
        'type': 'sweep',
        'colors': gradient.colors.map((c) => c.value).toList(),
      };
    }
    return {'type': 'unknown'};
  }

  void restoreFromState(Map<String, dynamic> state) {
    _isUndoRedoInProgress = true;
    print('Restoring state...');

    try {
      Offset? currentLogoPosition = _currentLogoState?.logoPosition;
      Offset? currentCompanyPosition = _currentLogoState?.companyNamePosition;
      Offset? currentSloganPosition = _currentLogoState?.sloganPosition;

      if (state['logoState'] != null) {
        _currentLogoState = LogoStateData.fromJson(state['logoState']);
      }

      if (state['logoPosition'] != null && _currentLogoState != null) {
        final posData = state['logoPosition'] as Map<String, dynamic>;
        _currentLogoState = _currentLogoState!.copyWith(
          logoPosition: Offset(posData['dx'], posData['dy']),
        );
      } else if (currentLogoPosition != null && _currentLogoState != null) {
        _currentLogoState = _currentLogoState!.copyWith(
          logoPosition: currentLogoPosition,
        );
      }

      if (state['companyNamePosition'] != null && _currentLogoState != null) {
        final posData = state['companyNamePosition'] as Map<String, dynamic>;
        _currentLogoState = _currentLogoState!.copyWith(
          companyNamePosition: Offset(posData['dx'], posData['dy']),
        );
      } else if (currentCompanyPosition != null && _currentLogoState != null) {
        _currentLogoState = _currentLogoState!.copyWith(
          companyNamePosition: currentCompanyPosition,
        );
      }

      if (state['sloganPosition'] != null && _currentLogoState != null) {
        final posData = state['sloganPosition'] as Map<String, dynamic>;
        _currentLogoState = _currentLogoState!.copyWith(
          sloganPosition: Offset(posData['dx'], posData['dy']),
        );
      } else if (currentSloganPosition != null && _currentLogoState != null) {
        _currentLogoState = _currentLogoState!.copyWith(
          sloganPosition: currentSloganPosition,
        );
      }

      if (state['opacity'] != null) {
        _opacity = (state['opacity'] as num).toDouble();
      }
      if (state['backgroundOpacity'] != null) {
        _backgroundOpacity = (state['backgroundOpacity'] as num).toDouble();
      }

      if (state['selectedShapeName'] != null) {
        _selectedShapeName = state['selectedShapeName'];
      }

      if (state['selectedElementId'] != null) {
        _selectedElementId = state['selectedElementId'];
      }

      if (state['selectedColor'] != null) {
        _selectedColor = Color(state['selectedColor']);
      }
      if (state['backgroundColor'] != null) {
        _backgroundColor = Color(state['backgroundColor']);
      }
      if (state['companyTextColor'] != null) {
        _companyTextColor = Color(state['companyTextColor']);
      }
      if (state['sloganColor'] != null) {
        _sloganColor = Color(state['sloganColor']);
      }
      if (state['shapeColor'] != null) {
        _shapeColor = Color(state['shapeColor']);
      }
      if (state['baseColor'] != null) {
        _baseColor = Color(state['baseColor']);
      }

      if (state['elementColors'] != null) {
        _elementColors.clear();
        (state['elementColors'] as Map<String, dynamic>).forEach((k, v) {
          _elementColors[int.parse(k)] = Color(v);
        });
      }

      if (state['elementGradients'] != null) {
        _elementGradients.clear();
        final gradientData = state['elementGradients'] as Map<String, dynamic>;
        gradientData.forEach((key, value) {
          final elementId = int.tryParse(key);
          if (elementId != null && value is Map<String, dynamic>) {
            final gradient = _mapToGradient(value);
            if (gradient != null) {
              _elementGradients[elementId] = gradient;
            }
          }
        });
      }

      if (state['companyTextGradient'] != null) {
        _companyTextGradient = _mapToGradient(state['companyTextGradient']);
      }

      if (state['sloganGradient'] != null) {
        _sloganGradient = _mapToGradient(state['sloganGradient']);
      }

      if (state['overrideColors'] != null) {
        _overrideColors.clear();
        (state['overrideColors'] as Map<String, dynamic>).forEach((k, v) {
          _overrideColors[int.parse(k)] = Color(v);
        });
      }

      if (state['individualElementColors'] != null) {
        _individualElementColors.clear();
        (state['individualElementColors'] as Map<String, dynamic>).forEach((
          k,
          v,
        ) {
          _individualElementColors[int.parse(k)] = Color(v);
        });
      }

      if (state['elementSizes'] != null) {
        _elementSizes.clear();
        (state['elementSizes'] as Map<String, dynamic>).forEach((k, v) {
          _elementSizes[int.parse(k)] = (v as num).toDouble();
        });
      }

      if (state['elementRotations'] != null) {
        _elementRotations.clear();
        (state['elementRotations'] as Map<String, dynamic>).forEach((k, v) {
          _elementRotations[int.parse(k)] = (v as num).toDouble();
        });
      }

      if (state['elementRotationX'] != null) {
        _elementRotationX.clear();
        (state['elementRotationX'] as Map<String, dynamic>).forEach((k, v) {
          _elementRotationX[int.parse(k)] = (v as num).toDouble();
        });
      }
      if (state['elementRotationY'] != null) {
        _elementRotationY.clear();
        (state['elementRotationY'] as Map<String, dynamic>).forEach((k, v) {
          _elementRotationY[int.parse(k)] = (v as num).toDouble();
        });
      }
      if (state['elementRotationZ'] != null) {
        _elementRotationZ.clear();
        (state['elementRotationZ'] as Map<String, dynamic>).forEach((k, v) {
          _elementRotationZ[int.parse(k)] = (v as num).toDouble();
        });
      }

      if (state['elementFonts'] != null) {
        _elementFonts.clear();
        (state['elementFonts'] as Map<String, dynamic>).forEach((k, v) {
          _elementFonts[int.parse(k)] = v as String;
        });
      }

      if (state['fontStyles'] != null) {
        _fontStyles.clear();
        (state['fontStyles'] as Map<String, dynamic>).forEach((k, v) {
          _fontStyles[int.parse(k)] = FontStyleState.fromJson(v);
        });
      }
      if (state['elementFontStyles'] != null) {
        _elementFontStyles.clear();
        (state['elementFontStyles'] as Map<String, dynamic>).forEach((k, v) {
          _elementFontStyles[int.parse(k)] = FontStyleState.fromJson(v);
        });
      }

      if (state['elementOutlineColors'] != null) {
        _elementOutlineColors.clear();
        (state['elementOutlineColors'] as Map<String, dynamic>).forEach((k, v) {
          _elementOutlineColors[int.parse(k)] = Color(v);
        });
      }
      if (state['elementOutlineWidths'] != null) {
        _elementOutlineWidths.clear();
        (state['elementOutlineWidths'] as Map<String, dynamic>).forEach((k, v) {
          _elementOutlineWidths[int.parse(k)] = (v as num).toDouble();
        });
      }

      if (state['elementShadowColors'] != null) {
        _elementShadowColors.clear();
        (state['elementShadowColors'] as Map<String, dynamic>).forEach((k, v) {
          _elementShadowColors[int.parse(k)] = Color(v);
        });
      }
      if (state['elementShadowOffsetsX'] != null) {
        _elementShadowOffsetsX.clear();
        (state['elementShadowOffsetsX'] as Map<String, dynamic>).forEach((
          k,
          v,
        ) {
          _elementShadowOffsetsX[int.parse(k)] = (v as num).toDouble();
        });
      }
      if (state['elementShadowOffsetsY'] != null) {
        _elementShadowOffsetsY.clear();
        (state['elementShadowOffsetsY'] as Map<String, dynamic>).forEach((
          k,
          v,
        ) {
          _elementShadowOffsetsY[int.parse(k)] = (v as num).toDouble();
        });
      }

      if (state['elementTextures'] != null) {
        _elementTextures.clear();
        (state['elementTextures'] as Map<String, dynamic>).forEach((k, v) {
          _elementTextures[int.parse(k)] = v as String;
        });
      }

      if (state['elementTextSizes'] != null) {
        _elementTextSizes.clear();
        (state['elementTextSizes'] as Map<String, dynamic>).forEach((k, v) {
          _elementTextSizes[int.parse(k)] = (v as num).toDouble();
        });
      }
      if (state['companyTextSize'] != null) {
        _companyTextSize = (state['companyTextSize'] as num).toDouble();
      }
      if (state['sloganTextSize'] != null) {
        _sloganTextSize = (state['sloganTextSize'] as num).toDouble();
      }

      if (state['rotateIndex'] != null) {
        _rotateIndex = state['rotateIndex'];
      }
      if (state['isColorManuallySelected'] != null) {
        _isColorManuallySelected = state['isColorManuallySelected'];
      }
      if (state['isSvgColorOverridden'] != null) {
        _isSvgColorOverridden = state['isSvgColorOverridden'];
      }
      if (state['brightness'] != null) {
        _brightness = (state['brightness'] as num).toDouble();
      }

      print('State restored successfully');
    } catch (e) {
      print('Error restoring state: $e');
    } finally {
      _isUndoRedoInProgress = false;
      notifyListeners();
    }
  }

  Gradient? _mapToGradient(Map<String, dynamic> map) {
    final type = map['type'] as String?;
    final colorValues = (map['colors'] as List?)?.cast<int>();

    if (colorValues == null) return null;

    final colors = colorValues.map((v) => Color(v)).toList();

    switch (type) {
      case 'linear':
        final beginStr = map['begin'] as String?;
        final endStr = map['end'] as String?;

        Alignment begin = Alignment.topLeft;
        Alignment end = Alignment.bottomRight;

        if (beginStr != null) {
          final parts = beginStr.split(',');
          if (parts.length == 2) {
            begin = Alignment(double.parse(parts[0]), double.parse(parts[1]));
          }
        }

        if (endStr != null) {
          final parts = endStr.split(',');
          if (parts.length == 2) {
            end = Alignment(double.parse(parts[0]), double.parse(parts[1]));
          }
        }

        return LinearGradient(colors: colors, begin: begin, end: end);

      case 'radial':
        final stops = (map['stops'] as List?)?.cast<double>();
        return RadialGradient(colors: colors, stops: stops);

      case 'sweep':
        return SweepGradient(colors: colors);

      default:
        return null;
    }
  }

  void setSizeForElement(int id, double size) {
    _saveUndoState('Resize element $id');
    _elementSizes[id] = size;
    notifyListeners();
  }

  void setColorForElement(int id, Color color) {
    _saveUndoState('Change color for element $id');
    _elementColors[id] = color;
    notifyListeners();
  }

  void setOutlineColor(int elementId, Color color) {
    _saveUndoState('Change outline color of element $elementId');
    _elementOutlineColors[elementId] = color;
    _throttledNotify();
  }

  void setOutlineWidth(int elementId, double width) {
    _saveUndoState('Change outline width of element $elementId');
    _elementOutlineWidths[elementId] = width;
    _throttledNotify();
  }

  void setShadowColorForElement(int id, Color color) {
    _saveUndoState('Change shadow color of element $id');
    _elementShadowColors[id] = color;
    _throttledNotify();
  }

  void setShadowOffsetXForElement(int id, double offsetX) {
    _saveUndoState('Change shadow X offset of element $id');
    _elementShadowOffsetsX[id] = offsetX;
    _throttledNotify();
  }

  void setShadowOffsetYForElement(int id, double offsetY) {
    _saveUndoState('Change shadow Y offset of element $id');
    _elementShadowOffsetsY[id] = offsetY;
    _throttledNotify();
  }

  void toggleBold(int id) {
    _saveUndoState('Toggle bold for element $id');
    _fontStyles[id] = getFontStyleForElement(
      id,
    ).copyWith(isBold: !getFontStyleForElement(id).isBold);
    notifyListeners();
  }

  void toggleItalic(int id) {
    _saveUndoState('Toggle italic for element $id');
    _fontStyles[id] = getFontStyleForElement(
      id,
    ).copyWith(isItalic: !getFontStyleForElement(id).isItalic);
    notifyListeners();
  }

  void toggleUnderline(int id) {
    _saveUndoState('Toggle underline for element $id');
    _fontStyles[id] = getFontStyleForElement(
      id,
    ).copyWith(isUnderline: !getFontStyleForElement(id).isUnderline);
    notifyListeners();
  }

  // Add this method to allow applying a palette of colors
  void applyPalette(List<Color> palette) {
    // Implement your logic to apply the palette to your elements.
    // For example, if you have a list of elements, assign each color from the palette.
    // This is a placeholder implementation:
    // _elements.asMap().forEach((i, element) {
    //   if (i < palette.length) {
    //     element.color = palette[i];
    //   }
    // });
    // notifyListeners();
  }

  void initializeUndoSystem() {
    if (_undoProvider != null) {
      _undoProvider!.saveState(
        action: 'Initial state',
        state: captureCurrentState(),
      );
    }
  }

  @override
  void dispose() {
    _notifyTimer?.cancel();
    super.dispose();
  }

  FontStyleState getFontStyleForElement(int id) {
    return _fontStyles[id] ?? FontStyleState();
  }

  void setFontStyleForElement(int id, FontStyleState style) {
    _fontStyles[id] = style;
    notifyListeners();
  }

  double? getCompanyTextSize() => _companyTextSize;
  void setCompanyTextSize(double size) {
    _saveUndoState('Change company text size');
    _companyTextSize = size;
    notifyListeners();
  }

  double? getSloganTextSize() => _sloganTextSize;
  void setSloganTextSize(double size) {
    _saveUndoState('Change slogan text size');
    _sloganTextSize = size;
    notifyListeners();
  }

  double? getTextSizeForElement(int id) {
    return _elementTextSizes[id];
  }

  void setTextSizeForElement(int id, double size) {
    _saveUndoState('Change text size for element $id');
    _elementTextSizes[id] = size;
    notifyListeners();
  }

  Color? getElementColor(int id) {
    return _overrideColors[id] ?? _elementColors[id];
  }

  List<int> getCurrentElementOrder() {
    if (_currentLogoState != null) {
      return _currentLogoState!.elementOrder;
    }
    return [0, 1, 2, 3, 4, 5];
  }

  // Add this missing method
  List<int> getAllElementIds() {
    if (_currentLogoState != null) {
      return _currentLogoState!.elementOrder;
    }
    return [0, 1, 2, 3, 4, 5];
  }

  List<Color> getCurrentPalette() {
    List<Color> palette = [];
    final elementOrder = getCurrentElementOrder();

    for (int id in elementOrder) {
      Color? elementColor = getElementColor(id);
      if (elementColor != null) {
        palette.add(elementColor);
      } else {
        switch (id) {
          case 0:
            palette.add(Colors.blue);
            break;
          case 1:
            palette.add(Colors.black);
            break;
          case 2:
            palette.add(Colors.grey);
            break;
          default:
            palette.add(Colors.red);
            break;
        }
      }
    }

    return palette.isNotEmpty
        ? palette
        : [Colors.blue, Colors.red, Colors.green];
  }

  void setElementColor(int elementId, Color color) {
    _elementColors[elementId] = color;
    notifyListeners();
  }

  void setBackgroundColor(Color? color) {
    _saveUndoState(
      color != null ? 'Change background color' : 'Clear background color',
    );
    _backgroundColor = color;
    if (color != null) {
      _selectedGradient = null;
    }
    notifyListeners();
  }

  Color? get backgroundColor => _backgroundColor;

  void setElementTexture(int i, param1) {}

  void _saveUndoState(String action) {
    if (_undoProvider != null) {
      _undoProvider!.saveState(action: action, state: captureCurrentState());
    }
  }

  void toggleLock(int elementId) {
    final state = _currentLogoState;
    if (state == null) return;

    _saveUndoState('Toggle lock for element $elementId');
    final newLockedSet = Set<int>.from(state.lockedElements);
    if (newLockedSet.contains(elementId)) {
      newLockedSet.remove(elementId);
    } else {
      newLockedSet.add(elementId);
    }
    _currentLogoState = state.copyWith(lockedElements: newLockedSet);
    notifyListeners();
  }

  // ✅ ADD THIS METHOD
  void toggleLockAll(bool shouldLock) {
    final state = _currentLogoState;
    if (state == null) return;

    _saveUndoState(shouldLock ? 'Lock all elements' : 'Unlock all elements');
    if (shouldLock) {
      _currentLogoState = state.copyWith(
        lockedElements: state.visibleElementIds.toSet(),
      );
    } else {
      _currentLogoState = state.copyWith(lockedElements: {});
    }
    notifyListeners();
  }

  // void moveElementUp(int elementId) {
  //   final state = _currentLogoState;
  //   if (state == null) return;

  //   final visible = state.visibleElementIds.toList();
  //   final vIdx = visible.indexOf(elementId);
  //   if (vIdx <= 0) return;

  //   final swapWith = visible[vIdx - 1];

  //   final order = List<int>.from(state.elementOrder);
  //   final i = order.indexOf(elementId);
  //   final j = order.indexOf(swapWith);
  //   if (i == -1 || j == -1) return;

  //   order.removeAt(i);
  //   final jAfter = i < j ? j - 1 : j;
  //   order.insert(jAfter, elementId);

  //   _currentLogoState = state.copyWith(elementOrder: order);
  //   notifyListeners();
  // }
  // void moveElementDown(int elementId) {
  //   final state = _currentLogoState;
  //   if (state == null) return;

  //   final visible = state.visibleElementIds.toList();
  //   final vIdx = visible.indexOf(elementId);
  //   if (vIdx == -1 || vIdx >= visible.length - 1) return;

  //   final swapWith = visible[vIdx + 1];

  //   final order = List<int>.from(state.elementOrder);
  //   final i = order.indexOf(elementId);
  //   final j = order.indexOf(swapWith);
  //   if (i == -1 || j == -1) return;

  //   order.removeAt(i);
  //   final jAfter = i < j ? j : j + 1;
  //   order.insert(jAfter, elementId);

  //   _currentLogoState = state.copyWith(elementOrder: order);
  //   notifyListeners();
  // }

  void updateLogoPosition(Offset newPosition) {
    if (_currentLogoState == null) return;
    _saveUndoState('Move logo');
    _currentLogoState = _currentLogoState!.copyWith(logoPosition: newPosition);
    notifyListeners();
  }

  void updateCompanyNamePosition(Offset newPosition) {
    if (_currentLogoState == null) return;
    _saveUndoState('Move company name');
    _currentLogoState = _currentLogoState!.copyWith(
      companyNamePosition: newPosition,
    );
    notifyListeners();
  }

  void updateSloganPosition(Offset newPosition) {
    if (_currentLogoState == null) return;
    _saveUndoState('Move slogan');
    _currentLogoState = _currentLogoState!.copyWith(
      sloganPosition: newPosition,
    );
    notifyListeners();
  }

  void resetAllEditorState() {
    _backgroundColor = Colors.white;
    _selectedColor = Colors.white;
    _selectedGradient = null;
    _backgroundImage = null;
    _backgroundTexture = null;
    _palette = null;
    _opacity = 1.0;
    _isColorManuallySelected = false;
    _companyTextColor = Colors.black;
    _sloganColor = Colors.black;
    _shapeColor = Colors.white;
    _rotateIndex = 0;
    _elementColors.clear();
    _overrideColors.clear();
    _elementFonts.clear();
    _elementShadowOffsets.clear();
    _elementShadowColors.clear();
    _elementOutlineColors.clear();
    _elementOutlineWidths.clear();
    _elementShadowOffsetsX.clear();
    _elementShadowOffsetsY.clear();
    _fontStyles.clear();
    _elementSizes.clear();
    _elementRotations.clear();
    _elementTextSizes.clear();
    _companyTextSize = 28.0;
    _sloganTextSize = 16.0;
    _selectedElementId = null;
    _isSvgColorOverridden = false;
    _elementRotationX.clear();
    _elementRotationY.clear();
    _elementRotationZ.clear();
    notifyListeners();
  }
}
