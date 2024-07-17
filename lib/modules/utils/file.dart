import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';

class FileUtils {
  FileUtils._();

  static Future<String> md5String(String path) async {
    final file = File(path);
    if (!await file.exists()) return '';
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  }

  static bool exists(String destPath) {
    return File(destPath).existsSync();
  }

  static Future<bool> copy(String src, String dest) async {
    final copiedFile = await File(src).copy(dest);
    return await copiedFile.exists();
  }
}
