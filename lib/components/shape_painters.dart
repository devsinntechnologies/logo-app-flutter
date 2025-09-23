import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/shape_painters.dart';

class SquarePainter extends CustomPainter {
  final Color shapeColor;
  final Gradient? gradient;
  final String? bgImage;

  SquarePainter(this.shapeColor, this.gradient, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = shapeColor;
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DiamondPainter extends CustomPainter {
  final Color shapeColor;
  final Gradient? gradient;
  final String? bgImage;

  DiamondPainter(this.shapeColor, this.gradient, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = shapeColor;
    }

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TrianglePainter extends CustomPainter {
  final Color shapeColor;
  final Gradient? gradient;
  final String? bgImage;

  TrianglePainter(this.shapeColor, this.gradient, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = shapeColor;
    }

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PentagonPainter extends CustomPainter {
  final Color shapeColor;
  final Gradient? gradient;
  final String? bgImage;

  PentagonPainter(this.shapeColor, this.gradient, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = shapeColor;
    }

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(centerX, centerY);

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - (pi / 2);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HexagonPainter extends CustomPainter {
  final Color shapeColor;
  final Gradient? gradient;
  final String? bgImage;

  HexagonPainter(this.shapeColor, this.gradient, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = shapeColor;
    }

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(centerX, centerY);

    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StarPainter extends CustomPainter {
  final Color shapeColor;
  final Gradient? gradient;
  final String? bgImage;

  StarPainter(this.shapeColor, this.gradient, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = shapeColor;
    }

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = min(centerX, centerY);
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < 10; i++) {
      final angle = (i * pi / 5) - (pi / 2);
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ArrowPainter extends CustomPainter {
  final Color shapeColor;
  final Gradient? gradient;
  final String? bgImage;

  ArrowPainter(this.shapeColor, this.gradient, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = shapeColor;
    }

    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.6, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width * 0.6, size.height * 0.8);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.lineTo(0, size.height * 0.6);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HeartPainter extends CustomPainter {
  final Color shapeColor;
  final Gradient? gradient;
  final String? bgImage;

  HeartPainter(this.shapeColor, this.gradient, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = shapeColor;
    }

    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width * 0.5, height * 0.25);

    path.cubicTo(
      width * 0.2,
      height * 0.1,
      -width * 0.25,
      height * 0.6,
      width * 0.5,
      height,
    );

    path.cubicTo(
      width * 1.25,
      height * 0.6,
      width * 0.8,
      height * 0.1,
      width * 0.5,
      height * 0.25,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
