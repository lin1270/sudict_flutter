import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/san_qian/struct.dart';

class SanQianReadPage extends StatefulWidget {
  const SanQianReadPage({super.key, this.arguments});

  final dynamic arguments;

  @override
  State<SanQianReadPage> createState() => _SanQianReadPageState();
}

class _SanQianReadPageState extends State<SanQianReadPage> {
  final _contentController = TextEditingController();
  final _scrollController = ScrollController();
  var _isFirstLoadForJump = true;

  @override
  void dispose() {
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SanQianReadParam param = widget.arguments as SanQianReadParam;

    WidgetsBinding.instance.addPostFrameCallback((mag) {
      if (_isFirstLoadForJump) {
        _scrollController.jumpTo(param.handler.scrollPos);
        _isFirstLoadForJump = false;
      }
    });

    _scrollController.addListener(() {
      param.handler.scrollPos = _scrollController.offset;
    });
  }

  _go(int direction) {
    SanQianReadParam param = widget.arguments as SanQianReadParam;
    param.handler.go(direction);
    setState(() {});
    Timer(const Duration(milliseconds: 20), () {
      _scrollController.jumpTo(param.handler.scrollPos);
    });
  }

  @override
  Widget build(BuildContext context) {
    SanQianReadParam param = widget.arguments as SanQianReadParam;
    SanQianItem item = param.handler.titleData[param.handler.titleIndex];
    final subItem = item.items[param.handler.titleSubIndex];
    String content = '${param.handler.contentData[param.handler.contentIndex]}\n\n\n';
    _contentController.text = '${subItem.fullTitle}\n\n${content.replaceAll('\n', '\n\n')}';
    return Scaffold(
        appBar: AppBar(
          title: Text(subItem.fullTitle),
          actions: [
            IconButton(
                onPressed: () {
                  if (param.handler.contentIndex == 0) {
                    UiUtils.toast(content: '當前已是首章，不能後退了哦。');
                    return;
                  }
                  _go(-1);
                },
                icon: const Icon(Icons.keyboard_arrow_left)),
            IconButton(
                onPressed: () {
                  if (param.handler.contentIndex >= param.handler.contentData.length - 1) {
                    UiUtils.toast(content: '當前已是尾章，不能前進了哦。');
                    return;
                  }
                  _go(1);
                },
                icon: const Icon(Icons.keyboard_arrow_right))
          ],
        ),
        body: Column(children: [
          Expanded(
              child: TextField(
            readOnly: true,
            maxLines: 99999,
            controller: _contentController,
            style: const TextStyle(fontSize: 18),
            scrollController: _scrollController,
            decoration: const InputDecoration(
                border: InputBorder.none, contentPadding: EdgeInsets.only(left: 16, right: 16)),
          ))
        ]));
  }
}
