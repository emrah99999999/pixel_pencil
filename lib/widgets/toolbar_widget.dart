import 'package:flutter/material.dart';

class ToolbarWidget extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onSave;
  final VoidCallback onOpen;
  final VoidCallback onTogglePencil;
  final bool isPencilActive;

  const ToolbarWidget({
    super.key,
    required this.onClear,
    required this.onSave,
    required this.onOpen,
    required this.onTogglePencil,
    required this.isPencilActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2D2D2D),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'باز کردن فایل EP',
            icon: const Icon(Icons.folder_open, color: Colors.white),
            onPressed: onOpen,
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'پاک کردن',
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: onClear,
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'ذخیره فایل EP',
            icon: const Icon(Icons.save_alt, color: Colors.white),
            onPressed: onSave,
          ),
          const SizedBox(width: 8),
          // دکمه مداد
          IconButton(
            tooltip: isPencilActive ? 'مداد فعال است' : 'مداد غیرفعال',
            icon: Icon(
              isPencilActive ? Icons.edit : Icons.edit_off,
              color: isPencilActive ? Colors.yellow : Colors.white54,
            ),
            onPressed: onTogglePencil,
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
