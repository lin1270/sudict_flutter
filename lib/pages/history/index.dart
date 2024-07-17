import 'package:flutter/material.dart';
import 'package:sudict/modules/tab/tab_param.dart';
import 'package:sudict/pages/history/favorite_tab.dart';
import 'package:sudict/pages/history/history_controller.dart';
import 'package:sudict/pages/history/history_tab.dart';

var _lastTabIndex = 0;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late final List<TabParam> _tabsData;
  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final controllers = [HistoryController(), HistoryController()];

    _tabsData = [
      TabParam(
          title: '搜尋痕跡',
          widget: HistoryTab(
            controller: controllers[0],
          ),
          param: controllers[0]),
      TabParam(
          title: '備忘本',
          widget: FavoriteTab(
            controller: controllers[1],
          ),
          param: controllers[1]),
    ];

    _tabController =
        TabController(initialIndex: _lastTabIndex, length: _tabsData.length, vsync: this);
    _tabController.addListener(() {
      _lastTabIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: SafeArea(
              child: TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  tabs: _tabsData.map((e) {
                    return Tab(text: e.title);
                  }).toList())),
          actions: [
            IconButton(
                onPressed: () {
                  HistoryController controller = _tabsData[_tabController.index].param;
                  controller.share();
                },
                icon: const Icon(
                  Icons.share_outlined,
                  size: 20,
                )),
            IconButton(
                onPressed: () {
                  HistoryController controller = _tabsData[_tabController.index].param;
                  controller.clear();
                },
                icon: const Icon(Icons.delete_outline))
          ],
        ),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: _tabsData.map((e) => e.widget).toList(),
          )),
        ])));
  }
}
