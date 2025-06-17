
import 'package:flutter/cupertino.dart';

class TextSizeUtil {
  static Size getTextSize(String text, TextStyle? style) {
    if (text.isEmpty) return Size.zero;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return textPainter.size;
  }
}