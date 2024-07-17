import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:sudict/modules/ui_comps/webview/controller.dart';
import 'package:sudict/modules/ui_comps/webview/delegate.dart';
import 'package:sudict/modules/ui_comps/webview/index.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/jgw/html_maker.dart';
import 'package:sudict/pages/jgw/mgr.dart';

class _WebViewHandler implements WebViewProxyDelegate {
  _WebViewHandler(this.index, this.isRandom);
  int index;
  bool isRandom;
  int totalPos = 0;
  final controller = WebViewProxyController();

  @override
  void onWebViewProxyInited() async {
    int pos = index;
    if (isRandom) {
      pos = JgwMgr.instance.generateRandom();
    }
    totalPos = pos;
    final posInfo = JgwMgr.instance.getPosInfoByTotalPos(pos);
    if (posInfo == null) return;
    final item = JgwMgr.instance.getWordInfoByPosInfo(posInfo);
    String c = item['content'];
    var content = await makeHtml(c);
    controller.loadContent(content);
  }

  @override
  bool onWebViewProxyNavigate(String url) {
    return true;
  }

  @override
  void onWebViewProxySearch(String selectedString) {}
}

// ignore: must_be_immutable
class JgwPracticePage extends StatefulWidget {
  JgwPracticePage({super.key, required this.isRandom});

  bool isRandom;

  @override
  State<JgwPracticePage> createState() => _JgwPracticePageState();
}

class _JgwPracticePageState extends State<JgwPracticePage> {
  final _webHandlers = <int, _WebViewHandler>{};
  late LoopPageController _pageViewController;

  @override
  void initState() {
    super.initState();
    _pageViewController = LoopPageController(
        initialPage:
            widget.isRandom ? JgwMgr.instance.randomTotalPos : JgwMgr.instance.currentTotalPos);
  }

  @override
  void dispose() {
    for (final ctrl in _webHandlers.values) {
      ctrl.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.isRandom ? '因緣會字' : '分類練習'),
          actions: [
            if (Platform.isWindows)
              IconButton(
                  onPressed: () {
                    _pageViewController.jumpToPage(
                        (_pageViewController.page.toInt() + 1) % JgwMgr.instance.totalCount);
                  },
                  icon: const Icon(Icons.keyboard_arrow_right)),
            IconButton(
                onPressed: () {
                  final handler = _webHandlers[_pageViewController.page.toInt()];
                  if (handler != null) {
                    final posInfo = JgwMgr.instance.getPosInfoByTotalPos(handler.totalPos);
                    if (posInfo != null) {
                      final wordInfo = JgwMgr.instance.getWordInfoByPosInfo(posInfo);
                      if (wordInfo != null) {
                        String? word = wordInfo['word'];
                        UiUtils.showTempDictDialog(context, word ?? '');
                      }
                    }
                  }
                },
                icon: const Icon(Icons.search_outlined))
          ],
        ),
        body: LoopPageView.builder(
          controller: _pageViewController,
          onPageChanged: (value) {
            final posInfo = JgwMgr.instance.getPosInfoByTotalPos(value);
            if (posInfo != null) {
              JgwMgr.instance
                  .setCurrentItem(posInfo.catalogIndex, posInfo.partIndex, posInfo.wordIndex);
            }
          },
          itemCount: JgwMgr.instance.totalCount,
          itemBuilder: (context, index) {
            var handler = _webHandlers[index];
            if (handler == null) {
              handler = _WebViewHandler(index, widget.isRandom);
              _webHandlers[index] = handler;
            }
            return WebViewProxyWidget(
              controller: handler.controller,
              delegate: handler,
              gestureRecognizers: {
                Factory(() => VerticalDragGestureRecognizer()), // 指定WebView只处理垂直手势。
              },
            );
          },
        ));
  }
}
