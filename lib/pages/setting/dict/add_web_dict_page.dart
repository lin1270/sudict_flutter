import 'package:flutter/material.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/http/misc.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/string.dart';
import 'package:sudict/modules/utils/ui.dart';

class AddWebDictPage extends StatefulWidget {
  const AddWebDictPage({super.key, this.arguments});
  final dynamic arguments;

  @override
  State<AddWebDictPage> createState() => _AddWebDictPageState();
}

class _AddWebDictPageState extends State<AddWebDictPage> {
  final _nameTextFieldController = TextEditingController();
  final _urlTextFieldController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _name = '網·';
  String _url = '';
  bool _bigFont = false;
  bool _isAdd = false;
  var _isFirstLoad = true;

  static dynamic _netDicts;

  @override
  void dispose() {
    _nameTextFieldController.dispose();
    _urlTextFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isAdd = widget.arguments is int;
    if (!_isAdd) {
      DictItem item = widget.arguments;
      _name = item.name;
      _url = item.path;
      _bigFont = item.bigFont;
    }

    WidgetsBinding.instance.addPostFrameCallback((mag) {
      if (_isFirstLoad) {
        _nameTextFieldController.text = _name;
        _urlTextFieldController.text = _url;
        _isFirstLoad = false;
      }
    });
  }

  _onDone() async {
    if (_name.isEmpty) {
      UiUtils.toast(content: '請輸入名稱');
      return;
    }

    if (_url.isEmpty) {
      UiUtils.toast(content: '請輸入網址');
      return;
    }

    if (!_url.startsWith('http://') && !_url.startsWith('https://')) {
      UiUtils.toast(content: '請輸入正確的網址');
      return;
    }
    if (!_url.contains('\${word}')) {
      UiUtils.toast(content: '網址需包含\${word}');
      return;
    }

    if (_isAdd) {
      DictItem item =
          DictItem(StringUtils.uuid(), _name, _url, DictType.web, DictFrom.user, true, false);
      item.bigFont = _bigFont;
      DictMgr.instance.addDict(widget.arguments, item);
      NavigatorUtils.pop(context, true);
    } else {
      DictItem item = widget.arguments;
      item.name = _name;
      item.path = _url;
      item.bigFont = _bigFont;
      item.reload();
      DictMgr.instance.saveCfg();
      NavigatorUtils.pop(context, true);
    }
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

  _loadNetDicts() async {
    if (_netDicts != null) return;
    _netDicts = await MiscHttpApi.getNetDicts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (!_isAdd) {
      actions.add(IconButton(onPressed: _onDelete, icon: const Icon(Icons.delete_outline)));
    }
    actions.add(IconButton(onPressed: _onDone, icon: const Icon(Icons.check)));
    final size = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_isAdd ? '添加網路辭典' : '修改網路辭典'),
          actions: actions,
        ),
        endDrawer: Container(
            width: size.width / 3 * 2,
            height: size.height,
            decoration: const BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SafeArea(
              child: _netDicts == null
                  ? const Text('  加載中...')
                  : ListView.builder(
                      itemCount: _netDicts!.length,
                      itemBuilder: (context, index) {
                        return TextButton(
                          onPressed: () {
                            _nameTextFieldController.text = _name = _netDicts[index]['name'];
                            _urlTextFieldController.text = _url = _netDicts[index]['url'];
                            _scaffoldKey.currentState?.closeEndDrawer();
                          },
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _netDicts[index]['name'],
                              )),
                        );
                      }),
            )),
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
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  prefixIcon: const Icon(Icons.mood),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      await _loadNetDicts();

                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                    icon: const Icon(Icons.list),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text('網址'),
                IconButton(
                    onPressed: () {
                      UiUtils.showAlertDialog(context: context, content: '''
示例：http://m.baidu.com/s?word=\${word}\n
說明：\${word}爲要搜尋的漢字，在真正搜尋的時候，APP會用真正的漢字替換\${word}進行搜尋。
''');
                    },
                    icon: const Icon(
                      Icons.question_mark,
                      size: 18,
                    ))
              ],
            ),
            TextField(
              controller: _urlTextFieldController,
              onChanged: (value) {
                setState(() {
                  _url = value;
                });
              },
              decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  hintText: '示例：http://m.baidu.com/s?word=\${word}',
                  prefixIcon: Icon(Icons.public)),
            ),
            const SizedBox(
              height: 20,
            ),
//             Row(
//               children: [
//                 const Text('支援擴展區漢字  '),
//                 AnimatedToggleSwitch<bool>.dual(
//                   current: _bigFont,
//                   first: false,
//                   second: true,
//                   spacing: 0,
//                   indicatorSize: const Size.fromWidth(26),
//                   animationDuration: const Duration(milliseconds: 200),
//                   style: const ToggleStyle(
//                     borderColor: Colors.transparent,
//                     indicatorColor: Colors.white,
//                     backgroundColor: Colors.amber,
//                   ),
//                   customStyleBuilder: (context, local, global) => ToggleStyle(
//                       backgroundGradient: LinearGradient(
//                     colors: const [Colors.green, Colors.black38],
//                     stops: [
//                       global.position - (1 - 2 * max(0, global.position - 0.5)) * 0.5,
//                       global.position + max(0, 2 * (global.position - 0.5)) * 0.5,
//                     ],
//                   )),
//                   borderWidth: 2.0,
//                   height: 30.0,
//                   loadingIconBuilder: (context, global) => CupertinoActivityIndicator(
//                       color: Color.lerp(Colors.black38, Colors.green, global.position)),
//                   onChanged: (b) {
//                     setState(() {
//                       _bigFont = b;
//                     });
//                   },
//                 ),
//                 IconButton(
//                     onPressed: () {
//                       UiUtils.showAlertDialog(context: context, content: '''
// 開啟該功能後，在加載網頁時，會加載支援擴展區漢字的字體，這樣在第一次加載時，會出現頁面閃爍的情況。\n
// 所以，如果網頁中只展示常規漢字，請不要開啟該功能。\n
// 如果您不是很理解這個功能，請不要開啟該功能。
// ''');
//                     },
//                     icon: const Icon(
//                       Icons.question_mark,
//                       size: 18,
//                     ))
//               ],
//             )
          ]),
        ));
  }
}
