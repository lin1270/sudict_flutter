import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/pages/go_url/go_url_page_param.dart';
import 'package:sudict/pages/jgw/html_maker.dart';
import 'package:sudict/pages/jgw/mgr.dart';
import 'package:sudict/pages/router.dart';

class JgwSearchPage extends StatefulWidget {
  const JgwSearchPage({super.key});
  @override
  State<JgwSearchPage> createState() => _JgwSearchPageState();
}

class _JgwSearchPageState extends State<JgwSearchPage> {
  dynamic _foundInfo;
  var _showSearchResult = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('搜尋')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              MaterialTextField(
                hint: '請輸入漢字搜尋',
                labelText: '搜尋',
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.mood),
                theme: FilledOrOutlinedTextTheme(
                    radius: 8,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    errorStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    fillColor: Colors.transparent,
                    prefixIconColor: Colors.black45,
                    enabledColor: Colors.grey,
                    focusedColor: Colors.black54,
                    floatingLabelStyle: const TextStyle(color: Colors.black),
                    width: 1.5,
                    labelStyle: const TextStyle(fontSize: 16, color: Colors.black38)),
                onChanged: (v) {
                  v = v.trim();
                  if (v.isEmpty) {
                    _foundInfo = null;
                    _showSearchResult = false;
                  } else {
                    _showSearchResult = true;
                    _foundInfo = JgwMgr.instance.find(v);
                  }

                  setState(() {});
                },
              ),
              const SizedBox(
                height: 16,
              ),
              _foundInfo == null
                  ? Text(_showSearchResult ? '未搜尋到結果' : '')
                  : FishInkwell(
                      onTap: () async {
                        final url = await makeHtml(_foundInfo['content']);
                        _goResult(url);
                      },
                      child: Text(
                        _foundInfo['jgw'],
                        style: const TextStyle(fontFamily: 'jgwiconfont', fontSize: 96),
                      ))
            ],
          ),
        ));
  }

  void _goResult(url) {
    NavigatorUtils.go(context, AppRouteName.goUrl, GoUrlPageParam('結果查看', url));
  }
}
