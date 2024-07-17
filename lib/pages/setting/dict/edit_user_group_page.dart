import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';

import 'package:sudict/modules/dict/dict_group.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/utils/navigator.dart';

import 'package:sudict/modules/utils/ui.dart';

class EditUserGroupPage extends StatefulWidget {
  const EditUserGroupPage({super.key, this.arguments});
  final dynamic arguments;

  @override
  State<EditUserGroupPage> createState() => _EditUserGroupPageState();
}

class _EditUserGroupPageState extends State<EditUserGroupPage> {
  final _nameTextFieldController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _name = '';
  bool _isAdd = false;
  var _isFirstLoad = true;

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
      DictGroup item = widget.arguments;
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
      final newId = DictMgr.instance.allGroupForSetting.last.id + 1;
      DictGroup item = DictGroup(newId, _name, DictFrom.user, []);
      DictMgr.instance.allGroupForSetting.add(item);
      DictMgr.instance.refreshShownDicts();
      DictMgr.instance.saveCfg();

      FishEventBus.fire(
          DictSettingGroupAddOrRemoveEvent(DictMgr.instance.allGroupForSetting.length - 1));
      NavigatorUtils.pop(context, true);
    } else {
      DictGroup item = widget.arguments;
      item.name = _name;
      DictMgr.instance.saveCfg();
      NavigatorUtils.pop(context, true);
    }
  }

  _onDelete() async {
    DictGroup item = widget.arguments;
    if (item.items.isNotEmpty) {
      Timer(const Duration(milliseconds: 10), () {
        UiUtils.toast(content: '請先清空分類中的辭典，再進行刪除操作。', showMs: 2000);
      });
      return;
    }

    bool ret = await UiUtils.showConfirmDialog(context: context, content: '確定要刪除該分類嗎?');
    if (ret) {
      int index = DictMgr.instance.deleteUserGroup(item);

      if (index >= 0) FishEventBus.fire(DictSettingGroupAddOrRemoveEvent(index));

      _pop();
    }
  }

  _pop() {
    NavigatorUtils.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (!_isAdd) {
      actions.add(IconButton(onPressed: _onDelete, icon: const Icon(Icons.delete_outline)));
    }
    actions.add(IconButton(onPressed: _onDone, icon: const Icon(Icons.check)));
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_isAdd ? '添加辭典分類' : '修改辭典分類'),
          actions: actions,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MaterialTextField(
              hint: '請輸入分類名稱',
              labelText: '分類名稱',
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
          ]),
        ));
  }
}
