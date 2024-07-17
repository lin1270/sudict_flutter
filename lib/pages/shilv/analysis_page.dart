import 'dart:async';

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/shilv/pingshuiyun_common_widget.dart';
import 'package:sudict/pages/shilv/pingshuiyun_data_mgr.dart';

// ignore: must_be_immutable
class ShilvAnalysisPage extends StatefulWidget {
  ShilvAnalysisPage({super.key, required this.content});

  String content;
  @override
  State<ShilvAnalysisPage> createState() => _ShilvAnalysisPageState();
}

class _RuleDescItem {
  _RuleDescItem(this.name, this.desc, {this.descWidget});
  String name;
  String desc;
  Widget? descWidget;
}

enum _Aj {
  a('A', Colors.red),
  j('J', Colors.red),
  z('Z', Colors.green),
  none('', Colors.black);

  const _Aj(this.name, this.color);
  final String name;
  final Color color;
}

enum _Pz {
  p('一'),
  z('|'),
  none('.'),
  unknown('.');

  const _Pz(this.name);
  final String name;
}

enum _PoemLineType {
  j('甲'),
  y('乙'),
  b('丙'),
  d('丁'),
  none('');

  const _PoemLineType(this.name);
  final String name;
}

class _PoemWord {
  // ignore: unused_element
  _PoemWord(this.word, {this.pz = _Pz.none, this.aj = _Aj.none});
  _Pz pz;
  _Aj aj;
  String word;
}

class _PoemLine {
  _PoemLineType type = _PoemLineType.none;
  List<_PoemWord> words = [];
}

