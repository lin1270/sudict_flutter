import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/webview/controller.dart';
import 'package:sudict/modules/ui_comps/webview/delegate.dart';
import 'package:sudict/modules/ui_comps/webview/webview_universal.dart';
import 'package:sudict/modules/ui_comps/webview/webview_windows.dart';

// ignore: must_be_immutable
class WebViewProxyWidget extends StatefulWidget {
  WebViewProxyWidget({
    super.key,
    this.controller,
    this.delegate,
    this.showSearchMenu = false,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  WebViewProxyController? controller;
  WebViewProxyDelegate? delegate;
  bool showSearchMenu;
  Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  State<WebViewProxyWidget> createState() => _WebViewProxyWidgetState();
}

class _WebViewProxyWidgetState extends State<WebViewProxyWidget> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isMacOS) {
      return WebViewProxyForWindows(
          controller: widget.controller,
          delegate: widget.delegate,
          showSearchMenu: widget.showSearchMenu);
    }

    return WebViewProxyUniversal(
        controller: widget.controller,
        delegate: widget.delegate,
        gestureRecognizers: widget.gestureRecognizers,
        showSearchMenu: widget.showSearchMenu);
  }
}
