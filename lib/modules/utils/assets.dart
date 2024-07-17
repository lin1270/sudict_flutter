import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sudict/config/path.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/path.dart';
import 'package:sudict/modules/utils/version.dart';
import 'package:path/path.dart' as p;

class AssetsUtils {
  AssetsUtils._();

  static Future<dynamic> readJsonFile(String path, {useThread = false}) async {
    try {
      final content = await rootBundle.loadString(path);
      if (useThread) {
        return await compute((message) => jsonDecode(message), content);
      }
      return jsonDecode(content);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> readStringFile(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List?> readBytesFile(String path) async {
    try {
      var buf = await rootBundle.load(path);
      return buf.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  static Future<RandomAccessFile> openFile(String path) async {
    var filePath = await copyAssets2local(path, path);

    return await File(filePath).open();
  }

  static Future<String> makeCopyPath(String path) async {
    return p.join(await PathUtils.localDirectory, PathConfig.assetsBase, path);
  }

  static Future<String> copyAssets2local(String path, String toPath, {bool force = false}) async {
    final appVersion = await VersionUtils.appVersion;
    String cfgKey = "${LocalStorageKeys.assetsFileCopyVersionPre}_$path";
    String? savedVersion = await LocalStorageUtils.getString(cfgKey);

    String filePath = await makeCopyPath(toPath);
    var file = File(filePath);
    var isFileExists = await file.exists();
    if (force || savedVersion != appVersion || !isFileExists) {
      await _copyAssets2localCore(path, filePath);
      LocalStorageUtils.setString(cfgKey, appVersion);
    }

    return filePath;
  }

  static Future<void> _copyAssets2localCore(path, toPath) async {
    String filePath = toPath;
    var file = File(filePath);
    var isFileExists = await file.exists();
    if (isFileExists) {
      await file.delete();
    }
    final dir = Directory(p.dirname(filePath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 使用temp，避免复制到一半时，程序异常终止，则文件损坏。
    // 使用temp则不会出现该情况
    String tempFilePath = toPath + ".temp";
    var tempFile = File(tempFilePath);

    final buffer = await rootBundle.load(path);
    var handler = await tempFile.open(mode: FileMode.write);
    await handler.writeFrom(buffer.buffer.asUint8List());
    await handler.close();

    // 复制完后，重命名
    await tempFile.rename(filePath);
  }
}
