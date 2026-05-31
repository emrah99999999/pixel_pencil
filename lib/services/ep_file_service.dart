import 'dart:typed_data';
import 'dart:ui';
import '../models/pixel_grid.dart';

class EpImage {
  final int width;
  final int height;
  final String tag;
  final List<List<bool>> pixels; // true = سیاه
  EpImage(this.width, this.height, this.tag, this.pixels);
}

class EpFileService {
  static const int _maxDimension = 1024; // حداکثر بعد مجاز

  /// تجزیه‌ی فایل EP و برگرداندن یک شیء EpImage
  static EpImage parse(Uint8List bytes) {
    if (bytes.length < 34) throw Exception('فایل EP معتبر نیست (کمتر از ۳۴ بایت)');

    // بررسی بایت‌های رزرو شده
    if (bytes[0] != 0x00 || bytes[1] != 0x00 || bytes[2] != 0x00) {
      throw Exception('بایت‌های رزرو شده نامعتبر');
    }

    // خواندن ارتفاع (uint16 LE) از آفست ۳
    int height = bytes[3] | (bytes[4] << 8);

    // عرض واقعی = (عرض ذخیره‌شده) + ۳۲
    int rawWidth = bytes[0x20] | (bytes[0x21] << 8);
    int width = rawWidth + 32;

    if (width <= 0 || height <= 0) throw Exception('ابعاد تصویر نامعتبر');
    if (width > _maxDimension || height > _maxDimension) {
      throw Exception('ابعاد فایل بیش از حد بزرگ است (حداکثر ${_maxDimension}x${_maxDimension})');
    }

    // خواندن برچسب (حداکثر ۱۴ کاراکتر + تهی)
    List<int> tagBytes = [];
    for (int i = 0x10; i < 0x10 + 14; i++) {
      if (bytes[i] == 0x00) break;
      tagBytes.add(bytes[i]);
    }
    String tag = String.fromCharCodes(tagBytes);

    // بررسی شناسه‌های ثابت
    if (bytes[0x0F] != 0x04) throw Exception('شناسه‌ی 0x04 نامعتبر');
    if (bytes[0x1F] != 0x02) throw Exception('شناسه‌ی 0x02 نامعتبر');

    // محاسبه‌ی تعداد بایت در هر سطر
    int rowBytes = (width + 7) ~/ 8;
    int dataSize = rowBytes * height;
    if (bytes.length < 34 + dataSize) throw Exception('داده‌های تصویر ناقص');

    // خواندن بیت‌مپ (از پایین به بالا)
    List<List<bool>> pixels = List.generate(height, (_) => List.filled(width, false));
    for (int yFile = 0; yFile < height; yFile++) {
      int srcY = height - 1 - yFile; // تبدیل به مختصات کارتزین
      int rowStart = 34 + yFile * rowBytes;
      for (int x = 0; x < width; x++) {
        int byteIndex = rowStart + (x ~/ 8);
        int bit = (bytes[byteIndex] >> (x % 8)) & 1;
        pixels[srcY][x] = (bit == 1);
      }
    }

    return EpImage(width, height, tag, pixels);
  }

  /// تبدیل شبکه‌ی پیکسلی فعلی به بایت‌های فایل EP
  static Uint8List write(PixelGrid grid, String tag) {
    int width = grid.width;
    int height = grid.height;
    int rowBytes = (width + 7) ~/ 8;
    int dataSize = rowBytes * height;
    int fileSize = 34 + dataSize;
    Uint8List out = Uint8List(fileSize);

    // بایت‌های رزرو شده
    out[0] = 0x00; out[1] = 0x00; out[2] = 0x00;

    // ارتفاع
    out[3] = height & 0xFF;
    out[4] = (height >> 8) & 0xFF;

    // بلااستفاده
    out[5] = 0x00;

    // رشته‌ی ابعاد خوانا (اختیاری)
    String sizeStr = '${width}a$height';
    for (int i = 0; i < sizeStr.length && i < 9; i++) {
      out[6 + i] = sizeStr.codeUnitAt(i);
    }
    // پر کردن با صفر
    for (int i = sizeStr.length; i < 9; i++) {
      out[6 + i] = 0x00;
    }

    // شناسه‌ی 0x04
    out[0x0F] = 0x04;

    // برچسب (حداکثر ۱۴ کاراکتر)
    List<int> tagBytes = tag.runes.take(14).toList();
    for (int i = 0; i < tagBytes.length; i++) {
      out[0x10 + i] = tagBytes[i];
    }
    // بایت پایان
    out[0x10 + tagBytes.length] = 0x00;

    // شناسه‌ی 0x02
    out[0x1F] = 0x02;

    // عرض ذخیره‌شده = عرض واقعی - ۳۲
    int storedWidth = width - 32;
    if (storedWidth < 0) storedWidth = 0; // جلوگیری از منفی
    out[0x20] = storedWidth & 0xFF;
    out[0x21] = (storedWidth >> 8) & 0xFF;

    // نوشتن بیت‌مپ (از پایین به بالا)
    for (int yFile = 0; yFile < height; yFile++) {
      int srcY = height - 1 - yFile; // ردیف در تصویر اصلی
      int rowStart = 34 + yFile * rowBytes;
      for (int x = 0; x < width; x++) {
        bool isBlack = grid.getPixel(x, srcY) == const Color(0xFF000000);
        if (isBlack) {
          int byteIndex = rowStart + (x ~/ 8);
          out[byteIndex] |= (1 << (x % 8));
        }
      }
    }

    return out;
  }
}
