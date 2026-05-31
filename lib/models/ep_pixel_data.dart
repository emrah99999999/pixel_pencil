import 'dart:typed_data';
import 'dart:ui';

class EpPixelData {
  final int width;
  final int height;
  final Uint8List _originalBytes; // داده‌های خام فشرده‌شده
  final Map<int, int> _overrides; // (y * width + x) -> 0 سفید / 1 سیاه
  String tag;

  EpPixelData({
    required this.width,
    required this.height,
    required Uint8List originalBytes,
    this.tag = '',
  })  : _originalBytes = originalBytes,
        _overrides = {};

  /// خواندن رنگ یک پیکسل (true = سیاه)
  bool getPixel(int x, int y) {
    final key = y * width + x;
    if (_overrides.containsKey(key)) {
      return _overrides[key] == 1;
    }
    // خواندن از بایت فشرده‌شده (سطر پایین‌به‌بالا)
    int rowBytes = (width + 7) ~/ 8;
    int yFile = height - 1 - y; // تبدیل به ترتیب فایل
    int byteIndex = yFile * rowBytes + (x ~/ 8);
    int bit = (x % 8);
    return ((_originalBytes[byteIndex] >> bit) & 1) == 1;
  }

  /// تنظیم رنگ پیکسل (true = سیاه)
  void setPixel(int x, int y, bool black) {
    final key = y * width + x;
    _overrides[key] = black ? 1 : 0;
  }

  /// برگرداندن کل بایت‌های تصویر با در نظر گرفتن تغییرات
  Uint8List toBytes() {
    int rowBytes = (width + 7) ~/ 8;
    Uint8List result = Uint8List.fromList(_originalBytes);
    _overrides.forEach((key, value) {
      int x = key % width;
      int y = key ~/ width;
      int yFile = height - 1 - y;
      int byteIndex = yFile * rowBytes + (x ~/ 8);
      int bit = (x % 8);
      if (value == 1) {
        result[byteIndex] |= (1 << bit);
      } else {
        result[byteIndex] &= ~(1 << bit);
      }
    });
    return result;
  }

  /// ایجاد یک شبکه‌ی خالی (همه سفید)
  factory EpPixelData.empty(int width, int height) {
    int rowBytes = (width + 7) ~/ 8;
    int dataSize = rowBytes * height;
    Uint8List empty = Uint8List(dataSize); // همه صفر = سفید
    return EpPixelData(width: width, height: height, originalBytes: empty);
  }

  /// تغییر اندازه (صفر کردن همه چیز)
  EpPixelData resized(int newWidth, int newHeight) {
    return EpPixelData.empty(newWidth, newHeight);
  }
}
