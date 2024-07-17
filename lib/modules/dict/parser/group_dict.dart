import 'dart:convert';
import 'dart:typed_data';

import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_redirect.dart';
import 'package:sudict/modules/dict/dict_search_result.dart';
import 'package:sudict/modules/dict/dict_word.dart';
import 'package:sudict/modules/dict/parser/i_dict.dart';

class GroupDict implements IDict {
  GroupDict(this.items);

  final List<DictItem> items;
  int index = 0;

  @override
  bool get isLoaded {
    for (DictItem item in items) {
      if (!item.isLoaded) return false;
    }
    return true;
  }

  @override
  Future<void> load() async {
    for (DictItem item in items) {
      item.load();
    }
  }

  @override
  Future<Uint8List?> loadResource(String resourceKey) {
    return items[index].loadResource(resourceKey);
  }

  @override
  Future<String?> loadWord(DictWord word, DictRedirectResult? redirectResult) {
    return items[index].loadWord(word, redirectResult);
  }

  @override
  Future<void> release() async {
    for (DictItem item in items) {
      await item.release();
    }
  }

  @override
  Future<DictSearchResult> search(String str, {bool isReg = false, int maxCount = 20}) async {
    final ret = DictSearchResult();
    for (DictItem item in items) {
      if (!item.visible) continue;
      final itemResult = await item.search(str, isReg: isReg, maxCount: 1);
      if (!(itemResult.errorMsg?.isNotEmpty == true) &&
          itemResult.firstTrueWord?.isNotEmpty == true) {
        itemResult.dict = item;
        ret.groupResult.add(itemResult);
      }
    }
    if (ret.groupResult.isEmpty) {
      ret.errorMsg = DictSearchResultError.notFound;
    } else {
      // first one
      final firstOne = ret.groupResult[0];

      ret.firstTrueWord = firstOne.firstTrueWord;
      ret.redirectResult = firstOne.redirectResult;
      ret.words.addAll(firstOne.words);
    }
    // 每次搜寻之后，都重置
    index = items.indexWhere((di) => di.visible);
    return ret;
  }

  @override
  String get title => "";

  @override
  int get wordCount => 1000;

  @override
  Future<String> getCatalog() async {
    // todo:
    // other dict ....
    if (items[index].type == DictType.fishdict) {
      final binData = await loadResource('assets/catalog.html');
      if (binData == null) return '';
      return utf8.decode(binData);
    }
    return '';
  }

  void setGroupCurrentIndexById(String id) {
    index = items.indexWhere((element) => element.id == id);
  }
}
