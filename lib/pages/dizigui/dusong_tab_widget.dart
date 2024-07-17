import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/audio/common.dart';
import 'package:sudict/modules/audio/unique_play_mgr.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/ui_comps/fish_slider_widget/index.dart';
import 'package:sudict/modules/ui_comps/fish_toggle_switch/index.dart';
import 'package:sudict/modules/ui_comps/third/animated_visibility/animated_visibility.dart';
import 'package:sudict/modules/utils/assets.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/zhuyin/index.dart';

class DiziguiDusongTabWidget extends StatefulWidget {
  const DiziguiDusongTabWidget({super.key});
  @override
  State<DiziguiDusongTabWidget> createState() => _DiziguiDusongTabWidgetState();
}

class _DiziguiLineItem extends ZhuyinLine {
  var catalogIndex = -1;
  var index = -1;
  var oriIndex = -1;
}

class _VoiceHandler {
  _VoiceHandler(this.assetsPath, this.audioUrl, this.volume, this.onGo);
  final String assetsPath;
  final String audioUrl;
  double volume;
  Function(int index) onGo;

  // time -> index
  final data = <int, int>{};
  bool _isLoaded = false;
  int _lastGoIndex = -1;

  int _timeStr2Second(String str) {
    final arr = str.trim().split(':');
    if (arr.length != 2) return 0;
    return int.parse(arr[0]) * 60 + int.parse(arr[1]);
  }

  Future<void> load() async {
    if (_isLoaded) return;
    String? str = await AssetsUtils.readStringFile(assetsPath);
    if (str == null) return;
    final lines = str.split('\n');
    for (final line in lines) {
      final arr = line.split(' ');
      final time = _timeStr2Second(arr[0]);
      final index = int.parse(arr[1].trim());
      data[time] = index ~/ 2;
    }

    UniqueAudioPlayMgr.instance.onEvent(AudioVideoPlayCatalog.dizigui, _onPlayCallback);

    _isLoaded = true;
  }

  void dispose() {
    UniqueAudioPlayMgr.instance.offEvent(AudioVideoPlayCatalog.dizigui, _onPlayCallback);
  }

  Future<void> playOrPause() async {
    if (_lastGoIndex == -1) {
      UniqueAudioPlayMgr.instance.setPosition(AudioVideoPlayCatalog.dizigui, 0);
    }
    setVolume(volume);
    UniqueAudioPlayMgr.instance.playOrPause(AudioVideoPlayCatalog.dizigui, audioUrl);
  }

  Future<void> setVolume(double newV) async {
    double v = await UniqueAudioPlayMgr.instance.getVolume(AudioVideoPlayCatalog.dizigui);
    if (v == newV) return;

    volume = newV;
    UniqueAudioPlayMgr.instance.setVolume(AudioVideoPlayCatalog.dizigui, newV / 100);
  }

  _onPlayCallback(String url, AudioVideoPlayStatus status, int pos, String? errorMsg) {
    if (url == audioUrl) {
      final index = data[pos ~/ 1000];
      if (index != null && index != _lastGoIndex) {
        _lastGoIndex = index;
        onGo(index);
      }
    }
  }
}

class _ZhuyinHelper {
  final _zhuyinHandler = Zhuyin();

  final lines = <_DiziguiLineItem>[];
  final catalogItems = <_DiziguiLineItem>[];
  bool _isLoaded = false;

  Future<void> load(String assetsPath, int wordPerLine) async {
    if (_isLoaded) return;

    await _zhuyinHandler.loadAssets(assetsPath);
    final catalogJson = await AssetsUtils.readJsonFile('assets/dizigui/catalog.json');
    final catalogIndex = catalogJson['catalog'] as List<dynamic>;
    final indexIndex = catalogJson['index'] as List<dynamic>;
    var theIndex = 1;
    for (int i = 0; i < _zhuyinHandler.lines.length; ++i) {
      final line = _zhuyinHandler.lines[i];
      for (int j = 0; j < line.data.length; j += wordPerLine) {
        final newLine = _DiziguiLineItem();
        newLine.oriIndex = i + 1;
        int end = j + wordPerLine;
        if (end > line.data.length) end = line.data.length;
        newLine.data.addAll(line.data.sublist(j, end));
        if (newLine.data.last.word.trim().isEmpty) {
          newLine.data.removeLast();
        }
        if (j == 0) {
          final tempIndex = (i + 1) * 2;
          if (catalogIndex.contains(tempIndex)) {
            newLine.catalogIndex = lines.length;
            catalogItems.add(newLine);
          } else if (indexIndex.contains(tempIndex)) {
            newLine.index = theIndex;
            ++theIndex;
          }
        }
        lines.add(newLine);
      }
    }
    _isLoaded = true;
  }
}

