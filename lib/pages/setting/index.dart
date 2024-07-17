import 'package:flutter/material.dart';
import 'package:sudict/app/theme_manager.dart';
import 'package:sudict/modules/menu/menu_item.dart';
import 'package:sudict/modules/share/index.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/version_update/index.dart';
import 'package:sudict/pages/router.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _menu = <MenuItem>[];

  @override
  void initState() {
    super.initState();
    _menu.add(MenuItem('字號設定', Icons.keyboard_arrow_right_outlined, _goPage,
        CommonRoutePageParam(AppRouteName.settingFont, null)));

    _menu.add(MenuItem('搜尋設定', Icons.keyboard_arrow_right_outlined, _goPage,
        CommonRoutePageParam(AppRouteName.settingSearch, null)));

    _menu.add(MenuItem('辭典設定', Icons.keyboard_arrow_right_outlined, _goPage,
        CommonRoutePageParam(AppRouteName.settingDict, null)));

    _menu.add(MenuItem.seperator());

    if (VersionUpdate.instance.downloadUrl.isNotEmpty) {
      _menu.add(MenuItem('分享App', Icons.keyboard_arrow_right_outlined, _share, null));
    }

    _menu.add(MenuItem('檢查更新', Icons.keyboard_arrow_right_outlined, _detectVersionUpdate, null));

    // _menu.add(MenuItem('聯絡作者', Icons.keyboard_arrow_right_outlined, _onContactMe, null));
    _menu.add(MenuItem('小記', Icons.keyboard_arrow_right_outlined, _goPage,
        CommonRoutePageParam(AppRouteName.about, null)));

    _menu.add(MenuItem.seperator());
    _menu.add(MenuItem('隨喜捐助', Icons.keyboard_arrow_right_outlined, _goPage,
        CommonRoutePageParam(AppRouteName.settingHappyDonate, null)));
  }

  _goPage(MenuItem item) {
    CommonRoutePageParam routeParam = item.param;
    NavigatorUtils.go(context, routeParam.path, routeParam.param);
  }

  // _onContactMe(MenuItem item) {
  //   NavigatorUtils.go(context, AppRouteName.settingContactMe, null);
  // }

  _share(MenuItem item) {
    ShareMgr.instance.shareUrl(VersionUpdate.instance.downloadUrl);
  }

  _detectVersionUpdate(MenuItem item) {
    VersionUpdate.instance.detect(context, showEqualToast: true);
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        appBar: AppBar(title: const Text('設定')),
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
              itemCount: _menu.length,
              itemBuilder: (context, index) {
                final item = _menu[index];

                return item.type == MenuItemType.seperator
                    ? Container(
                        height: 16,
                        color: ThemeManager.getTheme().appBarTheme.backgroundColor,
                      )
                    : FishInkwell(
                        onTap: () {
                          if (item.onClicked != null) item.onClicked!(item);
                        },
                        child: Container(
                            height: 40,
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Icon(item.icon)
                              ],
                            )));
              }),
        ));
  }
}
