import 'package:flutter/material.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/history/history_mgr.dart';
import 'package:sudict/modules/share/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/history/history_controller.dart';

// ignore: must_be_immutable
class HistoryTab extends StatefulWidget {
  HistoryTab({super.key, required this.controller});

  HistoryController controller;

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> with AutomaticKeepAliveClientMixin {
  final List<String> _data = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _data.addAll(HistoryMgr.instance.words);
    widget.controller.addListener(
      () async {
        if (widget.controller.notifyType == 0) {
          final r = await UiUtils.showConfirmDialog(context: context, content: '確定要清除所有搜尋痕跡嗎?');
          if (r) {
            HistoryMgr.instance.clear();
            _data.clear();
            _data.addAll(HistoryMgr.instance.words);
            setState(() {});
          }
        } else {
          String txt = HistoryMgr.instance.words.join(" ");
          ShareMgr.instance.shareString(txt);
        }
      },
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _data.isEmpty
        ? const Padding(padding: EdgeInsets.all(16), child: Text('暫無數據'))
        : GridView.builder(
            //将所有子控件在父控件中填满
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, //每行几列
                childAspectRatio: 2),
            itemCount: _data.length,
            itemBuilder: (context, index) {
              return TextButton(
                onPressed: () {
                  FishEventBus.fire(SearchWordEvent(_data[index]));
                  NavigatorUtils.pop(context);
                },
                child: Text(
                  _data[index],
                  style: const TextStyle(fontFamily: 'KaiXinSong'),
                ),
              );
            },
          );
  }

  @override
  bool get wantKeepAlive => true;
}
