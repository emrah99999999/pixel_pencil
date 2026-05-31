import 'package:flutter/material.dart';
import '../models/pixel_grid.dart';

class PixelPainter extends CustomPainter {
  final PixelGrid grid;
  final double pixelSize;

  PixelPainter({required this.grid, this.pixelSize = 20.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < grid.height; y++) {
      for (int x = 0; x < grid.width; x++) {
        paint.color = grid.getPixel(x, y);
        canvas.drawRect(
          Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
          paint,
        );
      }
    }

    // خطوط جدا کننده
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade600
      ..strokeWidth = 1.2;

    for (int y = 0; y <= grid.height; y++) {
      canvas.drawLine(
        Offset(0, y * pixelSize),
        Offset(grid.width * pixelSize, y * pixelSize),
        borderPaint,
      );
    }
    for (int x = 0; x <= grid.width; x++) {
      canvas.drawLine(
        Offset(x * pixelSize, 0),
        Offset(x * pixelSize, grid.height * pixelSize),
        borderPaint,
      );
    }

    // کادر دور کل شبکه
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2.0;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, grid.width * pixelSize, grid.height * pixelSize),
      outlinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
