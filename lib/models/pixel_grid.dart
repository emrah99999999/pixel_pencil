import 'dart:ui';

class PixelGrid {
  late int width;
  late int height;
  late List<List<Color>> _pixels;
  String tag = ''; // برچسب فایل EP

  PixelGrid({this.width = 32, this.height = 32, this.tag = ''}) {
    _pixels = List.generate(
      height,
      (_) => List.filled(width, const Color(0xFFFFFFFF)),
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

  /// بارگذاری از داده‌های EP (با لیست بولی)
  void loadFromEp(int w, int h, List<List<bool>> pixels, String newTag) {
    width = w;
    height = h;
    tag = newTag;
    _pixels = List.generate(h, (y) {
      return List.generate(w, (x) {
        return pixels[y][x] ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
      });
    });
  }
}
