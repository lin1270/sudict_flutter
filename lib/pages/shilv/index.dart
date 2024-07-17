import 'package:flutter/material.dart';
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/string.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/router.dart';

class ShilvPage extends StatefulWidget {
  const ShilvPage({super.key});
  @override
  State<ShilvPage> createState() => _ShilvPageState();
}

class _ShilvPageState extends State<ShilvPage> {
  final _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _editController.text = await LocalStorageUtils.getString(LocalStorageKeys.shilvLastInfo) ?? '';
    setState(() {});
  }

  _saveCfg() {
    LocalStorageUtils.setString(LocalStorageKeys.shilvLastInfo, _editController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('近體詩詩律'),
          actions: [
            IconButton(
                onPressed: () {
                  UiUtils.showAlertDialog(
                      context: context, content: '自動分析規則使用高小方教授的方法，具體可在bilibili上搜尋其古漢語視頻。');
                },
                icon: const Icon(Icons.info_outline)),
            TextButton(
                onPressed: () {
                  NavigatorUtils.go(context, AppRouteName.shilvPingshuiyun, null);
                },
                child: const Text('平水韻'))
          ],
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                        child: Stack(children: [
                      TextField(
                        style: const TextStyle(fontSize: 18),
                        controller: _editController,
                        maxLines: 99999999,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(16),
                            border: OutlineInputBorder(),
                            hintText: '請輸入絕句或律詩',
                            filled: true,
                            fillColor: Colors.white70),
                        onChanged: (value) {
                          _saveCfg();
                        },
                      ),
                      Positioned(
                          right: 0,
                          bottom: 0,
                          child: Column(children: [
                            IconButton(
                                onPressed: () {
                                  _editController.text = "";
                                  _saveCfg();
                                },
                                icon: const Icon(Icons.close)),
                            IconButton(
                                onPressed: () {
                                  StringUtils.copyToClipboard(_editController.text);
                                },
                                icon: const Icon(Icons.copy)),
                          ]))
                    ])),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              _editController.text =
                                  await ChineseConverter.convert(_editController.text, S2T());
                              _saveCfg();
                            },
                            child: const Text('簡=>正'),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              String content = _editController.text.trim();
                              if (content.isEmpty) {
                                UiUtils.toast(content: '請輸入詩文內容');
                                return;
                              }

                              NavigatorUtils.go(context, AppRouteName.shilvAnalysis, content);
                            },
                            child: const Text(
                              '分析',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ))));
  }
}
