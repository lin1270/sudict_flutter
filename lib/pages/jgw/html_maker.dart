import 'dart:io';

import 'package:sudict/config/path.dart';
import 'package:sudict/modules/setting/index.dart';
import 'package:sudict/modules/utils/path.dart';
import 'package:sudict/pages/jgw/css.dart';

String _end = '</body></html>';

int _index = 0;

Future<String> makeHtml(String body) async {
  String begin = '''
<!DOCTYPE html>
<html lang="zh-CN" style="font-size:${Setting.instance.jgwFontScale * 14}px">

<head>
    <meta charset="UTF-8">
    <meta name="renderer" content="webkit|ie-comp|ie-stand">
	  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no, minimal-ui">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <link rel="stylesheet" href="iconfont.css">
</head>
<body>
''';
  String full = begin + css() + body + _end;
  final path = PathUtils.join(await PathConfig.jgwDir, 'liushu_${(_index++) % 2}.html');
  await File(path).writeAsString(full);
  return path;
}
