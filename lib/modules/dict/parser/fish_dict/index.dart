import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:sudict/modules/dict/dict_search_result.dart';
import 'package:sudict/modules/dict/dict_word.dart';
import 'package:sudict/modules/dict/parser/i_dict.dart';
import 'package:sudict/modules/dict/parser/fish_dict/dict_load_handler.dart';
import 'package:sudict/modules/dict/dict_redirect.dart';
import 'package:sudict/modules/utils/assets.dart';
import 'package:sudict/modules/utils/debug.dart';
import 'package:sudict/modules/utils/zip.dart';
import 'package:synchronized/synchronized.dart';

class FishDict implements IDict {
  FishDict(this.path);

  String path;

  bool bigFont = false;
  int _hasJs = -1;
  int _hasCss = -1;
  Map<String, CacheFileItem>? _dictHeaderInfo;

  RandomAccessFile? _file; // todo: how to close
  dynamic _config;
  List<DictWord>? _index;
  List<KV>? _replace;
  List<DictRedirect>? _redirect;
  List<DictRedirect>? _second;
  var _loadStatus = DictLoadStatus.NotLoad;
  final _lock = Lock();

  @override
  Future<void> load() async {
    return await _loadCore();
  }

  @override
  Future<void> release() async {
    await _file?.close();
  }

  @override
  Future<Uint8List?> loadResource(String resourceKey) async {
    return await readFileBytes(filePath: resourceKey);
  }

  @override
  Future<String?> loadWord(DictWord word, DictRedirectResult? redirectResult) async {
    return await loadWordContent(word, redirectResult);
  }

  @override
  String get title => getConfig("title") ?? '';

  @override
  int get wordCount => _index?.length ?? 0;

  @override
  bool get isLoaded => _loadStatus == DictLoadStatus.Loaded;

  @override
  Future<String> getCatalog() async {
    final binData = await loadResource('assets/catalog.html');
    if (binData == null) return '';
    return utf8.decode(binData);
  }

  // 文字，或正則
  @override
  Future<DictSearchResult> search(String wordOrReg, {bool isReg = false, int maxCount = 20}) async {
    // index
    if (!isReg) {
      var tempIndex = int.tryParse(wordOrReg);
      if (tempIndex != null && tempIndex >= 0) {
        return await searchIndex(tempIndex);
      }

      // search string
      return searchString(word2search: wordOrReg, maxCount: maxCount);
    }

    return searchReg(reg: RegExp(wordOrReg), maxCount: maxCount);
  }

  Future<bool> hasCss() async {
    if (_hasCss == -1) {
      _hasCss = await readFileBytes(filePath: "assets/index.css") != null ? 1 : 0;
    }
    return _hasCss > 0;
  }

  Future<bool> hasJs() async {
    if (_hasJs == -1) {
      _hasJs = await readFileBytes(filePath: "assets/index.js") != null ? 1 : 0;
    }
    return _hasJs > 0;
  }

  readFileBytes({required String filePath, int offset = 0, int len = 0}) async {
    Uint8List? data;
    await _lock.synchronized(() async {
      data = await readFileBytesCore(
          dictHeaderInfo: _dictHeaderInfo!,
          file: _file!,
          filePath: filePath,
          offset: offset,
          len: len);
    });
    return data;
  }

  Future<String?> loadWordContent(DictWord r, DictRedirectResult? redirectResult) async {
    DictSearchResult? checkResult = checkLoaded();
    if (checkResult != null) return checkResult.errorMsg;
    await _loadWordContentInner(r);
    if (r.content == null) return null;
    if (redirectResult != null) return "${redirectResult.template}<br>${r.content!}";
    return r.content;
  }

  _loadWordContentInner(DictWord r) async {
    if (r.content?.isNotEmpty == true) return;

    var buf = await readFileBytes(filePath: "content.data", offset: r.offset, len: r.length);
    if (buf == null) return;

    // unzip
    var temp = ZipUtils.unzipUtf8Buffer(buf);

    // replace
    temp = replaceContent(temp);

    if (await hasCss()) {
      temp = "\n<link href=\"assets/index.css\" rel=\"stylesheet\">$temp";
    }
    if (await hasJs()) temp = "$temp\n<script src=\"assets/index.js\"></script>";

    r.content = temp;
  }

  String replaceContent(String str) {
    if (_replace == null || _replace!.isEmpty) return str;
    var i = _replace!.length - 1;
    var r = str;
    while (i >= 0) {
      var item = _replace![i];
      r = r.replaceAll(item.key, item.value);
      --i;
    }
    return r;
  }

