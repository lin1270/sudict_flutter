// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/lookfor_words/lookfor_dict_mgr.dart';
import 'package:sudict/pages/lookfor_words/lookfor_word_info.dart';

class LookforCommonTab extends StatefulWidget {
  const LookforCommonTab({super.key});

  @override
  State<LookforCommonTab> createState() => _LookforCommonTabState();
}

class _LookforCommonTabState extends State<LookforCommonTab> with AutomaticKeepAliveClientMixin {
  final List<String> _data = [];
  List<LookforWordInfo> _allData = [];
  static const _s_bihuas = ["一", "丨", "丿", "丶", "乚"];

  static const _s_bihuaNums = ["1", "2", "3", "4", "5"];

  final _preBihuaTextFieldController = TextEditingController();
  final _wordTextFieldController = TextEditingController();
  final _codeTextFieldController = TextEditingController();
  bool _showSearchCodeWidget = true;
  String _wordCodeResult = '';
  int _minBH = 0;
  int _maxBH = 0;
  var _currBH = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _preBihuaTextFieldController.dispose();
    _wordTextFieldController.dispose();
    _codeTextFieldController.dispose();
    super.dispose();
  }

  _init() async {
    setState(() {});
  }

  _onSearchCode() {
    String toSearch = _codeTextFieldController.text.trim();

    if (toSearch.isEmpty) {
      return;
    }

    if (LookforDictMgr.instance.currType == LookforDictType.bishun.value) {
      for (int i = 0; i < _s_bihuaNums.length; ++i) {
        toSearch = toSearch.replaceAll(_s_bihuas[i], _s_bihuaNums[i]);
      }
    }

    // 耗时的操作
    _allData = LookforDictMgr.instance.findWordByCode(toSearch) ?? [];

    _minBH = _maxBH = 0;
    _allData.sort((v1, v2) {
      if (v1.bishun.length > v2.bishun.length) {
        return 1;
      }

      if (v1.bishun.length < v2.bishun.length) {
        return -1;
      }
      return 0;
    });

    for (LookforWordInfo wordInfo in _allData) {
      int bhs = wordInfo.bishun.length;
      if (bhs > _maxBH) {
        _maxBH = bhs;
      }

      if (_minBH == 0) {
        _minBH = bhs;
      } else if (_minBH > bhs) {
        _minBH = bhs;
      }
    }

    _currBH = _minBH;

    _loadFilter();
  }

  _loadFilter() {
    _data.clear();

    String preBH = _preBihuaTextFieldController.text.trim();
    if (preBH.isNotEmpty) {
      for (int i = 0; i < _s_bihuaNums.length; ++i) {
        preBH = preBH.replaceAll(_s_bihuas[i], _s_bihuaNums[i]);
      }

      for (LookforWordInfo wordInfo in _allData) {
        if (wordInfo.bishun.length >= _currBH && wordInfo.bishun.startsWith(preBH)) {
          _data.add(wordInfo.word);
        }
      }
    } else {
      for (LookforWordInfo wordInfo in _allData) {
        if (wordInfo.bishun.length >= _currBH) {
          _data.add(wordInfo.word);
        }
      }
    }
    setState(() {});
  }

  _onSearchWord() {
    _wordCodeResult =
        LookforDictMgr.instance.findCodeByWord(_wordTextFieldController.text) ?? '未搜尋到結果';
    setState(() {});
  }

  Widget _searchCodeWidget() {
    return Column(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _s_bihuas.sublist(0, 3).map((e) {
              return TextButton(
                  onPressed: () {
                    _preBihuaTextFieldController.text += e;
                    _loadFilter();
                  },
                  child: Text(e));
            }).toList(),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _s_bihuas.sublist(3, _s_bihuas.length).map((e) {
              return TextButton(
                  onPressed: () {
                    _preBihuaTextFieldController.text += e;
                    _loadFilter();
                  },
                  child: Text(e));
            }).toList(),
          )
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_currBH > _minBH) {
                    --_currBH;
                    _loadFilter();
                  }
                },
                child: const Icon(Icons.remove),
              ),
              Text('$_currBH畫'),
              GestureDetector(
                onTap: () {
                  if (_currBH < _maxBH) {
                    ++_currBH;
                    _loadFilter();
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
              child: TextField(
            style: const TextStyle(fontFamily: 'KaiXinSong'),
            controller: _preBihuaTextFieldController,
            onChanged: (v) {
              _loadFilter();
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: '前幾畫',
            ),
          )),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  _showSearchCodeWidget = !_showSearchCodeWidget;
                });
              },
              child: Container(
                  decoration:
                      BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  margin: const EdgeInsets.only(right: 8),
                  child: const Text('反查'))),
          Expanded(
              child: TextField(
            style: const TextStyle(fontFamily: 'KaiXinSong'),
            controller: _codeTextFieldController,
            onChanged: (v) {
              _onSearchCode();
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: '搜尋編碼',
            ),
          )),
        ],
      )
    ]);
  }

  Widget _searchWordWidget() {
    return Column(children: [
      const SizedBox(
        height: 12,
      ),
      const Text(
        ' -反查 -',
        style: TextStyle(fontSize: 16),
      ),
      const SizedBox(
        height: 8,
      ),
      Text(
        _wordCodeResult,
        style: const TextStyle(fontSize: 24),
      ),
      const SizedBox(
        height: 8,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  _showSearchCodeWidget = !_showSearchCodeWidget;
                });
              },
              child: Container(
                  decoration:
                      BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  margin: const EdgeInsets.only(right: 8),
                  child: const Text('返回'))),
          Expanded(
              child: TextField(
            style: const TextStyle(fontFamily: 'KaiXinSong'),
            controller: _wordTextFieldController,
            onChanged: (v) {
              _onSearchWord();
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: '搜尋漢字',
            ),
          )),
        ],
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(children: [
      Expanded(
          child: _data.isEmpty
              ? const Padding(padding: EdgeInsets.all(16), child: Text('暫無數據'))
              : GridView.builder(
                  //将所有子控件在父控件中填满
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6, //每行几列
                      childAspectRatio: 1),
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    return TextButton(
                      onPressed: () {
                        UiUtils.showTempDictDialog(context, _data[index]);
                      },
                      child: Text(
                        _data[index],
                        style: const TextStyle(fontFamily: 'KaiXinSong', fontSize: 24),
                      ),
                    );
                  },
                )),
      Container(
          padding: const EdgeInsets.all(8),
          height: 210,
          decoration: const BoxDecoration(
              color: Colors.white54, border: Border(top: BorderSide(color: Colors.black12))),
          child: Column(children: [
            Visibility(
              visible: _showSearchCodeWidget,
              maintainState: true,
              child: _searchCodeWidget(),
            ),
            Visibility(
              visible: !_showSearchCodeWidget,
              maintainState: true,
              child: _searchWordWidget(),
            )
          ]))
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