class _ShilvAnalysisPageState extends State<ShilvAnalysisPage> {
  final _ruleDesc = <_RuleDescItem>[
    _RuleDescItem('甲種句', '',
        descWidget: const Row(
          children: [
            Text(
              '平平',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
            Text(
              '仄仄平平仄',
              style: TextStyle(fontSize: 12),
            )
          ],
        )),
    _RuleDescItem('乙種句', '',
        descWidget: const Wrap(
          children: [
            Text(
              '仄仄',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
            Text(
              '平平仄仄平',
              style: TextStyle(fontSize: 12),
            )
          ],
        )),
    _RuleDescItem('丙種句', '',
        descWidget: const Wrap(
          children: [
            Text(
              '仄仄',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
            Text(
              '平平平仄仄',
              style: TextStyle(fontSize: 12),
            )
          ],
        )),
    _RuleDescItem('丁種句', '',
        descWidget: const Wrap(
          children: [
            Text(
              '平平',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
            Text(
              '仄仄仄平平',
              style: TextStyle(fontSize: 12),
            )
          ],
        )),
    _RuleDescItem('A', '',
        descWidget: const Text(
          '拗',
          style: TextStyle(fontSize: 12, color: Colors.red),
        )),
    _RuleDescItem('J', '',
        descWidget: const Text(
          '救',
          style: TextStyle(fontSize: 12, color: Colors.red),
        )),
    _RuleDescItem('Z', '',
        descWidget: const Text(
          '自由',
          style: TextStyle(fontSize: 12, color: Colors.green),
        )),
    _RuleDescItem(
      '拗救規則',
      '1. 甲3拗。乙3救。\n2. 甲4拗。乙3救。\n3. 乙1拗。乙3救。\n4. 丙4拗。丙3救。',
    ),
    _RuleDescItem('自由規則', '1. 甲1。\n2. 丁1。\n3. 七言的首字。'),
    _RuleDescItem('半自由規則', '1. 乙3. 無救。\n2. 丙1. 本句無拗救。\n3. 丙3. 本句無救。'),
    _RuleDescItem('孤平', '乙種句僅含1平。'),
    _RuleDescItem('三平調', '丁種句含有3平。'),
    _RuleDescItem('黏', '對句第2字平仄相反。'),
    _RuleDescItem('對', '上聯與下聯的第2字平仄相同。')
  ];

  final _tableCellPaddingHeight = 4.0;
  final _tableCellPaddingWidth = 4.0;

  final _poemLines = <_PoemLine>[];
  bool _showPzaj = true;

  final _poemPzRule7 = [
    [_Pz.p, _Pz.p, _Pz.z, _Pz.z, _Pz.p, _Pz.p, _Pz.z],
    [_Pz.z, _Pz.z, _Pz.p, _Pz.p, _Pz.z, _Pz.z, _Pz.p],
    [_Pz.z, _Pz.z, _Pz.p, _Pz.p, _Pz.p, _Pz.z, _Pz.z],
    [_Pz.p, _Pz.p, _Pz.z, _Pz.z, _Pz.z, _Pz.p, _Pz.p]
  ];

  String _yun = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await PingshuiyunDataMgr.instance.init();
    _parsePoem();
    _showPzaj = await LocalStorageUtils.getBool(LocalStorageKeys.shilvShowPzaj) ?? true;
    setState(() {});
  }

  _parsePoem() {
    var tempData = widget.content
        .replaceAll(RegExp('[0-9A-Za-z，　 、\\\\\\,\\.“”""「」《》。！；？\\?\\!\\;\\r\\n]'), '');

    if (tempData.length % 4 != 0 && tempData.length != 10 && tempData.length != 14) {
      _toast('解析詩失敗！');

      return;
    }

    var isSeven = false;
    if (tempData.length == 14) {
      isSeven = true;
    } else {
      isSeven = tempData.length ~/ 7 % 4 == 0;
    }
    var countPerLine = isSeven ? 7 : 5;

    _poemLines.clear();
    try {
      for (var i = 0; i < tempData.length; i += countPerLine) {
        var line = _PoemLine();

        for (var j = 0; j < countPerLine; ++j) {
          line.words.add(_PoemWord(tempData.substring(i + j, i + j + 1)));
        }

        _poemLines.add(line);
      }
      // ignore: empty_catches
    } catch (e) {}

    _autoAnalysis();
  }

  List<_Pz> _getPingzeOfLine(_PoemLine line) {
    final ret = <_Pz>[];

    for (final wordItem in line.words) {
      var thePz = _Pz.none;
      final founds = PingshuiyunDataMgr.instance.find(wordItem.word);
      for (final catalog in founds) {
        if (catalog.fullName.indexOf('上平') == 0 || catalog.fullName.indexOf('下平') == 0) {
          if (thePz == _Pz.none) {
            thePz = _Pz.p;
          } else if (thePz == _Pz.z) {
            thePz = _Pz.unknown;
          }
        } else {
          if (thePz == _Pz.none) {
            thePz = _Pz.z;
          } else if (thePz == _Pz.p) {
            thePz = _Pz.unknown;
          }
        }
      }

      ret.add(thePz);
    }

    return ret;
  }

  _PoemLineType _getJybd(List<_Pz> linePz) {
    var twoPz = linePz[linePz.length - 4];
    var fivePz = linePz[linePz.length - 1];
    if (twoPz == _Pz.z && fivePz == _Pz.z) return _PoemLineType.j;
    if (twoPz == _Pz.p && fivePz == _Pz.p) return _PoemLineType.y;
    if (twoPz == _Pz.p && fivePz == _Pz.z) return _PoemLineType.b;
    if (twoPz == _Pz.z && fivePz == _Pz.p) return _PoemLineType.d;
    return _PoemLineType.none;
  }

  _autoAnalysis() {
    if (_poemLines.length < 2) {
      _toast('該詩內容不正確，無法自動填充！');
      return;
    }

    var lineWordCount = _poemLines[0].words.length;

    var detectAll = true;

    // 確定第一句
    var toastMsg = '';
    var pz1 = _getPingzeOfLine(_poemLines[0]);
    if (pz1[lineWordCount - 1] == _Pz.none || pz1[lineWordCount - 1 - 3] == _Pz.none) {
      toastMsg = ('首句未能二五定式，僅填充平仄，不作甲乙丙丁及拗救判斷！');
      detectAll = false;
    }

    if (pz1[lineWordCount - 1] == _Pz.unknown || pz1[lineWordCount - 1 - 3] == _Pz.unknown) {
      toastMsg = ('首句二、五字未能定平仄，僅填充平仄，不作甲乙丙丁及拗救判斷！');
      detectAll = false;
    }

    // 確定所有句
    var index = _getJybd(pz1);

    if (index == _PoemLineType.none) {
      toastMsg = ('首句未能確定甲乙丙丁句，僅填充平仄，不作甲乙丙丁及拗救判斷！');
      // return;

      detectAll = false;
    }

    // 填充第一句
    _poemLines[0].type = index;

    for (var j = 0; j < _poemLines[0].words.length && j < pz1.length; ++j) {
      _poemLines[0].words[j].pz = pz1[j];
    }

    if (index == _PoemLineType.y) {
      index = _PoemLineType.d;
    } else if (index == _PoemLineType.d) {
      index = _PoemLineType.y;
    } else {
      index = _PoemLineType.values[(index.index + 1) % _PoemLineType.values.length];
    }

    var i = 1;
    do {
      if (index.index >= _PoemLineType.values.length) index = _PoemLineType.j;
      if (detectAll) {
        _poemLines[i].type = index;
      }

      var pzStr = _getPingzeOfLine(_poemLines[i]);

      for (var j = 0; j < _poemLines[i].words.length && j < pzStr.length; ++j) {
        _poemLines[i].words[j].pz = pzStr[j];
      }
      ++i;
      index = _PoemLineType.values[(index.index + 1) % _PoemLineType.values.length];
      if (index == _PoemLineType.none) index = _PoemLineType.j;
    } while (i < _poemLines.length);

    // 確定拗救
    for (var checkI = 0; checkI < _poemLines.length && detectAll; ++checkI) {
      var typeIndex = _poemLines[checkI].type;

      // 只要不等，都是拗
      for (var i = 0; i < lineWordCount; ++i) {
        if (_poemLines[checkI].words[i].pz != _Pz.none &&
            _poemLines[checkI].words[i].pz != _Pz.unknown &&
            _poemLines[checkI].words[i].pz !=
                _poemPzRule7[typeIndex.index][7 - lineWordCount + i]) {
          _poemLines[checkI].words[i].aj = _Aj.a;
        } else {
          _poemLines[checkI].words[i].aj = _Aj.none;
        }
      }

      // -------------------------纯自由
      // 五言 甲1丁1
      if (typeIndex == _PoemLineType.j || typeIndex == _PoemLineType.d) {
        if (_poemLines[checkI].words[lineWordCount - 5].aj == _Aj.a) {
          _poemLines[checkI].words[lineWordCount - 5].aj = _Aj.z;
        }
      }

      // 七言 首1
      if (lineWordCount == 7) {
        if (_poemLines[checkI].words[0].aj == _Aj.a) {
          _poemLines[checkI].words[0].aj = _Aj.z;
        }
      }

      // --------------------------半自由
      // 乙3无救，3自由
      if (typeIndex == _PoemLineType.y) {
        if (_poemLines[checkI].words[lineWordCount - 3].aj == _Aj.a) {
          if (checkI == 0) {
            if (_poemLines[checkI].words[lineWordCount - 5].aj == _Aj.none) {
              _poemLines[checkI].words[lineWordCount - 3].aj = _Aj.z;
            }
          } else {
            var preLine = _poemLines[checkI - 1];

            if (preLine.type == _PoemLineType.j) {
              // 上一句是甲
              // 甲3甲4乙1都不拗
              if (preLine.words[lineWordCount - 3].aj == _Aj.none &&
                  preLine.words[lineWordCount - 2].aj == _Aj.none &&
                  _poemLines[checkI].words[lineWordCount - 5].aj == _Aj.none) {
                _poemLines[checkI].words[lineWordCount - 3].aj = _Aj.z;
              }
            }
          }
        }
      }

      if (typeIndex == _PoemLineType.b) {
        if (_poemLines[checkI].words[0].aj == _Aj.a) {
          if (_poemLines[checkI].words[2].aj == _Aj.none &&
              _poemLines[checkI].words[3].aj == _Aj.none) {
            _poemLines[checkI].words[0].aj = _Aj.z;
          }
        } else if (_poemLines[checkI].words[2].aj == _Aj.a) {
          if (_poemLines[checkI].words[3].aj == _Aj.none) {
            _poemLines[checkI].words[2].aj = _Aj.z;
          }
        }
      }

      // ------------------------- 拗救->丙4拗丙3救
      if (typeIndex == _PoemLineType.b) {
        var hasAo = _poemLines[checkI].words[lineWordCount - 2].aj == _Aj.a;

        if (_poemLines[checkI].words[lineWordCount - 3].aj == _Aj.a) {
          if (hasAo) {
            _poemLines[checkI].words[lineWordCount - 3].aj = _Aj.j;
          }
        }
      }

      // -------------------------- 拗救->甲3甲4乙1拗乙3救
      if (typeIndex == _PoemLineType.y) {
        var hasAo = _poemLines[checkI].words[lineWordCount - 5].aj == _Aj.a;

        if (_poemLines[checkI].words[lineWordCount - 3].aj == _Aj.a) {
          if (!hasAo && checkI > 0) {
            var preLine = _poemLines[checkI - 1];
            if (preLine.type == _PoemLineType.j) {
              // 上一句是甲
              // 甲3甲4乙1都不拗
              if (preLine.words[lineWordCount - 3].aj == _Aj.a ||
                  preLine.words[lineWordCount - 2].aj == _Aj.a) {
                hasAo = true;
              }
            }
          }

          if (hasAo) {
            _poemLines[checkI].words[lineWordCount - 3].aj = _Aj.j;
          }
        }
      }
    }

    // 押韻
    if (_poemLines[1].words.isNotEmpty) {
      var lastWord = _poemLines[1].words[_poemLines[1].words.length - 1];

      final found = PingshuiyunDataMgr.instance.find(lastWord.word);
      if (found.isNotEmpty) {
        _yun = found[0].name;
      }
    }

    _toast(toastMsg);

    setState(() {});
  }

  _toast(String toastMsg) {
    if (toastMsg.isNotEmpty) {
      Timer(const Duration(milliseconds: 50), () {
        UiUtils.toast(content: toastMsg);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('分析'), actions: [
          IconButton(
            onPressed: () {
              for (final line in _poemLines) {
                line.type = _PoemLineType.none;
                for (final word in line.words) {
                  word.aj = _Aj.none;
                  word.pz = _Pz.none;
                }
              }
              setState(() {});
            },
            icon: const Icon(Icons.remove_circle_outline),
          ),
          IconButton(
              onPressed: () {
                _showPzaj = !_showPzaj;
                LocalStorageUtils.setBool(LocalStorageKeys.shilvShowPzaj, _showPzaj);
                setState(() {});
              },
              icon: Icon(_showPzaj ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
          IconButton(
              onPressed: () {
                _autoAnalysis();
              },
              icon: const Icon(Icons.auto_fix_high_outlined)),
        ]),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: ListBody(
                children: [
                  _poemWidget(),
                  const SizedBox(
                    height: 10,
                  ),
                  _yunWidget(),
                  const SizedBox(
                    height: 40,
                  ),
                  _analysisDescWidget(),
                  _ruleDescWidget(),
                ],
              ),
            )));
  }

  final _typeWidth = 30.0;
  final _typeHeight = 50.0;
  final _ajHeight = 20.0;
  final _wordWidth = 30.0;
  final _ajpzHeight = 20.0;

  Widget _wordWidget(_PoemWord wordItem) {
    return Column(
      children: [
        if (_showPzaj)
          FishInkwell(
            onTap: () {
              setState(() {
                final nextIndex = (wordItem.aj.index + 1) % _Aj.values.length;
                wordItem.aj = _Aj.values[nextIndex];
              });
            },
            child: Container(
              alignment: Alignment.center,
              width: _wordWidth,
              height: _ajpzHeight,
              child: Text(wordItem.aj.name, style: TextStyle(color: wordItem.aj.color)),
            ),
          ),
        if (_showPzaj)
          FishInkwell(
            onTap: () {
              setState(() {
                final nextIndex = (wordItem.pz.index + 1) % _Pz.values.length;
                wordItem.pz = _Pz.values[nextIndex];
              });
            },
            child: Container(
              alignment: Alignment.center,
              width: _wordWidth,
              height: _ajpzHeight,
              child: Text(wordItem.pz.name, style: TextStyle(color: wordItem.aj.color)),
            ),
          ),
        FishInkwell(
          onTap: () {
            final size = MediaQuery.of(context).size;
            final foundResult = PingshuiyunDataMgr.instance.find(wordItem.word);

            MyDialog.popup(resultWidget(foundResult, wordItem.word),
                isScrollControlled: true, height: size.height * 0.6);
          },
          child: Container(
            alignment: Alignment.center,
            width: _wordWidth,
            height: _typeHeight - _ajpzHeight,
            child: Text(
              wordItem.word,
              style: TextStyle(fontSize: 20, color: _showPzaj ? wordItem.aj.color : _Aj.none.color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _yunWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 28,
          width: 4,
          margin: const EdgeInsets.only(right: 10),
          decoration: const BoxDecoration(color: Colors.purple),
        ),
        const Text(
          '押',
          style: TextStyle(fontSize: 24),
        ),
        FishInkwell(
            onTap: () {
              final size = MediaQuery.of(context).size;

              MyDialog.popup(groupWidget((catalog) {
                setState(() {
                  _yun = catalog.name;
                });
                NavigatorUtils.pop(context);
              }), isScrollControlled: true, height: size.height * 0.8);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Text(
                _yun.isEmpty ? '?' : _yun,
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.purple,
                    decorationColor: Colors.purple,
                    decoration: TextDecoration.underline),
              ),
            )),
        const Text(
          '韻',
          style: TextStyle(fontSize: 24),
        )
      ],
    );
  }

  Widget _poemWidget() {
    return Column(
      children: List.generate(_poemLines.length, (lineIndex) {
        final lineItem = _poemLines[lineIndex];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_showPzaj)
              SizedBox(
                height: _ajHeight + _typeHeight,
                child: Column(
                  children: [
                    Container(
                      width: _typeWidth,
                      height: _ajHeight,
                      alignment: Alignment.center,
                      child: const Text(
                        'AJ',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    FishInkwell(
                      onTap: () {
                        setState(() {
                          final nextIndex = (lineItem.type.index + 1) % _PoemLineType.values.length;
                          lineItem.type = _PoemLineType.values[nextIndex];
                        });
                      },
                      child: Container(
                        width: _typeWidth,
                        height: _typeHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue.withAlpha(100)),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(lineItem.type.name),
                      ),
                    )
                  ],
                ),
              ),
            ...List.generate(lineItem.words.length, (wordIndex) {
              final wordItem = lineItem.words[wordIndex];
              return _wordWidget(wordItem);
            })
          ],
        );
      }),
    );
  }

  Widget _analysisDescWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分析',
          style: TextStyle(fontSize: 12, color: Colors.purple),
        ),
        const SizedBox(
          height: 4,
        ),
        SizedBox(
            height: 100,
            child: DataTable2(
                border: TableBorder.all(color: Colors.black26),
                columnSpacing: 0,
                horizontalMargin: 0,
                headingRowHeight: 20,
                dividerThickness: 0,
                dataRowHeight: 60,
                columns: const [
                  DataColumn2(
                    label: Center(child: Text('用韻', style: TextStyle(fontSize: 12))),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Center(child: Text('平仄', style: TextStyle(fontSize: 12))),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                      label: Center(child: Text('對仗', style: TextStyle(fontSize: 12))),
                      size: ColumnSize.S,
                      fixedWidth: 110),
                  DataColumn2(
                    label: Center(child: Text('句式', style: TextStyle(fontSize: 12))),
                    size: ColumnSize.S,
                  ),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Center(
                      child: Text(
                        '鄰韻\n重韻\n一韻到底',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    )),
                    DataCell(Center(
                        child: Text('黏對\n犯孤平\n三平調',
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 12)))),
                    DataCell(Center(
                        child: Text('工對、鄰對\n寬對、藉對\n流水對、扇面對',
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 12)))),
                    DataCell(Center(
                        child: Text('三字尾',
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 12)))),
                  ])
                ])),
      ],
    );
  }

  Widget _ruleDescWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '說明（僅分析平韻）',
          style: TextStyle(fontSize: 12, color: Colors.purple),
        ),
        const SizedBox(
          height: 4,
        ),
        const Text(
          '請嘗試點擊“甲”、“A”、“一”、“|”及詩中字，均會有交互功能，方便校錯與查閱。',
          style: TextStyle(fontSize: 12, color: Colors.purple),
        ),
        Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: _tableCellPaddingHeight),
                  width: 80,
                  child: const Center(
                    child: Text(
                      '#',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                      padding: EdgeInsets.only(
                          top: _tableCellPaddingHeight,
                          bottom: _tableCellPaddingHeight,
                          left: _tableCellPaddingWidth),
                      decoration: const BoxDecoration(
                          border: Border(left: BorderSide(color: Colors.black26))),
                      width: 80,
                      child: const Text('說明', style: TextStyle(fontSize: 12))),
                )
              ],
            )),
        Column(
            children: List.generate(_ruleDesc.length, (index) {
          final item = _ruleDesc[index];
          return Container(
              decoration: const BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.black26),
                      bottom: BorderSide(color: Colors.black26),
                      left: BorderSide(color: Colors.black26))),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: _tableCellPaddingHeight),
                    width: 80,
                    child: Center(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.only(
                            top: _tableCellPaddingHeight,
                            bottom: _tableCellPaddingHeight,
                            left: _tableCellPaddingWidth),
                        decoration: const BoxDecoration(
                            border: Border(left: BorderSide(color: Colors.black26))),
                        width: 80,
                        child: item.descWidget != null
                            ? item.descWidget!
                            : Text(item.desc, style: const TextStyle(fontSize: 12))),
                  )
                ],
              ));
        })),
      ],
    );
  }
}
