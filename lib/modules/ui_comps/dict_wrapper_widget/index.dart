import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/dict/dict_search_result.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/history/favorite_mgr.dart';
import 'package:sudict/modules/history/history_mgr.dart';
import 'package:sudict/modules/setting/index.dart';
import 'package:sudict/modules/ui_comps/dict_wrapper_widget/type.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/ui_comps/third/animated_visibility/animated_visibility.dart';
import 'package:sudict/modules/utils/debug.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/modules/ui_comps/dict_wrapper_widget/dict_group_menu_widget.dart';
import 'package:sudict/modules/ui_comps/dict_wrapper_widget/dict_group_native_widget.dart';

// ignore: must_be_immutable
class DictWrapperWidget extends StatefulWidget {
  DictWrapperWidget({super.key, this.firstWidget, this.type = DictWrapperType.main, this.initWord});

  DictWrapperType type;
  Widget? firstWidget;
  String? initWord;

  @override
  State<DictWrapperWidget> createState() => _DictWrapperWidgetState();
}

class _DictWrapperWidgetState extends State<DictWrapperWidget> {
  final _dictWidgetControllers = <int, DictGroupNativeWidgetController>{};
  DictSearchResult? _lastResult;
  bool _isWordInFavorite = false;
  final _searchTextFieldController = TextEditingController();
  var _showRandomWidget = false;
  var _showQuickHistoryWidget = false;
  final _quickHistoryData = <String>[];
  final _searchFocusNode = FocusNode();

  DictMgr get _dictMgr =>
      widget.type == DictWrapperType.main ? DictMgr.instance : DictMgr.tempInstance;

  @override
  void dispose() {
    for (final item in _dictWidgetControllers.values) {
      item.dispose();
    }
    _dictWidgetControllers.clear();
    _searchTextFieldController.dispose();

    FishEventBus.offEvent<DictSettingGroupAddOrRemoveEvent>(_onDictSettingGroupAddOrRemoveEvent);
    FishEventBus.offEvent<ShowRandomWidgetEvent>(_onShowRandomWidgetEvent);
    FishEventBus.offEvent<ClearFavoriteEvent>(_onClearFavoriteEvent);
    FishEventBus.offEvent<SearchWordEvent>(_onSearchWordEvent);
    FishEventBus.offEvent<UpdateFavorite>(_onUpdateFavorite);
    super.dispose();
  }

  _onDictSettingGroupAddOrRemoveEvent(DictSettingGroupAddOrRemoveEvent event) {
    setState(() {});
  }

  _onShowRandomWidgetEvent(ShowRandomWidgetEvent event) {
    setState(() {
      _showRandomWidget = true;
      _onRandomBtnClicked();
    });
  }

  _onClearFavoriteEvent(ClearFavoriteEvent event) {
    _isWordInFavorite = false;
    setState(() {});
  }

  _onSearchWordEvent(SearchWordEvent event) {
    _searchTextFieldController.text = event.word;
    _searchCore(event.word, true);
  }

  _onUpdateFavorite(UpdateFavorite event) async {
    if (_lastResult != null &&
        _lastResult!.errorMsg == null &&
        _lastResult!.firstTrueWord?.isNotEmpty == true) {
      String myWord = _lastResult!.firstTrueWord!;
      if (myWord == event.word) {
        _isWordInFavorite = await FavoriteMgr.instance.isWordInFavorite(myWord);
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _dictMgr.currItem.load();

    if (widget.initWord != null) {
      _searchTextFieldController.text = widget.initWord!;
      Timer(const Duration(milliseconds: 100), () {
        _searchCore(_searchTextFieldController.text, true);
      });
    }

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });

    if (widget.type == DictWrapperType.main) {
      FishEventBus.onEvent<DictSettingGroupAddOrRemoveEvent>(_onDictSettingGroupAddOrRemoveEvent);
      FishEventBus.onEvent<ShowRandomWidgetEvent>(_onShowRandomWidgetEvent);
      FishEventBus.onEvent<ClearFavoriteEvent>(_onClearFavoriteEvent);
      FishEventBus.onEvent<SearchWordEvent>(_onSearchWordEvent);
      FishEventBus.onEvent<UpdateFavorite>(_onUpdateFavorite);
    }
  }

  _onRandomBtnClicked() async {
    DictItem dict = _dictMgr.currItem;
    var count = dict.isWeb() ? 1000 : dict.wordCount;
    if (count <= 0) count = 1000;
    final str = (Random().nextInt(count) + 1).toString();
    _searchTextFieldController.text = str;

    _searchCore(str, true);
  }

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[_dictContentWidget(), _topWidget(), _bottomWidget()];
    if (_showRandomWidget) {
      widgets.add(_randomWidget());
    }

