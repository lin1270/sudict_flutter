import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PathUtils {
  PathUtils._();

  static Future<String> get localDirectory async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.absolute.path;
  }

  static String join(String part1,
      [String? part2,
      String? part3,
      String? part4,
      String? part5,
      String? part6,
      String? part7,
      String? part8,
      String? part9,
      String? part10,
      String? part11,
      String? part12,
      String? part13,
      String? part14,
      String? part15,
      String? part16]) {
    return p.join(part1, part2, part3, part4, part5, part6, part7, part8, part9, part10, part11,
        part12, part13, part14, part15, part16);
  }

  static Future<void> mkdir(String path, {withFileName = false}) async {
    final dir = Directory(withFileName ? p.dirname(path) : path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// @ext .txt, .png
  static Future<String> randomTempFilePathWithDotExt(String ext) async {
    final path = join(await localDirectory, 'temp/${DateTime.now().millisecondsSinceEpoch}$ext');
    await mkdir(path, withFileName: true);
    return path;
  }

  // newExt: noDot, e.g.   png, mdd, mdx, jpg
  static String changeExt(String path, String newExt) {
    final ext = p.extension(path);
    return "${path.substring(0, path.length - ext.length)}.$newExt";
  }

  static String ext(String path, {hasDot = true}) {
    String ext = p.extension(path);
    if (!hasDot) {
      ext = ext.replaceAll(RegExp(r'^\.+'), '');
    }
    return ext;
  }

  static String fileName(String path, {hasExt = true}) {
    String name = p.basename(path);
    if (!hasExt) {
      int pos = name.lastIndexOf('.');
      if (pos > 0) {
        // not 0
        name = name.substring(0, pos);
      }
    }
    return name;
  }
}
