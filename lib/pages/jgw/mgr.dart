import 'dart:math';

import 'package:sudict/config/path.dart';
import 'package:sudict/modules/utils/assets.dart';
import 'package:sudict/modules/utils/local_storage.dart';

class JgwPosInfo {
  JgwPosInfo(this.catalogIndex, this.partIndex, this.wordIndex);
  int catalogIndex;
  int partIndex;
  int wordIndex;
}

class JgwMgr {
  JgwMgr._();
  static JgwMgr? _instance;
  static JgwMgr get instance {
    _instance ??= JgwMgr._();
    return _instance!;
  }

  dynamic _data;
  final _currPosInfo = JgwPosInfo(0, 0, 0);
  final _randomPosInfo = JgwPosInfo(-1, -1, -1);

  init() async {
    await AssetsUtils.copyAssets2local('assets/jgw/iconfont.css', '${PathConfig.jgw}/iconfont.css');
    await AssetsUtils.copyAssets2local('assets/jgw/iconfont.ttf', '${PathConfig.jgw}/iconfont.ttf');
  }

  JgwPosInfo get currPosInfo => _currPosInfo;

  loadData() async {
    _data ??= await AssetsUtils.readJsonFile('assets/jgw/words.json');
    final currCfgStr = await LocalStorageUtils.getString(LocalStorageKeys.jgwCurrentItem) ?? '';
    if (currCfgStr.isNotEmpty) {
      final arr = currCfgStr.split(',');
      if (arr.length == 3) {
        _currPosInfo.catalogIndex = int.tryParse(arr[0]) ?? 0;
        _currPosInfo.partIndex = int.tryParse(arr[1]) ?? 0;
        _currPosInfo.wordIndex = int.tryParse(arr[2]) ?? 0;
      }
    }

    final randomCfgStr = await LocalStorageUtils.getString(LocalStorageKeys.jgwRandomItem) ?? '';
    if (randomCfgStr.isNotEmpty) {
      final arr = randomCfgStr.split(',');
      if (arr.length == 3) {
        _randomPosInfo.catalogIndex = int.tryParse(arr[0]) ?? 0;
        _randomPosInfo.partIndex = int.tryParse(arr[1]) ?? 0;
        _randomPosInfo.wordIndex = int.tryParse(arr[2]) ?? 0;
      }
    } else {
      generateRandom();
    }
  }

  dynamic get data {
    return _data;
  }

  dynamic get currCatalog {
    final theData = data;
    return theData[_currPosInfo.catalogIndex];
  }

  dynamic get currPart {
    final catalog = currCatalog;
    return catalog['parts'][_currPosInfo.partIndex];
  }

  dynamic get currWord {
    final part = currPart;
    return part['words'][_currPosInfo.wordIndex];
  }

  dynamic get randomCatalog {
    final theData = data;
    return theData[_randomPosInfo.catalogIndex];
  }

  dynamic get randomPart {
    final catalog = randomCatalog;
    return catalog['parts'][_randomPosInfo.partIndex];
  }

  dynamic get randomWord {
    final part = randomPart;
    return part['words'][_randomPosInfo.wordIndex];
  }

  int get totalCount {
    final theData = data;
    int count = 0;
    for (final c in theData) {
      for (final p in c['parts']) {
        final words = p['words'] as List?;
        count += words?.length ?? 0;
      }
    }
    return count;
  }

  int generateRandom() {
    int pos = Random().nextInt(totalCount);
    final posInfo = getPosInfoByTotalPos(pos);
    if (posInfo == null) return 0;
    setRandomItem(posInfo.catalogIndex, posInfo.partIndex, posInfo.wordIndex);
    return pos;
  }

  JgwPosInfo? getPosInfoByTotalPos(int pos) {
    final theData = data;
    int currPos = 0;
    for (int cIndex = 0; cIndex < theData.length; ++cIndex) {
      final c = theData[cIndex];
      final parts = c['parts'];
      for (int pIndex = 0; pIndex < parts.length; ++pIndex) {
        final p = parts[pIndex];
        final words = p['words'] as List?;
        final temp = currPos + (words?.length ?? 0);
        if (temp > pos) {
          return JgwPosInfo(cIndex, pIndex, pos - currPos);
        }
        currPos = temp;
      }
    }
    return null;
  }

  dynamic getWordInfoByPosInfo(JgwPosInfo info) {
    return data[info.catalogIndex]['parts'][info.partIndex]['words'][info.wordIndex];
  }

  int getTotalPosByPosInfo(JgwPosInfo posInfo) {
    final theData = data;
    int currPos = 0;
    for (int cIndex = 0; cIndex <= posInfo.catalogIndex; ++cIndex) {
      final c = theData[cIndex];
      final parts = c['parts'];
      for (int pIndex = 0; pIndex < parts.length; ++pIndex) {
        final p = parts[pIndex];
        final words = p['words'] as List?;
        if (cIndex == posInfo.catalogIndex && pIndex == posInfo.partIndex) {
          currPos += posInfo.wordIndex;
          return currPos;
        } else {
          currPos += (words?.length ?? 0);
        }
      }
    }
    return currPos;
  }

  int get randomTotalPos {
    return getTotalPosByPosInfo(_randomPosInfo);
  }

  int get currentTotalPos {
    return getTotalPosByPosInfo(_currPosInfo);
  }

  /// @direction: 1, -1
  goNext(int direction) {
    int pos = currentTotalPos;
    pos += direction;
    pos %= totalCount;

    final theData = data;
    int currPos = 0;
    for (int cIndex = 0; cIndex < theData.length; ++cIndex) {
      final c = theData[cIndex];
      final parts = c['parts'];
      for (int pIndex = 0; pIndex < parts.length; ++pIndex) {
        final p = parts[pIndex];
        final words = p['words'] as List?;
        final temp = currPos + (words?.length ?? 0);
        if (temp > pos) {
          setCurrentItem(cIndex, pIndex, pos - currPos);
          break;
        }
        currPos = temp;
      }
    }
  }

  setCurrentItem(int catalogIndex, int partIndex, int wordIndex) {
    _currPosInfo.catalogIndex = catalogIndex;
    _currPosInfo.partIndex = partIndex;
    _currPosInfo.wordIndex = wordIndex;
    LocalStorageUtils.setString(
        LocalStorageKeys.jgwCurrentItem, '$catalogIndex,$partIndex,$wordIndex');
  }

  setRandomItem(int catalogIndex, int partIndex, int wordIndex) {
    _randomPosInfo.catalogIndex = catalogIndex;
    _randomPosInfo.partIndex = partIndex;
    _randomPosInfo.wordIndex = wordIndex;
    LocalStorageUtils.setString(
        LocalStorageKeys.jgwRandomItem, '$catalogIndex,$partIndex,$wordIndex');
  }

  dynamic find(String wordToFind) {
    for (dynamic catalog in data) {
      final parts = catalog['parts'];
      for (dynamic part in parts) {
        final words = part['words'];
        for (final word in words) {
          if (word['word'] == wordToFind) {
            return word;
          }
        }
      }
    }

    return null;
  }
}
