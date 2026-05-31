import 'package:flutter/material.dart';

class ZoomControls extends StatelessWidget {
  final double currentPixelSize;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const ZoomControls({
    super.key,
    required this.currentPixelSize,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  String get _zoomPercentage =>
      '${((currentPixelSize / 20.0) * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'کوچک‌نمایی',
          icon: const Icon(Icons.zoom_out, color: Colors.white),
          onPressed: onZoomOut,
        ),
        Text(
          _zoomPercentage,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        IconButton(
          tooltip: 'بزرگ‌نمایی',
          icon: const Icon(Icons.zoom_in, color: Colors.white),
          onPressed: onZoomIn,
        ),
      ],
    );
  }
}
