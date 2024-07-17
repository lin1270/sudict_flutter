import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/webview/controller.dart';
import 'package:sudict/modules/ui_comps/webview/delegate.dart';
import 'package:sudict/modules/ui_comps/webview/index.dart';
import 'package:sudict/modules/setting/index.dart';
import 'package:sudict/pages/jgw/html_maker.dart';
import 'package:sudict/pages/jgw/mgr.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';

class JgwSettingPage extends StatefulWidget {
  const JgwSettingPage({super.key});

  @override
  State<JgwSettingPage> createState() => _JgwSettingPageState();
}

class _JgwSettingPageState extends State<JgwSettingPage> implements WebViewProxyDelegate {
  final WebViewProxyController _controller = WebViewProxyController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _reloadContent() async {
    // 引用一個字釋義
    dynamic word = JgwMgr.instance.getWordInfoByPosInfo(JgwPosInfo(0, 0, 0));
    dynamic content = word['content'];
    _controller.loadContent(await makeHtml(content));
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        appBar: AppBar(title: const Text('甲骨文字號設定')),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            SfSliderTheme(
                data: const SfSliderThemeData(
                  inactiveTickColor: Colors.black38,
                  inactiveMinorTickColor: Colors.black38,
                  activeTickColor: Colors.black38,
                  activeMinorTickColor: Colors.black38,
                ),
                child: SfSlider(
                    min: 1.0,
                    max: 2.0,
                    interval: 0.5,
                    showTicks: true,
                    showLabels: true,
                    enableTooltip: false,
                    minorTicksPerInterval: 1,
                    inactiveColor: Colors.black12,
                    value: Setting.instance.jgwFontScale,
                    onChanged: (v) {
                      setState(() {
                        Setting.instance.jgwFontScale = v;
                        _reloadContent();
                      });
                    })),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: WebViewProxyWidget(
              controller: _controller,
              delegate: this,
            ))
          ]),
        ));
  }

  @override
  void onWebViewProxyInited() {
    _reloadContent();
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
