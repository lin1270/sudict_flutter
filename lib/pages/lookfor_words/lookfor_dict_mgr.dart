// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sudict/modules/utils/assets.dart';
import 'package:sudict/modules/utils/byte_data.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/string.dart';
import 'package:sudict/pages/lookfor_words/lookfor_word_info.dart';

enum LookforDictType {
  part(0, '部件查字'),
  wubi(1, '五筆查字'),
  pinyin(2, '拼音查字'),
  bishun(3, '筆順查字'),
  bihuashu(4, '筆劃數查字'),
  cangjie(5, '倉頡查字');

  const LookforDictType(this.value, this.name);

  final int value;
  final String name;
}

class LookforDictMgr {
  LookforDictMgr._();
  static LookforDictMgr? _instance;
  static LookforDictMgr get instance {
    _instance ??= LookforDictMgr._();
    return _instance!;
  }

  var _data = [];
  var _type = 0;
  bool _isLoaded = false;
  var _partsData = <dynamic>[];
  bool _isPartsLoaded = false;

  static const _s_shengDiao = "āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜüv";
  static const _s_shengDiao_r1 = "aaaaooooeeeeiiiiiuuuuuuuuuv";
  static const _s_shengDiao_r2 = "12341234 1234123412341234  ";

  _loadCore() async {
    await _loadCommon();

    await _loadParts();
  }

  _loadCommon() async {
    _isLoaded = false;
    var data = await AssetsUtils.readBytesFile('assets/words/lookforWords.data');
    if (data != null) {
      _data = await compute((data) {
        int pos = 0;
        var retData = [];
        while (pos < data.length - 1) {
          int len = ByteDataUtils.byteList2int(data: data, begin: pos);
          pos += 4;
          final infoBytes = data.sublist(pos, pos + len);
          String allInfo = utf8.decode(infoBytes);
          pos += len;
          if (allInfo.isNotEmpty) {
            final parts = allInfo.split('|');
            if (parts.length == 7) {
              final wordInfo = LookforWordInfo();
              wordInfo.word = parts[0];
              wordInfo.bushou = parts[1];
              wordInfo.bishun = parts[3];
              wordInfo.wubi = parts[4].toLowerCase();
              wordInfo.cangjie = parts[5].toLowerCase();

              String pysStr = parts[2];
              if (pysStr.isNotEmpty) {
                final pys = parts[2].split(',');
                if (pys.isNotEmpty) {
                  // 處理聲調拼音
                  for (int i = 0; i < pys.length; ++i) {
                    String py = pys[i];
                    py = dealPy(py);
                    wordInfo.pyList.add(py.toLowerCase());
                  }
                }
              }

              retData.add(wordInfo);
            }
          }
        }

        return retData;
      }, data);
    }

    _isLoaded = true;
  }

  _loadParts() async {
    _isPartsLoaded = false;
    final data = await AssetsUtils.readJsonFile('assets/words/ids.json', useThread: true);
    if (data != null) {
      _partsData = data;
    }
    _isPartsLoaded = true;
  }

  bool isLoaded() {
    return _isLoaded;
  }

  loadDic() async {
    if (_isLoaded) return;

    int type = await LocalStorageUtils.getInt(LocalStorageKeys.lookforWordDictTab) ?? 0;
    if (type >= LookforDictType.values.length) {
      type = 0;
    }

    _loadCore();
  }

  String dealPy(String? py) {
    if (py == null || py.isEmpty) return "";
    for (int i = 0; i < _s_shengDiao.length; ++i) {
      final c = _s_shengDiao.characters.characterAt(i);
      for (int j = 0; j < py.length; ++j) {
        final pc = py.characters.characterAt(j);
        if (pc == c) {
          String noShengDiao = _s_shengDiao_r1.substring(i, i + 1);
          String shengDiao = _s_shengDiao_r2.substring(i, i + 1);

          String newPy = py.replaceRange(j, j + 1, noShengDiao);
          if (shengDiao != ' ') {
            newPy = newPy + shengDiao;
          }

          return newPy;
        }
      }
    }

    return py;
  }

  goNextDic() {
    ++_type;
    if (_type >= LookforDictType.values.length) {
      _type = 0;
    }

    LocalStorageUtils.setInt(LocalStorageKeys.lookforWordDictTab, _type);
  }

  goPreDic() {
    --_type;
    if (_type < 0) {
      _type = LookforDictType.values.length - 1;
    }

    LocalStorageUtils.setInt(LocalStorageKeys.lookforWordDictTab, _type);
  }

  String get currDicTitle => LookforDictType.values[_type].name;

