import 'dart:ui';

class PixelGrid {
  late int width;
  late int height;
  late List<List<Color>> _pixels;

  PixelGrid({this.width = 32, this.height = 32}) {
    _pixels = List.generate(
      height,
      (_) => List.filled(width, const Color(0xFFFFFFFF)), // همه سفید
    );
  }

  Color getPixel(int x, int y) => _pixels[y][x];

  void setPixel(int x, int y, Color color) {
    _pixels[y][x] = color;
  }

  void resize(int newWidth, int newHeight) {
    width = newWidth;
    height = newHeight;
    _pixels = List.generate(
      newHeight,
      (_) => List.filled(newWidth, const Color(0xFFFFFFFF)),
    );
  }
}
