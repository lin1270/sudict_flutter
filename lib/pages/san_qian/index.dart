import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/pages/router.dart';
import 'package:sudict/pages/san_qian/handler.dart';
import 'package:sudict/pages/san_qian/struct.dart';

class SanQianPageParam {
  SanQianPageParam(this.title, this.bookPath);
  String title;
  String bookPath;
}

class SanQianPage extends StatefulWidget {
  const SanQianPage({super.key, required this.arguments});

  final dynamic arguments;

  @override
  State<SanQianPage> createState() => _SanQianPageState();
}

class _SanQianPageState extends State<SanQianPage> with SingleTickerProviderStateMixin {
  SanQianPageParam? _param;
  SanQianDataHandler? _handler;
  final _listController = FlutterListViewController();
  final double _itemHeight = 32;

  @override
  void initState() {
    super.initState();
    _param = widget.arguments;
    _init();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  _init() async {
    _handler = SanQianDataHandler(_param!.bookPath);
    await _handler!.init();
    setState(() {});
  }

  _refreshState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_param?.title ?? ''),
          actions: (_handler?.titleIndex ?? -1) >= 0
              ? [
                  IconButton(
                    onPressed: () {
                      _listController.animateTo(_handler!.titleIndex * _itemHeight,
                          curve: Curves.bounceIn, duration: const Duration(milliseconds: 200));
                    },
                    icon: const Icon(Icons.location_searching_rounded),
                  ),
                  TextButton(
                      onPressed: () async {
                        await NavigatorUtils.go(
                            context, AppRouteName.sanQianRead, SanQianReadParam(_handler!));
                        _refreshState();
                      },
                      child:
                          const Text('上次閱讀', style: TextStyle(color: Color.fromARGB(192, 0, 0, 0))))
                ]
              : null,
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  children: [
                    Expanded(
                        child: FlutterListView(
                            controller: _listController,
                            delegate: FlutterListViewDelegate((context, index) {
                              if (index == 0) {
                                return const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: Colors.black38,
                                    ),
                                    Text(
                                      ' 每行皆可點擊可查看釋義哦~',
                                      style: TextStyle(color: Colors.black38),
                                    )
                                  ],
                                );
                              }

                              final item = _handler!.titleData[index - 1];
                              return SizedBox(
                                  height: _itemHeight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: item.items
                                        .map((e) => GestureDetector(
                                            onTap: () async {
                                              _handler!.setIndex(
                                                  index - 1, item.items.indexOf(e), e.index);
                                              setState(() {});
                                              await NavigatorUtils.go(
                                                  context,
                                                  AppRouteName.sanQianRead,
                                                  SanQianReadParam(_handler!));
                                              _refreshState();
                                            },
                                            child: Text(
                                              e.title,
                                              style: TextStyle(
                                                  fontSize: item.isDesc ? 22 : 18,
                                                  fontWeight: item.isDesc
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: _handler!.contentIndex == e.index
                                                      ? UIConfig.selectedColor
                                                      : Colors.black),
                                            )))
                                        .toList(),
                                  ));
                            },
                                childCount: (_handler?.titleData.length ?? -1) + 1,
                                preferItemHeight: _itemHeight))),
                  ],
                ))));
  }
}
