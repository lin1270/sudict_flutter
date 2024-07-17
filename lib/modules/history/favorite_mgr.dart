import 'package:intl/intl.dart';
import 'package:sudict/modules/utils/local_storage.dart';

class FavoriteGroupItem {
  var _fileTime = 0;
  String? group;
  final words = <String>[];
  int get fileTime => _fileTime;
  set fileTime(int fileTime) {
    var d = DateTime.fromMillisecondsSinceEpoch(fileTime);
    group = DateFormat("yyyy-MM-dd").format(d);
    _fileTime = fileTime;
  }
}

class FavoriteMgr {
  FavoriteMgr._();
  static FavoriteMgr? _instance;
  static FavoriteMgr get instance {
    _instance ??= FavoriteMgr._();
    return _instance!;
  }

  final _words = <FavoriteGroupItem>[];
  bool _isLoaded = false;

  List<FavoriteGroupItem> get words => _words;

  _init() async {
    dynamic js = await LocalStorageUtils.getJson(LocalStorageKeys.favoriteWords);
    if (js == null || js.length == 0) {
      _addToDayDefault();
      _isLoaded = true;
      return;
    }

    var groupsJs = js;
    for (int i = 0; i < groupsJs.length; ++i) {
      var groupJs = groupsJs[i];
      var wordsJs = groupJs["words"];
      if (wordsJs != null && wordsJs.length > 0) {
        var favoriteGroup = FavoriteGroupItem();
        favoriteGroup.fileTime = groupJs["date"];
        for (var j = 0; j < wordsJs.length; ++j) {
          var wordItemstr = wordsJs[j];
          favoriteGroup.words.add(wordItemstr);
        }
        _words.add(favoriteGroup);
      }
    }

    if (!_hasTodayItem()) {
      _addToDayDefault();
    }
    _isLoaded = true;
  }

  Future<bool> add(String word) async {
    if (!_isLoaded) await _init();

    if (await isWordInFavorite(word)) return false;
    if (!_hasTodayItem()) {
      _addToDayDefault();
    }
    _words[0].words.insert(0, word);
    _save();
    return true;
  }

  Future<bool> isWordInFavorite(String word) async {
    if (!_isLoaded) await _init();
    for (var group in _words) {
      for (var item in group.words) {
        if (item == word) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> delete(String word) async {
    if (!_isLoaded) await _init();
    for (var group in _words) {
      for (var i = 0; i < group.words.length; ++i) {
        var item = group.words[i];
        if (item == word) {
          group.words.removeAt(i);
          _save();
          return true;
        }
      }
    }
    return false;
  }

  Future<List<FavoriteGroupItem>> getAll() async {
    if (!_isLoaded) await _init();
    return _words;
  }

  clear() {
    _words.clear();
    _save();
  }

  _save() {
    var groupsJs = <dynamic>[];
    for (var group in _words) {
      var groupJs = <String, dynamic>{};
      if (group.words.isNotEmpty) {
        groupJs["date"] = group.fileTime;
        var wordsJs = <dynamic>[];
        for (var i = 0; i < group.words.length; ++i) {
          var item = group.words.elementAt(i);
          wordsJs.add(item);
        }
        groupJs["words"] = wordsJs;
        groupsJs.add(groupJs);
      }
    }
    LocalStorageUtils.setJson(LocalStorageKeys.favoriteWords, groupsJs);
  }

  _hasTodayItem() {
    if (_words.isNotEmpty) {
      var tempItem = FavoriteGroupItem();
      tempItem.fileTime = DateTime.now().millisecondsSinceEpoch;
      return _words[0].group == tempItem.group;
    }
    return false;
  }

  _addToDayDefault() {
    var item = FavoriteGroupItem();
    item.fileTime = DateTime.now().millisecondsSinceEpoch;
    _words.insert(0, item);
  }
}
