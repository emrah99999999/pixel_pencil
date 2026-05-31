import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/pixel_grid.dart';
import 'pixel_painter.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  CanvasWidgetState createState() => CanvasWidgetState();
}

class CanvasWidgetState extends State<CanvasWidget> {
  late PixelGrid grid;
  double _pixelSize = 20.0; // مقدار پیش‌فرض
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    grid = PixelGrid();
  }

  void clearGrid() {
    setState(() {
      grid = PixelGrid(width: grid.width, height: grid.height);
    });
  }

  void setPixelSize(double newSize) {
    setState(() {
      _pixelSize = newSize.clamp(10.0, 40.0); // محدوده زوم
    });
  }

  void setGridSize(int width, int height) {
    setState(() {
      grid.resize(width, height);
    });
  }

  double get pixelSize => _pixelSize;

  Future<ui.Image> captureImage() async {
    final boundary =
        _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('نتوانست boundary را پیدا کند');
    }
    return boundary.toImage(pixelRatio: 1.0);
  }

  void _drawAtPosition(Offset localPosition) {
    final int x = (localPosition.dx / _pixelSize).floor();
    final int y = (localPosition.dy / _pixelSize).floor();

    if (x >= 0 && x < grid.width && y >= 0 && y < grid.height) {
      setState(() {
        grid.setPixel(x, y, Colors.black);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasWidth = grid.width * _pixelSize;
    final canvasHeight = grid.height * _pixelSize;

    return GestureDetector(
      onPanStart: (details) => _drawAtPosition(details.localPosition),
      onPanUpdate: (details) => _drawAtPosition(details.localPosition),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700, width: 2),
        ),
        child: RepaintBoundary(
          key: _repaintKey,
          child: CustomPaint(
            size: Size(canvasWidth, canvasHeight),
            painter: PixelPainter(grid: grid, pixelSize: _pixelSize),
          ),
        ),
      ),
    );
  }
}
