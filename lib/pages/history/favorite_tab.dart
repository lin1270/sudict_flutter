import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/history/favorite_mgr.dart';
import 'package:sudict/modules/share/index.dart';
import 'package:sudict/modules/utils/navigator.dart';

import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/history/history_controller.dart';

// ignore: must_be_immutable
class FavoriteTab extends StatefulWidget {
  FavoriteTab({super.key, required this.controller});

  HistoryController controller;
  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> with AutomaticKeepAliveClientMixin {
  final List<FavoriteGroupItem> _data = [];
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _data.addAll(await FavoriteMgr.instance.getAll());

    widget.controller.addListener(
      () async {
        if (widget.controller.notifyType == 0) {
          final r = await UiUtils.showConfirmDialog(context: context, content: '確定要清除備忘本嗎?');
          if (r) {
            FavoriteMgr.instance.clear();
            _data.clear();
            _data.addAll(await FavoriteMgr.instance.getAll());
            FishEventBus.fire(ClearFavoriteEvent());
            setState(() {});
          }
        } else {
          String txt = "";
          for (final group in FavoriteMgr.instance.words) {
            txt += group.group ?? "";
            txt += '\r\n';
            txt += group.words.join(" ");
            txt += "\r\n\r\n";
          }
          ShareMgr.instance.shareString(txt);
        }
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _data.isEmpty || (_data.length == 1 && _data[0].words.isEmpty)
        ? const Padding(padding: EdgeInsets.all(16), child: Text('暫無數據'))
        : FlutterListView(
            delegate: FlutterListViewDelegate(
            (context, index) {
              FavoriteGroupItem item = _data[index];
              return Visibility(
                  visible: item.words.isNotEmpty,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text(
                        item.group!,
                        style: const TextStyle(color: Colors.black38, fontStyle: FontStyle.italic),
                      ),
                    ),
                    GridView.builder(
                      //将所有子控件在父控件中填满
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, //每行几列
                          childAspectRatio: 2),
                      itemCount: item.words.length,
                      itemBuilder: (context, index) {
                        return TextButton(
                          onPressed: () {
                            FishEventBus.fire(SearchWordEvent(item.words[index]));
                            NavigatorUtils.pop(context);
                          },
                          child: Text(item.words[index],
                              style: const TextStyle(fontFamily: 'KaiXinSong')),
                        );
                      },
                    )
                  ]));
            },
            childCount: _data.length,
          ));
  }

  @override
  bool get wantKeepAlive => true;
}
