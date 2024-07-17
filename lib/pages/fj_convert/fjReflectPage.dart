// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:sudict/modules/utils/assets.dart';
import 'package:sudict/modules/utils/ui.dart';
// ignore: depend_on_referenced_packages
import 'package:xml/xml.dart';

class FjReflectPage extends StatefulWidget {
  const FjReflectPage({super.key});

  @override
  State<FjReflectPage> createState() => _FjReflectPageState();
}

class _Item {
  _Item(this.j, this.f, this.d, this.e);
  String j;
  String f;
  String d;
  String e;
}

class _FjReflectPageState extends State<FjReflectPage> with SingleTickerProviderStateMixin {
  List<_Item>? _data;
  List<_Item>? _searchResult;
  late XmlDocument _xmlDocument;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    final txt = await AssetsUtils.readStringFile('assets/opencc/reflect.xml');
    if (txt?.isNotEmpty == true) {
      _xmlDocument = XmlDocument.parse(txt!);
      _data = <_Item>[];
      for (final node in _xmlDocument.rootElement.children) {
        if (node is XmlElement) {
          _data!.add(_Item(node.children[1].text, node.children[3].text, node.children[5].text,
              node.children[7].text));
        }
      }
      _searchResult = <_Item>[];
      _searchResult!.addAll(_data!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextField(
                    onChanged: (v) {
                      if (_searchResult == null) return;
                      v = v.trim();
                      _searchResult!.clear();
                      if (v.isEmpty) {
                        _searchResult!.addAll(_data!);
                        setState(() {});
                        return;
                      }

                      for (final item in _data!) {
                        if (item.f.contains(v) || item.j.contains(v)) {
                          _searchResult!.add(item);
                        }
                      }
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      hintText: '輸入漢字搜尋',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 48, right: 48),
                    ),
                  ))),
          actions: [
            IconButton(
              onPressed: () {
                UiUtils.showAlertDialog(context: context, content: '此數據來自byvoid的opencc。');
              },
              icon: const Icon(Icons.info_outline),
            )
          ],
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: _searchResult == null
                    ? const Text("加載中..")
                    : FlutterListView.builder(
                        itemCount: _searchResult!.length,
                        itemBuilder: (context, index) {
                          final item = _searchResult!.elementAt(index);
                          return Card(
                            child: Padding(
                                padding: const EdgeInsets.all(8),
                                child:
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(
                                    '簡化字：${item.j}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '繁體字：${item.f}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '釋義：${item.d}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '示例：${item.e}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ])),
                          );
                        }))));
  }
}
