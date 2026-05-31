import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../models/pixel_grid.dart';
import '../services/ep_file_service.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/toolbar_widget.dart';
import '../widgets/settings_bar.dart';
import 'package:flutter/services.dart';

class EditorScreen extends StatelessWidget {
  EditorScreen({super.key});

  final GlobalKey<CanvasWidgetState> _canvasKey = GlobalKey();

  // ---------- باز کردن فایل EP ----------
  Future<void> _openEpFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
       type: FileType.any,
       allowMultiple: false,
     );

      if (result == null || result.files.isEmpty) return;

      // خواندن بایت‌ها
      Uint8List bytes;
      if (kIsWeb) {
        bytes = result.files.first.bytes!;
      } else {
        File file = File(result.files.first.path!);
        bytes = await file.readAsBytes();
      }

      EpImage epImage = EpFileService.parse(bytes);
      PixelGrid loadedGrid = PixelGrid();
      loadedGrid.loadFromEp(epImage.width, epImage.height, epImage.pixels, epImage.tag);

      _canvasKey.currentState?.loadGrid(loadedGrid);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ فایل EP "${epImage.tag}" بارگذاری شد'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطا: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  // ---------- ذخیره‌سازی فایل EP ----------
  Future<void> _saveEpFile(BuildContext context) async {
    final canvasState = _canvasKey.currentState;
    if (canvasState == null) return;

    // گرفتن نام فایل از کاربر
    String? fileName = await _showSaveDialog(context, canvasState.tag);
    if (fileName == null || fileName.isEmpty) return;

    try {
      Uint8List epBytes = EpFileService.write(canvasState.grid, fileName);

      if (kIsWeb) {
        // ذخیره در وب (دانلود)
        final blob = html.Blob([epBytes], 'application/octet-stream');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.ep')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // دسکتاپ (لینوکس) و اندروید
        String? outputPath = await FilePicker.saveFile(
         dialogTitle: 'ذخیره فایل EP',
         fileName: '$fileName.ep',
         type: FileType.any,
       );

        if (outputPath != null) {
          File(outputPath).writeAsBytesSync(epBytes);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ فایل $fileName.ep ذخیره شد'),
                backgroundColor: Colors.green.shade800,
              ),
            );
          }
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

  // گفتگوی نام (حداکثر ۸ کاراکتر)
  Future<String?> _showSaveDialog(BuildContext context, String initialTag) async {
    TextEditingController controller = TextEditingController(
      text: initialTag.length > 8 ? initialTag.substring(0, 8) : initialTag,
    );
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('نام فایل', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLength: 8,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'حداکثر ۸ حرف یا عدد انگلیسی',
            hintStyle: TextStyle(color: Colors.white54),
          ),
          inputFormatters: [
            // فقط حروف و اعداد انگلیسی
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx, controller.text.trim());
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
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
    _canvasKey.currentState?.setGridSize(size.width.toInt(), size.height.toInt());
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
            onOpen: () => _openEpFile(context),
            onClear: _clearCanvas,
            onSave: () => _saveEpFile(context),
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
