import 'package:flutter/material.dart';
import 'package:sudict/modules/utils/version.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = "";

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _version = await VersionUtils.appVersion;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('小記')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("版本：$_version"),
              const SizedBox(height: 16),
              const Text("開源地址：https://gitee.com/lin1270/sudict_flutter"),
              const Text("聯繫郵箱：414078791@qq.com")
            ],
          ),
        ));
  }
}
