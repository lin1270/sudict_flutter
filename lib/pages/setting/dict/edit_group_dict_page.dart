import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:sudict/modules/ui_comps/fish_toggle_switch/index.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/dict/dict_group.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/string.dart';
import 'package:sudict/modules/utils/ui.dart';

class EditGroupDictPage extends StatefulWidget {
  const EditGroupDictPage({super.key, this.arguments});
  final dynamic arguments;

  @override
  State<EditGroupDictPage> createState() => _EditGroupDictPageState();
}

class _EditGroupDictPageState extends State<EditGroupDictPage> {
  final _nameTextFieldController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _name = '';
  bool _isAdd = false;
  var _isFirstLoad = true;
  final _shownDicts = <DictItem>[];

  @override
  void dispose() {
    _nameTextFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isAdd = widget.arguments is int;
    if (!_isAdd) {
      DictItem item = widget.arguments;
      _shownDicts.addAll(item.children);
      _name = item.name;
    }

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

    if (_isAdd) {
      DictItem item =
          DictItem(StringUtils.uuid(), _name, "", DictType.group, DictFrom.user, true, false);
      item.children.addAll(_shownDicts);
      DictMgr.instance.addDict(widget.arguments, item);
      NavigatorUtils.pop(context, true);
    } else {
      DictItem item = widget.arguments;
      item.name = _name;
      item.children.clear();
      item.children.addAll(_shownDicts);
      item.groupCurrentIndex = 0;
      DictMgr.instance.saveCfg();
      NavigatorUtils.pop(context, true);
    }
  }

  _onDelete() async {
    bool ret = await UiUtils.showConfirmDialog(context: context, content: '確定要刪除該分組嗎?');
    if (ret) {
      DictItem item = widget.arguments;
      DictMgr.instance.deleteDict(item);
      _pop();
    }
  }

  _pop() {
    NavigatorUtils.pop(context, true);
  }

  int get _visibleCount {
    int count = 0;
    for (DictItem item in _shownDicts) {
      if (item.visible) ++count;
    }
    return count;
  }

  List<Widget> _groupWidget(DictGroup group) {
    final ret = <Widget>[
      Container(
          margin: const EdgeInsets.only(top: 16),
          decoration:
              const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black26))),
          width: double.infinity,
          child: Text(
            group.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ))
    ];

    for (DictItem dict in group.items) {
      // 不允許套娃添加分組
      if (dict.isGroup) continue;
      ret.add(Padding(
          padding: const EdgeInsets.only(left: 0, top: 4, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                dict.name,
                style: const TextStyle(fontSize: 18, overflow: TextOverflow.ellipsis),
              )),
              FishToggleSwitchWidget(
                isOn: _shownDicts.indexWhere((e) => e.id == dict.id) >= 0,
                onChanged: (b) {
                  setState(() {
                    if (b) {
                      final newItem = dict.clone();
                      newItem.visible = true;
                      _shownDicts.add(newItem);
                    } else {
                      _shownDicts.removeWhere((element) => element.id == dict.id);
                    }
                  });
                },
                onText: '已添加',
                offText: '未添加',
              )
            ],
          )));
    }

    return ret;
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
          title: Text(_isAdd ? '添加分組辭典' : '修改分組辭典'),
          actions: actions,
        ),
        endDrawer: Container(
            width: size.width * 0.9,
            height: size.height,
            decoration: const BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SafeArea(
                child: ListView.builder(
                    itemCount: DictMgr.instance.allGroupForSetting.length,
                    itemBuilder: (context, index) {
                      final group = DictMgr.instance.allGroupForSetting[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _groupWidget(group),
                      );
                    }))),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MaterialTextField(
              hint: '請輸入分組名稱',
              labelText: '分組名稱',
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.mood),
              controller: _nameTextFieldController,
              theme: FilledOrOutlinedTextTheme(
                  radius: 8,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  errorStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  fillColor: Colors.transparent,
                  prefixIconColor: Colors.black45,
                  enabledColor: Colors.grey,
                  focusedColor: Colors.black54,
                  floatingLabelStyle: const TextStyle(color: Colors.black),
                  width: 1.5,
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.black38)),
              onChanged: (v) {
                _name = v;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.black26,
                      size: 20,
                    ),
                    Text(
                      ' 長按可拖動排序',
                      style: TextStyle(color: Colors.black26),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                    icon: const Icon(Icons.settings_outlined))
              ],
            ),
            _shownDicts.isEmpty
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '請點擊上方圖標進入辭典設定。',
                        style: TextStyle(fontSize: 20, color: Colors.black45),
                      )
                    ],
                  )
                : Expanded(
                    child: ReorderableListView.builder(
                    itemCount: _shownDicts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = _shownDicts[index];
                      final isUserAdded = item.from == DictFrom.user;
                      final widgets = <Widget>[
                        Expanded(
                            child: Text(
                          item.name,
                          style: TextStyle(
                              color: item.visible
                                  ? (isUserAdded ? UIConfig.userColor : Colors.black)
                                  : Colors.black38,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis),
                        )),
                      ];
                      widgets.add(FishToggleSwitchWidget(
                        isOn: item.visible,
                        onChanged: (b) {
                          setState(() {
                            if (!b && _visibleCount <= 2) {
                              UiUtils.toast(content: '最少顯示兩個辭典。');
                              return;
                            }
                            item.visible = b;
                          });
                        },
                        onText: '已顯示',
                        offText: '已隱藏',
                      ));
                      return Padding(
                          key: Key(item.id),
                          padding: const EdgeInsets.only(top: 6, bottom: 6),
                          child: Row(
                            children: widgets,
                          ));
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      final old = _shownDicts.removeAt(oldIndex);
                      if (newIndex > oldIndex) --newIndex;

                      _shownDicts.insert(newIndex, old);
                    },
                  ))
          ]),
        ));
  }
}
