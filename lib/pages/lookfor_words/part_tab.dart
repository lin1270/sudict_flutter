import 'package:flutter/material.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/lookfor_words/lookfor_dict_mgr.dart';

class LookforPartTab extends StatefulWidget {
  const LookforPartTab({super.key});

  @override
  State<LookforPartTab> createState() => _LookforPartTabState();
}

class _PartPickGroup {
  _PartPickGroup(this.title, String wordsStr) {
    words = wordsStr.characters.toList();
  }
  String title;
  late List<String> words;
}

class _LookforPartTabState extends State<LookforPartTab> with AutomaticKeepAliveClientMixin {
  var _data = <String>[];
  final _pickData = <_PartPickGroup>[];
  final _searchTextFieldController = TextEditingController();
  bool _allMatch = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchTextFieldController.dispose();
    super.dispose();
  }

  _init() async {
    _pickData.add(_PartPickGroup('2劃', '厂匚刂冂亻勹儿亠冫丷冖讠凵卩阝厶廴'));
    _pickData.add(_PartPickGroup('3劃', '艹屮彳巛辶飞彑廾广彐宀犭彡尸饣扌氵纟忄幺弋尢夂'));
    _pickData.add(_PartPickGroup('4劃', '灬卝旡耂牜爿攴攵气礻爫癶钅皿疒罒疋业衤艮虍臼糹覀聿辵豸釒飠髟龠'));

    setState(() {});
  }

  _searchPart(String v) {
    _data = LookforDictMgr.instance.findWordByParts(v, _allMatch) ?? [];
    setState(() {});
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
        height: 200,
        decoration: const BoxDecoration(
            color: Colors.white54, border: Border(top: BorderSide(color: Colors.black12))),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: _pickData.length,
                    itemBuilder: (context, index) {
                      final item = _pickData[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(color: Colors.black38),
                          ),
                          GridView.builder(
                            //将所有子控件在父控件中填满
                            shrinkWrap: true,
                            //解决ListView嵌套GridView滑动冲突问题
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 9, //每行几列
                                childAspectRatio: 1),
                            itemCount: item.words.length,
                            itemBuilder: (context, index) {
                              return TextButton(
                                onPressed: () {
                                  _searchTextFieldController.text += item.words[index];
                                  _searchPart(_searchTextFieldController.text);
                                },
                                child: Text(item.words[index]),
                              );
                            },
                          )
                        ],
                      );
                    })),
            Row(children: [
              Expanded(
                  child: TextField(
                style: const TextStyle(fontFamily: 'KaiXinSong'),
                controller: _searchTextFieldController,
                onChanged: _searchPart,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintText: '搜尋部件',
                ),
              )),
              Checkbox(
                  value: _allMatch,
                  onChanged: (v) {
                    _allMatch = v ?? false;
                    _searchPart(_searchTextFieldController.text);
                    setState(() {});
                  }),
              GestureDetector(
                  onTap: () {
                    _allMatch = !_allMatch;
                    _searchPart(_searchTextFieldController.text);
                    setState(() {});
                  },
                  child: const Text('完全匹配'))
            ]),
          ],
        ),
      )
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
