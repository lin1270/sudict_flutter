import 'dart:typed_data';

import 'package:sudict/modules/dict/dict_redirect.dart';
import 'package:sudict/modules/dict/dict_search_result.dart';
import 'package:sudict/modules/dict/dict_word.dart';
import 'package:sudict/modules/dict/parser/i_dict.dart';

class WebDict implements IDict {
  WebDict(this.url, this.name);

  String url;
  String name;

  @override
  Future<void> load() async {}

  @override
  Future<Uint8List?> loadResource(String resourceKey) async {
    return null;
  }

  @override
  Future<String?> loadWord(DictWord word, DictRedirectResult? redirectResult) async {
    return null;
  }

  @override
  Future<DictSearchResult> search(String str, {bool isReg = false, int maxCount = 20}) async {
    var r = DictSearchResult();

    r.words.add(DictWord(
        index: 0, word: str, content: url.replaceAll("\${word}", str), offset: 0, length: 0));
    r.firstTrueWord = str;

    return r;
  }

  @override
  String get title => name;

  @override
  int get wordCount => 1000;

  @override
  bool get isLoaded => true;

  @override
  Future<void> release() async {}

  @override
  Future<String> getCatalog() async {
    return '';
  }
}
