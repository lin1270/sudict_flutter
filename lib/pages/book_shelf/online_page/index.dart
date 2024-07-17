import 'package:flutter/material.dart';
import 'package:sudict/app/theme_manager.dart';
import 'package:sudict/modules/http/misc.dart';
import 'package:sudict/modules/tab/tab_param.dart';
import 'package:sudict/pages/book_shelf/online_page/construct.dart';
import 'package:sudict/pages/book_shelf/online_page/tab.dart';

class OnlineBookPage extends StatefulWidget {
  const OnlineBookPage({super.key});

  @override
  State<OnlineBookPage> createState() => _OnlineBookPageState();
}

class _OnlineBookPageState extends State<OnlineBookPage> with SingleTickerProviderStateMixin {
  final List<TabParam> _tabsData = [];
  TabController? _tabController;
  final _bookData = <OnlineBookCatalog>[];

  static dynamic _data;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  _init() async {
    _data ??= await MiscHttpApi.getBooks();
    if (_data != null) {
      for (var i = 0; i < _data.length; ++i) {
        _bookData.add(OnlineBookCatalog.fromJson(_data[i]));
      }
    }

    for (final catalog in _bookData) {
      _tabsData.add(TabParam(title: catalog.name, widget: OnlineBookTab(catalog: catalog)));
    }

    _tabController = TabController(initialIndex: 0, length: _tabsData.length, vsync: this);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeManager.getTheme().appBarTheme.backgroundColor,
        appBar: _tabController == null
            ? null
            : AppBar(
                flexibleSpace: SafeArea(
                    child: TabBar(
                        isScrollable: true,
                        controller: _tabController,
                        tabs: _tabsData.map((e) {
                          return Tab(text: e.title);
                        }).toList())),
              ),
        body: SafeArea(
            child: _tabController == null
                ? const Text("加載中...")
                : Column(children: [
                    Expanded(
                        child: TabBarView(
                      controller: _tabController,
                      children: _tabsData.map((e) => e.widget).toList(),
                    )),
                  ])));
  }
}
