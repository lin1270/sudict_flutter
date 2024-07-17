import 'package:flutter/material.dart';
import 'package:sudict/app/theme_manager.dart';
import 'package:sudict/modules/http/misc.dart';
import 'package:sudict/modules/utils/navigator.dart';

class OnlineStudyResourcePage extends StatefulWidget {
  const OnlineStudyResourcePage({super.key});

  @override
  State<OnlineStudyResourcePage> createState() => _OnlineStudyResourcePageState();
}

class _OnlineStudyResourcePageState extends State<OnlineStudyResourcePage>
    with SingleTickerProviderStateMixin {
  dynamic _data;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _data = await MiscHttpApi.getOnlineStudyResource();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeManager.getTheme().appBarTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('網路資源'),
        ),
        body: SafeArea(
            child: _data == null
                ? const Column(
                    children: [Text('      加載中...')],
                  )
                : ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      dynamic item = _data[index];
                      final children = <Widget>[
                        Container(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, bottom: 2, top: index == 0 ? 0 : 16),
                            child: Text(
                              item['name'],
                              style: const TextStyle(fontSize: 14),
                            ))
                      ];
                      final subItems = item['items'];
                      for (dynamic item in subItems) {
                        children.add(GestureDetector(
                            onTap: () {
                              NavigatorUtils.goBrowserUrl(item['url']);
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: ThemeManager.getTheme().scaffoldBackgroundColor,
                              ),
                              padding: const EdgeInsets.only(left: 16, right: 16),
                              child: Container(
                                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                                  decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.black12))),
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(fontSize: 18),
                                  )),
                            )));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                      );
                    })));
  }
}
