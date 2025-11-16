// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ShapeSelectorWidget extends StatefulWidget {
  final Function(String shapeName) onShapeSelected;

  const ShapeSelectorWidget({super.key, required this.onShapeSelected});

  @override
  State<ShapeSelectorWidget> createState() => _ShapeSelectorWidgetState();
}

class _ShapeSelectorWidgetState extends State<ShapeSelectorWidget> {
  int? selectedIndex;

  final List<_ShapeData> shapes = [
    _ShapeData(
      "Transparent",
      Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,

          image: DecorationImage(
            opacity: .5,

            image: AssetImage(
              'assets/icons/check_small.png',
            ), // Your checkerboard pattern
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),

    _ShapeData(
      "Square",
   CustomPaint(
        size: const Size(24, 24),
        painter: SquarePainter(Colors.grey, null, null),
      ),
    ),
    _ShapeData(
      "Rounded Rect",
      CustomPaint(
        size: const Size(24, 17),
        painter: SquarePainter(Colors.grey, null, null),
      ),
    ),
    _ShapeData(
      "Triangle",
      CustomPaint(
        size: const Size(24, 24),
        painter: TrianglePainter(Colors.grey, null,null),
      ),
    ),
    _ShapeData(
      "Diamond",
      CustomPaint(
        size: const Size(24, 24),
        painter: DiamondPainter(Colors.grey, null, null),
      ),
    ),
    _ShapeData(
      "Pentagon",
      CustomPaint(
        size: const Size(24, 24),
        painter: PentagonPainter(Colors.grey, null,null),
      ),
    ),
    _ShapeData(
      "Hexagon",
      CustomPaint(
        size: const Size(24, 24),
        painter: HexagonPainter(Colors.grey, null,null),
      ),
    ),
    _ShapeData(
      "Star",
      CustomPaint(
        size: const Size(24, 24),
        painter: StarPainter(Colors.grey, null,null),
      ),
    ),
    _ShapeData(
      "Arrow",
      CustomPaint(
        size: const Size(28, 28),
        painter: ArrowPainter(Colors.grey, null,null),
      ),
    ),
    _ShapeData(
      "Heart",
      CustomPaint(
        size: const Size(26, 26),
        painter: HeartPainter(Colors.grey, null,null),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: shapes.length,
       itemBuilder: (context, index) {
  return GestureDetector(
    onTap: () {
      if (shapes[index].name == "Transparent") {
        final isSelected = selectedIndex == index;
        setState(() {
          selectedIndex = isSelected ? null : index;
        });
        widget.onShapeSelected(
          isSelected ? "TransparentOff" : "Transparent",
        );
      } else {
        setState(() {
          selectedIndex = index;
        });
        widget.onShapeSelected(shapes[index].name);
      }
    },
    child: Container(
      width: 25,
      margin: const EdgeInsets.symmetric(horizontal: 4.5),
      child: Stack(
        alignment: Alignment.center,
        children: [
          shapes[index].widget,
          if (selectedIndex == index)
            const Positioned(
            
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    ),
  );
},

      ),
    );
  }
}

class _ShapeData {
  final String name;
  final Widget widget;
  _ShapeData(this.name, this.widget);
}


class SquarePainter extends CustomPainter {
  final Color? color;
  final Gradient? gradient;
  final ui.Image? backgroundImage;

  SquarePainter(this.color, this.gradient, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint();

    if (backgroundImage != null) {
      paintImage(
        canvas: canvas,
        rect: rect,
        image: backgroundImage!,
        fit: BoxFit.cover,
      );
    } else {
      if (gradient != null) {
        paint.shader = gradient!.createShader(rect);
      } else {
        paint.color = color ?? Colors.white;
      }
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SquarePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gradient != gradient ||
        oldDelegate.backgroundImage != backgroundImage;
  }
}


class TrianglePainter extends CustomPainter {
  final Color ?color;
  final Gradient? gradient;
  final ui.Image? backgroundImage;

  TrianglePainter(this.color, this.gradient, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.save();
    canvas.clipPath(path);

    if (backgroundImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: backgroundImage!,
        fit: BoxFit.cover,
      );
    } else {
      final paint = Paint();
      if (gradient != null) {
        paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      } else {
       paint.color = color??Colors.white;
      }
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gradient != gradient ||
        oldDelegate.backgroundImage != backgroundImage;
  }
}


class DiamondPainter extends CustomPainter {
  final Color? color;
  final Gradient? gradient;
  final ui.Image? backgroundImage;

  DiamondPainter(this.color, this.gradient, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, size.height / 2)
      ..close();

    canvas.save();
    canvas.clipPath(path); // Clip to diamond shape

    final paint = Paint();

    if (backgroundImage != null) {
      // Draw the background image filling the area
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: backgroundImage!,
        fit: BoxFit.cover,
      );
    } else if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
      canvas.drawPath(path, paint);
    } else {
      // Fallback to white if no color or gradient
      paint.color = color ?? Colors.white;
      canvas.drawPath(path, paint);
    }

    canvas.restore(); // Unclip
  }

  @override
  bool shouldRepaint(covariant DiamondPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gradient != gradient ||
        oldDelegate.backgroundImage != backgroundImage;
  }
}

class PentagonPainter extends CustomPainter {
  final Color? color;
  final Gradient? gradient;
  final ui.Image? backgroundImage;

  PentagonPainter(this.color, this.gradient, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final angle = 2 * pi / 5;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 5; i++) {
      double x = center.dx + radius * cos(angle * i - pi / 2);
      double y = center.dy + radius * sin(angle * i - pi / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.save();
    canvas.clipPath(path);

    if (backgroundImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: backgroundImage!,
        fit: BoxFit.cover,
      );
    } else {
      final paint = Paint();
      if (gradient != null) {
        paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      } else {
       paint.color = color??Colors.white;
      }
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PentagonPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gradient != gradient ||
        oldDelegate.backgroundImage != backgroundImage;
  }
}


class HexagonPainter extends CustomPainter {
  final Color?color;
  final Gradient? gradient;
  final ui.Image? backgroundImage;

  HexagonPainter(this.color, this.gradient, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final angle = 2 * pi / 6;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 6; i++) {
      double x = center.dx + radius * cos(angle * i);
      double y = center.dy + radius * sin(angle * i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.save();
    canvas.clipPath(path);

    if (backgroundImage != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: backgroundImage!,
        fit: BoxFit.cover,
      );
    } else {
      final paint = Paint();
      if (gradient != null) {
        paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      } else {
        paint.color = color??Colors.white;
      }
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HexagonPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gradient != gradient ||
        oldDelegate.backgroundImage != backgroundImage;
  }
}

class StarPainter extends CustomPainter {
  final Color? color;
  final Gradient? gradient;
  final ui.Image? image;

  StarPainter(this.color, this.gradient, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final int points = 5;
    final r = size.width / 2;
    final rInner = r / 2.5;
    final angle = pi / points;

    for (int i = 0; i < 2 * points; i++) {
      final radius = i.isEven ? r : rInner;
      final x = size.width / 2 + radius * cos(i * angle - pi / 2);
      final y = size.height / 2 + radius * sin(i * angle - pi / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint();
    if (image != null) {
      canvas.save();
      canvas.clipPath(path);
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: image!,
        fit: BoxFit.cover,
      );
      canvas.restore();
    } else if (gradient != null) {
      paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(path, paint);
    } else {
      paint.color = color??Colors.white;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class ArrowPainter extends CustomPainter {
  final Color? color;
  final Gradient? gradient;
  final ui.Image? image;

  ArrowPainter(this.color, this.gradient, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    final double w = size.width;
    final double h = size.height;
    final double centerX = w / 2;
    final double centerY = h / 2;

    // Centered arrow shape
    path.moveTo(centerX - w * 0.3, centerY - h * 0.15);
    path.lineTo(centerX, centerY - h * 0.15);
    path.lineTo(centerX, centerY - h * 0.3);
    path.lineTo(centerX + w * 0.3, centerY);
    path.lineTo(centerX, centerY + h * 0.3);
    path.lineTo(centerX, centerY + h * 0.15);
    path.lineTo(centerX - w * 0.3, centerY + h * 0.15);
    path.close();

    final paint = Paint();
    if (image != null) {
      canvas.save();
      canvas.clipPath(path);
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, w, h),
        image: image!,
        fit: BoxFit.cover,
      );
      canvas.restore();
    } else if (gradient != null) {
      paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawPath(path, paint);
    } else {
      paint.color = color ?? Colors.white;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// class ArrowPainter extends CustomPainter {
//   final Color? color;
//   final Gradient? gradient;
//   final ui.Image? image;

//   ArrowPainter(this.color, this.gradient, this.image);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final path = Path()
//       ..moveTo(size.width * 0.1, size.height * 0.5)
//       ..lineTo(size.width * 0.7, size.height * 0.5)
//       ..lineTo(size.width * 0.7, size.height * 0.3)
//       ..lineTo(size.width * 0.9, size.height * 0.5)
//       ..lineTo(size.width * 0.7, size.height * 0.7)
//       ..lineTo(size.width * 0.7, size.height * 0.5)
//       ..close();

//     final paint = Paint();
//     if (image != null) {
//       canvas.save();
//       canvas.clipPath(path);
//       paintImage(
//         canvas: canvas,
//         rect: Rect.fromLTWH(0, 0, size.width, size.height),
//         image: image!,
//         fit: BoxFit.cover,
//       );
//       canvas.restore();
//     } else if (gradient != null) {
//       paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
//       canvas.drawPath(path, paint);
//     } else {
//       paint.color = color ?? Colors.white;
//       canvas.drawPath(path, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(_) => false;
// }


class HeartPainter extends CustomPainter {
  final Color? color;
  final Gradient? gradient;
  final ui.Image? image;

  HeartPainter(this.color, this.gradient, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    double w = size.width;
    double h = size.height;

    // Heart shape path
    path.moveTo(w / 2, h * 0.9); // bottom tip
    path.cubicTo(
      w * 1.1, h * 0.6, // control point 1
      w * 0.8, h * 0.1, // control point 2
      w / 2, h * 0.3,   // top center
    );
    path.cubicTo(
      w * 0.2, h * 0.1, // control point 1
      -w * 0.1, h * 0.6, // control point 2
      w / 2, h * 0.9,   // back to bottom tip
    );
    path.close();

    final paint = Paint();

    if (image != null) {
      canvas.save();
      canvas.clipPath(path);
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: image!,
        fit: BoxFit.cover,
      );
      canvas.restore();
    } else if (gradient != null) {
      paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(path, paint);
    } else {
      paint.color = color ?? Colors.red;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}