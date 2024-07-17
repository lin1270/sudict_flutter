import 'package:sudict/modules/utils/local_storage.dart';

class HistoryMgr {
  HistoryMgr._();
  static HistoryMgr? _instance;
  static HistoryMgr get instance {
    _instance ??= HistoryMgr._();
    return _instance!;
  }

  final _words = <String>[];
  final _preNextWords = <String>[];
  var _currPos = -1;
  // ignore: constant_identifier_names
  static const _MAX_COUNT = 200;

  init() async {
    final wordsJs = await LocalStorageUtils.getJson(LocalStorageKeys.historyWords);
    if (wordsJs != null && wordsJs.length > 0) {
      for (int i = 0; i < wordsJs.length; ++i) {
        var wordItemstr = wordsJs[i];
        _words.add(wordItemstr);
      }
      _preNextWords.addAll(_words.reversed.toList());
      _currPos = _words.length;
      if (_currPos == 0) {
        _currPos = -1;
      }
    }
  }

  _saveCfg() {
    LocalStorageUtils.setJson(LocalStorageKeys.historyWords, _words);
  }

  Future<void> add(String word) async {
    var found = true;
    while (_words.length >= _MAX_COUNT) {
      _words.removeAt(_words.length - 1);
    }
    while (found) {
      found = false;
      for (var i = 0; i < _words.length; ++i) {
        if (_words.elementAt(i) == word) {
          _words.removeAt(i);
          found = true;
          break;
        }
      }
    }
    _words.insert(0, word);
    var preNextToRemoveCount = _preNextWords.length - _currPos - 1;
    while (preNextToRemoveCount > 0) {
      _preNextWords.removeAt(_currPos + preNextToRemoveCount);
      --preNextToRemoveCount;
    }
    if (_preNextWords.isNotEmpty) {
      if (_preNextWords.elementAt(_preNextWords.length - 1) != word) {
        _preNextWords.add(word);
      }
    } else {
      _preNextWords.add(word);
    }
    _currPos = _preNextWords.length - 1;
    if (_currPos < 0) _currPos = 0;

    _saveCfg();
  }

  clear() {
    _words.clear();
    _preNextWords.clear();
    _currPos = -1;
    _saveCfg();
  }

  Future<String?> nextWord() async {
    if (_preNextWords.isEmpty || _currPos >= _preNextWords.length - 1) return null;
    ++_currPos;
    return _preNextWords.elementAt(_currPos);
  }

  Future<String?> preWord() async {
    if (_preNextWords.isEmpty || _currPos <= 0) return null;
    --_currPos;
    return _preNextWords.elementAt(_currPos);
  }

  List<String> get words => _words;
}
