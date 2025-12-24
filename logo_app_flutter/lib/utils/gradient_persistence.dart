import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GradientPersistence {
  static const _startColorKey = 'gradient_start_color';
  static const _endColorKey = 'gradient_end_color';
  static const _angleKey = 'gradient_angle';
  static const _isLinearKey = 'gradient_is_linear';

  /// SAVE
  static Future<void> saveGradient({
    required Color startColor,
    required Color endColor,
    required double angle,
    required bool isLinear,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_startColorKey, startColor.value);
    await prefs.setInt(_endColorKey, endColor.value);
    await prefs.setDouble(_angleKey, angle);
    await prefs.setBool(_isLinearKey, isLinear);
  }

  /// LOAD
  static Future<GradientData?> loadGradient() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_startColorKey)) return null;

    return GradientData(
      startColor: Color(prefs.getInt(_startColorKey)!),
      endColor: Color(prefs.getInt(_endColorKey)!),
      angle: prefs.getDouble(_angleKey) ?? 0,
      isLinear: prefs.getBool(_isLinearKey) ?? true,
    );
  }

  /// CLEAR
  static Future<void> clearGradient() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_startColorKey);
    await prefs.remove(_endColorKey);
    await prefs.remove(_angleKey);
    await prefs.remove(_isLinearKey);
  }
}

/// Simple model (clean & readable)
class GradientData {
  final Color startColor;
  final Color endColor;
  final double angle;
  final bool isLinear;

  GradientData({
    required this.startColor,
    required this.endColor,
    required this.angle,
    required this.isLinear,
  });
}
