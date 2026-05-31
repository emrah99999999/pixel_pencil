import 'dart:typed_data';
import '../models/ep_pixel_data.dart';

class EpFileService {
  static const int maxDimension = 65535; // حداکثر مجاز (۶۵۵۳۵)
  static const int minDimension = 1;

  /// خواندن فایل EP و برگرداندن EpPixelData
  static EpPixelData parse(Uint8List bytes) {
    if (bytes.length < 34) throw Exception('فایل EP معتبر نیست (کمتر از ۳۴ بایت)');

    // بررسی بایت‌های رزرو شده
    if (bytes[0] != 0x00 || bytes[1] != 0x00 || bytes[2] != 0x00) {
      throw Exception('بایت‌های رزرو شده نامعتبر');
    }

    int height = bytes[3] | (bytes[4] << 8);
    int rawWidth = bytes[0x20] | (bytes[0x21] << 8);
    int width = rawWidth + 32;

    if (width < minDimension || height < minDimension) {
      throw Exception('ابعاد نمی‌تواند کمتر از ۱×۱ باشد');
    }
    if (width > maxDimension || height > maxDimension) {
      throw Exception('ابعاد بیش از حد بزرگ است (حداکثر ۶۵۵۳۵×۶۵۵۳۵)');
    }

    // خواندن برچسب
    List<int> tagBytes = [];
    for (int i = 0x10; i < 0x10 + 14; i++) {
      if (bytes[i] == 0x00) break;
      tagBytes.add(bytes[i]);
    }
    String tag = String.fromCharCodes(tagBytes);

    if (bytes[0x0F] != 0x04) throw Exception('شناسه‌ی 0x04 نامعتبر');
    if (bytes[0x1F] != 0x02) throw Exception('شناسه‌ی 0x02 نامعتبر');

    int rowBytes = (width + 7) ~/ 8;
    int dataSize = rowBytes * height;
    if (bytes.length < 34 + dataSize) throw Exception('داده‌های تصویر ناقص');

    // استخراج داده‌های بیت‌مپ (بعد از هدر)
    Uint8List pixelData = bytes.sublist(34, 34 + dataSize);

    return EpPixelData(
      width: width,
      height: height,
      originalBytes: pixelData,
      tag: tag,
    );
  }

  /// نوشتن EpPixelData به فایل EP
  static Uint8List write(EpPixelData data, String tag) {
    int width = data.width;
    int height = data.height;
    int rowBytes = (width + 7) ~/ 8;
    int dataSize = rowBytes * height;
    Uint8List out = Uint8List(34 + dataSize);

    // هدر
    out[0] = 0x00; out[1] = 0x00; out[2] = 0x00;
    out[3] = height & 0xFF;
    out[4] = (height >> 8) & 0xFF;
    out[5] = 0x00;

    String sizeStr = '${width}a$height';
    for (int i = 0; i < sizeStr.length && i < 9; i++) {
      out[6 + i] = sizeStr.codeUnitAt(i);
    }
    for (int i = sizeStr.length; i < 9; i++) {
      out[6 + i] = 0x00;
    }

    out[0x0F] = 0x04;

    List<int> tagBytes = tag.runes.take(14).toList();
    for (int i = 0; i < tagBytes.length; i++) {
      out[0x10 + i] = tagBytes[i];
    }
    out[0x10 + tagBytes.length] = 0x00;

    out[0x1F] = 0x02;

    int storedWidth = (width - 32).clamp(0, 65535);
    out[0x20] = storedWidth & 0xFF;
    out[0x21] = (storedWidth >> 8) & 0xFF;

    // دریافت بایت‌های نهایی (با تغییرات)
    Uint8List finalPixels = data.toBytes();
    out.setRange(34, 34 + finalPixels.length, finalPixels);

    return out;
  }
}
