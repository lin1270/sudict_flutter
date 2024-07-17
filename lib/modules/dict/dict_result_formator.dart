import 'dart:io';

import 'package:sudict/config/path.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_search_result.dart';
import 'package:path/path.dart' as p;
import 'package:sudict/modules/setting/index.dart';
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';

class DictFormatedResult {
  DictFormatedResult(this.content, this.url);
  String content;
  String url;
}

class DictResultFormator {
  static Future<DictFormatedResult> format(DictItem dict, DictSearchResult result, int index,
      {isGroup = false}) async {
    var contentCore = '';
    if (result.errorMsg != null) {
      contentCore = result.errorMsg!;
    } else {
      final word = result.words[index];
      await dict.loadWord(word, result.redirectResult);
      if (word.content == null) {
        contentCore = '異常錯誤！';
      } else if (dict.isWeb()) {
        contentCore = word.content!;
        return DictFormatedResult(contentCore, contentCore);
      } else {
        contentCore = word.content!;
      }
    }

    // todo:
    // markdown 組裝
    var temp = contentCore;
    if (result.redirectResult != null) {
      temp = '${result.redirectResult!.template}$temp';
    }

    var fullHtml = formatString(temp, bigFont: dict.bigFont, isGroup: isGroup);
    if (Setting.instance.convertSimple) {
      fullHtml = await ChineseConverter.convert(fullHtml, T2S());
    }

    // 写内容到本地 => 主要是因为ttf无法通过 webview 内存加载
    String filePath = p.join(await PathConfig.resultDir, 'index.html');
    var handler = await File(filePath).open(mode: FileMode.write);
    await handler.writeString(fullHtml);
    handler.close();
    return DictFormatedResult(fullHtml, 'file://$filePath');
  }

  static Future<String> formatCatalog(String html, String where) async {
    String fullHtml = '';
    int bodyEnd = html.lastIndexOf(RegExp(r'</body>', caseSensitive: false));
    String fontAndGo =
        '$_sFonttyle\n<style type="text/css">body{background:#ddd;font-family:KaiXinSong;}</style><script>goCatalog("$where");</script>';
    if (bodyEnd >= 0) {
      fullHtml = html.replaceRange(bodyEnd, bodyEnd + '</body>'.length, fontAndGo);
    }

    // 写内容到本地 => 主要是因为ttf无法通过 webview 内存加载
    String filePath = p.join(await PathConfig.resultDir, 'catalog.html');
    var handler = await File(filePath).open(mode: FileMode.write);
    await handler.writeString(fullHtml);
    handler.close();
    return 'file://$filePath';
  }

  static const String _sFonttyle =
      '<style type="text/css">@font-face {font-family: "KaiXinSong";src: url("./dict.ttf") format("truetype");font-weight:normal;font-style:normal;}</style>';

  static String formatString(String str, {bigFont = false, isGroup = false}) {
    // 如果isGroup，因底部会添加一条辞典UI，会挡住辞典释义，
    // 所以需要添加许多换行，让用户能滚动到底部。

    return '''<html lang="zh">
                <head>
                  <meta charset="utf-8">
                  <meta name="viewport" content="initial-scale=1,maximum-scale=5,user-scalable=yes,width=device-width">
                    ${bigFont ? _sFonttyle : ''}
                </head>
                <body style="background:#ddd;font-family:KaiXinSong;zoom:${Setting.instance.fontScale * 100}%;msTransformOrigin:center top;">
                    $str
                    ${isGroup ? '<br><br><br><br><br><br>' : ''}
                </body>
            </html>''';
  }
}
