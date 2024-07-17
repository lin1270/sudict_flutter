import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sudict/modules/ui_comps/fish_button_tab_bar_widget/index.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/path.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/all_widget.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/common.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/day_widget.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/mgr.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/month_widget.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/year_widget.dart';

class DiziguiGongguogeTabWidget extends StatefulWidget {
  const DiziguiGongguogeTabWidget({super.key});
  @override
  State<DiziguiGongguogeTabWidget> createState() => _DiziguiGongguogeTabWidgetState();
}

class _DiziguiGongguogeTabWidgetState extends State<DiziguiGongguogeTabWidget> {
  int _currTabIndex = 0;
  final _widgets = <Widget>[];
  late DzgGggDay _todayData;

  @override
  void initState() {
    super.initState();

    _init();
  }

  _init() async {
    await DzgGggMgr.instance.load();
    _reloadTabs();
  }

  void _reloadTabs() {
    _todayData = DzgGggMgr.instance.today;
    _widgets.clear();
    _widgets.add(DzgGggDayWidget(
      day: _todayData,
    ));

    final now = DateTime.now();
    final currMonth = DzgGggMgr.instance.getMonth(year: now.year, month: now.month);
    _widgets.add(DzgGggMonthWidget(month: currMonth));

    final currYear = DzgGggMgr.instance.getYear(year: now.year);
    _widgets.add(DzgGggYearWidget(year: currYear));

    _widgets.add(const DzgGggAllWidget());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FishButtonTabBarWidget(
                initIndex: _currTabIndex,
                onChanged: (index, item) {
                  setState(() {
                    _currTabIndex = index;
                  });
                },
                items: [
                  FishButtonTabBarItem(title: '日'),
                  FishButtonTabBarItem(title: '月'),
                  FishButtonTabBarItem(title: '年'),
                  FishButtonTabBarItem(title: '全部'),
                ],
              ),
              const Spacer(),
              FishInkwell(
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.any, allowMultiple: false, allowCompression: false,
                      // allowedExtensions: ['epub'],
                    );
                    if (result == null || result.files.isEmpty) return;

                    final item = result.files[0];
                    if (item.path != null && item.path?.isNotEmpty == true) {
                      _import(item.path!);
                    }
                  },
                  child: const Text('導入')),
              const SizedBox(
                width: 16,
              ),
              FishInkwell(
                  onTap: () async {
                    // 获取外部存储目录
                    final directory = await getExternalStorageDirectory();
                    if (directory != null) {
                      final now = DateTime.now();
                      final filePath =
                          '${directory.path}/sudict/dzg/ggg/export/${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}_${now.second}_${now.millisecond}.dzgggg';
                      await PathUtils.mkdir(filePath, withFileName: true);
                      final file = File(filePath);
                      await file.writeAsString(DzgGggMgr.instance.getJsonString());
                      _alert('已存儲至：\n$filePath');
                    } else {
                      UiUtils.toast(content: '無法訪問外部存儲');
                    }
                  },
                  child: const Text('導出')),
            ],
          ),
          if (_widgets.isNotEmpty) Expanded(child: _widgets[_currTabIndex]),
        ],
      ),
    );
  }

  void _alert(String s) {
    UiUtils.showAlertDialog(context: context, content: s);
  }

  void _import(String path) async {
    final ok = await UiUtils.showConfirmDialog(
        context: context, content: '導入後會覆蓋當前數據，且不可撤銷，確定要導入嗎？', title: '導入提醒');
    if (ok) {
      final result = await DzgGggMgr.instance.tryImport(path);
      _alert('導入${result ? '成功' : '失敗'}');
      if (result) {
        // 導入成功後，要刷新全部：today, month, year, all
        _reloadTabs();
      }
    }
  }
}
