import 'dart:typed_data';

import 'package:sudict/modules/dict/dict_search_result.dart';
import 'package:sudict/modules/dict/dict_word.dart';
import 'package:sudict/modules/dict/dict_redirect.dart';

// ignore: constant_identifier_names
enum DictLoadStatus { NotLoad, Loading, LoadFailed, Loaded }

abstract class IDict {
  Future<void> load();
  Future<void> release();
  Future<DictSearchResult> search(String str, {bool isReg = false, int maxCount = 20});

  // because it takes so many time and memory to load all words
  // so only load first, others are not loaded.
  // so app interface caller need to load
  Future<String?> loadWord(DictWord word, DictRedirectResult? redirectResult);

  Future<Uint8List?> loadResource(String resourceKey);
  Future<String> getCatalog();

  int get wordCount;
  String get title;
  bool get isLoaded;
}
