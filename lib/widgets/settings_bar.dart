import 'package:flutter/material.dart';
import 'zoom_controls.dart';
import 'grid_size_selector.dart';

class SettingsBar extends StatelessWidget {
  final double currentPixelSize;
  final int gridWidth;
  final int gridHeight;
  final String tag;
  final int fileSize;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;
  final ValueChanged<Size> onGridSizeChanged;

  const SettingsBar({
    super.key,
    required this.currentPixelSize,
    required this.gridWidth,
    required this.gridHeight,
    required this.tag,
    required this.fileSize,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
    required this.onGridSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF252525),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              ZoomControls(
                currentPixelSize: currentPixelSize,
                onZoomIn: onZoomIn,
                onZoomOut: onZoomOut,
                onFit: onFit,
              ),
              const Spacer(),
              GridSizeSelector(
                currentWidth: gridWidth,
                currentHeight: gridHeight,
                onSizeChanged: onGridSizeChanged,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  '📄 ${tag.isNotEmpty ? tag : "بدون نام"}  |  ابعاد: ${gridWidth}×${gridHeight}  |  حجم: ${_formatSize(fileSize)}',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
