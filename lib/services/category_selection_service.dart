import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logo_app_flutter/models/industry_model.dart';

class CategorySelectionService {
static Future<IndustryModel> getIndustries() async {
  final response = await http.get(
    Uri.parse('https://www.smart-logomaker.com/api/industries'),
  );

  if (response.statusCode == 200) {
    return IndustryModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load industries');
  }
}
}

