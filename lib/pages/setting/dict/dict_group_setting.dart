import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/fish_toggle_switch/index.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/pages/setting/dict/add_user_local_dict_handler.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/menu/menu_item.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/router.dart';

class DictGroupSettingPage extends StatefulWidget {
  const DictGroupSettingPage({super.key, this.arguments});

  final dynamic arguments;

  @override
  State<DictGroupSettingPage> createState() => _DictGroupSettingPageState();
}

class _DictGroupSettingPageState extends State<DictGroupSettingPage> {
  var _hasChanged = false;
  final _addMenuController = CustomPopupMenuController();
  final _addMenuItems = <MenuItem>[];
  final _dictContextMenuControllers = <String, CustomPopupMenuController>{};

  @override
  void dispose() {
    _addMenuController.dispose();
    for (final ctrl in _dictContextMenuControllers.values) {
      ctrl.dispose();
    }
    _dictContextMenuControllers.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _addMenuItems.addAll([
      MenuItem('網路辭典', Icons.public, _onAddNetDict, null),
      MenuItem('本地文檔', Icons.file_open_outlined, _onAddLocalFile, null),
      MenuItem('分組', Icons.group_add_outlined, _onAddGroup, null),
    ]);
  }

  _onAddNetDict(MenuItem item) async {
    int index = widget.arguments as int;
    bool? added = await NavigatorUtils.go(context, AppRouteName.settingDictAddWebDict, index);
    if (added == true) {
      _hasChanged = true;
      setState(() {});
    }
  }

  _onAddLocalFile(MenuItem item) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, allowMultiple: true, allowCompression: false,
      // allowedExtensions: ['mdd', 'mdx', 'fishdict'],
    );
    if (result == null) return;
    final addOk = await AddUserLocalDictHandler.handle(
        result.files.map((e) => e.path ?? '').toList(), widget.arguments as int, false);
    if (addOk) {
      _hasChanged = true;
      setState(() {});
    }
  }

  _onAddGroup(MenuItem item) async {
    int index = widget.arguments as int;
    bool? added = await NavigatorUtils.go(context, AppRouteName.settingEditGroupDict, index);
    if (added == true) {
      _hasChanged = true;
      setState(() {});
    }
  }

  Widget _buildAddMenu() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
            color: const Color(0xFF4C4C4C),
            constraints: const BoxConstraints(minWidth: 120),
            child: IntrinsicWidth(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _addMenuItems
                  .map(
                    (item) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        item.onClicked!(item);
                        _addMenuController.hideMenu();
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              item.icon,
                              size: 18,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ))));
  }

  Widget _buildDictContextMenu(DictItem item, CustomPopupMenuController ctrl) {
    final menuItems = <MenuItem>[];
    if (item.from == DictFrom.user) {
      menuItems.add(MenuItem('修改', Icons.edit_outlined, (menuItem) async {
        ctrl.hideMenu();

        final dict = menuItem.param as DictItem;

        bool? ret = await NavigatorUtils.go(
            context,
            dict.isWeb()
                ? AppRouteName.settingDictAddWebDict
                : (dict.isGroup
                    ? AppRouteName.settingEditGroupDict
                    : AppRouteName.settingDictEidtLocalDict),
            item);
        if (ret == true) {
          _hasChanged = true;
          setState(() {});
        }
      }, item));
    }

    int groupIndex = widget.arguments as int;
    for (int i = 0; i < DictMgr.instance.allGroupForSetting.length; ++i) {
      if (i != groupIndex) {
        final group = DictMgr.instance.allGroupForSetting[i];
        menuItems.add(MenuItem('移動 => ${group.name}', Icons.move_down_outlined, (menuItem) async {
          ctrl.hideMenu();

          final groupIndex = menuItem.param as int;
          final group = DictMgr.instance.allGroupForSetting[groupIndex];

          DictMgr.instance.allGroupForSetting[widget.arguments].items.remove(item);
          group.items.add(item);
          DictMgr.instance.refreshShownDicts();
          DictMgr.instance.saveCfg();
          setState(() {});
          FishEventBus.fire(DictSettingChangedEvent(widget.arguments));
          FishEventBus.fire(DictSettingChangedEvent(
              DictMgr.instance.allGroupForSetting.indexWhere((element) => element.id == group.id)));
        }, i));
      }
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
            color: const Color(0xFF4C4C4C),
            constraints: const BoxConstraints(minWidth: 120),
            child: IntrinsicWidth(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: menuItems
                  .map(
                    (item) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        item.onClicked!(item);
                        ctrl.hideMenu();
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              item.icon,
                              size: 18,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ))));
  }

  @override
  Widget build(BuildContext context) {
    int index = widget.arguments as int;
    final group = DictMgr.instance.allGroupForSetting[index];
    return Scaffold(
        appBar: AppBar(
          title: Text('${group.name} - 設定'),
          actions: [
            CustomPopupMenu(
              menuBuilder: _buildAddMenu,
              barrierColor: Colors.transparent,
              pressType: PressType.singleClick,
              controller: _addMenuController,
              child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.add)),
            ),
          ],
        ),
        body: PopScope(
            onPopInvoked: (didPop) async {
              if (_hasChanged) {
                FishEventBus.fire(DictSettingChangedEvent(widget.arguments));
              }
            },
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(
                      size: 16,
                      Icons.info_outline,
                      color: Colors.black26,
                    ),
                    Text(
                      "長按可拖動排序 + 支援mdx辭典哦",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black26,
                      ),
                    )
                  ]),
                  Expanded(
                      child: ReorderableListView.builder(
                    itemCount: group.items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = group.items[index];
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

                      var dictContextMenuController = _dictContextMenuControllers[item.id];
                      if (dictContextMenuController == null) {
                        dictContextMenuController = CustomPopupMenuController();
                        _dictContextMenuControllers[item.id] = dictContextMenuController;
                      }

                      // 添加編輯按鈕
                      widgets.add(CustomPopupMenu(
                          controller: dictContextMenuController,
                          barrierColor: Colors.transparent,
                          verticalMargin: 0,
                          menuBuilder: () =>
                              _buildDictContextMenu(item, dictContextMenuController!),
                          pressType: PressType.singleClick,
                          child: Icon(
                            Icons.more_vert_outlined,
                            color: isUserAdded ? UIConfig.userColor : Colors.black,
                          )));

                      widgets.add(FishToggleSwitchWidget(
                        isOn: item.visible,
                        onChanged: (b) {
                          setState(() {
                            if (!b &&
                                DictMgr.instance.allGroup[widget.arguments].items.length <= 1) {
                              UiUtils.toast(content: '最少顯示一個辭典。');
                              return;
                            }
                            _hasChanged = true;
                            DictMgr.instance.setDictVisible(item, b);
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
                      _hasChanged = true;
                      DictMgr.instance.changeDictPos(group: group, from: oldIndex, to: newIndex);
                    },
                  ))
                ]))));
  }
}
