import 'package:flutter/material.dart';
import 'dart:math' as math;

class MiniGraphPainter extends CustomPainter {
  final Color color;

  MiniGraphPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final Path path = Path();

    // Generate random points for mini graph
    final rng = math.Random();
    final points = List.generate(5, (index) {
      double x = size.width * index / 4;
      double y = size.height * (0.3 + rng.nextDouble() * 0.7);
      return Offset(x, y);
    });

    // First point
    path.moveTo(points[0].dx, points[0].dy);

    // Connect points
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
