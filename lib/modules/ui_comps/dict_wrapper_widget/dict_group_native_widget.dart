import 'dart:async';
import 'dart:io';

import 'package:dict_page_view_plugin/dict_page_view_widget.dart';
import 'package:dict_page_view_plugin/dict_page_view_widget_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:sudict/config/path.dart';
import 'package:sudict/modules/audio/audio_player.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_result_formator.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/dict/dict_search_result.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/http/index.dart';
import 'package:sudict/modules/share/index.dart';
import 'package:sudict/modules/ui_comps/dict_wrapper_widget/type.dart';
import 'package:sudict/modules/utils/debug.dart';
import 'package:sudict/modules/utils/navigator.dart';

import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/go_url/go_url_page_param.dart';
import 'package:path/path.dart' as p;
import 'package:sudict/pages/router.dart';

enum _NotifyType {
  none,
  loadContent,
  changeDict,
  takePhoto,
}

class DictGroupNativeWidgetController extends ChangeNotifier {
  late DictSearchResult result;
  late bool isUrl;
  var isForceLoadContent = true;
  late DictItem change2dict;

  var notifyType = _NotifyType.none;

  loadResult(DictSearchResult result, {bool isUrl = true, isForce = true}) {
    this.result = result;
    this.isUrl = isUrl;
    isForceLoadContent = isForce;
    notifyType = _NotifyType.loadContent;
    notifyListeners();
  }

  changeDict(DictItem dict) {
    change2dict = dict;
    notifyType = _NotifyType.changeDict;
    notifyListeners();
  }

  takePhoto() {
    notifyType = _NotifyType.takePhoto;
    notifyListeners();
  }
}

// ignore: must_be_immutable
class DictGroupNativeWidget extends StatefulWidget {
  DictGroupNativeWidget(
      {super.key,
      required this.groupIndex,
      required this.controller,
      required this.onSearchWord,
      required this.type,
      this.onDictChanged});

  int groupIndex;
  DictGroupNativeWidgetController controller;
  DictWrapperType type;

  Function(int tabIndex)? onDictChanged;
  Function(String word) onSearchWord;

  @override
  State<DictGroupNativeWidget> createState() => _DictGroupNativeWidgetState();
}

class _GroupResultItem {
  _GroupResultItem(this.index, this.result);
  int index;
  DictSearchResult result;
}

class _DictGroupNativeWidgetState extends State<DictGroupNativeWidget> {
  int _tabIndex = 0;
  DictPageViewWidgetController? _controller;
  final _lastLoadStringResult = <String, String>{};
  final _lastLoadSearchResult = <String, _GroupResultItem>{};

  _genFormatedStr(DictSearchResult r, {groupIndex = 0}) async {
    DictItem? item = r.dict;
    DictSearchResult trueResult = r;
    if (r.dict?.isGroup == true && r.groupResult.isNotEmpty) {
      trueResult = r.groupResult[groupIndex];
      item = trueResult.dict;
    }

    if (item == null) return '';
    return await DictResultFormator.format(item, trueResult, 0, isGroup: r.dict?.isGroup);
  }

  DictMgr get dictMgr =>
      widget.type == DictWrapperType.main ? DictMgr.instance : DictMgr.tempInstance;

  _updateSearchResult(bool isForce) async {
    final r = _currSearchResult;
    if (r == null) return;
    // 如果结果一样，则不load，保持原来的结果，这样为了做到切换TAB，比较两个词典结果的效果。因为滚动条位置没变。
    final group = dictMgr.getGroupByIndex(widget.groupIndex);

    final dictId = group.items[_tabIndex].id;

    var formatedRet = await _genFormatedStr(r.result, groupIndex: r.index);

    var canLoadUrl = false;
    if (isForce) {
      canLoadUrl = true;
    } else {
      if (_lastLoadStringResult[dictId] != formatedRet.content) {
        canLoadUrl = true;
      }
    }

    _lastLoadStringResult[dictId] = formatedRet.content;
    if (canLoadUrl) _controller?.loadUrl(_tabIndex, formatedRet.url);
  }

  @override
  void dispose() {
    FishEventBus.offEvent<DictSettingChangedEvent>(_onDictSettingChangedEvent);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() async {
      final group = dictMgr.getGroupByIndex(widget.groupIndex);
      if (widget.controller.notifyType == _NotifyType.loadContent) {
        final dictId = group.items[_tabIndex].id;
        // 存起来，groupDict要显示UI。
        _lastLoadSearchResult[dictId] = _GroupResultItem(0, widget.controller.result);
        _updateSearchResult(widget.controller.isForceLoadContent);
      } else if (widget.controller.notifyType == _NotifyType.changeDict) {
        int index = group.items.indexOf(widget.controller.change2dict);
        if (index >= 0 && index != _tabIndex) {
          _tabIndex = index;
          _controller?.changeTab(index);
          dictMgr.setCurrentGroupCurrDictIndex(index: _tabIndex);
        }
      } else if (widget.controller.notifyType == _NotifyType.takePhoto) {
        final imgData = await _controller?.takePhoto(_tabIndex);
        if (imgData != null) {
          final saveResult = await ImageGallerySaver.saveImage(imgData, quality: 100);
          if (saveResult != null && saveResult['isSuccess'] == true) {
            String imagePath = saveResult['filePath'];
            const filePre = 'file://';
            if (imagePath.startsWith(filePre)) {
              imagePath = imagePath.substring(filePre.length);
              ShareMgr.instance.shareFile(imagePath);
            } else if (!imagePath.startsWith('/')) {
              ShareMgr.instance.shareStream(imgData, '.png');
            }

            _showTakePhotoResult(true);
            return;
          }
        }

        _showTakePhotoResult(false);
      }
    });

