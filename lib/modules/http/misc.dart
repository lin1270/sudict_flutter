import 'package:sudict/modules/http/index.dart';
import 'package:sudict/modules/utils/local_storage.dart';

class MiscHttpApi {
  MiscHttpApi._();

  static Future<dynamic> getOnlineStudyResource() async {
    return await HttpUtils.request(url: 'http://www.maiyuren.com/config/study-res.json');
  }

  static Future<dynamic> getNetDicts() async {
    return await HttpUtils.request(
        url: 'http://www.maiyuren.com/config/sudict_flutter/net_dict.json');
  }

  static Future<dynamic> getUpdateVersion() async {
    return await HttpUtils.request(
        url: 'http://www.maiyuren.com/config/sudict_flutter/version.json');
  }

  static Future<dynamic> getBooks() async {
    return await HttpUtils.request(
        url: 'http://www.maiyuren.com/static/sudic/bookstore/index.json');
  }

  static Future<dynamic> getEnterAreaInfo() async {
    return await HttpUtils.request(url: 'http://www.maiyuren.com/config/enter_area/index.json');
  }

  static Future<dynamic> getXiguicidiAudioInfo() async {
    var localData = await LocalStorageUtils.getJson(LocalStorageKeys.jingyuanAudioInfo);
    if (localData == null) {
      localData =
          await HttpUtils.request(url: 'http://www.maiyuren.com/static/more/jingyuan/index.json');
      await LocalStorageUtils.setJson(LocalStorageKeys.jingyuanAudioInfo, localData);
    }

    return localData;
  }
}
