import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/pages/jgw/mgr.dart';
import 'package:sudict/pages/router.dart';

class JgwPage extends StatefulWidget {
  const JgwPage({super.key});
  @override
  State<JgwPage> createState() => _JgwPageState();
}

class _LiuShuItem {
  _LiuShuItem(this.name, this.desc);
  String name;
  String desc;
}

class _JgwPageState extends State<JgwPage> {
  final _liushuData = [
    _LiuShuItem('象形', '象形者，\n畫成其物，隨體詰屈，\n日月是也。'),
    _LiuShuItem('指事', '指事者，\n視而可識，察而可見，\n上下是也。'),
    _LiuShuItem('會意', '會意者，\n比類合誼，以見指撝，\n武信是也'),
    _LiuShuItem('形聲', '形聲者，\n以事爲名，取譬相成，\n江河是也。'),
    _LiuShuItem('轉注', '轉注者，\n建類一首，同意相受，\n考老是也。'),
    _LiuShuItem('假借', '假借者，\n本無其字，依聲託事，\n令長是也。'),
  ];

  String? _currWord;
  String? _currPart;
  String? _currCatalog;

  String? _randomWord;
  String? _randomPart;
  String? _randomCatalog;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await JgwMgr.instance.loadData();
    _refreshUI();
  }

  _refreshUI() {
    // current
    final currWordInfo = JgwMgr.instance.currWord;
    _currWord = currWordInfo['jgw'];

    final currPartInfo = JgwMgr.instance.currPart;
    _currPart = currPartInfo['name'];

    final currCatalogInfo = JgwMgr.instance.currCatalog;
    _currCatalog = currCatalogInfo['name'];

    // random
    final randomWordInfo = JgwMgr.instance.randomWord;
    _randomWord = randomWordInfo['jgw'];

    final randomPartInfo = JgwMgr.instance.randomPart;
    _randomPart = randomPartInfo['name'];

    final randomCatalogInfo = JgwMgr.instance.randomCatalog;
    _randomCatalog = randomCatalogInfo['name'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const itemHeight = 80.0;
    const intervalSpace = 40.0;
    const innerIntervalSpace = 4.0;
    return Scaffold(
        appBar: AppBar(
          title: const Text('甲骨文字'),
          actions: [
            IconButton(
                onPressed: () {
                  NavigatorUtils.go(context, AppRouteName.jgwSearch, null);
                },
                icon: const Icon(Icons.search_outlined))
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Text(' 因緣會字'),
                  const SizedBox(
                    height: innerIntervalSpace,
                  ),
                  FishInkwell(
                    onTap: () async {
                      await NavigatorUtils.go(context, AppRouteName.jgwPrictice, true);
                      _refreshUI();
                    },
                    child: Container(
                      height: itemHeight,
                      padding: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.withOpacity(0.6),
                              Colors.blue.withOpacity(0.9),
                            ],
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _randomWord ?? '',
                            style: const TextStyle(fontFamily: 'jgwiconfont', fontSize: 48),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Text('部首：'),
                                  Text(_randomPart ?? '',
                                      style:
                                          const TextStyle(fontFamily: 'jgwiconfont', fontSize: 30))
                                ],
                              ),
                              Row(children: [const Text('分類：'), Text(_randomCatalog ?? '')])
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: intervalSpace,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(' 分類練習'),
                      FishInkwell(
                        onTap: () async {
                          await NavigatorUtils.go(context, AppRouteName.jgwCatalog, null);
                          _refreshUI();
                        },
                        child: const Row(
                          children: [
                            Text('切換'),
                            Icon(
                              Icons.keyboard_arrow_right_outlined,
                              size: 18,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: innerIntervalSpace,
                  ),
                  FishInkwell(
                      onTap: () async {
                        await NavigatorUtils.go(context, AppRouteName.jgwPrictice, false);
                        _refreshUI();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        height: itemHeight,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.brown.withOpacity(0.6),
                                Colors.brown.withOpacity(0.9),
                              ],
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _currWord ?? '',
                              style: const TextStyle(fontFamily: 'jgwiconfont', fontSize: 48),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Text('部首：'),
                                    Text(_currPart ?? '',
                                        style: const TextStyle(
                                            fontFamily: 'jgwiconfont', fontSize: 30))
                                  ],
                                ),
                                Row(children: [const Text('分類：'), Text(_currCatalog ?? '')])
                              ],
                            )
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: intervalSpace,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(' 六書'),
                      FishInkwell(
                        onTap: () {
                          NavigatorUtils.go(context, AppRouteName.jgwLiushuRead, 0);
                        },
                        child: const Row(
                          children: [
                            Text('古文字引言'),
                            Icon(
                              Icons.keyboard_arrow_right_outlined,
                              size: 18,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: innerIntervalSpace,
                  ),
                  SizedBox(
                      height: itemHeight,
                      child: ListView.builder(
                          itemCount: _liushuData.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final item = _liushuData[index];
                            return Row(
                              children: [
                                if (index > 0)
                                  const SizedBox(
                                    width: 20,
                                  ),
                                FishInkwell(
                                    onTap: () {
                                      NavigatorUtils.go(
                                          context, AppRouteName.jgwLiushuRead, index + 1);
                                    },
                                    child: Container(
                                      height: itemHeight,
                                      width: 220,
                                      padding: const EdgeInsets.only(left: 16, bottom: 4, right: 4),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.black.withOpacity(0.7),
                                            ],
                                          )),
                                      child: Row(
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                                color: Colors.white54, fontSize: 24),
                                          ),
                                          Expanded(
                                              child: Text(
                                            item.desc,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(color: Colors.white24),
                                          ))
                                        ],
                                      ),
                                    ))
                              ],
                            );
                          })),
                  const SizedBox(
                    height: intervalSpace,
                  ),
                  const Text(
                    ' 設定',
                    style: TextStyle(color: Color.fromARGB(255, 226, 90, 40)),
                  ),
                  const SizedBox(
                    height: innerIntervalSpace,
                  ),
                  FishInkwell(
                    onTap: () {
                      NavigatorUtils.go(context, AppRouteName.jgwSetting, null);
                    },
                    child: Container(
                      height: itemHeight,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.black.withOpacity(0.4),
                            ],
                          )),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.settings_outlined, color: Color.fromARGB(255, 226, 90, 40)),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '字號設定',
                            style: TextStyle(color: Color.fromARGB(255, 226, 90, 40)),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: intervalSpace,
                  ),
                  const Text(' 小記'),
                  const SizedBox(
                    height: innerIntervalSpace,
                  ),
                  FishInkwell(
                      onTap: () {
                        NavigatorUtils.go(context, AppRouteName.jgwAbout, null);
                      },
                      child: Container(
                        height: itemHeight,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.1),
                              ],
                            )),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.settings_outlined, color: Colors.black87),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              '甲骨文字製作說明',
                              style: TextStyle(color: Colors.black87),
                            )
                          ],
                        ),
                      )),
                ],
              ),
            )));
  }
}
