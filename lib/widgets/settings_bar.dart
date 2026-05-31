import 'package:flutter/material.dart';
import 'zoom_controls.dart';
import 'grid_size_selector.dart';

class SettingsBar extends StatelessWidget {
  final double currentPixelSize;
  final int gridWidth;
  final int gridHeight;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final ValueChanged<Size> onGridSizeChanged;

  const SettingsBar({
    super.key,
    required this.currentPixelSize,
    required this.gridWidth,
    required this.gridHeight,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onGridSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF252525),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          ZoomControls(
            currentPixelSize: currentPixelSize,
            onZoomIn: onZoomIn,
            onZoomOut: onZoomOut,
          ),
          const Spacer(),
          GridSizeSelector(
            currentWidth: gridWidth,
            currentHeight: gridHeight,
            onSizeChanged: onGridSizeChanged,
          ),
        ],
      ),
    );
  }
}