    FishEventBus.onEvent<DictSettingChangedEvent>(_onDictSettingChangedEvent);
  }

  _onDictSettingChangedEvent(DictSettingChangedEvent event) {
    if (event.groupIndex == widget.groupIndex) {
      final tab = dictMgr.allGroup[widget.groupIndex];
      _lastLoadStringResult.clear();
      _tabIndex = dictMgr.getCurrentDictItemIndexInGroup(index: widget.groupIndex);
      _controller?.loadTabs(tab.itemsJson());
      _lastLoadSearchResult.clear();
      _lastLoadStringResult.clear();
      _controller?.changeTab(_tabIndex);
      // 更新结果，因为如果是GROUP的话，不更新结果，会导致INDEX错乱
      _updateSearchResult(false);
    }
  }

  _showTakePhotoResult(bool r) {
    if (r) {
      UiUtils.toast(content: '已複製到相冊');
    } else {
      UiUtils.toast(content: '截圖失敗~');
    }
  }

  _shouldInterceptRequest(dynamic param, {userDictIndex = -1}) async {
    final url = param['url'];
    if (!url.startsWith('file:///')) return null;
    String localDir = await PathConfig.resultDir;
    String filePre = 'file://$localDir';
    final urlFilePath = url.substring(filePre.length);
    final group = dictMgr.getGroupByIndex(widget.groupIndex);
    final tabIndex = userDictIndex == -1 ? param['tabIndex'] : userDictIndex;
    var buf = await group.items[tabIndex].loadResource(urlFilePath);

    if (buf != null) {
      String filePath = p.join(localDir, urlFilePath);
      var file = File(filePath);
      final dir = Directory(p.dirname(filePath));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      var handler = await file.open(mode: FileMode.write);
      await handler.writeFrom(buf);
      await handler.close();
    }
    return null;
  }

  static const _mdictSoundSheme = 'sound://';
  static const _mdictEntrySheme = 'entry://';
  static FishAudioPlayer? _audioPlayer;
  _shouldOverrideUrlLoading(dynamic param, {isPopup = false}) async {
    String url = Uri.decodeFull(param['url']);
    final group = dictMgr.getGroupByIndex(widget.groupIndex);
    if (url.startsWith('http://') || url.startsWith('https://')) {
      if (group.items[_tabIndex].isWeb()) {
        return false;
      }
      NavigatorUtils.go(context, AppRouteName.goUrl, GoUrlPageParam('', url));
      return true;
    } else if (url.startsWith(_mdictSoundSheme)) {
      final path = url.substring(_mdictSoundSheme.length);
      final data = await group.items[_tabIndex].loadResource('\\$path');
      if (data != null) {
        _audioPlayer ??= FishAudioPlayer();
        await _audioPlayer!.setBytes(data);
        await _audioPlayer!.play();
      }
      return true;
    } else if (url.startsWith(_mdictEntrySheme)) {
      final word = url.substring(_mdictEntrySheme.length);
      widget.onSearchWord(word);
      if (isPopup) {
        _pop();
      }
      return true;
    } else {
      // 非http禁止加载
      if (group.items[_tabIndex].isWeb()) {
        return true;
      }
    }

    const goGroupPre = 'fishdict://go?group=';
    if (url.startsWith(goGroupPre)) {
      final catalogHtml = await group.items[_tabIndex].getCatalog();
      if (catalogHtml.isEmpty) {
        UiUtils.toast(content: '暫不支援綱目查看');
      } else {
        String catalogToGo = url.substring(goGroupPre.length);
        final path = await DictResultFormator.formatCatalog(catalogHtml, catalogToGo);
        _showCatalog(path);
      }

      return true;
    }
    String wordPre = 'fishdict://go?word=';
    if (url.startsWith(wordPre) == true) {
      var word = url.substring(wordPre.length);
      widget.onSearchWord(word);
      if (isPopup) {
        _pop();
      }
      return true;
    }
    return false;
  }

  _showCatalog(String htmlPath) {
    final size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (context) {
          return Container(
              color: Colors.white,
              width: size.width * 0.9,
              height: size.height * 0.9,
              child: Stack(
                children: [
                  DictPageViewWidget(
                    onDictPageViewCreated: (DictPageViewWidgetController controller) async {
                      controller.loadTabs([
                        {"name": "綱目查看"}
                      ]);
                      controller.changeTab(0);
                      Timer(const Duration(milliseconds: 10), () {
                        controller.loadUrl(0, htmlPath);
                      });

                      controller.setMethodHandler((method, param) async {
                        FishDebugUtils.log("... $method $param");
                        switch (method) {
                          case 'shouldInterceptRequest':
                            return await _shouldInterceptRequest(param, userDictIndex: _tabIndex);
                          case 'shouldOverrideUrlLoading':
                            return await _shouldOverrideUrlLoading(param, isPopup: true);
                          case 'search':
                            await _search(param);
                            return _pop();
                          case 'shareImage':
                            await _shareImage(param);
                            return;
                        }

                        return null;
                      });
                    },
                  ),
                  Positioned(
                      left: 0,
                      top: 0,
                      child: IconButton(
                        onPressed: () {
                          NavigatorUtils.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ))
                ],
              ));
        });
  }

  _pop() {
    NavigatorUtils.pop(context);
  }

  _onPageSelected(dynamic param) async {
    _tabIndex = param['tabIndex'];

    dictMgr.setCurrentIndex(groupIndex: widget.groupIndex, index: _tabIndex);
    if (widget.onDictChanged != null) {
      widget.onDictChanged!(_tabIndex);
    }
    return null;
  }

  bool get _currentTabDicIsGroup {
    final group = dictMgr.getGroupByIndex(widget.groupIndex);
    if (group.items.isEmpty) return false;
    return group.items[_tabIndex].isGroup;
  }

  _GroupResultItem? get _currSearchResult {
    final group = dictMgr.getGroupByIndex(widget.groupIndex);
    if (group.items.isEmpty) return null;
    final dict = group.items[_tabIndex];
    final r = _lastLoadSearchResult[dict.id];
    if (r == null) return null;
    return r;
  }

  _search(dynamic param) async {
    String? word = param['word'];
    if (word?.isNotEmpty == true) {
      widget.onSearchWord(word!);
    }
    return null;
  }

  _shareImage(dynamic param) async {
    String url = param['url'];
    String filePre = 'file://';
    if (url.startsWith(filePre)) {
      ShareMgr.instance.shareFile(url.substring(filePre.length));
    } else {
      final data = await HttpUtils.request(url: url, parseJson: false, appendTimestamp: false);
      if (data != null) {
        ShareMgr.instance.shareStream(data, '.png');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      DictPageViewWidget(
        onDictPageViewCreated: (DictPageViewWidgetController controller) async {
          _controller = controller;

          _tabIndex = dictMgr.getCurrentDictItemIndexInGroup(index: widget.groupIndex);
          final tabsInfo = dictMgr.getGroupByIndex(widget.groupIndex).itemsJson();
          _controller?.loadTabs(tabsInfo);
          _lastLoadSearchResult.clear();
          _lastLoadStringResult.clear();
          _controller?.changeTab(_tabIndex);

          _controller?.setMethodHandler((method, param) async {
            FishDebugUtils.log("... $method $param");
            switch (method) {
              case 'shouldInterceptRequest':
                return await _shouldInterceptRequest(param);
              case 'shouldOverrideUrlLoading':
                return await _shouldOverrideUrlLoading(param);
              case 'onPageSelected':
                return await _onPageSelected(param);
              case 'search':
                return await _search(param);
              case 'shareImage':
                await _shareImage(param);
            }

            return null;
          });
        },
      ),
      Positioned(
          bottom: 0,
          left: 0,
          height: 48,
          right: 0,
          child: Visibility(
            visible:
                _currentTabDicIsGroup && _currSearchResult?.result.groupResult.isNotEmpty == true,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  decoration: const BoxDecoration(color: Colors.black87),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _currSearchResult?.result.groupResult.length ?? 0,
                      itemBuilder: (context, index) {
                        var width = MediaQuery.of(context).size.width /
                            _currSearchResult!.result.groupResult.length;
                        if (width < 50) {
                          width = 50;
                        }
                        final ri = _currSearchResult!.result.groupResult[index];
                        final isCurrentItem = _currSearchResult!.index == index;
                        return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currSearchResult?.result.dict
                                    ?.setGroupCurrentIndexById(ri.dict?.id ?? '');
                                _currSearchResult?.index = index;
                                _updateSearchResult(true);
                              });
                            },
                            child: Container(
                                padding: const EdgeInsets.only(left: 4, right: 4),
                                alignment: Alignment.center,
                                width: width - 8,
                                height: 48,
                                color: const Color.fromARGB(1, 0, 0, 0),
                                child: Text(
                                  ri.dict?.name ?? '',
                                  style: isCurrentItem
                                      ? const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)
                                      : const TextStyle(
                                          color: Colors.white54,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14),
                                )));
                      }),
                )),
          ))
    ]);
  }
}
