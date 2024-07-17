import 'dart:convert';
import 'dart:io';

import 'package:sudict/config/path.dart';
import 'package:sudict/modules/ggg/common.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/common.dart';

int _currVerson = 1;

class DzgGggMgr {
  DzgGggMgr._();
  static DzgGggMgr? _instance;
  static DzgGggMgr get instance {
    _instance ??= DzgGggMgr._();
    return _instance!;
  }

  final _data = <DzgGggYear>[];
  var _isLoaded = false;

  List<DzgGggYear> get data => _data;

  Future<void> load() async {
    if (_isLoaded) return;
    await tryImport(await PathConfig.dzgGggPath);
    _isLoaded = true;
  }

  DzgGggYear? getYear({required int year}) {
    for (var i = 0; i < _data.length; ++i) {
      final yearObj = _data[i];
      if (yearObj.date == year) {
        return yearObj;
      }
    }
    return null;
  }

  DzgGggMonth? getMonth({required int year, required int month}) {
    for (var i = 0; i < _data.length; ++i) {
      final yearObj = _data[i];
      if (yearObj.date == year) {
        for (var j = 0; j < yearObj.records.length; ++j) {
          final monthObj = yearObj.records[j];
          if (monthObj.date == month) {
            return monthObj;
          }
        }
      }
    }
    return null;
  }

  DzgGggDay? getDay({required int year, required int month, required int day}) {
    for (var i = 0; i < _data.length; ++i) {
      final yearObj = _data[i];
      if (yearObj.date == year) {
        for (var j = 0; j < yearObj.records.length; ++j) {
          final monthObj = yearObj.records[j];
          if (monthObj.date == month) {
            for (var k = 0; k < monthObj.records.length; ++k) {
              final dayObj = monthObj.records[k];
              if (dayObj.date == day) {
                return dayObj;
              }
            }
          }
        }
      }
    }
    return null;
  }

  DzgGggDay get today {
    final now = DateTime.now();
    var dayObj = getDay(year: now.year, month: now.month, day: now.day);
    if (dayObj == null) {
      dayObj = DzgGggDay(type: DzgGggType.day, date: now.day, status: GggStatus.none);
      dayObj.month = now.month;
      dayObj.year = now.year;
      for (var i = 0; i < dzgGggDescItems.length; ++i) {
        dayObj.records.add(0);
      }
      saveDay(dayObj);
    }

    return dayObj;
  }

  Future<bool> saveDay(DzgGggDay day) async {
    if (_data.isEmpty) {
      _data.add(DzgGggYear(type: DzgGggType.year, date: day.year ?? 0, status: GggStatus.doing));
    }
    for (var i = 0; i < _data.length; ++i) {
      final yearObj = _data[i];
      if (yearObj.date == day.year) {
        DzgGggMonth? foundMonthObj;
        for (var j = 0; j < yearObj.records.length; ++j) {
          final monthObj = yearObj.records[j];
          if (monthObj.date == day.month) {
            foundMonthObj = monthObj;
            break;
          }
        }

        if (foundMonthObj == null) {
          foundMonthObj =
              DzgGggMonth(type: DzgGggType.month, date: day.month ?? 0, status: GggStatus.doing);
          yearObj.records.add(foundMonthObj);
        }

        var found = false;
        for (var k = 0; k < foundMonthObj.records.length; ++k) {
          final dayObj = foundMonthObj.records[k];
          if (dayObj.date == day.date) {
            found = true;
            break;
          }
        }

        if (!found) {
          foundMonthObj.records.add(day);
        }
        // save json
        return _save();
      }
    }
    return false;
  }

  Future<bool> saveMonthRemark(
      {required int year, required int month, required String remark}) async {
    for (var i = 0; i < _data.length; ++i) {
      final yearObj = _data[i];
      if (yearObj.date == year) {
        for (var j = 0; j < yearObj.records.length; ++j) {
          final monthObj = yearObj.records[j];
          if (monthObj.date == month) {
            monthObj.remark = remark;
            // save json
            return _save();
          }
        }
      }
    }
    return false;
  }

  Future<bool> saveMonthStatus(
      {required int year, required int month, required GggStatus status}) async {
    for (var i = 0; i < _data.length; ++i) {
      final yearObj = _data[i];
      if (yearObj.date == year) {
        for (var j = 0; j < yearObj.records.length; ++j) {
          final monthObj = yearObj.records[j];
          if (monthObj.date == month) {
            monthObj.status = status;
            // save json
            return _save();
          }
        }
      }
    }
    return false;
  }

  Future<bool> saveYearRemark({required int year, required String remark}) async {
    for (var i = 0; i < _data.length; ++i) {
      final yearObj = _data[i];
      if (yearObj.date == year) {
        yearObj.remark = remark;
        _save();
      }
    }
    return false;
  }

  Future<bool> saveYearStatus({required int year, required GggStatus status}) async {
    for (var i = 0; i < _data.length; ++i) {
      final yearObj = _data[i];
      if (yearObj.date == year) {
        yearObj.status = status;
        _save();
      }
    }
    return false;
  }

  Future<bool> _save() async {
    final f = File(await PathConfig.dzgGggPath);
    await f.writeAsString(getJsonString());
    return true;
  }

  String getJsonString() {
    final records = <dynamic>[];
    for (final year in _data) {
      records.add(year.toJson());
    }
    var allJson = {"version": _currVerson, "records": records};
    final str = jsonEncode(allJson);
    return str;
  }

  Future<bool> tryImport(String path) async {
    try {
      final f = File(path);
      final str = await f.readAsString();
      final json = jsonDecode(str);
      if (json != null) {
        if (_currVerson == json['version']) {
          final records = json['records'];
          _data.clear();
          if (records != null) {
            for (final ji in records) {
              _data.add(DzgGggYear.fromJson(ji));
            }
          }

          return true;
        }
      }
      // ignore: empty_catches
    } catch (e) {}
    return false;
  }
}
