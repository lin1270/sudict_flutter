import 'package:sudict/modules/utils/local_storage.dart';

enum BookFrom { online, local }

class BookItem {
  BookItem(
      {required this.name,
      required this.path,
      required this.from,
      this.count = 0,
      this.url = "",
      this.lastReadIndex = -1});
  static BookItem fromJson(dynamic json) {
    return BookItem(
        name: json['name'],
        path: json['path'],
        from: BookFrom.values[json['from']],
        count: json['count'],
        url: json['url'],
        lastReadIndex: json['lastReadIndex']);
  }

  toJson() {
    return {
      "name": name,
      "path": path,
      "from": from.index,
      "count": count,
      "url": url,
      "lastReadIndex": lastReadIndex
    };
  }

  String name;
  String path;
  int count; // for online
  String url; // for online
  int lastReadIndex = -1;
  BookFrom from;
}

class BookMgr {
  BookMgr._();
  static BookMgr? _instance;
  static BookMgr get instance {
    _instance ??= BookMgr._();
    return _instance!;
  }

  final _data = <BookItem>[];
  bool _isLoaded = false;

  int _lastIndex = -1;

  int get lastIndex => _lastIndex;
  set lastIndex(int index) {
    _lastIndex = index;
    saveCfg();
  }

  init() async {
    return await _readCfg();
  }

  List<BookItem> get books => _data;

  addItem(String name, String path, BookFrom from, {int count = 0, String url = ""}) {
    if (isItemExist(path.isEmpty ? url : path)) return;
    _data.add(BookItem(name: name, path: path, from: from, count: count, url: url));
    saveCfg();
  }

  bool isItemExist(String path) {
    return _data.any((e) => e.path == path || e.url == path);
  }

  removeItem(String path) {
    _data.removeWhere((e) => e.path == path || e.url == path);
    saveCfg();
  }

  _readCfg() async {
    if (_isLoaded) return;
    final json = await LocalStorageUtils.getJson(LocalStorageKeys.bookShelfAddedBooks);
    if (json != null) {
      for (var i = 0; i < json.length; ++i) {
        _data.add(BookItem.fromJson(json[i]));
      }
    }
    _lastIndex = await LocalStorageUtils.getInt(LocalStorageKeys.bookShelfLastReadIndex) ?? -1;
    _isLoaded = true;
  }

  saveCfg() {
    final json = [];
    for (final item in _data) {
      json.add(item.toJson());
    }
    LocalStorageUtils.setJson(LocalStorageKeys.bookShelfAddedBooks, json);
    LocalStorageUtils.setInt(LocalStorageKeys.bookShelfLastReadIndex, _lastIndex);
  }
}
