import 'package:flutter/material.dart';

class GridSizeSelector extends StatelessWidget {
  final int currentWidth;
  final int currentHeight;
  final ValueChanged<Size> onSizeChanged; // Size(width, height)

  const GridSizeSelector({
    super.key,
    required this.currentWidth,
    required this.currentHeight,
    required this.onSizeChanged,
  });

  static const _sizes = [
    Size(16, 16),
    Size(32, 32),
    Size(48, 48),
    Size(64, 64),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.grid_on, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        DropdownButton<Size>(
          dropdownColor: const Color(0xFF2D2D2D),
          style: const TextStyle(color: Colors.white),
          underline: const SizedBox(),
          value: _sizes.firstWhere(
            (s) => s.width == currentWidth && s.height == currentHeight,
            orElse: () => const Size(32, 32),
          ),
          items: _sizes.map((s) {
            return DropdownMenuItem<Size>(
              value: s,
              child: Text('${s.width.toInt()}×${s.height.toInt()}'),
            );
          }).toList(),
          onChanged: (selected) {
            if (selected != null) {
              onSizeChanged(selected);
            }
          },
        ),
      ],
    );
  }
}
