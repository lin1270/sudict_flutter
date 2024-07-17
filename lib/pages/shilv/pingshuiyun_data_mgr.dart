import 'package:flutter/material.dart';
import 'package:sudict/modules/utils/assets.dart';

class PingshuiyunCatalogGroup {
  PingshuiyunCatalogGroup(this.name);
  String name;
  final items = <PingshuiyunCatalog>[];
}

class PingshuiyunCatalog {
  PingshuiyunCatalog(this.name, this.fullName);
  String name;
  String fullName;
  final items = <String>[];
}

class PingshuiyunDataMgr {
  PingshuiyunDataMgr._();
  static PingshuiyunDataMgr? _instance;
  static PingshuiyunDataMgr get instance {
    _instance ??= PingshuiyunDataMgr._();
    return _instance!;
  }

  final _data = <PingshuiyunCatalogGroup>[];

  List<PingshuiyunCatalogGroup> get data => _data;

  init() async {
    if (_data.isNotEmpty) return;

    final assetsData = await AssetsUtils.readJsonFile('assets/shilv/pingshuiyun.json');
    for (final group in assetsData) {
      String title = group['title'];
      String name = title.substring(0, 2);
      String head = group['head'];
      String content = group['content'];
      final catalog = PingshuiyunCatalog(head, title);
      catalog.items.addAll(content.characters);

      var cg = _data.firstWhere((di) {
        return di.name == name;
      }, orElse: () {
        final newGroup = PingshuiyunCatalogGroup(name);
        _data.add(newGroup);
        return newGroup;
      });
      cg.items.add(catalog);
    }
  }

  List<PingshuiyunCatalog> find(String word) {
    final ret = <PingshuiyunCatalog>[];
    for (final di in _data) {
      for (final dii in di.items) {
        if (dii.items.contains(word)) {
          ret.add(dii);
        }
      }
    }
    return ret;
  }
}
