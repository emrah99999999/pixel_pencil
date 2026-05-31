import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import '../models/pixel_grid.dart';
import 'pixel_painter.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  CanvasWidgetState createState() => CanvasWidgetState();
}

class CanvasWidgetState extends State<CanvasWidget> {
  late PixelGrid grid;
  double _pixelSize = 20.0;
  double _basePixelSize = 20.0;
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
      _pixelSize = newSize.clamp(10.0, 40.0);
    });
  }

  void setGridSize(int width, int height) {
    setState(() {
      grid.resize(width, height);
    });
  }

  double get pixelSize => _pixelSize;

  /// بارگذاری کامل شبکه از یک PixelGrid (مثلاً از EP)
  void loadGrid(PixelGrid newGrid) {
    setState(() {
      grid = newGrid;
      // تنظیم زوم بر اساس ابعاد (اختیاری)
    });
  }

  String get tag => grid.tag;

  Future<ui.Image> captureImage() async {
    final boundary =
        _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('نتوانست boundary را پیدا کند');
    }
    return boundary.toImage(pixelRatio: 1.0);
  }

  // رسم به‌صورت معکوس‌کننده (toggle)
  void _togglePixel(int x, int y) {
    Color current = grid.getPixel(x, y);
    Color newColor = (current == Colors.black) ? Colors.white : Colors.black;
    grid.setPixel(x, y, newColor);
  }

  void _drawAtPosition(Offset localPosition) {
    final int x = (localPosition.dx / _pixelSize).floor();
    final int y = (localPosition.dy / _pixelSize).floor();

    if (x >= 0 && x < grid.width && y >= 0 && y < grid.height) {
      setState(() {
        _togglePixel(x, y);
      });
    }
  }

  void _handleScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        _pixelSize =
            (_pixelSize + event.scrollDelta.dy.sign * -2).clamp(10.0, 40.0);
      });
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _basePixelSize = _pixelSize;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 1) {
      _drawAtPosition(details.localFocalPoint);
    } else {
      setState(() {
        _pixelSize =
            (_basePixelSize * details.scale).clamp(10.0, 40.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasWidth = grid.width * _pixelSize;
    final canvasHeight = grid.height * _pixelSize;

    return Listener(
      onPointerSignal: _handleScroll,
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
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
      ),
    );
  }
}
