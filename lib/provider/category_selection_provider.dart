import 'package:flutter/material.dart';
import 'package:logo_app_flutter/models/industry_model.dart';
import 'package:logo_app_flutter/services/category_selection_service.dart';


class CategorySelectionProvider with ChangeNotifier {
  IndustryModel? _industryModel;
  bool _isLoading = false;
  String? _error;

  // Getters
  IndustryModel? get industryModel => _industryModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch Industries
  Future<void> fetchIndustries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await CategorySelectionService.getIndustries();
      _industryModel = data;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}