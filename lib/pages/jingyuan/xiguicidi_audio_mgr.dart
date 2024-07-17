import 'dart:async';
import 'dart:math';

import 'package:sudict/modules/http/misc.dart';
import 'package:sudict/modules/utils/local_storage.dart';

class PlayItem {
  PlayItem({required this.name, required this.url, required this.length});

  String name;
  String url;
  int length;
}

class CatalogItem {
  CatalogItem(this.name, this.begin, this.end, this._catalogIndex);
  final String name;
  final int begin;
  final int end;
  int _currPlayIndex = 0;
  final int _catalogIndex;

  Future<void> init() async {
    _currPlayIndex = await LocalStorageUtils.getInt(_currPlayIndexCfgKey) ?? 0;
    if (_currPlayIndex >= length) _currPlayIndex = 0;
  }

  String get _currPlayIndexCfgKey =>
      '${LocalStorageKeys.jingyuanAudioCatalogCurrPlayIndexPre}_$_catalogIndex';

  int get length => end - begin + 1;
  final _itemsTemp = <int, PlayItem>{};
  PlayItem? getItemAt(int index) {
    if (index < 0 || index >= length) return null;
    var item = _itemsTemp[index];
    if (item != null) return item;

    final allData = XiguicidiAudioMgr.instance._data!;
    final indexInAllData = begin + index - 1;
    final jsonItem = allData['items'][indexInAllData];
    final url = jsonItem['url'] as String;
    final dotIndex = url.lastIndexOf('.');
    final name = url.substring(0, dotIndex);
    final len = jsonItem['len'] as int;
    final baseUrl = allData['urlBase'];

    item = PlayItem(name: name, url: '$baseUrl/$url', length: len);
    _itemsTemp[index] = item;
    return item;
  }

  PlayItem get currItem {
    return getItemAt(_currPlayIndex)!;
  }

  int get currIndex => _currPlayIndex;

  PlayItem next(int direction) {
    _currPlayIndex += direction;
    _currPlayIndex %= length;
    LocalStorageUtils.setInt(_currPlayIndexCfgKey, _currPlayIndex);
    return getItemAt(_currPlayIndex)!;
  }

  PlayItem random() {
    _currPlayIndex = Random().nextInt(length);
    LocalStorageUtils.setInt(_currPlayIndexCfgKey, _currPlayIndex);
    return getItemAt(_currPlayIndex)!;
  }

  void setCurrIndex(int index) {
    if (index < 0 || index >= length) return;
    _currPlayIndex = index;
    LocalStorageUtils.setInt(_currPlayIndexCfgKey, _currPlayIndex);
  }
}

class XiguicidiAudioMgr {
  XiguicidiAudioMgr._();
  static XiguicidiAudioMgr? _instance;
  static XiguicidiAudioMgr get instance {
    _instance ??= XiguicidiAudioMgr._();
    return _instance!;
  }

  /*
   {
      urlBase: 
      items: [
        {
          url: 0001.老法师2019年3月3日重要开示（恭听100天）.mp3
          len: 222015
        }
      ]
   }
   */
  dynamic _data;

  dynamic _catalogData;
  int _currCatalogIndex = -1;

  Future<void> init() async {
    if (_data != null) return;
    _data = await MiscHttpApi.getXiguicidiAudioInfo();
    _catalogData = _data['catalog'];
    _currCatalogIndex =
        await LocalStorageUtils.getInt(LocalStorageKeys.jingyuanAudioCatalogCurrIndex) ?? 0;
  }

  int get currCatalogIndex => _currCatalogIndex;

  int get catalogLength => _catalogData == null ? 0 : _catalogData.length;

  Future<CatalogItem?> get currCatalog async => await getCatalogItemAt(_currCatalogIndex);
  CatalogItem? get currCatalogSync => getCatalogItemAtSync(_currCatalogIndex);

  set currCatalogIndex(int newIndex) {
    _currCatalogIndex = newIndex;
    LocalStorageUtils.setInt(LocalStorageKeys.jingyuanAudioCatalogCurrIndex, _currCatalogIndex);
  }

  final _catalogTemp = <int, CatalogItem>{};
  Future<CatalogItem?> getCatalogItemAt(int index) async {
    var ci = getCatalogItemAtSync(index);
    if (ci == null) return ci;
    await ci.init();
    return ci;
  }

  CatalogItem? getCatalogItemAtSync(int index) {
    if (index < 0 || index >= catalogLength) return null;
    var ci = _catalogTemp[index];
    if (ci != null) return ci;
    final jsonItem = _catalogData[index];

    String rangeItem = jsonItem['range'];
    final rangeArr = rangeItem.split(',');
    ci = CatalogItem(jsonItem['name'], int.tryParse(rangeArr[0].trim()) ?? -1,
        int.tryParse(rangeArr[1].trim()) ?? -1, index);
    _catalogTemp[index] = ci;
    return ci;
  }

  void setCatalog(CatalogItem catalog) {
    final found = _catalogTemp.entries.where((entry) => entry.value == catalog);
    if (found.isNotEmpty) {
      currCatalogIndex = found.first.key;
    }
  }
}
