import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:sudict/modules/dict/dict_redirect.dart';
import 'package:sudict/modules/dict/dict_word.dart';
import 'package:sudict/modules/utils/byte_data.dart';

// ignore: constant_identifier_names
const DICT_FISH_ID = "__FISHDICT__";

class CacheFileItem {
  CacheFileItem(this.offset, this.length);

  int offset;
  int length;
}

class KV {
  KV(this.key, this.value);
  String key;
  String value;
}

class LoadThreadParam {
  LoadThreadParam(this.path, this.mainPort);
  String path;
  SendPort mainPort;
}

enum LoadThreadEvent {
  loadFail,
  done,
}

class LoadedData {
  dynamic config;
  dynamic header;
  dynamic index;
  dynamic replace;
  dynamic redirect;
  dynamic second;
}

class LoadThreadEventInfo {
  LoadThreadEventInfo({required this.event, this.param});
  LoadThreadEvent event;
  dynamic param;
}

void loadProc(LoadThreadParam param) async {
  final file = await File(param.path).open();
  final loadedData = LoadedData();

  var header = await _readDictHeader(file: file, loadedData: loadedData);
  var configStr =
      await _readFileStringCore(dictHeaderInfo: header, file: file, filePath: "config.json");
  if (configStr == null) {
    param.mainPort.send(LoadThreadEventInfo(event: LoadThreadEvent.loadFail));
    return;
  }

  // FishDebugUtils.log('config: $configStr');
  var config = jsonDecode(configStr);

  loadedData.config = config;
  await _readIndex(dictHeaderInfo: header, file: file, loadedData: loadedData);
  await _readReplace(dictHeaderInfo: header, file: file, loadedData: loadedData);
  await _readRedirect(dictHeaderInfo: header, file: file, config: config, loadedData: loadedData);
  await _readRedirect(
      dictHeaderInfo: header,
      file: file,
      config: config,
      loadedData: loadedData,
      isRedirect: false);
  await file.close();

  param.mainPort.send(LoadThreadEventInfo(event: LoadThreadEvent.done, param: loadedData));
}

_readDictHeader({
  required RandomAccessFile file,
  required LoadedData loadedData,
}) async {
  var offset = 0;

  var buf = await file.read(DICT_FISH_ID.length);
  if (buf.length != DICT_FISH_ID.length) return;
  final readHeaderStr = utf8.decode(buf);
  if (readHeaderStr != DICT_FISH_ID) return;
  offset += buf.length;

  var lenBuf = await file.read(4);
  if (lenBuf.length != 4) return;
  offset += lenBuf.length;

  var headLen = ByteDataUtils.byteList2int(data: lenBuf);
  var headBuf = await file.read(headLen);
  if (headBuf.length != headLen) return;
  offset += headLen;

  var headStr = utf8.decode(headBuf);
  var headArr = headStr.split("\n");
  var dictHeaderInfo = <String, CacheFileItem>{};
  for (var line in headArr) {
    var kv = line.split(":");
    if (kv.length == 2) {
      var item = CacheFileItem(offset, int.parse(kv[1]));
      dictHeaderInfo[kv[0].toLowerCase()] = item;
      offset += item.length;
    }
  }
  loadedData.header = dictHeaderInfo;

  return dictHeaderInfo;
}

Future<String?> _readFileStringCore(
    {required Map<String, CacheFileItem> dictHeaderInfo,
    required RandomAccessFile file,
    required String filePath,
    int offset = 0,
    int len = 0}) async {
  final bytes = await readFileBytesCore(
      dictHeaderInfo: dictHeaderInfo, file: file, filePath: filePath, offset: offset, len: len);
  if (bytes == null) return null;
  return utf8.decode(bytes);
}

