import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/webview/controller.dart';
import 'package:sudict/modules/ui_comps/webview/delegate.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class WebViewProxyUniversal extends StatefulWidget {
  WebViewProxyUniversal({
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
  State<WebViewProxyUniversal> createState() => _WebViewProxyUniversalWidgetState();
}

class _WebViewProxyUniversalWidgetState extends State<WebViewProxyUniversal> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (widget.delegate == null) return NavigationDecision.navigate;
            return widget.delegate!.onWebViewProxyNavigate(request.url)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      );

    _loadCurrentContent();
    widget.controller?.addListener(() {
      _loadCurrentContent();
    });
    widget.delegate?.onWebViewProxyInited();
  }

  _loadCurrentContent() {
    if (widget.controller!.content.isNotEmpty) {
      if (widget.controller!.isUrl) {
        if (widget.controller!.content.startsWith('/')) {
          _webViewController.loadFile(widget.controller!.content);
        } else {
          _webViewController.loadRequest(Uri.parse(widget.controller!.content));
        }
      } else {
        _webViewController.loadHtmlString(widget.controller!.content,
            baseUrl: widget.controller!.baseUrlForHtmlString);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: _webViewController,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }
}
