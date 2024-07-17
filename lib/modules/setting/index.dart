import 'package:flutter/material.dart';
import 'package:sudict/modules/utils/local_storage.dart';

class Setting {
  Setting._();
  static Setting? _instance;
  static Setting get instance {
    _instance ??= Setting._();
    return _instance!;
  }

  init() async {
    // 读取配置，
    _fontScale.value =
        await LocalStorageUtils.getDouble(LocalStorageKeys.settingFontScale) ?? _fontScale.value;
    // 添加监听
    _fontScale.addListener(() {
      LocalStorageUtils.setDouble(LocalStorageKeys.settingFontScale, _fontScale.value);
    });

    _jgwFontScale.value = await LocalStorageUtils.getDouble(LocalStorageKeys.settingJgwFontScale) ??
        _jgwFontScale.value;
    _jgwFontScale.addListener(() {
      LocalStorageUtils.setDouble(LocalStorageKeys.settingJgwFontScale, _jgwFontScale.value);
    });

    _convertSimple.value = await LocalStorageUtils.getBool(LocalStorageKeys.settingConvertSimple) ??
        _convertSimple.value;
    _convertSimple.addListener(() {
      LocalStorageUtils.setBool(LocalStorageKeys.settingConvertSimple, _convertSimple.value);
    });

    _dictInnerJumpPage.value =
        await LocalStorageUtils.getBool(LocalStorageKeys.settingDictInnerJumpPage) ??
            _dictInnerJumpPage.value;
    _dictInnerJumpPage.addListener(() {
      LocalStorageUtils.setBool(
          LocalStorageKeys.settingDictInnerJumpPage, _dictInnerJumpPage.value);
    });
  }

  // 字体缩放
  final _fontScale = ValueNotifier<double>(1.0);
  double get fontScale => _fontScale.value;
  set fontScale(double v) => _fontScale.value = v;

  // 甲骨文字体缩放
  final _jgwFontScale = ValueNotifier<double>(1.2);
  double get jgwFontScale => _jgwFontScale.value;
  set jgwFontScale(double v) => _jgwFontScale.value = v;

  // 是否转换简化字
  final _convertSimple = ValueNotifier<bool>(false);
  bool get convertSimple => _convertSimple.value;
  set convertSimple(bool v) => _convertSimple.value = v;

  // 辞典跳转，是否打开另外的页面，或是直接在辞典中搜寻
  final _dictInnerJumpPage = ValueNotifier<bool>(false);
  bool get dictInnerJumpPage => _dictInnerJumpPage.value;
  set dictInnerJumpPage(bool v) => _dictInnerJumpPage.value = v;
}
