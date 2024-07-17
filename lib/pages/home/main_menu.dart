import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/menu/menu_item.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/pages/router.dart';
import 'package:sudict/pages/san_qian/index.dart';

class _MenuParam {
  String path;
  dynamic param;

  _MenuParam(this.path, this.param);
}

class MainMenu {
  static final _InnerMainMenu _instance = _InnerMainMenu();
  static late BuildContext _context;
  static late CustomPopupMenuController _menuController;

  static final List<MenuItem> _menuItems = [
    // line 1
    // -----------------------------------------
    MenuItem('入門法庫', Icons.door_front_door_outlined, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.enterArea, null)),
    MenuItem('我的書架', Icons.shelves, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.bookShelf, null)),

    MenuItem(
        '淨緣', null, _instance.onCommonMainMenuItemClicked, _MenuParam(AppRouteName.jingyuan, null)),
    MenuItem(
        '弟子規', null, _instance.onCommonMainMenuItemClicked, _MenuParam(AppRouteName.dizigui, null)),
    MenuItem('心念集', null, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.thoughtRecord, null)),
    // MenuItem('', Icons.no_encryption, _instance.onCommonMainMenuItemClicked, _MenuParam('', null)),

    // line 2
    // -----------------------------------------
    MenuItem('編碼查字', Icons.keyboard, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.lookforWords, null)),
    MenuItem('繁簡轉換', Icons.change_circle, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.fjConvert, null)),
    MenuItem('詩律', Icons.music_note, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.shilv, null)),

    MenuItem('三字經講記', null, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.sanQian, SanQianPageParam("三字經講記", 'assets/books/szj.txt'))),
    MenuItem('網路資源', Icons.public, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.onlineStudyResource, null)),

    // line 3
    // -----------------------------------------
    MenuItem('因緣會字', Icons.shuffle, _instance.onRandomMainMenuItemClicked, null),

    MenuItem('搜尋痕跡', Icons.manage_search, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.history, null)),
    MenuItem('甲骨文字', Icons.elderly, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.jgw, null)),

    MenuItem('千字文講記', null, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.sanQian, SanQianPageParam("千字文講記", 'assets/books/qzw.txt'))),
    MenuItem('設定', Icons.settings, _instance.onCommonMainMenuItemClicked,
        _MenuParam(AppRouteName.setting, null)),
  ];

  static build(BuildContext context, controller) {
    _context = context;
    _menuController = controller;
    return _buildCore;
  }

  static Widget _buildCore() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: MediaQuery.of(_context).size.width,
          color: const Color(0xFF4C4C4C),
          child: GridView.count(
            padding: const EdgeInsets.only(left: 5, right: 5, bottom: 0, top: 0),
            crossAxisCount: 5, // ------
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            childAspectRatio: 0.9,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _menuItems
                .map((item) => GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      item.onClicked!(item);
                      _menuController.hideMenu();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (item.title.isNotEmpty)
                          item.icon != null
                              ? Icon(
                                  item.icon,
                                  size: 30,
                                  color: Colors.white,
                                )
                              : Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 2),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Text(
                                    item.title.substring(0, 1),
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.title,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    )))
                .toList(),
          ),
        ));
  }
}

class _InnerMainMenu {
  onCommonMainMenuItemClicked(MenuItem item) {
    _MenuParam param = item.param;
    if (item.param != null && param.path.isNotEmpty) {
      NavigatorUtils.go(MainMenu._context, param.path, param.param);
    }
  }

  onRandomMainMenuItemClicked(MenuItem item) {
    FishEventBus.fire(ShowRandomWidgetEvent());
  }
}
