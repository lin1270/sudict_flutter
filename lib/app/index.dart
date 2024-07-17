import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:sudict/app/common_localizations_delegate.dart';
import 'package:sudict/app/loading.dart';
import 'package:sudict/app/theme_manager.dart';
import 'package:sudict/config/path.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/history/history_mgr.dart';
import 'package:sudict/modules/setting/index.dart';
import 'package:sudict/modules/share/index.dart';
import 'package:sudict/modules/utils/assets.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/pages/home/index.dart';
import 'package:sudict/pages/jgw/mgr.dart';
import 'package:sudict/pages/router.dart';

class SudictApp extends StatefulWidget {
  const SudictApp({super.key});
  @override
  State<SudictApp> createState() => _SudictAppState();
}

class _SudictAppState extends State<SudictApp> {
  var loading = true;

  @override
  void initState() {
    super.initState();
    initModules();
  }

  initModules() async {
    await DictMgr.instance.init();
    await AssetsUtils.copyAssets2local(
        'assets/fonts/dict.ttf', '${PathConfig.resultBase}/dict.ttf');
    await Setting.instance.init();
    await HistoryMgr.instance.init();
    await ShareMgr.instance.init();
    await JgwMgr.instance.init();
    MyDialog.navigatorKey = NavigatorUtils.key;

    loading = false;
    setState(() {});
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '素典',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorUtils.key,
      onGenerateRoute: (settings) {
        //String? 表示name为可空类型
        final String? name = settings.name;
        //Function? 表示pageContentBuilder为可空类型
        final Function? pageContentBuilder = AppRouter.routes[name];
        if (pageContentBuilder != null) {
          if (settings.arguments != null) {
            final Route route = MaterialPageRoute(
                builder: (context) => pageContentBuilder(context, arguments: settings.arguments));
            return route;
          } else {
            final Route route =
                MaterialPageRoute(builder: (context) => pageContentBuilder(context));
            return route;
          }
        }
        return null;
      },
      // 设置本地化代理
      localizationsDelegates: const [
        ShirneDialogLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        CommonLocalizationsDelegate(),
      ],
      // 设置默认语言为中文
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'), // 设置默认显示语言为中文
      theme: ThemeManager.getTheme(),
      home: loading ? const LoadingPage() : const HomePage(),
    );
  }
}
