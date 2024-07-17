import 'package:flutter/material.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/pages/router.dart';
import 'package:sudict/pages/thought_record/mgr.dart';
import 'package:sudict/pages/thought_record/record_widget.dart';

class ThoughtRecordPage extends StatefulWidget {
  const ThoughtRecordPage({super.key});
  @override
  State<ThoughtRecordPage> createState() => _ThoughtRecordPageState();
}

class _ThoughtRecordPageState extends State<ThoughtRecordPage> {
  var _isInited = false;
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await ThoughtRecordMgr.instance.load();
    _isInited = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('心念集'),
        actions: [
          IconButton(
              onPressed: () {
                NavigatorUtils.go(context, AppRouteName.thoughtRecordChart, null);
              },
              icon: const Icon(Icons.area_chart_outlined))
        ],
      ),
      body: _isInited
          ? const Row(
              children: [
                Expanded(
                    child: RecordWidget(
                  isGood: true,
                )),
                Expanded(
                    child: RecordWidget(
                  isGood: false,
                ))
              ],
            )
          : Container(),
    );
  }
}
