import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/pages/jgw/mgr.dart';
import 'package:sudict/pages/router.dart';

class JgwCatalogPage extends StatefulWidget {
  const JgwCatalogPage({super.key});
  @override
  State<JgwCatalogPage> createState() => _JgwCatalogPageState();
}

class _JgwCatalogPageState extends State<JgwCatalogPage> {
  dynamic _data;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _data = await JgwMgr.instance.data;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('分類')),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: _data == null
                ? Container()
                : ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      final catalog = _data![index];
                      final parts = catalog['parts'];
                      return Column(
                        children: [
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
                              margin: EdgeInsets.only(top: index == 0 ? 0 : 32, bottom: 4),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black.withOpacity(0.2),
                                      Colors.black.withOpacity(0.3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                catalog['name'],
                                style: const TextStyle(fontSize: 18),
                              )),
                          Wrap(
                            children: List.generate(parts.length, (partIndex) {
                              final part = parts[partIndex];
                              bool isCurrent = index == JgwMgr.instance.currPosInfo.catalogIndex &&
                                  partIndex == JgwMgr.instance.currPosInfo.partIndex;
                              return FishInkwell(
                                  onTap: () {
                                    JgwMgr.instance.setCurrentItem(index, partIndex, 0);
                                    NavigatorUtils.go(context, AppRouteName.jgwPrictice, false);
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 8, right: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isCurrent ? Colors.blue : Colors.transparent,
                                        )),
                                    child: Text(
                                      part['name'],
                                      style: TextStyle(
                                          fontFamily: 'jgwiconfont',
                                          fontSize: 40,
                                          color: isCurrent ? Colors.blue : Colors.black),
                                    ),
                                  ));
                            }),
                          )
                        ],
                      );
                    })));
  }
}