class _DiziguiDusongTabWidgetState extends State<DiziguiDusongTabWidget>
    with AutomaticKeepAliveClientMixin {
  final _isPinyin = ValueNotifier<bool>(true);
  final _pinyinHandler = _ZhuyinHelper();
  final _zhuyinHandler = _ZhuyinHelper();

  var _showMenu = true;
  final _showZhuyin = ValueNotifier<bool>(true);

  final _contentController = FlutterListViewController();
  final _volumeValue = ValueNotifier<double>(100);
  final _voiceHandlers = <int, _VoiceHandler>{};
  var _voiceGoIndex = -1;
  var _voiceHandlerIndex = -1;

  static const _wordWidth = 48.0;
  static const _wordHeight = 38.0;
  static const _zhuyinHeight = 18.0;
  static const _pinyinHeight = 22.0;
  static const _indexWidth = 30.0;
  static const _spaceWidth = 10.0;

  var _maxLinesInScreen = 0;

  final _autoScrollSpeed = ValueNotifier<double>(0.5);
  bool _isAutoScrolling = false;
  Timer? _autoScrollTimer;

  double get _trueWordWidth {
    if (_showZhuyin.value) {
      return _wordWidth;
    }
    return _wordWidth - 18;
  }

  double get _trueZhuyinHeight => _isPinyin.value ? _pinyinHeight : _zhuyinHeight;

  double get _itemHeigt {
    if (_showZhuyin.value) {
      return _wordHeight + _trueZhuyinHeight;
    }
    return _wordHeight;
  }

  @override
  void dispose() {
    UniqueAudioPlayMgr.instance.stop(AudioVideoPlayCatalog.dizigui);
    _voiceHandlers.forEach((index, v) {
      v.dispose();
    });
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  static const _wordPerLine = 8;
  _init() async {
    _isPinyin.value =
        await LocalStorageUtils.getBool(LocalStorageKeys.diziguiZhuyinIsPinyin) ?? true;
    _showZhuyin.value = await LocalStorageUtils.getBool(LocalStorageKeys.diziguiShowZhuyin) ?? true;
    _volumeValue.value = await LocalStorageUtils.getDouble(LocalStorageKeys.diziguiVoice) ?? 100.0;
    _autoScrollSpeed.value =
        await LocalStorageUtils.getDouble(LocalStorageKeys.diziguiAutoScrollSpeed) ?? 0.5;
    await _pinyinHandler.load('assets/dizigui/py.txt', _wordPerLine);
    await _zhuyinHandler.load('assets/dizigui/zy.txt', _wordPerLine);
    setState(() {});
  }

  void _setPinyin(bool v) {
    _isPinyin.value = v;
    LocalStorageUtils.setBool(LocalStorageKeys.diziguiZhuyinIsPinyin, v);
  }

  void _setShowZhuyin(bool v) {
    _showZhuyin.value = v;
    LocalStorageUtils.setBool(LocalStorageKeys.diziguiShowZhuyin, v);
  }

  void _setVoiceValue(double v) {
    _volumeValue.value = v;
    _voiceHandlers.forEach((index, handler) {
      handler.setVolume(v);
    });
    LocalStorageUtils.setDouble(LocalStorageKeys.diziguiVoice, v);
  }

  void _setAutoScrollSpeed(double v) {
    _autoScrollSpeed.value = v;
    LocalStorageUtils.setDouble(LocalStorageKeys.diziguiAutoScrollSpeed, v);
  }

  List<_DiziguiLineItem> get _lines =>
      _isPinyin.value ? _pinyinHandler.lines : _zhuyinHandler.lines;
  List<_DiziguiLineItem> get _catalogItems =>
      _isPinyin.value ? _pinyinHandler.catalogItems : _zhuyinHandler.catalogItems;
  Widget _horWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final trueIndexWidth = size.width - (_indexWidth + _spaceWidth + _trueWordWidth * 6) - 4;

    return FlutterListView(
        controller: _contentController,
        delegate: FlutterListViewDelegate(preferItemHeight: _itemHeigt, childCount: _lines.length,
            (context, index) {
          final zhuyinLine = _lines[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(zhuyinLine.data.length + 1, (j) {
              if (j == 0) {
                return Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 30,
                    width: trueIndexWidth < 30 ? trueIndexWidth : 30,
                    decoration: zhuyinLine.index >= 0
                        ? BoxDecoration(
                            border: Border.all(color: Colors.black.withAlpha(8)),
                            borderRadius: BorderRadius.circular(15))
                        : null,
                    child: Text(
                      zhuyinLine.index >= 0 ? '${zhuyinLine.index}' : '',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black.withAlpha(8), fontSize: 20),
                    ),
                  ),
                );
              }
              final item = zhuyinLine.data[j - 1];
              return Container(
                width: item.zhuyin.isNotEmpty == true ? _trueWordWidth : _spaceWidth,
                decoration: const BoxDecoration(),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    if (_showZhuyin.value)
                      Container(
                          alignment: Alignment.bottomCenter,
                          height: _trueZhuyinHeight,
                          child: Text(
                            item.zhuyin,
                            style: TextStyle(
                              fontSize: _isPinyin.value ? 16 : 12,
                              color: _voiceGoIndex == zhuyinLine.oriIndex
                                  ? UIConfig.selectedColor
                                  : Colors.black,
                            ),
                          )),
                    SizedBox(
                      height: _wordHeight,
                      child: Text(
                        item.word,
                        style: TextStyle(
                            fontSize: 24,
                            color: _voiceGoIndex == zhuyinLine.oriIndex
                                ? UIConfig.selectedColor
                                : Colors.black,
                            fontWeight: zhuyinLine.catalogIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        }));
  }

  // Widget _verWidget() {
  //   return const Text('not supported');
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_maxLinesInScreen == 0) {
      final size = MediaQuery.of(context).size;
      _maxLinesInScreen = size.height ~/ _itemHeigt;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 16),
      child: Row(
        children: [
          Expanded(child: _horWidget(context)),
          Column(
            children: [
              FishInkwell(
                onTap: () {
                  setState(() {
                    _showMenu = !_showMenu;
                  });
                },
                child: Icon(
                  _showMenu
                      ? Icons.keyboard_double_arrow_up_outlined
                      : Icons.keyboard_double_arrow_down_outlined,
                  color: _showMenu ? Colors.black : Colors.black.withAlpha(5),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              AnimatedVisibility(
                visible: _showMenu,
                child: Column(
                  children: [
                    FishInkwell(
                        onTap: () {
                          _playVoice(0);
                        },
                        child: Icon(
                          Icons.person_outline,
                          color: _voiceHandlerIndex == 0 ? UIConfig.selectedColor : Colors.black,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    FishInkwell(
                        onTap: () {
                          _playVoice(1);
                        },
                        child: Icon(
                          Icons.group_outlined,
                          color: _voiceHandlerIndex == 1 ? UIConfig.selectedColor : Colors.black,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    FishInkwell(
                        onTap: () {
                          _playVoice(2);
                        },
                        child: Icon(
                          Icons.play_for_work,
                          color: _voiceHandlerIndex == 2 ? UIConfig.selectedColor : Colors.black,
                        )),
                    const SizedBox(
                      height: 24,
                    ),
                    FishInkwell(
                        onTap: () {
                          _showCatalogDialog();
                        },
                        child: const Icon(Icons.find_in_page_outlined)),
                    const SizedBox(
                      height: 10,
                    ),
                    FishInkwell(
                        onTap: () {
                          _showSettingDialog();
                        },
                        child: const Icon(Icons.settings_outlined)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _showSettingDialog() {
    MyDialog.popup(
        height: 240,
        Column(
          children: [
            Row(
              children: [
                const Text('顯示注音/拼音：'),
                ValueListenableBuilder(
                    valueListenable: _showZhuyin,
                    builder: (context, v, widget) {
                      return FishToggleSwitchWidget(
                        isOn: _showZhuyin.value,
                        onText: '已顯示',
                        offText: '已隱藏',
                        onChanged: (value) {
                          setState(() {
                            _setShowZhuyin(value);
                          });
                        },
                      );
                    }),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text('切換注音/拼音：'),
                ValueListenableBuilder(
                    valueListenable: _isPinyin,
                    builder: (context, v, widget) {
                      return FishToggleSwitchWidget(
                        isOn: _isPinyin.value,
                        offBackgroundColor: Colors.blue,
                        onText: '拼音',
                        offText: '注音',
                        onChanged: (value) {
                          setState(() {
                            _setPinyin(value);
                          });
                        },
                      );
                    }),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text('播音音量：'),
                const SizedBox(
                  width: 10,
                ),
                ValueListenableBuilder(
                    valueListenable: _volumeValue,
                    builder: (context, v, widget) {
                      return FishSliderWidget(
                        value: _volumeValue.value,
                        onChanged: (v) {
                          _setVoiceValue(v);
                        },
                      );
                    }),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text('自動滾動速度：'),
                const SizedBox(
                  width: 10,
                ),
                ValueListenableBuilder(
                    valueListenable: _autoScrollSpeed,
                    builder: (context, v, widget) {
                      return FishSliderWidget(
                        value: _autoScrollSpeed.value,
                        min: 0.1,
                        max: 2,
                        onChanged: (v) {
                          _setAutoScrollSpeed(v);
                        },
                      );
                    }),
              ],
            )
          ],
        ));
  }

  void _showCatalogDialog() {
    MyDialog.popup(ListView.builder(
        itemCount: _catalogItems.length,
        itemBuilder: (context, index) {
          final item = _catalogItems[index];
          var title = '';
          for (final zi in item.data) {
            title += zi.word;
          }

          return FishInkwell(
            onTap: () {
              double pos = (item.catalogIndex - 1) * _itemHeigt;
              if (pos < 0) pos = 0;
              _contentController.animateTo(pos,
                  curve: Curves.bounceIn, duration: const Duration(milliseconds: 200));
              NavigatorUtils.pop(context);
            },
            child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                child: Text(
                  '${index + 1}. $title',
                  style: const TextStyle(fontSize: 18),
                )),
          );
        }));
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_isAutoScrolling) {
      _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        // 到达底部，结束
        if (_contentController.offset >= _contentController.position.maxScrollExtent) {
          _voiceHandlerIndex = -1;
          _isAutoScrolling = false;
          _autoScrollTimer?.cancel();
          setState(() {});
          return;
        }
        _contentController.jumpTo(_contentController.offset + _autoScrollSpeed.value);
      });
    }
  }

  void _playVoice(int i) {
    _voiceHandlerIndex = i;
    if (i == 2) {
      // no voice
      // just scroll
      _isAutoScrolling = !_isAutoScrolling;
      _startAutoScroll();
      if (!_isAutoScrolling) {
        _voiceHandlerIndex = -1;
      }
      setState(() {});
      return;
    }
    _isAutoScrolling = false;
    _autoScrollTimer?.cancel();

    if (i == 0) {
      _voiceHandlers[i] ??= _VoiceHandler(
          'assets/dizigui/voice1.txt',
          'http://www.maiyuren.com/static/more/jingyuan/audio/1873.【弟子规】.mp3',
          _volumeValue.value,
          _onGoVoice);
    } else {
      _voiceHandlers[i] ??= _VoiceHandler(
          'assets/dizigui/voice2.txt',
          'http://www.maiyuren.com/static/more/jingyuan/audio/1874.《弟子规》共修.mp3',
          _volumeValue.value,
          _onGoVoice);
    }

    _voiceHandlers[i]?.load();

    _voiceHandlers[i]?.playOrPause();
    setState(() {});
  }

  _onGoVoice(int index) {
    try {
      final middleIndex = _showZhuyin.value ? 3 : 5;
      var lineIndex = _lines.indexWhere((e) => e.oriIndex == index) - middleIndex;
      while (lineIndex < 0) {
        ++lineIndex;
      }
      setState(() {
        _voiceGoIndex = index;
      });

      double pos = lineIndex * _itemHeigt;
      // 到達底部時，會有一個彈動效果，不太好
      if (pos < _contentController.position.maxScrollExtent) {
        _contentController.animateTo(pos,
            curve: Curves.bounceIn, duration: const Duration(milliseconds: 200));
      }

      // ignore: empty_catches
    } catch (e) {}
  }
}
