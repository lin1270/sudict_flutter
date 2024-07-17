import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_redirect.dart';
import 'package:sudict/modules/dict/dict_word.dart';

class DictSearchResultError {
  static const loadedFail = "辭典加載失敗！";
  static const outofRange = "超出辭典範圍[1，MAX]。";
  static const notFound = "未搜尋到結果。";
  static const loading = "辭典加載中，請再試一次。";
}

class DictSearchResult {
  DictSearchResult({this.errorMsg, this.redirectResult, this.dict});
  String? errorMsg; // one of DictSearchResultError
  String? firstTrueWord;
  DictRedirectResult? redirectResult;
  DictItem? dict;
  List<DictWord> words = [];

  // only for group, and others are invalid for group.
  // please tell me a solution if you have a better way to handle both searching.
  List<DictSearchResult> groupResult = [];
}
