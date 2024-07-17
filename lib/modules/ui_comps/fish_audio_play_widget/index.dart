import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:sudict/modules/audio/common.dart';
import 'package:sudict/modules/audio/unique_play_mgr.dart';
import 'package:sudict/modules/ui_comps/fish_audio_play_widget/controller.dart';
import 'package:sudict/modules/ui_comps/fish_slider_widget/index.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/ui_comps/fish_audio_play_widget/PlayIconWidget.dart';

class FishAudioPlayWidget extends StatefulWidget {
  const FishAudioPlayWidget(
      {super.key, required this.catalog, required this.controller, this.onPre, this.onNext});

  final AudioVideoPlayCatalog catalog;
  final FishAudioPlayWidgetController controller;
  final Function(bool isRandom)? onPre;
  final Function(bool isRandom)? onNext;

  @override
  State<FishAudioPlayWidget> createState() => _FishAudioPlayWidgetState();
}

class _FishAudioPlayWidgetState extends State<FishAudioPlayWidget>
    with AutomaticKeepAliveClientMixin {
  int _currPlayingPos = 0;
  final _playIconController = PlayIconController();
  int _length = 0;
  var _playMode = AudioVideoPlayMode.seq;

  var _playStatus = AudioVideoPlayStatus.notPlay;
  var _loaded = false;
  var _speed = 1.0;
  final _speedMenuController = CustomPopupMenuController();

  static const _sSpeeds = [0.5, 1.0, 1.5, 2.0, 4.0];

  @override
  void dispose() {
    _playIconController.dispose();
    UniqueAudioPlayMgr.instance.offEvent(widget.catalog, _audioPlayCallback);
    _speedMenuController.dispose();
    UniqueAudioPlayMgr.instance.stop(widget.catalog);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  String get _currPlayPosCfgKey =>
      '${LocalStorageKeys.audioPlayCurrPosPre}_${widget.controller.url}';
  String get _playModeCfgKey => '${LocalStorageKeys.audioPlayModePre}_${widget.catalog}';

  _init() async {
    final playModeIndex = await LocalStorageUtils.getInt(_playModeCfgKey) ?? 0;
    _playMode = AudioVideoPlayMode.values[playModeIndex];

    await _load();
    UniqueAudioPlayMgr.instance.onEvent(widget.catalog, _audioPlayCallback);
    widget.controller.addListener(
      () {
        _load();
      },
    );

    setState(() {});
  }

  _load() async {
    if (widget.controller.url.isEmpty) {
      return;
    }
    _currPlayingPos = await LocalStorageUtils.getInt(_currPlayPosCfgKey) ?? 0;
    _length = await UniqueAudioPlayMgr.instance
        .load(widget.catalog, widget.controller.url, widget.controller.play ?? false);

    // last saved position is end
    // reset to 0
    if (_currPlayingPos >= length) _currPlayingPos = 0;

    UniqueAudioPlayMgr.instance.setPosition(widget.catalog, _currPlayingPos);
    _speed = await UniqueAudioPlayMgr.instance.getSpeed(widget.catalog);
    _loaded = true;
  }

  _audioPlayCallback(String url, AudioVideoPlayStatus status, int pos, String? errorMsg) {
    if (url == widget.controller.url) {
      _playStatus = status;

      if (widget.controller.length != null) {
        final totalLen = widget.controller.length!;
        if (pos <= totalLen) {
          _pos = pos;
        } else {
          _pos = totalLen;
        }
      } else {
        _pos = pos;
      }

      _playStatus == AudioVideoPlayStatus.playing
          ? _playIconController.play()
          : _playIconController.stop();

      if (_playStatus == AudioVideoPlayStatus.completed) {
        // play next
        _onNext();
      }

      setState(() {});
    }
  }

  _onNext({auto = true}) {
    if (auto && _playMode == AudioVideoPlayMode.one) {
      UniqueAudioPlayMgr.instance.play(widget.catalog, widget.controller.url);
    } else {
      if (widget.onNext != null) {
        widget.onNext!(_playMode == AudioVideoPlayMode.random);
      }
    }
  }

  _onPre({auto = true}) {
    if (!auto && widget.onPre != null) {
      widget.onPre!(_playMode == AudioVideoPlayMode.random);
    }
  }

  set _pos(int newPos) {
    _currPlayingPos = newPos;
    // 播放完了，要刪除KEY
    int tempLength = widget.controller.length ?? 0;
    if (_currPlayingPos == 0 || _currPlayingPos >= tempLength) {
      LocalStorageUtils.remove(_currPlayPosCfgKey);
    } else {
      LocalStorageUtils.setInt(_currPlayPosCfgKey, _currPlayingPos);
    }
  }

  String get _name {
    if (widget.controller.name != null) {
      return widget.controller.name!;
    }

    final pos = widget.controller.url.lastIndexOf('/');
    return widget.controller.url.substring(pos + 1);
  }

  int get length {
    if (widget.controller.length != null) return widget.controller.length!;
    return _length;
  }

  String get _currPosStr {
    final min = (_currPlayingPos / 1000 / 60).floor();
    final sec = (_currPlayingPos / 1000).floor() % 60;
    return '${min >= 10 ? '' : '0'}$min:${sec >= 10 ? '' : '0'}$sec';
  }

  String get _currLenStr {
    final min = (length / 1000 / 60).floor();
    final sec = (length / 1000).floor() % 60;
    return '${min >= 10 ? '' : '0'}$min:${sec >= 10 ? '' : '0'}$sec';
  }

  Widget _buildSpeedMenu() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
            color: const Color(0xFF4C4C4C),
            constraints: const BoxConstraints(minWidth: 80),
            child: IntrinsicWidth(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _sSpeeds
                  .map(
                    (item) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _speed = item;
                        });
                        UniqueAudioPlayMgr.instance.setSpeed(widget.catalog, item);
                        _speedMenuController.hideMenu();
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  '${item}X',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ))));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return !_loaded
        ? Container()
        : Column(
            children: [
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(20),
                child: PlayIconWidget(controller: _playIconController),
              )),
              Text(
                _name,
                textAlign: TextAlign.center,
                style: const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 20),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FishInkwell(
                          onTap: () {
                            var newPos = _currPlayingPos - 5000;
                            if (newPos < 0) newPos = 0;
                            UniqueAudioPlayMgr.instance.setPosition(widget.catalog, newPos);
                          },
                          child: Container(
                              padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.black26)),
                              child: const Text('<5s')),
                        ),
                        Expanded(child: Container()),
                        FishInkwell(
                          onTap: () {
                            var newPos = _currPlayingPos + 5000;
                            if (newPos > length) newPos = length;
                            UniqueAudioPlayMgr.instance.setPosition(widget.catalog, newPos);
                          },
                          child: Container(
                              padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.black26)),
                              child: const Text('5s>')),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    FishSliderWidget(
                      value: _currPlayingPos.toDouble(),
                      max: length.toDouble(),
                      onChanged: (value) {
                        if (value.toInt() != _currPlayingPos) {
                          _pos = value.toInt();
                          UniqueAudioPlayMgr.instance.setPosition(widget.catalog, _currPlayingPos);
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_currPosStr),
                        Text(_currLenStr),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        _playMode = AudioVideoPlayMode
                            .values[(_playMode.index + 1) % AudioVideoPlayMode.values.length];
                        LocalStorageUtils.setInt(_playModeCfgKey, _playMode.index);
                        setState(() {});
                      },
                      icon: Icon(_playMode.icon)),
                  IconButton(
                      onPressed: () {
                        _onPre(auto: false);
                      },
                      icon: const Icon(Icons.skip_previous)),
                  IconButton(
                      onPressed: () {
                        if (_playStatus == AudioVideoPlayStatus.playing) {
                          UniqueAudioPlayMgr.instance.stop(widget.catalog);
                        } else {
                          UniqueAudioPlayMgr.instance.play(widget.catalog, widget.controller.url);
                        }
                      },
                      icon: Icon(
                        _playStatus == AudioVideoPlayStatus.playing
                            ? Icons.pause_circle_filled_outlined
                            : Icons.play_circle_fill_outlined,
                        size: 70,
                      )),
                  IconButton(
                      onPressed: () {
                        _onNext(auto: false);
                      },
                      icon: const Icon(Icons.skip_next)),
                  CustomPopupMenu(
                    menuBuilder: _buildSpeedMenu,
                    controller: _speedMenuController,
                    pressType: PressType.singleClick,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${_speed}X',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  )
                ],
              )
            ],
          );
  }

  @override
  bool get wantKeepAlive => true;
}
