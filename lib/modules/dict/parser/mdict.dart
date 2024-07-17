import 'dart:typed_data';

import 'package:mdict_flutter_plugin/mdict_flutter_plugin.dart';
import 'package:sudict/modules/dict/dict_redirect.dart';
import 'package:sudict/modules/dict/dict_search_result.dart';
import 'package:sudict/modules/dict/dict_word.dart';
import 'package:sudict/modules/dict/parser/i_dict.dart';

class MDict implements IDict {
  MDict(this.path);

  String path;
  String _title = "";
  int _count = 0;
  final _mdictFlutterPlugin = MdictFlutterPlugin();

  DictLoadStatus _loadStatus = DictLoadStatus.NotLoad;

  @override
  Future<void> load() async {
    if (_loadStatus != DictLoadStatus.NotLoad) return;
    _loadStatus = DictLoadStatus.Loading;
    _title = await _mdictFlutterPlugin.getNameMdict(path) ?? '';
    _count = await _mdictFlutterPlugin.getSizeMdict(path) ?? 0;
    _loadStatus = _count > 0 ? DictLoadStatus.Loaded : DictLoadStatus.LoadFailed;
  }

  @override
  Future<Uint8List?> loadResource(String resourceKey) async {
    if (_loadStatus != DictLoadStatus.Loaded) return null;
    if (!resourceKey.startsWith(RegExp(r'[\/\\]'))) {
      resourceKey = '\\$resourceKey';
    }
    resourceKey = resourceKey.replaceAll('/', '\\');
    return await _mdictFlutterPlugin.getResourceMdict(path, resourceKey);
  }

  @override
  Future<String?> loadWord(DictWord word, DictRedirectResult? redirectResult) async {
    if (_loadStatus != DictLoadStatus.Loaded) return null;
    return word.content;
  }

  @override
  Future<DictSearchResult> search(String str, {bool isReg = false, int maxCount = 20}) async {
    if (_loadStatus == DictLoadStatus.LoadFailed) {
      return DictSearchResult(errorMsg: DictSearchResultError.loadedFail);
    }
    if (_loadStatus == DictLoadStatus.Loading) {
      return DictSearchResult(errorMsg: DictSearchResultError.loading);
    }
    if (_loadStatus == DictLoadStatus.NotLoad) {
      return DictSearchResult(errorMsg: DictSearchResultError.loading);
    }

    int? searchIndex = int.tryParse(str);

    if (searchIndex != null && (searchIndex <= 0 || searchIndex > wordCount)) {
      return DictSearchResult(
          errorMsg: DictSearchResultError.outofRange.replaceAll("MAX", wordCount.toString()));
    }

    String? content = await _mdictFlutterPlugin.lookforMdict(path, str);
    DictSearchResult r = DictSearchResult();
    if (content?.isNotEmpty == true) {
      r.firstTrueWord = str;
      r.words.add(DictWord(word: str, content: content));
    } else {
      r.errorMsg = DictSearchResultError.notFound;
    }
    return r;
  }

  @override
  String get title => _title;

  @override
  int get wordCount => _count;

  @override
  Future<void> release() async {
    await _mdictFlutterPlugin.releaseMdict(path);
    _loadStatus = DictLoadStatus.NotLoad;
  }

  @override
  bool get isLoaded => _loadStatus == DictLoadStatus.Loaded;

  @override
  Future<String> getCatalog() async {
    return '';
  }
}
