import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ZipUtils {
  static List<int> unzipBuffer(List<int> buf) {
    return zlib.decode(buf);
  }

  static String unzipUtf8Buffer(Uint8List buf) {
    var unzipBuf = unzipBuffer(buf);
    return utf8.decode(unzipBuf);
  }
}
