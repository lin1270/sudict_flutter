import 'package:flutter/material.dart';
import 'package:sudict/modules/tab/tab_param.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/pages/dizigui/dusong_tab_widget.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/index.dart';
import 'package:sudict/pages/dizigui/video_tab_widget.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class DiziguiPage extends StatefulWidget {
  const DiziguiPage({super.key});
  @override
  State<DiziguiPage> createState() => _DiziguiPageState();
}

class _DiziguiPageState extends State<DiziguiPage> with SingleTickerProviderStateMixin {
  List<TabParam>? _tabsData;
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _init();
  }

  _init() async {
    _tabsData = [
      TabParam(
        title: '視頻',
        widget: const DiziguiVideoTabWidget(),
      ),
      TabParam(
        title: '讀誦',
        widget: const DiziguiDusongTabWidget(),
      ),
      TabParam(
        title: '功過格',
        widget: const DiziguiGongguogeTabWidget(),
      ),
    ];

    var lastTabIndex = await LocalStorageUtils.getInt(LocalStorageKeys.diziguiLastTabIndex) ?? 0;

    _tabController =
        TabController(initialIndex: lastTabIndex, length: _tabsData!.length, vsync: this);
    _tabController!.addListener(() {
      LocalStorageUtils.setInt(LocalStorageKeys.diziguiLastTabIndex, _tabController!.index);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: SafeArea(
              child: _tabsData == null || _tabController == null
                  ? Container()
                  : TabBar(
                      isScrollable: true,
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      tabs: _tabsData!.map((e) {
                        return Tab(text: e.title);
                      }).toList())),
        ),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: _tabsData == null || _tabController == null
                  ? Container()
                  : TabBarView(
                      controller: _tabController,
                      children: _tabsData!.map((e) => e.widget).toList(),
                    )),
        ])));
  }
}
