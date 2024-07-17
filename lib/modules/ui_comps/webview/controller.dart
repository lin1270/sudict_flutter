import 'package:flutter/material.dart';

class WebViewProxyController extends ChangeNotifier {
  String content = "";
  String? baseUrlForHtmlString;
  bool isUrl = false;

  loadContent(String content, {bool isUrl = true, String? baseUrlForHtmlString}) {
    this.content = content;
    this.isUrl = isUrl;
    this.baseUrlForHtmlString = baseUrlForHtmlString;
    notifyListeners();
  }
}
