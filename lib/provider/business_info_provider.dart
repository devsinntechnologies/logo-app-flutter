import 'package:flutter/material.dart';

class BusinessInfoProvider extends ChangeNotifier {
  String _businessName = '';
  String _slogan = '';
  String _categoryName = '';
  int? _categoryId;
  String _selectedFontId = "1"; // Default
  String _selectedColorId = "1"; // Default

  String get businessName => _businessName;
  String get slogan => _slogan;
  String get categoryName => _categoryName;
  int? get categoryId => _categoryId;
  String get selectedFontId => _selectedFontId;
  String get selectedColorId => _selectedColorId;

  // Logic: Show container ONLY if Business Name is NOT empty (Slogan is optional)
  bool get showPreview => _businessName.trim().isNotEmpty;
  bool get canContinue => _businessName.trim().isNotEmpty;

  void updateBusinessName(String name) {
    _businessName = name;
    notifyListeners();
  }

  void updateSlogan(String slogan) {
    _slogan = slogan;
    notifyListeners();
  }

  void updateCategory(String category, {int? id}) {
    _categoryName = category;
    if (id != null) _categoryId = id;
    notifyListeners();
  }

  void updateDesign(String fontId, String colorId) {
    _selectedFontId = fontId;
    _selectedColorId = colorId;
    notifyListeners();
  }

  void reset() {
    _businessName = '';
    _slogan = '';
    _categoryName = '';
    _categoryId = null;
    _selectedFontId = "1";
    _selectedColorId = "1";
    notifyListeners();
  }
}
