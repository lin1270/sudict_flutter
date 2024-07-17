// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:sudict/modules/utils/assets.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/pages/san_qian/struct.dart';

class SanQianDataHandler {
  SanQianDataHandler(this.bookPath);

  init() async {
    String? cfg = await LocalStorageUtils.getString(_cfgKey);
    if (cfg != null) {
      final cfgArr = cfg.split('_');
      if (cfgArr.length == 3) {
        _titleIndex = int.parse(cfgArr[0]);
        _titleSubIndex = int.parse(cfgArr[1]);
        _contentIndex = int.parse(cfgArr[2]);
      }
    }
    await _readScrollPos();
    final txt = await AssetsUtils.readStringFile(bookPath);
    final groups = txt!.split('\n\n');
    const titlePre = '[desc]';

    for (String group in groups) {
      final titlePos = group.indexOf('\n');
      if (titlePos == -1) continue;
      final titleLine = group.substring(0, titlePos);
      String contentLine = group.substring(titlePos + 1);

      if (titleLine.startsWith(titlePre)) {
        final trueDescTitle = titleLine.substring(titlePre.length);
        SanQianItem a = SanQianItem(isDesc: true);
        a.items.add(SanQianLinkItem(trueDescTitle, trueDescTitle, _contentData.length));
        _titleData.add(a);
      } else {
        final arr = titleLine.split(RegExp(r'[。，]'));
        for (int i = 0; i < arr.length; ++i) {
          if (arr[i].trim().isEmpty) continue;
          if (_titleData.isNotEmpty) {
            if (_titleData.last.items.length < 2 && (!_titleData.last.isDesc)) {
              SanQianItem a = _titleData.last;
              a.items.add(SanQianLinkItem('${arr[i]}。', titleLine, _contentData.length));
              continue;
            }
          }

          SanQianItem a = SanQianItem();
          a.items.add(SanQianLinkItem('${arr[i]}，', titleLine, _contentData.length));
          _titleData.add(a);
        }
      }

      _contentData.add(contentLine);
    }
  }

  String bookPath;

  int _titleIndex = -1;
  int _titleSubIndex = -1;
  int _contentIndex = -1;
  double _scrollPos = 0;

  final List<SanQianItem> _titleData = [];
  final _contentData = <String>[];

  int get titleIndex => _titleIndex;
  int get titleSubIndex => _titleSubIndex;
  int get contentIndex => _contentIndex;
  double get scrollPos => _scrollPos;
  set scrollPos(double newPos) {
    _scrollPos = newPos;
    LocalStorageUtils.setDouble(_scrollPosCfgKey, _scrollPos);
  }

  String get _scrollPosCfgKey =>
      '${LocalStorageKeys.sanQianCurrentIndexScrollPosPre}_${bookPath}_${contentIndex}';

  List<SanQianItem> get titleData => _titleData;
  List<String> get contentData => _contentData;

  setIndex(int ti, int tsi, int ci) {
    _titleIndex = ti;
    _titleSubIndex = tsi;
    _contentIndex = ci;
    _readScrollPos();
    _saveCfg();
  }

  _readScrollPos() async {
    _scrollPos = await LocalStorageUtils.getDouble(_scrollPosCfgKey) ?? 0;
  }

  _saveCfg() {
    LocalStorageUtils.setString(_cfgKey, '${_titleIndex}_${_titleSubIndex}_${_contentIndex}');
  }

  String get _cfgKey => '${LocalStorageKeys.sanQianCurrentIndexPre}_$bookPath';

  void go(int direction) {
    if (direction == -1) {
      if (contentIndex == 0) return;
      --_contentIndex;
      while (true) {
        if (_titleSubIndex > 0 && (!titleData[titleIndex].isDesc)) --_titleSubIndex;
        if (titleData[titleIndex].items[titleSubIndex].index == contentIndex) break;

        if (_titleIndex > 0) {
          --_titleIndex;
          _titleSubIndex = titleData[titleIndex].items.length - 1;
        }
        if (titleData[titleIndex].items[titleSubIndex].index == contentIndex) break;
      }
      _saveCfg();
      _readScrollPos();
    } else if (direction == 1) {
      if (contentIndex >= contentData.length - 1) return;
      ++_contentIndex;
      while (true) {
        if (_titleSubIndex == 0 && (!titleData[titleIndex].isDesc)) ++_titleSubIndex;
        if (titleData[titleIndex].items[titleSubIndex].index == contentIndex) break;

        ++_titleIndex;
        _titleSubIndex = 0;
        if (titleData[titleIndex].items[titleSubIndex].index == contentIndex) break;
      }
      _saveCfg();
      _readScrollPos();
    }
  }
}
