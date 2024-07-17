import 'package:flutter/material.dart';
import 'package:sudict/app/theme_manager.dart';
import 'package:sudict/modules/tab/tab_param.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/pages/lookfor_words/common_tab.dart';
import 'package:sudict/pages/lookfor_words/lookfor_dict_mgr.dart';
import 'package:sudict/pages/lookfor_words/part_tab.dart';

class LookforWordsPage extends StatefulWidget {
  const LookforWordsPage({super.key});

  @override
  State<LookforWordsPage> createState() => _LookforWordsPageState();
}

class _LookforWordsPageState extends State<LookforWordsPage> with SingleTickerProviderStateMixin {
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
    _tabsData = [];
    for (var element in LookforDictType.values) {
      var widget =
          element == LookforDictType.part ? const LookforPartTab() : const LookforCommonTab();
      _tabsData.add(TabParam(title: element.name, widget: widget));
    }

    LocalStorageUtils.getInt(LocalStorageKeys.lookforWordDictTab);

    _tabController = TabController(initialIndex: 0, length: _tabsData.length, vsync: this);
    _tabController.addListener(() {
      LookforDictMgr.instance.currType = _tabController.index;
    });

    _loadLookforData();
  }

  _loadLookforData() async {
    await LookforDictMgr.instance.loadDic();
    _tabController.index = LookforDictMgr.instance.currType;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeManager.getTheme().appBarTheme.backgroundColor,
        appBar: AppBar(
          flexibleSpace: SafeArea(
              child: TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  tabs: _tabsData.map((e) {
                    return Tab(text: e.title);
                  }).toList())),
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
