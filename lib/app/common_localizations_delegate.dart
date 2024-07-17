import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

///语言(主要解决cupertino控件不能显示中文的问题)
class CommonLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const CommonLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => <String>['zh', 'CN'].contains(locale.languageCode);

  @override
  // ignore: library_private_types_in_public_api
  SynchronousFuture<_DefaultCupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<_DefaultCupertinoLocalizations>(_DefaultCupertinoLocalizations());
  }

  @override
  bool shouldReload(CommonLocalizationsDelegate old) => false;
}

class _DefaultCupertinoLocalizations extends CupertinoLocalizations {
  _DefaultCupertinoLocalizations();

  static const List<String> _shortWeekdays = <String>[
    '週一',
    '週二',
    '週三',
    '週四',
    '週五',
    '週六',
    '週日',
  ];

  static const List<String> _shortMonths = <String>[
    '一月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '十一月',
    '十二月',
  ];

  static const List<String> _months = <String>[
    '一月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '十一月',
    '十二月',
  ];

  @override
  String get alertDialogLabel => '提醒';

  @override
  String get anteMeridiemAbbreviation => "上午";

  @override
  String get postMeridiemAbbreviation => "下午";

  @override
  String get copyButtonLabel => "拷貝";

  @override
  String get cutButtonLabel => "剪切";

  @override
  String get pasteButtonLabel => "粘貼";

  @override
  String get selectAllButtonLabel => "全選";

  @override
  DatePickerDateOrder get datePickerDateOrder => DatePickerDateOrder.ymd;

  @override
  DatePickerDateTimeOrder get datePickerDateTimeOrder =>
      DatePickerDateTimeOrder.date_time_dayPeriod;

  @override
  String datePickerHour(int hour) => hour.toString();

  @override
  String datePickerHourSemanticsLabel(int hour) => hour.toString();

  @override
  String datePickerMediumDate(DateTime date) {
    return '${_shortWeekdays[date.weekday - DateTime.monday]} '
        '${_shortMonths[date.month - DateTime.january]} '
        '${date.day.toString().padRight(2)}';
  }

  @override
  String datePickerMinute(int minute) => minute.toString().padLeft(2, '0');

  @override
  String datePickerMinuteSemanticsLabel(int minute) {
    if (minute == 1) return '1 分鐘';
    return '$minute 分鐘';
  }

  @override
  String datePickerMonth(int monthIndex) => _months[monthIndex - 1];

  @override
  String datePickerYear(int yearIndex) => yearIndex.toString();

  @override
  String timerPickerHour(int hour) => hour.toString();

  @override
  String timerPickerHourLabel(int hour) => '時';

  @override
  String timerPickerMinute(int minute) => minute.toString();

  @override
  String timerPickerMinuteLabel(int minute) => '分';

  @override
  String timerPickerSecond(int second) => second.toString();

  @override
  String timerPickerSecondLabel(int second) => '秒';

  @override
  String datePickerStandaloneMonth(int monthIndex) {
    return _months[monthIndex - 1];
  }

  @override
  String get lookUpButtonLabel => '搜尋';

  @override
  String get menuDismissLabel => '';

  @override
  String get modalBarrierDismissLabel => '';

  @override
  String get noSpellCheckReplacementsLabel => '無法匹配拼寫項';

  @override
  String get searchTextFieldPlaceholderLabel => '搜尋';

  @override
  String get searchWebButtonLabel => '網路搜尋';

  @override
  String get shareButtonLabel => '分享';

  @override
  String tabSemanticsLabel({required int tabIndex, required int tabCount}) {
    return '$tabIndex/$tabCount';
  }

  @override
  List<String> get timerPickerHourLabels {
    final ret = <String>[];
    for (int i = 0; i < 24; ++i) {
      ret.add(i.toString());
    }
    return ret;
  }

  @override
  List<String> get timerPickerMinuteLabels {
    final ret = <String>[];
    for (int i = 0; i < 60; ++i) {
      ret.add(i.toString());
    }
    return ret;
  }

  @override
  List<String> get timerPickerSecondLabels {
    final ret = <String>[];
    for (int i = 0; i < 60; ++i) {
      ret.add(i.toString());
    }
    return ret;
  }

  @override
  String get todayLabel => '今天';

  @override
  String datePickerDayOfMonth(int dayIndex, [int? weekDay]) {
    return dayIndex.toString();
  }

  @override
  String get clearButtonLabel => '取消';
}
