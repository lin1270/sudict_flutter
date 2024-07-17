import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';
import 'package:sudict/modules/audio/common.dart';
import 'package:sudict/modules/audio/unique_play_mgr.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/jingyuan/xiguicidi_audio_mgr.dart';

class XiguicidiPlayListPage extends StatefulWidget {
  const XiguicidiPlayListPage({super.key});

  @override
  State<XiguicidiPlayListPage> createState() => _XiguicidiPlayListPageState();
}

class _XiguicidiPlayListPageState extends State<XiguicidiPlayListPage> {
  final _flutterListViewController = FlutterListViewController();

  final double _itemHeight = 40;
  final List<int> _searchResult = [];
  int _searchResultCursor = -1;

  bool _isFirstLoadForJump = true;
  var _currClickItemIndex = -1;
  final _searchFocusNode = FocusNode();
  final _searchTextFieldController = TextEditingController();
  final _openccModeT2S = T2S();
  final _openccModeS2T = T2S();
  var _playStatus = AudioVideoPlayStatus.notPlay;
  CatalogItem? _currCatalogItem;

  @override
  void dispose() {
    _flutterListViewController.dispose();
    UniqueAudioPlayMgr.instance.offEvent(AudioVideoPlayCatalog.xiguicidi, _audioPlayCallback);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((mag) {
      if (_isFirstLoadForJump) {
        // onJumpCurrentPos();
        FocusScope.of(context).requestFocus(_searchFocusNode);

        _isFirstLoadForJump = false;
      }
    });

    _init();
  }

  _init() async {
    _currCatalogItem = await XiguicidiAudioMgr.instance.currCatalog;
    _getAndUpdatePlayingStatus();

    UniqueAudioPlayMgr.instance.onEvent(AudioVideoPlayCatalog.xiguicidi, _audioPlayCallback);

    setState(() {});
  }

  _audioPlayCallback(String url, AudioVideoPlayStatus status, int pos, String? errorMsg) {
    if (status != _playStatus) {
      setState(() {
        _playStatus = status;
      });
    }
  }

  _getAndUpdatePlayingStatus() async {
    final status = await UniqueAudioPlayMgr.instance.getPlayStatus(AudioVideoPlayCatalog.xiguicidi);
    _playStatus = status;
    setState(() {});
  }

  onJumpCurrentPos() {
    int pos = _currCatalogItem!.currIndex - 1;
    if (pos < 0) pos = 0;
    jumpToIndex(pos);
  }

  _onSearch(String word) async {
    _searchResult.clear();
    _searchResultCursor = 0;
    if (word.isNotEmpty) {
      bool firstMatched = true;
      var strToSearchSimple = await ChineseConverter.convert(word, _openccModeT2S);
      var strToSearchTr = await ChineseConverter.convert(word, _openccModeS2T);

      for (var i = 0; i < _currCatalogItem!.length; ++i) {
        final item = _currCatalogItem!.getItemAt(i);
        var name = item!.name;
        if (name.contains(strToSearchSimple) || name.contains(strToSearchTr)) {
          if (firstMatched) jumpToIndex(i);
          firstMatched = false;
          _searchResult.add(i);
        }
      }
    }

    setState(() {});
  }

  jumpToIndex(int index) {
    if (index < 0) {
      UiUtils.toast(content: "跳轉失敗~");
      return;
    }
    _flutterListViewController.animateTo(index * _itemHeight,
        curve: Curves.bounceIn, duration: const Duration(milliseconds: 200));
  }

  _goNextSearch(int nextSearchDirection) {
    if (_searchResult.isEmpty) return;
    if (nextSearchDirection == 1) {
      _searchResultCursor = (_searchResultCursor + 1) % _searchResult.length;
      jumpToIndex(_searchResult[_searchResultCursor]);
    } else {
      --_searchResultCursor;
      if (_searchResultCursor < 0) _searchResultCursor = _searchResult.length - 1;
      jumpToIndex(_searchResult[_searchResultCursor]);
    }
  }

  _playOrPause(int index) async {
    _currClickItemIndex = index;
    _currCatalogItem!.setCurrIndex(index);
    FishEventBus.fire(UpdateAudioCatalog(AudioVideoPlayCatalog.xiguicidi, true));
    _getAndUpdatePlayingStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currCatalogItem?.name ?? ''),
        actions: [
          IconButton(
            onPressed: () {
              onJumpCurrentPos();
            },
            icon: const Icon(Icons.location_searching_rounded),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 4,
          ),
          Row(children: [
            Expanded(
                child: TextField(
              textInputAction: TextInputAction.search,
              focusNode: _searchFocusNode,
              controller: _searchTextFieldController,
              scrollPadding: EdgeInsets.zero,
              decoration: const InputDecoration(
                  hintText: '搜尋', border: InputBorder.none, prefixIcon: Icon(Icons.search)),
              onChanged: (value) {
                var coreV = value.trim();
                _onSearch(coreV);
              },
            )),
            if (_searchResult.isNotEmpty)
              IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _searchTextFieldController.clear();
                    _onSearch('');
                  },
                  icon: const Icon(Icons.close)),
            if (_searchResult.isNotEmpty)
              IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _goNextSearch(-1);
                  },
                  icon: const Icon(Icons.arrow_upward)),
            if (_searchResult.isNotEmpty)
              IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _goNextSearch(1);
                  },
                  icon: const Icon(Icons.arrow_downward))
          ]),
          Container(
            height: 1,
            decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
          ),
          Expanded(
              child: FlutterListView(
                  controller: _flutterListViewController,
                  delegate: FlutterListViewDelegate((context, index) {
                    final item = _currCatalogItem!.getItemAt(index)!;

                    final min = (item.length / 1000 / 60).floor();
                    final sec = (item.length / 1000).floor() % 60;
                    final lenStr = '$min:${sec >= 10 ? '' : '0'}$sec';
                    final isInSearch = _searchResult.contains(index);
                    return Container(
                      color: _currClickItemIndex == index
                          ? Colors.black12
                          : isInSearch
                              ? Colors.purple.withAlpha(128)
                              : _currCatalogItem!.currIndex == index
                                  ? Colors.blue
                                  : Colors.transparent,
                      child: FishInkwell(
                          onTap: () {
                            setState(() {
                              _currClickItemIndex = index;
                            });
                          },
                          onDoubleTap: () {
                            _playOrPause(index);
                          },
                          child: Container(
                            height: _itemHeight,
                            padding: const EdgeInsets.only(left: 8, right: 16),
                            child: Row(
                              children: [
                                FishInkwell(
                                    onTap: () {
                                      _playOrPause(index);
                                    },
                                    child: Icon(_playStatus == AudioVideoPlayStatus.playing &&
                                            _currCatalogItem!.currIndex == index
                                        ? Icons.pause_circle_outlined
                                        : Icons.play_arrow_outlined)),
                                Expanded(
                                    child: Text(
                                  item.name,
                                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                                )),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(lenStr)
                              ],
                            ),
                          )),
                    );
                  },
                      preferItemHeight: _itemHeight,
                      childCount: _currCatalogItem == null
                          ? 0
                          : _currCatalogItem!.end - _currCatalogItem!.begin + 1))),
        ],
      ),
    );
  }
}
