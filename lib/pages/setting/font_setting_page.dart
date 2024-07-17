import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/webview/controller.dart';
import 'package:sudict/modules/ui_comps/webview/delegate.dart';
import 'package:sudict/modules/ui_comps/webview/index.dart';
import 'package:sudict/modules/dict/dict_result_formator.dart';
import 'package:sudict/modules/setting/index.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';

class FontSettingPage extends StatefulWidget {
  const FontSettingPage({super.key});

  @override
  State<FontSettingPage> createState() => _FontSettingPageState();
}

class _FontSettingPageState extends State<FontSettingPage> implements WebViewProxyDelegate {
  final WebViewProxyController _controller = WebViewProxyController();
  var _hasChanged = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _reloadContent() {
    _controller.loadContent(DictResultFormator.formatString("<h1>H1大小</h1><h2>H2大小</h2>正常大小<br>"),
        isUrl: false);
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        appBar: AppBar(title: const Text('字號設定')),
        body: PopScope(
            onPopInvoked: (didPop) {
              if (didPop && _hasChanged) {}
            },
            child: Padding(
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
                        max: 5.0,
                        interval: 0.5,
                        showTicks: true,
                        showLabels: true,
                        enableTooltip: false,
                        minorTicksPerInterval: 1,
                        inactiveColor: Colors.black12,
                        value: Setting.instance.fontScale,
                        onChanged: (v) {
                          _hasChanged = true;
                          setState(() {
                            Setting.instance.fontScale = v;
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
            )));
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