  String getStringOfWordInfo(LookforWordInfo info, int type) {
    String title = "";
    if (type >= 0 && type < LookforDictType.values.length) {
      title = LookforDictType.values[type].name;
      title = title.substring(0, title.length - 2);
    }
    final coreType = LookforDictType.values[type];
    switch (coreType) {
      case LookforDictType.pinyin:
        {
          String pyStr = "";
          for (int i = 0; i < info.pyList.length; ++i) {
            String py = info.pyList[i];
            pyStr += py;
            if (i != info.pyList.length - 1) {
              pyStr += ", ";
            }
          }
          return '$title: $pyStr';
        }

      case LookforDictType.bishun:
        return "$title: ${info.bishun}";
      case LookforDictType.bihuashu:
        return "$title: ${info.bishun.length}";
      case LookforDictType.wubi:
        return "$title: ${info.wubi}";
      case LookforDictType.cangjie:
        return "$title: ${info.cangjie}";

      default:
        break;
    }

    return "";
  }

  int get currType => _type;
  set currType(int type) {
    if (type >= 0 && type < LookforDictType.values.length) {
      _type = type;
      LocalStorageUtils.setInt(LocalStorageKeys.lookforWordDictTab, _type);
    }
  }

  List<LookforWordInfo>? findWordByCode(String code) {
    // list of WordInfo
    if (!_isLoaded) return null;
    if (_data.isEmpty) return null;
    final coreType = LookforDictType.values[_type];
    switch (coreType) {
      case LookforDictType.pinyin:
        return findWordByPinyin(code, false);
      case LookforDictType.bihuashu:
        return findWordByBihuashu(code, false);
      case LookforDictType.bishun:
        return findWordByBishun(code, false);
      case LookforDictType.wubi:
        return findWordByWubi(code, false);
      case LookforDictType.cangjie:
        return findWordByCangjie(code, false);
      default:
        break;
    }

    return null;
  }

  String? findCodeByWord(String word) {
    if (!_isLoaded) return null;
    if (_data.isEmpty) return null;
    final coreType = LookforDictType.values[_type];
    List<LookforWordInfo>? foundWord;
    switch (coreType) {
      case LookforDictType.pinyin:
        foundWord = findWordByPinyin(word, true);
        break;

      case LookforDictType.bihuashu:
        foundWord = findWordByBihuashu(word, true);
        break;

      case LookforDictType.bishun:
        foundWord = findWordByBishun(word, true);
        break;

      case LookforDictType.wubi:
        foundWord = findWordByWubi(word, true);
        break;

      case LookforDictType.cangjie:
        foundWord = findWordByCangjie(word, true);
        break;

      default:
        break;
    }

    if (foundWord == null || foundWord.isEmpty) return null;

    return getStringOfWordInfo(foundWord[0], _type);
  }

  List<String> getCodeByMutiWord(String words) {
    var arr = <String>[];

    String temp = words;
    if (temp.isNotEmpty) {
      temp = temp.trim();
    }
    while (temp.isNotEmpty) {
      for (LookforWordInfo wordInfo in _data) {
        if (temp.startsWith(wordInfo.word)) {
          arr.add(wordInfo.bishun);
        }
      }

      if (temp.isNotEmpty) {
        temp = temp.substring(1);
        if (temp.isNotEmpty) {
          temp = temp.trim();
        }
      }
    }
    return arr;
  }

  List<LookforWordInfo> findWordByPart(String codeOrWord, bool reverse) {
    var arr = <LookforWordInfo>[];
    if (reverse) {
      // 不支援反查
    } else {
      String code = codeOrWord;
      final codeArr = getCodeByMutiWord(code);

      int bishunCount = 0;
      for (String codeSub in codeArr) {
        bishunCount += codeSub.length;
      }

      if (bishunCount == 0) return arr;

      for (LookforWordInfo info in _data) {
        String bishun = info.bishun;
        if (bishun.length < bishunCount) continue;

        bool match = true;
        for (String toMathItem in codeArr) {
          final foundIndex = bishun.indexOf(toMathItem);
          if (foundIndex == -1) {
            match = false;
            break;
          }

          bishun = bishun.replaceRange(foundIndex, foundIndex + toMathItem.length, " ");
        }

        if (match) {
          arr.add(info);
        }
      }
    }

    return arr;
  }

  List<LookforWordInfo> findWordByPinyin(String codeOrWord, bool reverse) {
    final arr = <LookforWordInfo>[];
    if (reverse) {
      String word = codeOrWord;
      for (LookforWordInfo info in _data) {
        if (word.startsWith(info.word)) {
          arr.add(info);
          break;
        }
      }
    } else {
      String code = codeOrWord.toLowerCase();
      for (LookforWordInfo info in _data) {
        for (String py in info.pyList) {
          if (py.startsWith(code)) {
            arr.add(info);
            break;
          }
        }
      }
    }

    return arr;
  }

