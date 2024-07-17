import 'package:path/path.dart';
import 'package:sudict/modules/utils/path.dart';

class PathConfig {
  PathConfig._();
  static const String assetsBase = 'sudict';
  static const String resultBase = 'result';

  static Future<String> get resultDir async {
    String path = PathUtils.join(await PathUtils.localDirectory, '$assetsBase/$resultBase/');
    await PathUtils.mkdir(path);
    return path;
  }

  static Future<String> get userLocalDictDir async {
    String path = PathUtils.join(await PathUtils.localDirectory, 'user/dict/');
    await PathUtils.mkdir(path);
    return path;
  }

  static Future<String> get downloadDir async {
    String path = PathUtils.join(await PathUtils.localDirectory, 'downloadDir');
    await PathUtils.mkdir(path);
    return path;
  }

  static Future<String> get userLocalBookDir async {
    String path = PathUtils.join(await PathUtils.localDirectory, 'user/book/');
    await PathUtils.mkdir(path);
    return path;
  }

  static const String jgw = 'jgw';
  static Future<String> get jgwDir async {
    String path = PathUtils.join(await PathUtils.localDirectory, assetsBase, jgw);
    await PathUtils.mkdir(path);
    return path;
  }

  static const String dzg = 'dzg';
  static Future<String> get dzgGggPath async {
    String path = PathUtils.join(await PathUtils.localDirectory, dzg);
    await PathUtils.mkdir(path);
    path = join(path, 'record.dzgggg');
    return path;
  }

  static const String thoughtRecord = 'thoughtRecord';
  static Future<String> get thoughtRecordPath async {
    String path = PathUtils.join(await PathUtils.localDirectory, thoughtRecord);
    await PathUtils.mkdir(path);
    path = join(path, 'thoughtRecord.json');
    return path;
  }
}