    if (_showQuickHistoryWidget) {
      widgets.add(_quickHistoryWidget());
    }
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: widgets,
    );
  }

  Widget _quickHistoryWidget() {
    return Positioned(
        left: 8,
        right: 8,
        bottom: UIConfig.dictBottomHeight,
        child: Container(
            height: 46,
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(8), color: Colors.white),
            child: ListView.builder(
              itemCount: _quickHistoryData.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _searchTextFieldController.text = _quickHistoryData[index];
                    _searchCore(_quickHistoryData[index], true);
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 9, bottom: 5),
                      child: Text(
                        _quickHistoryData[index],
                        style: const TextStyle(fontSize: 18, fontFamily: 'KaiXinSong'),
                      )),
                );
              },
            )));
  }

  Widget _randomWidget() {
    return Positioned(
        bottom: 130,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _showRandomWidget = false;
                });
              },
              child: const Icon(
                Icons.close,
                size: 26,
                color: Colors.red,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
                onTap: _onRandomBtnClicked,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(color: Colors.brown, shape: BoxShape.circle),
                  child: const Icon(
                    Icons.shuffle,
                    color: Colors.white,
                    size: 36,
                  ),
                )),
          ],
        ));
  }

  Widget _dictContentWidget() {
    return Positioned(
        left: 8,
        top: 0,
        right: 8,
        bottom: UIConfig.dictBottomHeight,
        child: Stack(
            fit: StackFit.expand,
            children: _dictMgr.allGroup.map((groupItem) {
              var groupWidgetController = _dictWidgetControllers[groupItem.id];
              if (groupWidgetController == null) {
                groupWidgetController = DictGroupNativeWidgetController();
                _dictWidgetControllers[groupItem.id] = groupWidgetController;
              }
              return AnimatedVisibility(
                  visible: groupItem.id == _dictMgr.currentGroup.id,
                  maintainState: true,
                  child: Platform.isWindows || Platform.isMacOS
                      ? Container(
                          padding: const EdgeInsets.only(top: UIConfig.dictHeaderHeight),
                          child: Container(
                            color: UIConfig.dictBkColor,
                          ),
                        )
                      : DictGroupNativeWidget(
                          type: widget.type,
                          groupIndex: _dictMgr.getGroupIndex(groupItem),
                          controller: groupWidgetController,
                          onDictChanged: (tabIndex) {
                            _searchCore(_searchTextFieldController.text, false);
                          },
                          onSearchWord: (word) {
                            // setting, open page, or search directly
                            if (Setting.instance.dictInnerJumpPage) {
                              UiUtils.showTempDictDialog(context, word);
                            } else {
                              _searchTextFieldController.text = word;
                              _searchCore(word, true);
                            }
                          },
                        ));
            }).toList()));
  }

  Widget _topWidget() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: UIConfig.dictHeaderHeight,
      child: Row(children: [
        IconButton(
            onPressed: _lastResult != null &&
                    _lastResult!.errorMsg == null &&
                    _lastResult!.firstTrueWord?.isNotEmpty == true
                ? _onFavoriteBtnClicked
                : null,
            icon: Icon(_isWordInFavorite ? Icons.star : Icons.star_border_outlined)),
        Padding(
            padding: const EdgeInsets.only(left: 14, right: 14),
            child: GestureDetector(
              onTap: () {
                Setting.instance.convertSimple = !Setting.instance.convertSimple;
                _searchCore(_searchTextFieldController.text, true);
                if (Setting.instance.convertSimple) {
                  UiUtils.toast(content: '繁簡轉換可能會出現錯字別字，請仔細辨別哦。', showMs: 3000);
                }
                setState(() {});
              },
              child: Text(
                Setting.instance.convertSimple ? '简' : '正',
                style: const TextStyle(
                    color: Color.fromARGB(192, 0, 0, 0), fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )),
        Expanded(
            child: Stack(children: [
          const Positioned(
              left: 0,
              right: 0,
              bottom: 1,
              top: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 22,
                  )
                ],
              )),
          Positioned(
            left: 10,
            right: 10,
            top: 0,
            bottom: 0,
            child: DictGroupMenuWidget(
              groupController: _dictWidgetControllers[_dictMgr.currentGroup.id],
              groupIndex: _dictMgr.currentGroupIndex,
            ),
          ),
        ])),
        IconButton(
            onPressed: _onTakePhotoBtnClicked, icon: const Icon(Icons.photo_camera_outlined)),
        IconButton(
            onPressed: _onSwapDictGroupBtnClicked, icon: const Icon(Icons.swap_horiz_outlined)),
      ]),
    );
  }

  Widget _bottomWidget() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: UIConfig.dictBottomHeight,
      child: Row(children: [
        if (widget.firstWidget != null) widget.firstWidget!,
        if (widget.firstWidget == null)
          const SizedBox(
            width: 20,
          ),
        FishInkwell(
            onTap: _onQuickHistoryBtnClicked,
            child: SizedBox(
                width: 30,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                        top: 4,
                        child: Icon(
                          _showQuickHistoryWidget
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          size: 22,
                        )),
                    const Icon(
                      Icons.manage_search,
                      size: 32,
                    )
                  ],
                ))),
        IconButton(
            onPressed: _onPreHistoryBtnClicked,
            icon: const Icon(
              Icons.keyboard_arrow_left_outlined,
              size: 32,
            )),
        IconButton(
            onPressed: _onNextHistoryBtnClicked,
            icon: const Icon(
              Icons.keyboard_arrow_right_outlined,
              size: 32,
            )),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                child: TextField(
                  focusNode: _searchFocusNode,
                  controller: _searchTextFieldController,
                  onSubmitted: _onSearch,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontFamily: 'KaiXinSong', fontSize: 20),
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      hintText: '搜尋內容',
                      prefixIcon: Icon(Icons.search)),
                )))
      ]),
    );
  }

  _onFavoriteBtnClicked() async {
    if (_lastResult != null &&
        _lastResult!.errorMsg == null &&
        _lastResult!.firstTrueWord?.isNotEmpty == true) {
      String word = _lastResult!.firstTrueWord!;
      _isWordInFavorite = await FavoriteMgr.instance.isWordInFavorite(word);
      if (_isWordInFavorite) {
        FavoriteMgr.instance.delete(word);
      } else {
        FavoriteMgr.instance.add(word);
      }
      _isWordInFavorite = !_isWordInFavorite;
      setState(() {});

      if (widget.type != DictWrapperType.main) {
        FishEventBus.fire(UpdateFavorite(word));
      }
    }
  }

  _onSwapDictGroupBtnClicked() {
    _dictMgr.goNextGroup();
    // > 2才提示，默認2個分組，無須提示
    if (_dictMgr.allGroup.length > 2) {
      final settingGroup = _dictMgr.allGroupForSetting[_dictMgr.currentGroupIndex];
      UiUtils.toast(content: '已切換到${settingGroup.name}', showMs: 600);
    }

    setState(() {
      Timer(const Duration(milliseconds: 100), () {
        _searchCore(_searchTextFieldController.text, false);
      });
    });
  }

  _onTakePhotoBtnClicked() {
    _dictWidgetControllers[_dictMgr.currentGroup.id]?.takePhoto();
  }

  _onQuickHistoryBtnClicked() {
    _showQuickHistoryWidget = !_showQuickHistoryWidget;
    if (_showQuickHistoryWidget) {
      _quickHistoryData.clear();
      _quickHistoryData.addAll(HistoryMgr.instance.words);
    }

    setState(() {});
  }

  _onPreHistoryBtnClicked() async {
    String? word = await HistoryMgr.instance.preWord();
    if (word?.isNotEmpty == true) {
      _searchTextFieldController.text = word!;
      _searchCore(word, false);
    }
  }

  _onNextHistoryBtnClicked() async {
    String? word = await HistoryMgr.instance.nextWord();
    if (word?.isNotEmpty == true) {
      _searchTextFieldController.text = word!;
      _searchCore(word, false);
    }
  }

  _onSearch(String word) {
    _searchCore(word, true);
  }

  _searchCore(String word, bool foreceLoadResult) async {
    word = word.trim();
    if (word.isEmpty) return;

    final result = await _dictMgr.currItem.search(word, maxCount: 1);
    FishDebugUtils.log('...foundWord: ${result.firstTrueWord}');
    _dictWidgetControllers[_dictMgr.currentGroup.id]
        ?.loadResult(result, isUrl: true, isForce: foreceLoadResult);

    _lastResult = result;

    _isWordInFavorite = false;
    if (result.errorMsg == null) {
      if (result.firstTrueWord?.isNotEmpty == true) {
        // 歷史記錄
        if (foreceLoadResult) HistoryMgr.instance.add(result.firstTrueWord!);

        // favorite
        _isWordInFavorite = await FavoriteMgr.instance.isWordInFavorite(result.firstTrueWord!);
      }
    }

    setState(() {});
  }
}
