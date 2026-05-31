import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/toolbar_widget.dart';
import '../widgets/settings_bar.dart';

class EditorScreen extends StatelessWidget {
  EditorScreen({super.key});

  final GlobalKey<CanvasWidgetState> _canvasKey = GlobalKey();

  Future<void> _saveImage(BuildContext context) async {
    final canvasState = _canvasKey.currentState;
    if (canvasState == null) return;

    try {
      final ui.Image image = await canvasState.captureImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // ذخیره در گالری با استفاده از بسته‌ی gal
        await Gal.putImageBytes(
          pngBytes,
          album: 'PixelPencil',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ تصویر در گالری ذخیره شد'),
              backgroundColor: Colors.green.shade800,
            ),
          );
        }
      } else {
        // ذخیره در فایل (دسکتاپ / وب)
        final dir = await getApplicationDocumentsDirectory();
        final fileName =
            'pixel_art_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(pngBytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تصویر ذخیره شد: $fileName'),
              backgroundColor: Colors.green.shade800,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطا در ذخیره‌سازی: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  void _clearCanvas() {
    _canvasKey.currentState?.clearGrid();
  }

  void _zoomIn() {
    final state = _canvasKey.currentState;
    if (state != null) {
      state.setPixelSize(state.pixelSize + 2.0);
    }
  }

  void _zoomOut() {
    final state = _canvasKey.currentState;
    if (state != null) {
      state.setPixelSize(state.pixelSize - 2.0);
    }
  }

  void _changeGridSize(Size size) {
    _canvasKey.currentState
        ?.setGridSize(size.width.toInt(), size.height.toInt());
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = _canvasKey.currentState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('✏️ Pixel Pencil'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ToolbarWidget(
            onClear: _clearCanvas,
            onSave: () => _saveImage(context),
          ),
          SettingsBar(
            currentPixelSize: canvasState?.pixelSize ?? 20.0,
            gridWidth: canvasState?.grid.width ?? 32,
            gridHeight: canvasState?.grid.height ?? 32,
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
            onGridSizeChanged: _changeGridSize,
          ),
          Expanded(
            child: Center(
              child: CanvasWidget(key: _canvasKey),
            ),
          ),
        ],
      ),
    );
  }
}
