import 'package:just_audio/just_audio.dart';
import 'package:sudict/modules/audio/audio_player.dart';
import 'package:sudict/modules/audio/common.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/ui.dart';

typedef OnUniqueAudioPlayCallback = Function(
    String url, AudioVideoPlayStatus status, int pos, String? errorMsg);

class _Item {
  final player = FishAudioPlayer();
  String url = '';
  final List<OnUniqueAudioPlayCallback> callbacks = [];
}

class UniqueAudioPlayMgr {
  UniqueAudioPlayMgr._();
  static UniqueAudioPlayMgr? _instance;
  static UniqueAudioPlayMgr get instance {
    _instance ??= UniqueAudioPlayMgr._();
    return _instance!;
  }

  final _data = <AudioVideoPlayCatalog, _Item>{};

  Future<void> playOrPause(AudioVideoPlayCatalog type, String url) async {
    final item = await _getItem(type);
    if (item == null) return;
    if (url != item.url) {
      if (item.player.playing) {
        await item.player.stop();
      }
      item.url = url;
      await item.player.setUrl(url);
      item.player.play();
    } else {
      if (item.player.playing) {
        item.player.pause();
      } else {
        item.player.play();
      }
    }
  }

  Future<bool> play(AudioVideoPlayCatalog type, String url) async {
    final item = await _getItem(type);
    try {
      if (item!.url != url) {
        if (item.player.playing) {
          await item.player.stop();
        }
        item.url = url;
        await item.player.setUrl(url);
      }

      if (item.player.playerState.processingState == ProcessingState.completed) {
        item.player.seek(Duration.zero);
      }

      item.player.play();

      return true;
    } catch (e) {
      // do nothing
    }
    return false;
  }

  Future<bool> stop(AudioVideoPlayCatalog type) async {
    final item = await _getItem(type);
    try {
      if (item!.player.playing) {
        item.player.pause();
      }

      return true;
    } catch (e) {
      // do nothing
    }
    return false;
  }

  AudioVideoPlayStatus _getPlayStatusByPlayer(FishAudioPlayer player) {
    var status = AudioVideoPlayStatus.playing;
    if (player.playing) {
      var durationMs = (player.duration?.inMilliseconds ?? ~0);
      if (player.playerState.processingState == ProcessingState.completed &&
          player.position.inMilliseconds >= durationMs) {
        status = AudioVideoPlayStatus.completed;
      }
    } else {
      status = AudioVideoPlayStatus.paused;
    }
    return status;
  }

  Future<_Item?> _getItem(AudioVideoPlayCatalog type, {createIfNotExist = true}) async {
    var item = _data[type];
    if (item == null && createIfNotExist) {
      item = _Item();
      _data[type] = item;
      item.player.positionStream.listen(
        (event) {
          var status = _getPlayStatusByPlayer(item!.player);
          _call(type, item.url, status, item.player.position.inMilliseconds, null);
        },
        onDone: () {
          _call(type, item!.url, AudioVideoPlayStatus.completed,
              item.player.position.inMilliseconds, null);
        },
      );
      item.player.playerStateStream.listen((event) {
        var status = _getPlayStatusByPlayer(item!.player);
        _call(type, item.url, status, item.player.position.inMilliseconds, null);
      }, onError: (Object e, StackTrace st) {
        UiUtils.toast(content: '網路異常或播放設備出現問題');
        _call(type, item!.url, AudioVideoPlayStatus.failed, item.player.position.inMilliseconds,
            e.toString());
      });
      // read speed
      item.player.setSpeed(await LocalStorageUtils.getDouble(
              '${LocalStorageKeys.uniqueAudioPlaySpeedPre}_${type.index}') ??
          1.0);
    }
    return item;
  }

  _call(AudioVideoPlayCatalog type, String url, AudioVideoPlayStatus status, int pos,
      String? errorMsg) async {
    final item = await _getItem(type);
    for (final cb in item!.callbacks) {
      cb(url, status, pos, errorMsg);
    }
  }

  void onEvent(AudioVideoPlayCatalog type, OnUniqueAudioPlayCallback cb) async {
    final item = await _getItem(type);
    item!.callbacks.add(cb);
  }

  void offEvent(AudioVideoPlayCatalog type, OnUniqueAudioPlayCallback cb) {
    _data[type]?.callbacks.remove(cb);
  }

  void clearEvent(AudioVideoPlayCatalog type) {
    _data.remove(type);
  }

  void setSpeed(AudioVideoPlayCatalog type, double speed) async {
    final item = await _getItem(type);
    item!.player.setSpeed(speed);
    LocalStorageUtils.setDouble('${LocalStorageKeys.uniqueAudioPlaySpeedPre}_${type.index}', speed);
  }

  Future<double> getSpeed(AudioVideoPlayCatalog type) async {
    final item = await _getItem(type);
    return item!.player.speed;
  }

  Future<void> setPosition(AudioVideoPlayCatalog type, int ms) async {
    final item = await _getItem(type);
    return item!.player.seek(Duration(milliseconds: ms));
  }

  Future<int> load(AudioVideoPlayCatalog type, String url, bool play) async {
    final item = await _getItem(type);
    if (item == null) return -1;
    if (url != item.url) {
      if (item.player.playing) {
        await item.player.stop();
      }

      item.url = url;
      await item.player.setUrl(url);
      final duration = await item.player.load();
      if (play) {
        item.player.play();
      }
      return duration?.inMilliseconds ?? 0;
    }

    return 0;
  }

  Future<int> getLength(AudioVideoPlayCatalog type) async {
    final item = await _getItem(type);
    final duration = await item!.player.durationFuture;
    return duration?.inMilliseconds ?? 0;
  }

  Future<AudioVideoPlayStatus> getPlayStatus(AudioVideoPlayCatalog type) async {
    final item = await _getItem(type);
    return _getPlayStatusByPlayer(item!.player);
  }

  Future<void> setVolume(AudioVideoPlayCatalog type, double volume) async {
    final item = await _getItem(type);
    return await item!.player.setVolume(volume);
  }

  Future<double> getVolume(AudioVideoPlayCatalog type) async {
    final item = await _getItem(type);
    return item!.player.volume;
  }
}
