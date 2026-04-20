import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:logo_app_flutter/models/industry_model.dart';

class CategorySelectionService {
  static Future<IndustryModel> getIndustries() async {
    final response = await http.get(
        Uri.parse('https://www.smart-logomaker.com/api/industries'),
        headers: {
          'Content-Type': 'application/json',
          'x-app-id': 'com.devsinntechnologies.smartlogomaker'
        });

    if (response.statusCode == 200) {
      return IndustryModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load industries');
    }
  }
}
