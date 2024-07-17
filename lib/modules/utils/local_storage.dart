import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageUtils {
  LocalStorageUtils._();

  static Future<bool> setInt(String key, int val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(key, val);
  }

  static Future<bool> setBool(String key, bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(key, val);
  }

  static Future<bool> setDouble(String key, double val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setDouble(key, val);
  }

  static Future<bool> setString(String key, String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, val);
  }

  static Future<bool> setStringList(String key, List<String> val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(key, val);
  }

  static Future<bool> remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  static setJson(String key, dynamic jsonObj) async {
    return await setString(key, jsonEncode(jsonObj));
  }

  static Future<int?> getInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<bool?> getBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<double?> getDouble(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<String?> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static getStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  static Future<dynamic> getJson(String key) async {
    String? str = await getString(key);
    if (str != null) {
      return jsonDecode(str);
    }
    return null;
  }
}

class LocalStorageKeys {
  LocalStorageKeys._();

  static const settingFontScale = 'settingFontScale';
  static const settingConvertSimple = 'settingConvertSimple';
  static const settingDictInnerJumpPage = 'settingDictInnerJumpPage';
  static const settingJgwFontScale = 'settingJgwFontScale';
  static const settingHappyDonateTabIndex = 'settingHappyDonateTabIndex';

  static const assetsFileCopyVersionPre = "assetsFileCopyVersionPre";
  static const currentDictGroupIndex = "currentDictGroupIndex";
  static const dictsSetting = 'dictsSetting';
  static const dictGroupInfoPre = "dictGroupInfoPre";
  static const currentDictPre = "currentDictPre";
  static const historyWords = "historyWords";
  static const favoriteWords = "favoriteWords";
  static const lookforWordDictTab = 'lookforWordDictTab';
  static const donotMindVersion = "donotMindVersion";
  static const fjCurrentIndex = "fjCurrentIndex";
  static const sanQianCurrentIndexPre = "sanQianCurrentIndexPre";
  static const sanQianCurrentIndexScrollPosPre = "sanQianCurrentIndexScrollPosPre";

  static const enterAreaDislikeList = 'enterAreaDislikeList';
  static const bookShelfAddedBooks = 'bookShelfAddedBooks';
  static const bookShelfLastReadIndex = 'bookShelfLastReadIndex';

  static const bookCurrScalePre = 'bookCurrScalePre';
  static const bookCurrPagePre = 'bookCurrPagePre';

  static const jgwCurrentItem = 'jgwCurrentItem';
  static const jgwRandomItem = 'jgwRandomItem';

  static const shilvLastInfo = 'shilvLastInfo';
  static const shilvShowPzaj = 'shilvShowPzaj';

  static const jingyuanAuth = 'jingyuanAuth';
  static const jingyuanAudioInfo = 'jingyuanAudioInfo';
  static const jingyuanAudioCatalogCurrIndex = 'jingyuanAudioCatalogCurrIndex';
  static const jingyuanAudioCatalogCurrPlayIndexPre = 'jingyuanAudioCatalogCurrPlayIndexPre';

  static const audioPlayCurrPosPre = 'audioPlayCurrPosPre';
  static const audioPlayModePre = 'audioPlayModePre';
  static const uniqueAudioPlaySpeedPre = 'uniqueAudioPlaySpeedPre';

  static const videoListCurrIndexPre = 'videoListCurrIndexPre';
  static const videoListSpeedPre = 'videoListSpeedPre';
  static const videoPlayCurrPosPre = 'videoPlayCurrPosPre';
  static const videoPlayModePre = 'videoPlayModePre';

  static const diziguiLastTabIndex = 'zidiguiLastTabIndex';
  static const diziguiVoice = 'zidiguiVoice';
  static const diziguiShowZhuyin = 'diziguiShowZhuyin';
  static const diziguiZhuyinIsPinyin = 'diziguiZhuyinIsPinyin';
  static const diziguiAutoScrollSpeed = 'diziguiAutoScrollSpeed';
}
