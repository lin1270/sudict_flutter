import 'package:flutter/services.dart';
import 'package:sudict/modules/dict/parser/group_dict.dart';
import 'package:sudict/modules/dict/parser/i_dict.dart';
import 'package:sudict/modules/dict/dict_redirect.dart';
import 'package:sudict/modules/dict/dict_search_result.dart';
import 'package:sudict/modules/dict/dict_word.dart';
import 'package:sudict/modules/dict/parser/fish_dict/index.dart';
import 'package:sudict/modules/dict/parser/mdict.dart';
import 'package:sudict/modules/dict/parser/web_dict.dart';

class DictType {
  DictType._();
  static const local = 'local'; // first version
  static const fishdict = "fishdict";
  static const mdict = "mdict";
  static const web = "web";
  static const group = "group"; // 分组
}

class DictFrom {
  DictFrom._();

  static const res = "res";
  static const user = "user";
}

class DictItem implements IDict {
  DictItem(this.id, this.name, this.path, this.type, this.from, this.visible, this.bigFont) {
    _createDict();
  }

  static DictItem fromJson(dynamic json) {
    String id = json['id'];
    String name = json['name'];
    String? type = json['type'];
    String path = json['path'];
    String? from = json['from'];
    bool? visible = json['visible'];
    bool? bigFont = json['bigFont'];

    final dict = DictItem(id, name, path, type ?? DictType.fishdict, from ?? DictFrom.res,
        visible ?? true, bigFont ?? false);

    if (type == DictType.group) {
      final cc = json['children'];
      for (final ci in cc) {
        DictItem childItem = DictItem.fromJson(ci);
        dict.children.add(childItem);
      }
    }

    return dict;
  }

  DictItem clone() {
    final cloneItem = DictItem(id, name, path, type, from, visible, bigFont);
    for (DictItem subItem in children) {
      cloneItem.children.add(subItem.clone());
    }
    return cloneItem;
  }

  String id;
  String name;
  String type;
  String path;
  String from;
  final children = <DictItem>[];
  bool visible = true;
  bool bigFont = false;

  late IDict _dictCore;

  IDict get dict => _dictCore;

  // path->dict
  // 同一路徑只允許一個真實辭典
  // ignore: non_constant_identifier_names
  static final _s_dicts = <String, IDict>{};

  toJson() {
    return {
      "id": id,
      "name": name,
      "type": type,
      "path": path,
      "from": from,
      "visible": visible,
      "bigFont": bigFont,
      "children": childrenJson()
    };
  }

  childrenJson() {
    final ret = <dynamic>[];
    for (DictItem item in children) {
      ret.add(item.toJson());
    }
    return ret;
  }

  bool isWeb() {
    return type == DictType.web;
  }

  @override
  Future<void> load() async {
    await _dictCore.load();
    if (isLoaded) {
      if ((type == DictType.fishdict || type == DictType.local) && bigFont == false) {
        bigFont = (_dictCore as FishDict).bigFont;
      }
    }
  }

  @override
  Future<Uint8List?> loadResource(String resourceKey) {
    return _dictCore.loadResource(resourceKey);
  }

  @override
  Future<String?> loadWord(DictWord word, DictRedirectResult? redirectResult) {
    return _dictCore.loadWord(word, redirectResult);
  }

  @override
  Future<DictSearchResult> search(String str, {bool isReg = false, int maxCount = 20}) async {
    await load();
    final ret = await _dictCore.search(str, isReg: isReg, maxCount: maxCount);
    ret.dict = this;
    return ret;
  }

  @override
  String get title => _dictCore.title;

  @override
  int get wordCount => _dictCore.wordCount;

  @override
  bool get isLoaded => _dictCore.isLoaded;

  @override
  Future<void> release() {
    return _dictCore.release();
  }

  @override
  Future<String> getCatalog() {
    return _dictCore.getCatalog();
  }

  _createDict() {
    // 如果已存在，則不需要再創建了
    final existDict = _s_dicts[path];
    if (existDict != null) {
      _dictCore = existDict;
      return;
    }

    if (type == DictType.mdict) {
      _dictCore = MDict(path);
    } else if (type == DictType.web) {
      _dictCore = WebDict(path, name);
    } else if (type == DictType.group) {
      _dictCore = GroupDict(children);
    } else {
      // default is fishdict
      _dictCore = FishDict(path);
    }
  }

  void reload() async {
    await release();
    _createDict();
    await load();
  }

  bool get isGroup => type == DictType.group;

  int get groupCurrentIndex {
    if (!isGroup) return -1;
    GroupDict group = _dictCore as GroupDict;
    return group.index;
  }

  set groupCurrentIndex(int index) {
    if (!isGroup) return;
    GroupDict group = _dictCore as GroupDict;
    group.index = index;
  }

  setGroupCurrentIndexById(String id) {
    if (!isGroup) return;
    GroupDict group = _dictCore as GroupDict;
    group.setGroupCurrentIndexById(id);
  }
}
