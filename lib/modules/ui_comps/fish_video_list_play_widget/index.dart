import 'dart:math';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/audio/common.dart';
import 'package:sudict/modules/ui_comps/fish_slider_widget/index.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:video_player/video_player.dart';

class FishVideoPlayWidget extends StatefulWidget {
  const FishVideoPlayWidget(
      {super.key,
      required this.catalog,
      required this.baseUrl,
      required this.count,
      this.ext = '.mp4',
      this.aspectRatio = 1.0});

  final AudioVideoPlayCatalog catalog;
  final String baseUrl;
  final int count;
  final String ext;
  final double aspectRatio;

  @override
  State<FishVideoPlayWidget> createState() => _FishVideoPlayWidgetState();
}

class _FishVideoPlayWidgetState extends State<FishVideoPlayWidget>
    with AutomaticKeepAliveClientMixin {
  int _currPlayingPos = 0;
  int _length = 0;
  var _playMode = AudioVideoPlayMode.seq;
  int _currIndex = 0;

  var _playStatus = AudioVideoPlayStatus.notPlay;
  var _loaded = false;
  var _speed = 1.0;
  final _speedMenuController = CustomPopupMenuController();
  VideoPlayerController? _controller;

  static const _sSpeeds = [0.5, 1.0, 1.5, 2.0, 4.0];

  @override
  void dispose() {
    _speedMenuController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  String get url {
    return '${widget.baseUrl}${widget.baseUrl.endsWith('/') ? '' : '/'}${_currIndex + 1}${widget.ext}';
  }

  String get _currIndexCfgKey => '${LocalStorageKeys.videoListCurrIndexPre}_${widget.baseUrl}';
  String get _currPlayPosCfgKey => '${LocalStorageKeys.videoPlayCurrPosPre}_$url';
  String get _playModeCfgKey => '${LocalStorageKeys.videoPlayModePre}_${widget.catalog}';
  String get _speedCfgKey => '${LocalStorageKeys.videoListSpeedPre}_${widget.catalog}';

  _init() async {
    final playModeIndex = await LocalStorageUtils.getInt(_playModeCfgKey) ?? 0;
    _playMode = AudioVideoPlayMode.values[playModeIndex];
    _currIndex = await LocalStorageUtils.getInt(_currIndexCfgKey) ?? 0;
    // speed
    _speed = await LocalStorageUtils.getDouble(_speedCfgKey) ?? 1.0;
    _load();

    setState(() {});
  }

  _load({play = false}) async {
    int cfgPlayingPos = await LocalStorageUtils.getInt(_currPlayPosCfgKey) ?? 0;

    _controller?.removeListener(_onPlayListenter);
    _controller?.dispose();

    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((value) async {
        _currPlayingPos = cfgPlayingPos;
        _length = _controller!.value.duration.inMilliseconds;
        // last saved position is end
        // reset to 0
        if (_currPlayingPos >= length) _currPlayingPos = 0;

        _controller!.seekTo(Duration(milliseconds: _currPlayingPos));
        _controller!.setPlaybackSpeed(_speed);
        if (play) {
          _controller!.play();
        }
        setState(() {});
      });

    _controller!.addListener(_onPlayListenter);

    _loaded = true;
  }

  _onPlayListenter() {
    var status = AudioVideoPlayStatus.notPlay;
    if (_controller!.value.isCompleted) {
      status = AudioVideoPlayStatus.completed;
    } else if (_controller!.value.isPlaying) {
      status = AudioVideoPlayStatus.playing;
    }
    _onPlayCallback(status, _controller!.value.position.inMilliseconds, null);
  }

  _onPlayCallback(AudioVideoPlayStatus status, int pos, String? errorMsg) {
    _playStatus = status;

    final totalLen = length;
    if (pos <= totalLen) {
      _pos = pos;
    } else {
      _pos = totalLen;
    }

    if (_playStatus == AudioVideoPlayStatus.completed) {
      // play next
      _onNext();
    }

    setState(() {});
  }

  _saveCurrIndex() {
    LocalStorageUtils.setInt(_currIndexCfgKey, _currIndex);
  }

  _onNext({auto = true}) {
    if (auto && _playMode == AudioVideoPlayMode.one) {
      _pos = 0;
      _load(play: true);
    } else {
      if (_playMode == AudioVideoPlayMode.random) {
        _currIndex = Random().nextInt(widget.count);
      } else {
        _currIndex = (_currIndex + 1) % widget.count;
      }

      _saveCurrIndex();
      _load(play: true);
    }
    setState(() {});
  }

  _onPre() {
    if (_playMode == AudioVideoPlayMode.random) {
      _currIndex = Random().nextInt(widget.count);
    } else {
      _currIndex = (_currIndex - 1) % widget.count;
    }
    _saveCurrIndex();
    _load(play: true);
    setState(() {});
  }

  set _pos(int newPos) {
    _currPlayingPos = newPos;
    // 播放完了，要刪除KEY
    if (_currPlayingPos == 0 || _currPlayingPos >= length) {
      LocalStorageUtils.remove(_currPlayPosCfgKey);
    } else {
      LocalStorageUtils.setInt(_currPlayPosCfgKey, _currPlayingPos);
    }
  }

  String get _name {
    final pos = url.lastIndexOf('/');
    return url.substring(pos + 1);
  }

  int get length {
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

  _saveSpeedCfg() {
    LocalStorageUtils.setDouble(_speedCfgKey, _speed);
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
                          if (_controller?.value.isInitialized == true) {
                            _controller!.setPlaybackSpeed(_speed);
                          }
                        });

                        _saveSpeedCfg();
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
              _controller != null && _controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : AspectRatio(
                      aspectRatio: widget.aspectRatio,
                      child: const CircularProgressIndicator.adaptive()),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 20),
                  ),
                  IconButton(
                      onPressed: () {
                        final size = MediaQuery.of(context).size;
                        MyDialog.popup(
                            maxHeight: size.height * 0.6,
                            SingleChildScrollView(
                              child: Wrap(
                                children: List.generate(widget.count, (i) {
                                  return Container(
                                    margin:
                                        const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: i == _currIndex
                                            ? UIConfig.selectedColor
                                            : Colors.transparent),
                                    child: FishInkwell(
                                      onTap: () {
                                        _currIndex = i;
                                        _saveCurrIndex();
                                        _load(play: true);
                                        NavigatorUtils.pop(context);
                                      },
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black26),
                                            borderRadius: BorderRadius.circular(8)),
                                        child: Text('${i + 1}'),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            isScrollControlled: true);
                      },
                      icon: const Icon(Icons.list))
                ],
              ),
              Expanded(child: Container()),
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
                            _controller?.seekTo(Duration(milliseconds: newPos));
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
                            _controller?.seekTo(Duration(milliseconds: newPos));
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
                    const SizedBox(height: 16),
                    FishSliderWidget(
                      value: _currPlayingPos.toDouble(),
                      max: length.toDouble(),
                      onChanged: (value) {
                        if (value.toInt() != _currPlayingPos) {
                          _pos = value.toInt();
                          _controller?.seekTo(Duration(milliseconds: _currPlayingPos));
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_currPosStr),
                        Text(_currLenStr),
                      ],
                    ),
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
                        _onPre();
                      },
                      icon: const Icon(Icons.skip_previous)),
                  IconButton(
                      onPressed: () {
                        if (_playStatus == AudioVideoPlayStatus.playing) {
                          _controller?.pause();
                        } else {
                          _controller?.play();
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
