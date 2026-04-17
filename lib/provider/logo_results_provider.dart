import 'package:flutter/material.dart';
import 'package:logo_app_flutter/services/logo_service.dart';

class LogoResult {
  final String name;
  final String svg;
  final List<Color> colors;
  bool isFavorite;

  LogoResult({
    required this.name,
    required this.svg,
    required this.colors,
    this.isFavorite = false,
  });
}

class LogoResultsProvider extends ChangeNotifier {
  List<LogoResult> _generatedLogos = [];
  bool _isLoading = false;

  List<LogoResult> get generatedLogos => _generatedLogos;
  bool get isLoading => _isLoading;

  void toggleFavorite(int index) {
    if (index >= 0 && index < _generatedLogos.length) {
      _generatedLogos[index].isFavorite = !_generatedLogos[index].isFavorite;
      notifyListeners();
    }
  }

  Future<void> fetchLogos(
    String name,
    String slogan, {
    int? industryId,
    String? fontId,
    String? colorId,
  }) async {
    _isLoading = true;
    // Defer notification to avoid 'setState() called during build' errors
    Future.microtask(() => notifyListeners());

    try {
      final svgs = await LogoService().fetchLogoSVGs(
        name,
        slogan,
        industryId: industryId,
        fontId: fontId,
        colorId: colorId,
      );
      _generatedLogos = svgs.asMap().entries.map((entry) {
        int idx = entry.key;
        String svg = entry.value;

        // Assign some default varied colors for the cards
        List<Color> colors;
        switch (idx % 6) {
          case 0:
            colors = [const Color(0xFF7C4DFF), const Color(0xFF651FFF)];
            break;
          case 1:
            colors = [const Color(0xFFFF4081), const Color(0xFFF50057)];
            break;
          case 2:
            colors = [const Color(0xFF00B0FF), const Color(0xFF0091EA)];
            break;
          case 3:
            colors = [const Color(0xFFFF6D00), const Color(0xFFFF3D00)];
            break;
          case 4:
            colors = [const Color(0xFF00BFA5), const Color(0xFF1DE9B6)];
            break;
          default:
            colors = [const Color(0xFFFFAB00), const Color(0xFFFFD600)];
        }

        return LogoResult(
          name: 'Design ${idx + 1}',
          svg: svg,
          colors: colors,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching logos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void regenerateVariations(
    String name,
    String slogan, {
    int? industryId,
    String? fontId,
    String? colorId,
  }) {
    fetchLogos(
      name,
      slogan,
      industryId: industryId,
      fontId: fontId,
      colorId: colorId,
    );
  }
}