  List<LookforWordInfo> findWordByBihuashu(String codeOrWord, bool reverse) {
    final arr = <LookforWordInfo>[];
    if (reverse) {
      String word = codeOrWord;
      for (LookforWordInfo info in _data) {
        if (word.startsWith(info.word)) {
          arr.add(info);
          break;
        }
      }
    } else {
      String code = codeOrWord;
      int count = int.parse(code);
      for (LookforWordInfo info in _data) {
        if (info.bishun.length == count) {
          arr.add(info);
        }
      }
    }

    return arr;
  }

  List<LookforWordInfo> findWordByBishun(String codeOrWord, bool reverse) {
    final arr = <LookforWordInfo>[];
    if (reverse) {
      String word = codeOrWord;
      for (LookforWordInfo info in _data) {
        if (word.startsWith(info.word)) {
          arr.add(info);
          break;
        }
      }
    } else {
      String code = codeOrWord;
      for (LookforWordInfo info in _data) {
        if (info.bishun.startsWith(code)) {
          arr.add(info);
        }
      }
    }

    return arr;
  }

  List<LookforWordInfo> findWordByWubi(String codeOrWord, bool reverse) {
    final arr = <LookforWordInfo>[];
    if (reverse) {
      String word = codeOrWord;
      for (LookforWordInfo info in _data) {
        if (word.startsWith(info.word)) {
          arr.add(info);
          break;
        }
      }
    } else {
      String code = codeOrWord.toLowerCase();

      code = StringUtils.trim(code, RegExp(r'z'));

      if (code.isEmpty) return arr;
      for (LookforWordInfo info in _data) {
        if (info.wubi.length < code.length) continue;

        bool match = true;
        for (int i = 0; i < code.length; ++i) {
          var cc = code.characters.characterAt(i).string;
          var ic = info.wubi.characters.characterAt(i).string;
          if (cc != 'z' && cc != ic) {
            match = false;
            break;
          }
        }

        if (match) {
          arr.add(info);
        }
      }
    }

    return arr;
  }

  List<LookforWordInfo> findWordByCangjie(String codeOrWord, bool reverse) {
    final arr = <LookforWordInfo>[];
    if (reverse) {
      String word = codeOrWord;
      for (LookforWordInfo info in _data) {
        if (word.startsWith(info.word)) {
          arr.add(info);
          break;
        }
      }
    } else {
      String code = codeOrWord.toLowerCase();
      for (LookforWordInfo info in _data) {
        if (info.cangjie.startsWith(code)) {
          arr.add(info);
        }
      }
    }

    return arr;
  }

  String getDicTitleByType(int type) {
    if (_type >= 0 && _type < LookforDictType.values.length) {
      return LookforDictType.values[type].name;
    }
    return "";
  }

  int get dicCount => LookforDictType.values.length;

  List<dynamic>? getPartWordItemByWord(String word) {
    if (word.isEmpty || _partsData.isEmpty) return null;
    for (dynamic item in _partsData) {
      if (item.length < 2) continue;
      if (word == item[0]) return item;
    }
    return null;
  }

  List<String>? seperateParts(String str) {
    List<String> arr = str.characters.toList();
    if (arr.isEmpty) return null;
    List<String> ret = [];

    for (String part in arr) {
      List<dynamic>? item = getPartWordItemByWord(part);
      if (item == null || item.length < 2) {
        ret.add(part);
      } else {
        ret.add(item[1]);
      }
    }

    return ret;
  }

  List<String>? findWordByParts(String partsStr, bool allMatch) {
    if (partsStr.isEmpty || !_isPartsLoaded || _partsData.isEmpty) return null;

    // 分解字符串為單字
    List<String>? arr = seperateParts(partsStr);
    var result = <String>[];

    for (dynamic item in _partsData) {
      if (item.length < 2) continue;
      bool found = false;
      String word = item[0];
      if (word.isEmpty) continue;

      // 里面部件相等
      for (int j = 1; j < item.length && !found; ++j) {
        String part = item[j];
        if (isParts(arr!, part, allMatch)) {
          found = true;
          break;
        }
      }

      if (found) {
        result.add(word);
      }
    }

    return result;
  }

// parts: 要搜寻的部件
// partsStr: 数据库的部件
  bool isParts(List<String> parts, String partsStr, bool allMatch) {
    String temp = partsStr;
    for (int i = 0; i < parts.length; ++i) {
      String part = parts[i];
      int foundIndex = temp.indexOf(part);
      if (foundIndex == -1) return false;
      temp = temp.replaceRange(foundIndex, foundIndex + part.length, '');
    }

    if (allMatch) {
      return temp.isEmpty;
    }

    return true;
  }
}
