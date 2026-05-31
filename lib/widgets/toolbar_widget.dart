import 'package:flutter/material.dart';

class ToolbarWidget extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onSave;

  const ToolbarWidget({
    super.key,
    required this.onClear,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2D2D2D),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'پاک کردن',
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: onClear,
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'ذخیره تصویر',
            icon: const Icon(Icons.save_alt, color: Colors.white),
            onPressed: onSave,
          ),
          const Spacer(),
          const Text(
            '🖌️ Pixel Pencil',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