  DictSearchResult? checkLoaded() {
    if (_loadStatus == DictLoadStatus.LoadFailed) {
      return DictSearchResult(errorMsg: DictSearchResultError.loadedFail);
    }
    if (_loadStatus == DictLoadStatus.NotLoad || _loadStatus == DictLoadStatus.Loading) {
      return DictSearchResult(errorMsg: DictSearchResultError.loading);
    }
    return null;
  }

  Future<DictSearchResult> searchIndex(int index) async {
    var errResult = checkLoaded();
    if (errResult != null) return errResult;
    if (index <= 0 || index > _index!.length) {
      return DictSearchResult(
          errorMsg: DictSearchResultError.outofRange.replaceAll("MAX", _index!.length.toString()));
    }
    var wordItem = DictWord.copy(_index![index - 1]);
    wordItem.word = "$index";
    var r = DictSearchResult();
    r.words.add(wordItem);
    r.firstTrueWord = wordItem.word;
    return r;
  }

  DictRedirectResult? getRedirectWord(String word, {isRedirect = true}) {
    final data = isRedirect ? _redirect : _second;
    if (data == null || data.isEmpty) return null;
    for (var i = 0; i < data.length; ++i) {
      var ri = data[i];
      var riResult = ri.search(word);
      if (riResult != null) return riResult;
    }

    return null;
  }

  DictSearchResult searchString({required String word2search, int maxCount = 20}) {
    var errResult = checkLoaded();
    if (errResult != null) return errResult;
    // redirect
    var redirectInfo = getRedirectWord(word2search);

    var trueWordForsearch = (redirectInfo == null) ? word2search : redirectInfo.to;

    var r = DictSearchResult(redirectResult: redirectInfo);
    for (int i = 0; i < _index!.length && r.words.length < maxCount; ++i) {
      var item = _index![i];
      if (item.word == trueWordForsearch) {
        r.words.add(item);
      }
    }

    for (int i = 0; i < _index!.length && r.words.length < maxCount; ++i) {
      var item = _index![i];
      if (item.word.startsWith(trueWordForsearch)) {
        r.words.add(item);
      }
    }

    for (int i = 0; i < _index!.length && r.words.length < maxCount; ++i) {
      var item = _index![i];
      if (trueWordForsearch.startsWith(item.word)) {
        r.words.add(item);
      }
    }

    if (redirectInfo != null) {
      r.redirectResult = redirectInfo;
    }

    // 先查正體字，如果查不到，
    // 或者second字是完全相等，就使用second的字
    var secondRedirectInfo = getRedirectWord(word2search, isRedirect: false);
    if (secondRedirectInfo != null && (secondRedirectInfo.from == word2search || r.words.isEmpty)) {
      return searchString(word2search: secondRedirectInfo.to, maxCount: maxCount);
    }

    if (r.words.isEmpty) {
      r.errorMsg = DictSearchResultError.notFound;
    } else {
      if (r.redirectResult != null) {
        r.firstTrueWord = r.redirectResult!.from;
      } else {
        r.firstTrueWord = r.words[0].word;
      }
    }

    return r;
  }

  DictSearchResult searchReg({required RegExp reg, int maxCount = 20}) {
    var errResult = checkLoaded();
    if (errResult != null) return errResult;

    var r = DictSearchResult();
    for (int i = 0; i < _index!.length; ++i) {
      var item = _index![i];
      if (reg.hasMatch(item.word)) {
        r.words.add(item);
        if (r.words.length >= maxCount) break;
      }
    }

    if (r.words.isEmpty) {
      r.errorMsg = DictSearchResultError.notFound;
    } else {
      r.firstTrueWord = r.words[0].word;
    }

    return r;
  }

  _loadCore() async {
    if (_loadStatus != DictLoadStatus.NotLoad) return;
    _loadStatus = DictLoadStatus.Loading;

    final mainPort = ReceivePort();
    String localPath = await AssetsUtils.copyAssets2local(path, path);

    final thread = await Isolate.spawn(loadProc, LoadThreadParam(localPath, mainPort.sendPort));

    LoadThreadEventInfo info = await mainPort.first;
    if (info.event == LoadThreadEvent.loadFail) {
      _loadStatus = DictLoadStatus.LoadFailed;
    } else if (info.event == LoadThreadEvent.done) {
      _file ??= await AssetsUtils.openFile(path);
      LoadedData loadedData = info.param;
      _config = loadedData.config;
      bigFont = getConfig('big_font') == 'true';
      _dictHeaderInfo = loadedData.header;
      _index = loadedData.index;
      _redirect = loadedData.redirect;
      _second = loadedData.second;
      _replace = loadedData.replace;

      _loadStatus = DictLoadStatus.Loaded;
      FishDebugUtils.log('dict $title count:${_index!.length}');
    }

    thread.kill();
  }

  String? getConfig(String key) {
    if (_config == null) return null;
    try {
      return _config![key];
    } catch (e) {
      return null;
    }
  }
}
