import 'package:flutter/material.dart';
import '../models/ep_pixel_data.dart';

class PixelPainter extends CustomPainter {
  final EpPixelData data;
  final double pixelSize;
  final Rect visibleGridRect; // ناحیه‌ی قابل مشاهده (در مختصات شبکه)

  PixelPainter({
    required this.data,
    required this.pixelSize,
    required this.visibleGridRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // محدوده‌ی پیکسل‌ها را محاسبه می‌کنیم
    int startX = visibleGridRect.left.floor().clamp(0, data.width);
    int endX = visibleGridRect.right.ceil().clamp(0, data.width);
    int startY = visibleGridRect.top.floor().clamp(0, data.height);
    int endY = visibleGridRect.bottom.ceil().clamp(0, data.height);

    for (int y = startY; y < endY; y++) {
      for (int x = startX; x < endX; x++) {
        bool isBlack = data.getPixel(x, y);
        paint.color = isBlack ? Colors.black : Colors.white;
        canvas.drawRect(
          Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
          paint,
        );
      }
    }

    // خطوط شبکه (فقط در محدوده‌ی دید)
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade600
      ..strokeWidth = 0.8;

    for (int y = startY; y <= endY; y++) {
      canvas.drawLine(
        Offset(startX * pixelSize, y * pixelSize),
        Offset(endX * pixelSize, y * pixelSize),
        gridPaint,
      );
    }
    for (int x = startX; x <= endX; x++) {
      canvas.drawLine(
        Offset(x * pixelSize, startY * pixelSize),
        Offset(x * pixelSize, endY * pixelSize),
        gridPaint,
      );
    }

    // کادر بیرونی (همیشه برای کل تصویر)
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2.0;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, data.width * pixelSize, data.height * pixelSize),
      outlinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant PixelPainter oldDelegate) => true;
}
