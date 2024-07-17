import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/audio/common.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/jingyuan/xiguicidi_audio_mgr.dart';

class XiguicidiCatalogWidget extends StatefulWidget {
  const XiguicidiCatalogWidget({super.key});
  @override
  State<XiguicidiCatalogWidget> createState() => _XiguicidiCatalogWidgetState();
}

class _XiguicidiCatalogWidgetState extends State<XiguicidiCatalogWidget> {
  final List<CatalogItem> _data = [];
  final List<CatalogItem> _searchResult = [];
  final _openccModeT2S = T2S();
  final _openccModeS2T = T2S();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _init() async {
    for (var i = 0; i < XiguicidiAudioMgr.instance.catalogLength; ++i) {
      _data.add(XiguicidiAudioMgr.instance.getCatalogItemAtSync(i)!);
    }
    _searchCore('');
  }

  _showCatalogDialog(CatalogItem catalog, int catalogIndex) {
    final size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (statefullContext, setState) {
              return AlertDialog(
                  content: SizedBox(
                      width: size.width,
                      height: size.height * 0.8,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  catalog.name,
                                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                                )),
                                Text('  共${catalog.length}集'),
                                IconButton(
                                    onPressed: () {
                                      _setCurrentCatalog(catalog);
                                      NavigatorUtils.pop(context);
                                    },
                                    icon: const Icon(Icons.play_arrow_outlined))
                              ],
                            ),
                          ),
                          Expanded(
                              child: FlutterListView.builder(
                                  itemCount: catalog.length,
                                  itemBuilder: (lvContext, index) {
                                    final item = catalog.getItemAt(index);
                                    return FishInkwell(
                                      onDoubleTap: () {
                                        catalog.setCurrIndex(index);
                                        _setCurrentCatalog(catalog);
                                        setState(() {});
                                      },
                                      child: Container(
                                          decoration: const BoxDecoration(
                                            border:
                                                Border(bottom: BorderSide(color: Colors.black12)),
                                          ),
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10, left: 8, right: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text(item?.name ?? '',
                                                      style: TextStyle(
                                                          overflow: TextOverflow.ellipsis,
                                                          color: index == catalog.currIndex
                                                              ? UIConfig.selectedColor
                                                              : Colors.black)))
                                            ],
                                          )),
                                    );
                                  }))
                        ],
                      )));
            },
          );
        });
  }

  ListView _catalogListViewWidget() {
    const height = 48.0;
    return ListView.builder(
        itemCount: _searchResult.length,
        itemBuilder: (content, index) {
          final catalog = _searchResult[index];
          return FishInkwell(
            onTap: () {
              _showCatalogDialog(catalog, index);
              setState(() {});
            },
            child: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                ),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    color: catalog == XiguicidiAudioMgr.instance.currCatalogSync
                        ? UIConfig.selectedColor
                        : Colors.transparent),
                height: height,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        catalog.name,
                        style: const TextStyle(overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _setCurrentCatalog(catalog);
                        },
                        icon: const Icon(Icons.play_arrow_outlined))
                  ],
                )),
          );
        });
  }

  void _searchCore(String v) async {
    _searchResult.clear();
    if (v.isEmpty) {
      _searchResult.addAll(_data);
      setState(() {});
      return;
    }
    var strToSearchSimple = await ChineseConverter.convert(v, _openccModeT2S);
    var strToSearchTr = await ChineseConverter.convert(v, _openccModeS2T);

    final allAudioCatalog = XiguicidiAudioMgr.instance.getCatalogItemAtSync(0);
    if (allAudioCatalog == null) return;
    int i = 0;
    var j = 1;
    while (i < allAudioCatalog.length) {
      final item = allAudioCatalog.getItemAt(i);
      bool handled = false;
      if (item?.name.contains(strToSearchSimple) == true ||
          item?.name.contains(strToSearchTr) == true) {
        for (; j < XiguicidiAudioMgr.instance.catalogLength && !handled; ++j) {
          final c = XiguicidiAudioMgr.instance.getCatalogItemAtSync(j);
          if (c == null) break;
          if (c.begin <= i + 1 && c.end >= i + 1) {
            _searchResult.add(c);

            i = c.end;
            handled = true;
          }
        }
      }

      if (!handled) ++i;
    }

    if (_searchResult.isNotEmpty) {
      _searchResult.insert(0, allAudioCatalog);
    }

    for (var i = 0; i < XiguicidiAudioMgr.instance.catalogLength; ++i) {
      final x = XiguicidiAudioMgr.instance.getCatalogItemAtSync(i);
      if (x == null) continue;
      if (x.name.contains(strToSearchSimple) || x.name.contains(strToSearchTr)) {
        if (!_searchResult.contains(x)) {
          _searchResult.add(x);
        }
      }
    }
    setState(() {});
  }

  void _setCurrentCatalog(CatalogItem catalog) {
    XiguicidiAudioMgr.instance.setCatalog(catalog);
    FishEventBus.fire(UpdateAudioCatalog(AudioVideoPlayCatalog.xiguicidi, true));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  UiUtils.showAlertDialog(
                      context: context, content: '分類不包含全部。主要原因爲有些音頻太獨立，只有一箇，無法分類。');
                },
                icon: const Icon(Icons.info_outline))
          ],
          flexibleSpace: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextField(
                    onChanged: (v) {
                      v = v.trim();

                      _searchCore(v);
                    },
                    decoration: const InputDecoration(
                      hintText: '搜尋',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 48, right: 48),
                    ),
                  ))),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _catalogListViewWidget(),
        ));
  }
}
