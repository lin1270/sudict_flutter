import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:sudict/modules/ui_comps/webview/controller.dart';
import 'package:sudict/modules/ui_comps/webview/delegate.dart';
import 'package:sudict/modules/ui_comps/webview/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/pages/go_url/go_url_page_param.dart';

class GoUrlPage extends StatefulWidget {
  const GoUrlPage({super.key, required this.arguments});

  final Object arguments;

  @override
  State<GoUrlPage> createState() => _GoUrlPageState();
}

class _GoUrlPageState extends State<GoUrlPage> implements WebViewProxyDelegate {
  final WebViewProxyController _controller = WebViewProxyController();
  late GoUrlPageParam _param;

  @override
  void initState() {
    super.initState();
    _param = widget.arguments as GoUrlPageParam;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        backgroundColor: _param.backgroundColor,
        appBar: _param.title.isNotEmpty ? AppBar(title: Text(_param.title)) : null,
        floatingActionButton: (_param.title.isEmpty && _param.showBackButtonIfNoTitle)
            ? IconButton(
                onPressed: () {
                  NavigatorUtils.pop(context);
                },
                icon: const Icon(Icons.arrow_back))
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
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
    _controller.loadContent(_param.url);
  }

  // @override
  // Future<WebResourceResponse?> onWebViewProxyInterceptUrl(String url) async {
  //   return null;
  // }

  @override
  bool onWebViewProxyNavigate(String url) {
    return true;
  }

  @override
  void onWebViewProxySearch(String selectedString) {}
}
