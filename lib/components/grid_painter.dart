import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final Color gridColor;
  final int? highlightedHorizontalLine;
  final int? highlightedVerticalLine;

  GridPainter({
    required this.gridColor,
    this.highlightedHorizontalLine,
    this.highlightedVerticalLine,
  });

  final double _dashWidth = 8.0; 
  final double _dashSpace = 8.0; 
  final double _strokeWidth = 2.0; 
  final double _highlightStrokeWidth = 3.0; 
  final Color _highlightColor = Colors.orange;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = gridColor
          ..strokeWidth = _strokeWidth
          ..style = PaintingStyle.stroke;

    final Paint highlightPaint =
        Paint()
          ..color = _highlightColor
          ..strokeWidth = _highlightStrokeWidth
          ..style = PaintingStyle.stroke;

    final double colStep = size.width / 4;
    final double rowStep = size.height / 4;

    for (int i = 0; i <= 4; i++) {
      final double y = i * rowStep;
      double currentX = 0;
      final Paint currentPaint =
          i == highlightedHorizontalLine ? highlightPaint : paint;
      while (currentX < size.width) {
        double segmentEnd = currentX + _dashWidth;
        if (segmentEnd > size.width) {
          segmentEnd = size.width;
        }
        canvas.drawLine(
          Offset(currentX, y),
          Offset(segmentEnd, y),
          currentPaint,
        );
        currentX += _dashWidth + _dashSpace;
      }
    }

    for (int i = 0; i <= 4; i++) {
      final double x = i * colStep;
      double currentY = 0;
      final Paint currentPaint =
          i == highlightedVerticalLine ? highlightPaint : paint;
      while (currentY < size.height) {
        double segmentEnd = currentY + _dashWidth;
        if (segmentEnd > size.height) {
          segmentEnd = size.height;
        }
        canvas.drawLine(
          Offset(x, currentY),
          Offset(x, segmentEnd),
          currentPaint,
        );
        currentY += _dashWidth + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor ||
        oldDelegate.highlightedHorizontalLine != highlightedHorizontalLine ||
        oldDelegate.highlightedVerticalLine != highlightedVerticalLine;
  }
}
