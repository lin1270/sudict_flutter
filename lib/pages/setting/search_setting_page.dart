import 'package:flutter/material.dart';
import 'package:sudict/modules/setting/index.dart';
import 'package:sudict/modules/ui_comps/fish_toggle_switch/index.dart';

class SearchSettingPage extends StatefulWidget {
  const SearchSettingPage({super.key});
  @override
  State<SearchSettingPage> createState() => _SearchSettingPageState();
}

class _SearchSettingPageState extends State<SearchSettingPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('搜尋設定')),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                      child: Text(
                    '跳轉鍊接',
                    style: TextStyle(fontSize: 18),
                  )),
                  FishToggleSwitchWidget(
                    isOn: Setting.instance.dictInnerJumpPage,
                    onText: '彈框',
                    offText: '不彈框',
                    onChanged: (value) {
                      setState(() {
                        Setting.instance.dictInnerJumpPage = value;
                      });
                    },
                  )
                ],
              ),
            )
          ]),
        ));
  }
}
