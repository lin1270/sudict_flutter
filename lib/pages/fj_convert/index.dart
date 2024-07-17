import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/string.dart';
import 'package:sudict/pages/router.dart';

class FjConvertPage extends StatefulWidget {
  const FjConvertPage({super.key});

  @override
  State<FjConvertPage> createState() => _FjConvertPageState();
}

class _FjConvertPageState extends State<FjConvertPage> with SingleTickerProviderStateMixin {
  final _options = [
    ["簡化字 ⇒ 繁體字", S2T()],
    ["繁體字 ⇒ 簡化字", T2S()],
    ["簡化字 ⇒ 香港繁體", S2HK()],
    ["香港繁體 ⇒ 簡化字", HK2S()],
    ["簡化字 ⇒ 臺灣正體", S2TW()],
    ["臺灣正體 ⇒ 簡化字", TW2S()],
    ["簡化字 ⇒ 臺灣正體(習慣用語)", S2TWp()],
    ["臺灣正體 ⇒ 簡化字(習慣用語)", TW2Sp()],
  ];
  int _currIndex = 0;
  final _editController = TextEditingController();
  final _optionMenuController = CustomPopupMenuController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _optionMenuController.dispose();
    _editController.dispose();
    super.dispose();
  }

  _init() async {
    _currIndex = await LocalStorageUtils.getInt(LocalStorageKeys.fjCurrentIndex) ?? 0;
    setState(() {});
  }

  _convert() async {
    dynamic option = _options[_currIndex][1];
    var result = await ChineseConverter.convert(_editController.text, option);
    _editController.text = result;
  }

  _onChanged(List<Object> item, index) {
    _currIndex = index;
    LocalStorageUtils.setInt(LocalStorageKeys.fjCurrentIndex, _currIndex);
    _optionMenuController.hideMenu();
    _convert();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('繁簡轉換 - opencc'),
          actions: [
            IconButton(
                onPressed: () {
                  NavigatorUtils.go(context, AppRouteName.fjConvertReflect, null);
                },
                icon: const Icon(Icons.menu_book_outlined)),
          ],
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                        child: Stack(children: [
                      TextField(
                        style: const TextStyle(fontSize: 18),
                        controller: _editController,
                        maxLines: 99999999,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(16),
                            border: OutlineInputBorder(),
                            hintText: '請輸入要轉換的文字',
                            filled: true,
                            fillColor: Colors.white70),
                      ),
                      Positioned(
                          right: 0,
                          bottom: 0,
                          child: Column(children: [
                            IconButton(
                                onPressed: () {
                                  _editController.text = "";
                                },
                                icon: const Icon(Icons.close)),
                            IconButton(
                                onPressed: () {
                                  StringUtils.copyToClipboard(_editController.text);
                                },
                                icon: const Icon(Icons.copy)),
                          ]))
                    ])),
                    Row(
                      children: [
                        Expanded(
                            child: CustomPopupMenu(
                          horizontalMargin: 2,
                          controller: _optionMenuController,
                          barrierColor: Colors.transparent,
                          pressType: PressType.singleClick,
                          menuBuilder: () {
                            return ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.center,
                                    height: 178,
                                    color: const Color(0xFF4C4C4C),
                                    child: ListView.builder(
                                        itemCount: _options.length ~/ 2,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                      child: GestureDetector(
                                                    onTap: () {
                                                      _onChanged(
                                                          _options[index * 2 + 0], index * 2 + 0);
                                                    },
                                                    child: Text(
                                                      _options[index * 2 + 0][0] as String,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color: Colors.white, fontSize: 16),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  )),
                                                  Expanded(
                                                      child: GestureDetector(
                                                    onTap: () {
                                                      _onChanged(
                                                          _options[index * 2 + 1], index * 2 + 1);
                                                    },
                                                    child: Text(
                                                      maxLines: 1,
                                                      _options[index * 2 + 1][0] as String,
                                                      style: const TextStyle(
                                                          color: Colors.white, fontSize: 16),
                                                      textAlign: TextAlign.end,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                                ],
                                              ));
                                        })));
                          },
                          verticalMargin: 0,
                          showArrow: true,
                          child: Container(
                              decoration: BoxDecoration(
                                  border: const Border.fromBorderSide(
                                      BorderSide(color: Colors.black45)),
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 8),
                              child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    _options[_currIndex][0] as String,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ))),
                        )),
                        IconButton(
                            onPressed: () {
                              if (_currIndex % 2 == 0) {
                                ++_currIndex;
                              } else {
                                --_currIndex;
                              }
                              _convert();
                              setState(() {});
                            },
                            icon: const Icon(Icons.swap_horiz_outlined)),
                        IconButton(
                            onPressed: _convert,
                            icon: const Icon(
                              Icons.change_circle,
                              size: 48,
                            )),
                      ],
                    )
                  ],
                ))));
  }
}
