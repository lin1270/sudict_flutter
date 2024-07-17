import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sudict/config/path.dart';
import 'package:sudict/modules/utils/path.dart';
import 'package:dio/dio.dart';
import 'package:sudict/modules/utils/ui.dart';

class HttpUtils {
  HttpUtils._();

  static Future<dynamic> request(
      {required String url,
      String method = 'get',
      Object? bodyParam,
      bool parseJson = true,
      bool appendTimestamp = true,
      Map<String, String>? headers}) async {
    try {
      var isGet = method.toLowerCase() == 'get';
      if (appendTimestamp) {
        url += url.contains('?') ? '&' : '?';
        url += '_=${DateTime.now().millisecondsSinceEpoch}';
      }
      final uri = Uri.parse(url);
      final response = isGet
          ? await http.get(uri, headers: headers)
          : await http.post(uri, headers: headers, body: bodyParam);
      if (response.statusCode == 200) {
        if (parseJson) {
          return jsonDecode(utf8.decode(response.bodyBytes));
        }
        return response.bodyBytes;
      }
    } catch (e) {
      UiUtils.toast(content: '網路異常！');
    }

    return null;
  }

  static String getUrlUniqueFileName(String url) {
    // ignore: valid_regexps
    return url.replaceAll(RegExp(r'[/\\:%?=&_\-"!*<>|]'), '').replaceAll('\'', '');
  }

  static Future<String?> getUrlDownloadedPath(String url) async {
    String destFilePath = PathUtils.join(await PathConfig.downloadDir, getUrlUniqueFileName(url));
    if (await File(destFilePath).exists()) return destFilePath;
    return null;
  }

  static download({
    required String url,
    required Function(String path) onSuccess,
    required Function() onFailed,
    Function(double progress)? onProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    String? downloadedPath = await getUrlDownloadedPath(url);
    // 已下载好了，直接返回
    if (downloadedPath != null) {
      onSuccess(downloadedPath);
      return;
    }
    String destFilePath = PathUtils.join(await PathConfig.downloadDir, getUrlUniqueFileName(url));

    final dio = Dio();
    final response = await dio.download(
      url,
      destFilePath,
      queryParameters: queryParameters,
      onReceiveProgress: (count, total) {
        if (onProgress != null) onProgress(count / total);
      },
    );
    if (response.statusCode != 200) {
      onFailed();
    } else {
      onSuccess(destFilePath);
    }
  }
}
