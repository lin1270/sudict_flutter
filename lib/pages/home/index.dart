import 'dart:async';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/ui_comps/dict_wrapper_widget/index.dart';
import 'package:sudict/modules/version_update/index.dart';
import 'package:sudict/pages/home/main_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CustomPopupMenuController _mainMenuController = CustomPopupMenuController();

  @override
  void dispose() {
    _mainMenuController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 1), () {
      VersionUpdate.instance.detect(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: UIConfig.dictWrapperBkColor,
        body: SafeArea(
            child: DictWrapperWidget(
          firstWidget: CustomPopupMenu(
            controller: _mainMenuController,
            barrierColor: Colors.transparent,
            pressType: PressType.singleClick,
            menuBuilder: MainMenu.build(context, _mainMenuController),
            verticalMargin: 0,
            showArrow: true,
            child: const Padding(
                padding: EdgeInsets.only(left: 18, right: 18),
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(
                      Icons.menu_outlined,
                      size: 32,
                    ))),
          ),
        )));
  }
}
