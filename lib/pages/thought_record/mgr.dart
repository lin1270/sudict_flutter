// ignore_for_file: non_constant_identifier_names, unused_element

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sudict/config/path.dart';
import 'package:sudict/modules/ggg/common.dart';

// ignore: dangling_library_doc_comments, slash_for_doc_comments
/**
  version: 0,
  // 只記10天。
  records: [
    {
      date: 1/1,
      status: 2,
      good: 10,
      bad: 20
    }
  ]
 */
int _currVerson = 1;
int _MAX_LENGTH = 10;

class ThoughtRecordItem {
  ThoughtRecordItem(
      {required this.date, required this.status, required this.good, required this.bad});

  static ThoughtRecordItem fromJson(dynamic json) {
    final status = GggStatus.values[json['status']];
    return ThoughtRecordItem(
        bad: json['bad'], good: json['good'], date: json['date'], status: status);
  }

  dynamic toJson() {
    return {"date": date, "status": status.index, "good": good, "bad": bad};
  }

  final int date;
  String? _dateStr;
  String get dateStr {
    if (_dateStr == null) {
      final d = DateTime.fromMillisecondsSinceEpoch(date);
      _dateStr = '${d.month}/${d.day}';
    }
    return _dateStr!;
  }

  GggStatus status;
  int good;
  int bad;
}

class ThoughtRecordMgr {
  ThoughtRecordMgr._();
  static ThoughtRecordMgr? _instance;
  static ThoughtRecordMgr get instance {
    _instance ??= ThoughtRecordMgr._();
    return _instance!;
  }

  final _data = <ThoughtRecordItem>[];
  var _isLoaded = false;

  List<ThoughtRecordItem> get data => _data;

  Future<void> load() async {
    if (_isLoaded) return;
    final f = File(await PathConfig.thoughtRecordPath);
    try {
      final str = await f.readAsString();
      final json = jsonDecode(str);
      if (json != null) {
        if (_currVerson == json['version']) {
          final records = json['records'];
          if (records != null) {
            for (final ji in records) {
              _data.add(ThoughtRecordItem.fromJson(ji));
            }
          }
        }
      }
      // ignore: empty_catches
    } catch (e) {
    } finally {
      _isLoaded = true;
    }
  }

  ThoughtRecordItem? getDay({required String date}) {
    for (var i = 0; i < _data.length; ++i) {
      final obj = _data[i];
      if (obj.dateStr == date) {
        return obj;
      }
    }
    return null;
  }

  ThoughtRecordItem get today {
    var now = DateTime.now();
    final date = '${now.month}/${now.day}';
    var dayObj = getDay(date: date);
    if (dayObj == null) {
      if (_data.isNotEmpty) {
        final lastDt = DateTime.fromMillisecondsSinceEpoch(_data.last.date);
        try {
          final range = DateTimeRange(start: lastDt, end: now);
          final days = range.duration.inDays;
          if (days > _MAX_LENGTH) {
            _data.clear();
          } else {
            for (int i = 0; i < days; ++i) {
              final newDateMs = _data.last.date + (24 * 60 * 60 * 1000);
              final newDate = DateTime.fromMillisecondsSinceEpoch(newDateMs);
              if (newDate.month != now.month || newDate.day != now.day) {
                _data.add(
                    ThoughtRecordItem(date: newDateMs, status: GggStatus.none, good: 0, bad: 0));
              }
            }
          }
        } catch (e) {
          // do nothing
        }

        var changed = false;
        while (_data.length >= _MAX_LENGTH) {
          _data.removeAt(0);
          changed = true;
        }
        if (changed) {
          save();
        }
      }

      dayObj = ThoughtRecordItem(
          date: now.millisecondsSinceEpoch, status: GggStatus.none, good: 0, bad: 0);

      _data.add(dayObj);
      save();
    }

    return dayObj;
  }

  Future<bool> save() async {
    final records = <dynamic>[];
    for (final item in _data) {
      records.add(item.toJson());
    }
    var allJson = {"version": _currVerson, "records": records};
    final f = File(await PathConfig.thoughtRecordPath);
    final str = jsonEncode(allJson);
    await f.writeAsString(str);
    return true;
  }
}
