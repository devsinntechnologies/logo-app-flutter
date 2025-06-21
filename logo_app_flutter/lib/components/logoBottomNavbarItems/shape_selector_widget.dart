import 'package:flutter/material.dart';
import 'dart:math';

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
              'lib/assets/icons/check_small.png',
            ), // Your checkerboard pattern
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),

    _ShapeData("Square", Container(width: 20, height: 20, color: Colors.grey)),
    _ShapeData(
      "Rounded Rect",
      Container(
        width: 12,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    ),
    _ShapeData(
      "Triangle",
      CustomPaint(size: const Size(24, 24), painter: TrianglePainter()),
    ),
    _ShapeData(
      "Diamond",
      CustomPaint(size: const Size(24, 24), painter: DiamondPainter()),
    ),
    _ShapeData(
      "Pentagon",
      CustomPaint(size: const Size(24, 24), painter: PentagonPainter()),
    ),
    _ShapeData(
      "Hexagon",
      CustomPaint(size: const Size(24, 24), painter: HexagonPainter()),
    ),
    _ShapeData(
      "Star",
      CustomPaint(size: const Size(24, 24), painter: StarPainter()),
    ),
    _ShapeData(
      "Arrow",
      CustomPaint(size: const Size(24, 24), painter: ArrowPainter()),
    ),
    _ShapeData(
      "Heart",
      CustomPaint(size: const Size(24, 24), painter: HeartPainter()),
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
                // Toggle checkerboard on/off
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // border: Border.all(
                //   color: selectedIndex == index ? Colors.blue : Colors.grey,
                //   width: selectedIndex == index ? 2 : 1,
                // ),
              ),
              child: Center(child: shapes[index].widget),
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

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey;
    final path =
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey;
    final path =
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(size.width, size.height / 2)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class PentagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey;
    final path = Path();
    final angle = 2 * pi / 5;
    for (int i = 0; i < 5; i++) {
      final x = size.width / 2 + size.width / 2 * cos(angle * i - pi / 2);
      final y = size.height / 2 + size.height / 2 * sin(angle * i - pi / 2);
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
  bool shouldRepaint(_) => false;
}

class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey;
    final path = Path();
    final angle = 2 * pi / 6;
    for (int i = 0; i < 6; i++) {
      final x = size.width / 2 + size.width / 2 * cos(angle * i - pi / 2);
      final y = size.height / 2 + size.height / 2 * sin(angle * i - pi / 2);
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
  bool shouldRepaint(_) => false;
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey;
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
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey;
    final path =
        Path()
          ..moveTo(0, size.height / 2)
          ..lineTo(size.width * 0.6, size.height / 2)
          ..lineTo(size.width * 0.6, size.height * 0.3)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width * 0.6, size.height * 0.7)
          ..lineTo(size.width * 0.6, size.height / 2)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey;
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height * 0.75);
    path.cubicTo(0, height * 0.5, 0, height * 0.2, width / 2, height * 0.35);
    path.cubicTo(
      width,
      height * 0.2,
      width,
      height * 0.5,
      width / 2,
      height * 0.75,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
