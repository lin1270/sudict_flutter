import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:share_handler/share_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sudict/modules/utils/path.dart';
import 'package:sudict/pages/setting/dict/add_user_local_dict_handler.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';

class ShareMgr {
  ShareMgr._();
  static ShareMgr? _instance;
  static ShareMgr get instance {
    _instance ??= ShareMgr._();
    return _instance!;
  }

  SharedMedia? _media;
  final _handler = ShareHandlerPlatform.instance;

  init() async {
    // not support
    if (!Platform.isAndroid && !Platform.isIOS) return;

    _media = await _handler.getInitialSharedMedia();

    _handler.sharedMediaStream.listen((SharedMedia media) {
      _media = media;
      _handleSharedData();
    });

    _handleSharedData();
  }

  _handleSharedData() async {
    if (_media == null) return;
    if (_media!.attachments == null) return;
    if (_media!.attachments!.isEmpty) return;

    final addOk = await AddUserLocalDictHandler.handle(
        _media!.attachments!.map((e) => e!.path).toList(), 0, true);
    if (addOk) {
      FishEventBus.fire(DictSettingChangedEvent(0));
    }
  }

  shareString(String txt) async {
    var tempFilePath = await PathUtils.randomTempFilePathWithDotExt('.txt');
    await File(tempFilePath).writeAsString(txt);
    Timer(const Duration(milliseconds: 100), () {
      Share.shareXFiles([XFile(tempFilePath)]);
    });
  }

  shareFile(String path) async {
    Timer(const Duration(milliseconds: 100), () {
      Share.shareXFiles([XFile(path)]);
    });
  }

  shareStream(Uint8List bytes, String extWithDot) async {
    var tempFilePath = await PathUtils.randomTempFilePathWithDotExt(extWithDot);
    await File(tempFilePath).writeAsBytes(bytes);
    Timer(const Duration(milliseconds: 100), () {
      Share.shareXFiles([XFile(tempFilePath)]);
    });
  }

  shareUrl(String url) {
    Share.shareUri(Uri.parse(url));
  }
}