Future<Uint8List?> readFileBytesCore(
    {required Map<String, CacheFileItem> dictHeaderInfo,
    required RandomAccessFile file,
    required String filePath,
    int offset = 0,
    int len = 0}) async {
  var foundInfo = dictHeaderInfo[filePath.toLowerCase()];
  if (foundInfo == null) return null;
  var rOffset = offset;
  var rLen = len;
  if (rLen == 0) rLen = foundInfo.length;
  var fileoffset = rOffset + foundInfo.offset;
  Uint8List? buf;

  if (fileoffset > 0) await file.setPosition(fileoffset);
  buf = await file.read(rLen);

  if (buf.length != rLen) return null;
  return buf;
}

_readIndex({
  required Map<String, CacheFileItem> dictHeaderInfo,
  required RandomAccessFile file,
  required LoadedData loadedData,
}) async {
  var allIndexStr =
      await _readFileStringCore(dictHeaderInfo: dictHeaderInfo, file: file, filePath: "index.data");
  if (allIndexStr == null) return;
  // print('...length:${allIndexStr.length}');

  var retData = <DictWord>[];
  var group = "";
  var offset = 0;
  int begin = 0;
  int end = allIndexStr.length;
  while (begin < end) {
    var len = 0;
    var word = "";

    var pos = allIndexStr.indexOf(':', begin);
    if (pos == -1) break;
    if (pos >= end) break;
    if (allIndexStr[pos + 1] == '\n') {
      group = allIndexStr.substring(begin, pos);
      begin = pos + 2; // :\n
      // not use group yet
      continue;
    }
    word = allIndexStr.substring(begin, pos);
    var wordEndPos = allIndexStr.indexOf('\n', pos + 1);
    if (wordEndPos == -1) wordEndPos = end;
    len = int.parse(allIndexStr.substring(pos + 1, wordEndPos));

    var newItem =
        DictWord(index: retData.length + 1, word: word, offset: offset, length: len, group: group);
    retData.add(newItem);

    begin = wordEndPos + 1;
    offset += len;
  }

  loadedData.index = retData;
}

_readReplace({
  required Map<String, CacheFileItem> dictHeaderInfo,
  required RandomAccessFile file,
  required LoadedData loadedData,
}) async {
  var content = await _readFileStringCore(
      dictHeaderInfo: dictHeaderInfo, file: file, filePath: "assets/replace.txt");
  if (content == null) return;

  var replace = <KV>[];

  int begin = 0;
  while (begin < content.length) {
    final keyPos = content.indexOf(' ', begin);
    if (keyPos == -1) break;
    final key = content.substring(begin, keyPos);
    var valuePos = content.indexOf('\n', keyPos + 1);
    if (valuePos == -1) valuePos = content.length;
    var value = content.substring(keyPos + 1, valuePos);
    begin = valuePos + 1;
    value = value.trim();
    if (value.isNotEmpty) {
      replace.add(KV(key, value));
    }
  }

  loadedData.replace = replace;
}

_readRedirect(
    {required Map<String, CacheFileItem> dictHeaderInfo,
    required RandomAccessFile file,
    required dynamic config,
    required LoadedData loadedData,
    isRedirect = true}) async {
  String? strRedirectfiles = _getConfigCore(config, isRedirect ? "redirect" : "second");
  if (strRedirectfiles?.isNotEmpty == true) {
    var files = strRedirectfiles!.split(",");
    var redirect = <DictRedirect>[];
    for (var item in files) {
      var path = 'assets${item.startsWith("/") ? item.trim() : "/${item.trim()}"}';
      var str =
          await _readFileStringCore(dictHeaderInfo: dictHeaderInfo, file: file, filePath: path);
      redirect.add(DictRedirect(content: str!));
    }

    if (isRedirect) {
      loadedData.redirect = redirect;
    } else {
      loadedData.second = redirect;
    }
  }
}

String? _getConfigCore(dynamic config, String key) {
  if (config == null) return null;
  try {
    return config![key];
  } catch (e) {
    return null;
  }
}
