import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:sudict/pages/shilv/pingshuiyun_common_widget.dart';
import 'package:sudict/pages/shilv/pingshuiyun_data_mgr.dart';

class PingshuiyunPage extends StatefulWidget {
  const PingshuiyunPage({super.key});
  @override
  State<PingshuiyunPage> createState() => _PingshuiyunPageState();
}

class _PingshuiyunPageState extends State<PingshuiyunPage> {
  final _searchResult = <PingshuiyunCatalog>[];
  bool _showResult = false;
  String _searchWord = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await PingshuiyunDataMgr.instance.init();

    setState(() {});
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
                _searchWord = v.trim();
                if (_searchWord.isEmpty) {
                  _showResult = false;
                } else {
                  _showResult = true;
                  _searchResult.clear();
                  final foundResult = PingshuiyunDataMgr.instance.find(_searchWord);
                  _searchResult.addAll(foundResult);
                }
                setState(() {});
              },
              decoration: const InputDecoration(
                hintText: '輸入漢字搜尋',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 48, right: 48),
              ),
            ),
          )),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: _showResult
                ? resultWidget(_searchResult, _searchWord)
                : groupWidget((catalog) {
                    final size = MediaQuery.of(context).size;
                    MyDialog.popup(catalogWidget(catalog, catalog.items[0]),
                        isScrollControlled: true, height: size.height * 0.6);
                  })));
  }
}
