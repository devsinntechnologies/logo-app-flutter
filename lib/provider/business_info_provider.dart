import 'package:flutter/material.dart';

class BusinessInfoProvider extends ChangeNotifier {
  String _businessName = '';
  String _slogan = '';
  String _categoryName = '';

  String get businessName => _businessName;
  String get slogan => _slogan;
  String get categoryName => _categoryName;

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

  void updateCategory(String category) {
    _categoryName = category;
    notifyListeners();
  }

  void reset() {
    _businessName = '';
    _slogan = '';
    _categoryName = '';
    notifyListeners();
  }
}
