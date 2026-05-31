import 'package:flutter/material.dart';
import 'screens/editor_screen.dart';

void main() {
  runApp(const PixelPencilApp());
}

class PixelPencilApp extends StatelessWidget {
  const PixelPencilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Pencil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D2D2D),
          foregroundColor: Colors.white,
        ),
      ),
        home: EditorScreen(),
    );
  }
}
