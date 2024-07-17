import 'package:flutter/material.dart';
import 'package:sudict/config/dict.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/router.dart';

class DictSettingPage extends StatefulWidget {
  const DictSettingPage({super.key});

  @override
  State<DictSettingPage> createState() => _DictSettingPageState();
}

class _DictSettingPageState extends State<DictSettingPage> {
  @override
  void initState() {
    super.initState();
  }

  _restoreSetting() async {
    bool confirm = await UiUtils.showConfirmDialog(context: context, content: '請再次確定，確定要恢復到原始設定嗎?');
    if (confirm) {
      int preGroupCount = DictMgr.instance.allGroupForSetting.length;
      await DictMgr.instance.restore();
      for (int i = 0; i < DictMgr.instance.allGroupForSetting.length; ++i) {
        FishEventBus.fire(DictSettingChangedEvent(i));
      }
      if (preGroupCount != DictMgr.instance.allGroupForSetting.length) {
        FishEventBus.fire(
            DictSettingGroupAddOrRemoveEvent(DictMgr.instance.allGroupForSetting.length - 1));
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        appBar: AppBar(
          title: const Text('辭典設定'),
          actions: [
            IconButton(
                onPressed: () async {
                  bool confirm = await UiUtils.showConfirmDialog(
                      context: context, content: '恢復原始設定後，您的本地修改將全部丟失，無法還原。\n確定要恢復到原始設定嗎?');
                  if (confirm) {
                    _restoreSetting();
                  }
                },
                icon: const Icon(Icons.settings_backup_restore_outlined)),
            IconButton(
                onPressed: () async {
                  if (DictMgr.instance.allGroupForSetting.length >= DictConfig.maxGroupCount) {
                    UiUtils.toast(
                      content: '最多容納${DictConfig.maxGroupCount}個分類，已無法再創建。',
                    );
                    return;
                  }

                  bool? added =
                      await NavigatorUtils.go(context, AppRouteName.settingEditUserGroup, 0);
                  if (added == true) {
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
              itemCount: DictMgr.instance.allGroupForSetting.length,
              itemBuilder: (context, index) {
                final group = DictMgr.instance.allGroupForSetting[index];
                bool isFromUser = group.from == DictFrom.user;
                return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      NavigatorUtils.go(context, AppRouteName.settingDictGroup, index);
                    },
                    child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  group.name,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: isFromUser ? UIConfig.userColor : Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                )),
                                if (isFromUser)
                                  IconButton(
                                      onPressed: () async {
                                        bool? ret = await NavigatorUtils.go(
                                            context, AppRouteName.settingEditUserGroup, group);
                                        if (ret == true) {
                                          setState(() {});
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.edit_note_outlined,
                                        color: UIConfig.userColor,
                                      )),
                                const Icon(Icons.keyboard_arrow_right_outlined)
                              ],
                            ))));
              }),
        ));
  }
}
