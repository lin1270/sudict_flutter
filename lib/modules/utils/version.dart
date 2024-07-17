import 'package:package_info_plus/package_info_plus.dart';

class VersionUtils {
  static Future<String> get appVersion async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (e) {
      return "";
    }
  }
}
