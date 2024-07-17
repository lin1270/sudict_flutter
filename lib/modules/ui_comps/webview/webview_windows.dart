import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/webview/controller.dart';
import 'package:sudict/modules/ui_comps/webview/delegate.dart';
import 'package:webview_win_floating/webview.dart';

// ignore: must_be_immutable
class WebViewProxyForWindows extends StatefulWidget {
  WebViewProxyForWindows({super.key, this.controller, this.delegate, this.showSearchMenu = false});

  WebViewProxyController? controller;
  WebViewProxyDelegate? delegate;
  bool showSearchMenu;

  @override
  State<WebViewProxyForWindows> createState() => _WebViewProxyForWindowsState();
}

class _WebViewProxyForWindowsState extends State<WebViewProxyForWindows> {
  final _controller = WinWebViewController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    widget.controller?.addListener(() {
      String content = widget.controller!.content;
      if (widget.controller!.isUrl) {
        if (content.startsWith('https://') || content.startsWith('http://')) {
          _controller.loadRequest(Uri.parse(content));
        } else {
          _controller.loadRequest(Uri.parse(content));
        }
      } else {
        _controller.loadHtmlString(content);
      }
    });

    widget.delegate?.onWebViewProxyInited();
  }

  @override
  Widget build(BuildContext context) {
    return WinWebViewWidget(controller: _controller);
  }
}
