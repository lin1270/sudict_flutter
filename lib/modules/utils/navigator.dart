import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigatorUtils {
  NavigatorUtils._();

  static final _key = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get key => _key;
  // ignore: slash_for_doc_comments
  /**
   * if error, try below:
   
   Future.delayed(Duration(seconds:0)).then((onValue)  {
   });

   */
  static BuildContext? get currContext => key.currentContext;

  static go(context, String path, param) async {
    return Navigator.of(context).pushNamed(path, arguments: param);
  }

  static pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  static quitApp() {
    SystemNavigator.pop();
  }

  static goBrowserUrl(String url) {
    if (url.isEmpty) return;
    if (!url.startsWith(RegExp(r'[a-zA-Z0-9]+://'))) {
      UiUtils.toast(content: '打開$url失敗');
      return;
    }
    launchUrl(Uri.parse(url));
  }
}
