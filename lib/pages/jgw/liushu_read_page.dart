import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:sudict/modules/ui_comps/webview/controller.dart';
import 'package:sudict/modules/ui_comps/webview/delegate.dart';
import 'package:sudict/modules/ui_comps/webview/index.dart';
import 'package:sudict/pages/jgw/html_maker.dart';
import 'package:sudict/pages/jgw/liushu_desc/index.dart';

class LiushuReadPage extends StatefulWidget {
  const LiushuReadPage({super.key, required this.arguments});

  final int arguments;

  @override
  State<LiushuReadPage> createState() => _LiushuReadPageState();
}

class _LiushuReadPageState extends State<LiushuReadPage> implements WebViewProxyDelegate {
  final WebViewProxyController _controller = WebViewProxyController();
  int _index = 0;

  LiuShuDesc get _data {
    return liushuData[_index];
  }

  @override
  void initState() {
    super.initState();
    _index = widget.arguments;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _reloadHtml() async {
    _controller.loadContent(await makeHtml(_data.descCallback()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(_data.name)),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(8),
          child: WebViewProxyWidget(
            controller: _controller,
            delegate: this,
          ),
        )));
  }

  @override
  void onWebViewProxyInited() {
    _reloadHtml();
  }

  // @override
  // Future<WebResourceResponse?> onWebViewProxyInterceptUrl(String url) async {
  //   return null;
  // }

  @override
  bool onWebViewProxyNavigate(String url) {
    String pre = 'jgw://liushu/';
    if (url.startsWith(pre)) {
      int? newIndex = int.tryParse(url.substring(pre.length));
      setState(() {
        _index = newIndex!;
        _reloadHtml();
      });

      return false;
    }

    return true;
  }

  @override
  void onWebViewProxySearch(String selectedString) {}
}
