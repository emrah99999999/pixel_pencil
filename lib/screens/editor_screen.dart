import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../models/ep_pixel_data.dart';
import '../services/ep_file_service.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/toolbar_widget.dart';
import '../widgets/settings_bar.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey<CanvasWidgetState> _canvasKey = GlobalKey();
  bool _pencilActive = true;

  Future<void> _openEpFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;

      Uint8List bytes;
      if (kIsWeb) {
        bytes = result.files.first.bytes!;
      } else {
        File file = File(result.files.first.path!);
        bytes = await file.readAsBytes();
      }

      EpPixelData epData = EpFileService.parse(bytes);
      _canvasKey.currentState?.loadData(epData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ فایل "${epData.tag}" بارگذاری شد'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطا: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  Future<void> _saveEpFile() async {
    final canvasState = _canvasKey.currentState;
    if (canvasState == null) return;

    String? fileName = await _showSaveDialog(canvasState.tag);
    if (fileName == null || fileName.isEmpty) return;

    try {
      Uint8List epBytes = EpFileService.write(canvasState.data, fileName);

      if (kIsWeb) {
        final blob = html.Blob([epBytes], 'application/octet-stream');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.ep')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        String? outputPath = await FilePicker.saveFile(
          dialogTitle: 'ذخیره فایل EP',
          fileName: '$fileName.ep',
          type: FileType.any,
        );
        if (outputPath != null) {
          File(outputPath).writeAsBytesSync(epBytes);
          if (mounted) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطا در ذخیره‌سازی: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  Future<String?> _showSaveDialog(String initialTag) async {
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

  void _togglePencil() {
    setState(() {
      _pencilActive = !_pencilActive;
      _canvasKey.currentState?.setPencilMode(_pencilActive);
    });
  }

  void _clearCanvas() {
    _canvasKey.currentState?.clearGrid();
  }

  void _zoomIn() {
    _canvasKey.currentState?.setPixelSize(
      (_canvasKey.currentState?.pixelSize ?? 20.0) + 2.0,
    );
  }

  void _zoomOut() {
    _canvasKey.currentState?.setPixelSize(
      (_canvasKey.currentState?.pixelSize ?? 20.0) - 2.0,
    );
  }

  void _fitToView() {
    _canvasKey.currentState?.fitToView();
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
            onOpen: _openEpFile,
            onClear: _clearCanvas,
            onSave: _saveEpFile,
            onTogglePencil: _togglePencil,
            isPencilActive: _pencilActive,
          ),
          SettingsBar(
            currentPixelSize: canvasState?.pixelSize ?? 20.0,
            gridWidth: canvasState?.data.width ?? 32,
            gridHeight: canvasState?.data.height ?? 32,
            tag: canvasState?.tag ?? '',
            fileSize: canvasState?.fileSizeEstimate ?? 0,
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
            onFit: _fitToView,
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
