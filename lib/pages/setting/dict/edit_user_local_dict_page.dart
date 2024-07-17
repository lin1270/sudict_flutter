import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/fish_toggle_switch/index.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';

class EditUserLocalDictPage extends StatefulWidget {
  const EditUserLocalDictPage({super.key, this.arguments});
  final dynamic arguments;

  @override
  State<EditUserLocalDictPage> createState() => _EditUserLocalDictPageState();
}

class _EditUserLocalDictPageState extends State<EditUserLocalDictPage> {
  final _nameTextFieldController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _name = '';
  bool _bigFont = false;
  var _isFirstLoad = true;
  var _canChangedBigFont = false;

  @override
  void dispose() {
    _nameTextFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    DictItem item = widget.arguments;
    _name = item.name;
    _bigFont = item.bigFont;
    _canChangedBigFont = item.type == DictType.mdict;

    WidgetsBinding.instance.addPostFrameCallback((mag) {
      if (_isFirstLoad) {
        _nameTextFieldController.text = _name;
        _isFirstLoad = false;
      }
    });
  }

  _onDone() async {
    if (_name.isEmpty) {
      UiUtils.toast(content: '請輸入名稱');
      return;
    }

    DictItem item = widget.arguments;
    item.name = _name;

    item.bigFont = _bigFont;
    DictMgr.instance.saveCfg();
    NavigatorUtils.pop(context, true);
  }

  _onDelete() async {
    bool ret = await UiUtils.showConfirmDialog(context: context, content: '確定要刪除該辭典嗎?');
    if (ret) {
      DictItem item = widget.arguments;
      DictMgr.instance.deleteDict(item);
      _pop();
    }
  }

  _pop() {
    NavigatorUtils.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    actions.add(IconButton(onPressed: _onDelete, icon: const Icon(Icons.delete_outline)));

    actions.add(IconButton(onPressed: _onDone, icon: const Icon(Icons.check)));

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('修改本地辭典'),
          actions: actions,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              '名稱',
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
                controller: _nameTextFieldController,
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  prefixIcon: Icon(Icons.mood),
                )),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            _canChangedBigFont
                ? Row(
                    children: [
                      const Text('支援擴展區漢字  '),
                      FishToggleSwitchWidget(
                        isOn: _bigFont,
                        onChanged: (b) {
                          setState(() {
                            _bigFont = b;
                          });
                        },
                      ),
                      IconButton(
                          onPressed: () {
                            UiUtils.showAlertDialog(context: context, content: '''
如果辭典中只展示常規漢字，請不要開啟該功能。\n
如果您不是很理解這個功能，請不要開啟該功能。
''');
                          },
                          icon: const Icon(
                            Icons.question_mark,
                            size: 18,
                          ))
                    ],
                  )
                : const SizedBox(
                    height: 16,
                  )
          ]),
        ));
  }
}
