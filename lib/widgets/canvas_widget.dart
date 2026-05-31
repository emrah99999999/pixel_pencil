import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import '../models/ep_pixel_data.dart';
import 'pixel_painter.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  CanvasWidgetState createState() => CanvasWidgetState();
}

class CanvasWidgetState extends State<CanvasWidget> {
  late EpPixelData pixelData;
  double _pixelSize = 20.0;
  double _basePixelSize = 20.0;
  Offset _panOffset = Offset.zero;
  Offset _basePanOffset = Offset.zero;
  bool _pencilMode = true;
  BoxConstraints? _lastConstraints;
  bool _needsFit = false;

  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    pixelData = EpPixelData.empty(32, 32);
  }

  // متدهای عمومی
  void clearGrid() {
    setState(() {
      pixelData = EpPixelData.empty(pixelData.width, pixelData.height);
      _panOffset = Offset.zero;
      _needsFit = true;
    });
  }

  void setPixelSize(double newSize) {
    setState(() {
      _pixelSize = newSize.clamp(1.0, 100.0); // دامنه گسترده
    });
  }

  void setGridSize(int width, int height) {
    setState(() {
      pixelData = pixelData.resized(width, height);
      _panOffset = Offset.zero;
      _needsFit = true;
    });
  }

  void loadData(EpPixelData newData) {
    setState(() {
      pixelData = newData;
      _panOffset = Offset.zero;
      _needsFit = true;
    });
  }

  /// تنظیم زوم به‌گونه‌ای که کل تصویر در قاب جا شود
  void fitToView() {
    if (_lastConstraints == null) return;
    final availableWidth = _lastConstraints!.maxWidth;
    final availableHeight = _lastConstraints!.maxHeight;
    if (availableWidth.isInfinite || availableHeight.isInfinite) return;

    double idealX = availableWidth / pixelData.width;
    double idealY = availableHeight / pixelData.height;
    double newSize = (idealX < idealY ? idealX : idealY) * 0.95;
    newSize = newSize.clamp(1.0, 100.0);

    setState(() {
      _pixelSize = newSize;
      _panOffset = Offset.zero;
    });
  }

  double get pixelSize => _pixelSize;
  String get tag => pixelData.tag;
  EpPixelData get data => pixelData;
  int get fileSizeEstimate => 34 + ((pixelData.width + 7) ~/ 8) * pixelData.height;

  Future<ui.Image> captureImage() async {
    final boundary =
        _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw Exception('boundary not found');
    return boundary.toImage(pixelRatio: 1.0);
  }

  // رویدادها
  void _onScaleStart(ScaleStartDetails details) {
    _basePixelSize = _pixelSize;
    _basePanOffset = _panOffset;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_pencilMode && details.pointerCount == 1) {
      // در حالت مداد، کلیک‌های تکی از طریق onTapUp مدیریت می‌شوند
      // اینجا کاری نمی‌کنیم تا از حرکت ناخواسته جلوگیری شود
      return;
    } else if (!_pencilMode && details.pointerCount == 1) {
      // جابجایی (Pan)
      setState(() {
        _panOffset = _basePanOffset + details.focalPointDelta;
      });
    } else {
      // زوم (دو انگشت)
      setState(() {
        _pixelSize =
            (_basePixelSize * details.scale).clamp(1.0, 100.0);
      });
    }
  }

  void _handleScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        _pixelSize =
            (_pixelSize + event.scrollDelta.dy.sign * -2).clamp(1.0, 100.0);
      });
    }
  }

  // مداد دقیق: فقط با یک کلیک (بدون نیاز به چندبار کلیک)
  void _onTapUp(TapUpDetails details) {
    if (!_pencilMode) return; // فقط وقتی مداد فعال است کلیک کنیم

    final localPos = details.localPosition;
    final double gridX = (localPos.dx - _panOffset.dx) / _pixelSize;
    final double gridY = (localPos.dy - _panOffset.dy) / _pixelSize;
    final int x = gridX.floor();
    final int y = gridY.floor();

    if (x >= 0 && x < pixelData.width && y >= 0 && y < pixelData.height) {
      setState(() {
        bool current = pixelData.getPixel(x, y);
        pixelData.setPixel(x, y, !current);
      });
    }
  }

  void setPencilMode(bool active) {
    setState(() {
      _pencilMode = active;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gridWidth = pixelData.width * _pixelSize;
    final gridHeight = pixelData.height * _pixelSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        _lastConstraints = constraints;

        if (_needsFit) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _needsFit = false;
            fitToView();
          });
        }

        final visibleRect = Rect.fromLTRB(
          -_panOffset.dx / _pixelSize,
          -_panOffset.dy / _pixelSize,
          (constraints.maxWidth - _panOffset.dx) / _pixelSize,
          (constraints.maxHeight - _panOffset.dy) / _pixelSize,
        );

        return Listener(
          onPointerSignal: _handleScroll,
          child: GestureDetector(
            onTapUp: _onTapUp,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            child: ClipRect(
              child: Transform.translate(
                offset: _panOffset,
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: CustomPaint(
                    size: Size(gridWidth, gridHeight),
                    painter: PixelPainter(
                      data: pixelData,
                      pixelSize: _pixelSize,
                      visibleGridRect: visibleRect,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
