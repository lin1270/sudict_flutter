import 'package:flutter/material.dart';
import 'package:sudict/modules/utils/assets.dart';

const _tones = '˙ˊˇˋ';

class ZhuyinItem {
  ZhuyinItem(this.word, this.zhuyin);
  String word;
  String zhuyin;
  List<String>? _zhuyinShupai;

  List<String>? get zhuyinShupai {
    if (_zhuyinShupai != null) return _zhuyinShupai;
    _zhuyinShupai = [];

    final chars = zhuyin.characters;
    var tone = '';
    for (final char in chars) {
      if (_tones.contains(char)) {
        tone = char;
        continue;
      }
      _zhuyinShupai!.add(char);
    }
    _zhuyinShupai![_zhuyinShupai!.length - 1] = _zhuyinShupai!.last + tone;
    return _zhuyinShupai;
  }
}

class ZhuyinLine {
  final data = <ZhuyinItem>[];
}

class Zhuyin {
  final _lines = <ZhuyinLine>[];

  List<ZhuyinLine> get lines => _lines;

  Future<void> loadAssets(String path) async {
    String? str = await AssetsUtils.readStringFile(path);
    if (str == null) return;
    final lines = str.split('\n');
    for (var i = 0; i < lines.length; i += 2) {
      final zhuyinStrArr = lines[i].replaceAll(RegExp('\t+'), '\t').split('\t');
      final wordStrArr = lines[i + 1].replaceAll(RegExp('\t+'), '\t').split('\t');
      if (zhuyinStrArr.length == wordStrArr.length) {
        ZhuyinLine zyl = ZhuyinLine();
        for (var j = 0; j < wordStrArr.length; ++j) {
          zyl.data.add(ZhuyinItem(wordStrArr.elementAt(j), zhuyinStrArr.elementAt(j).trim()));
        }
        _lines.add(zyl);
      }
    }
  }
}
