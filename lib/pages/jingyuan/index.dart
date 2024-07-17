import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:sudict/modules/audio/common.dart';
import 'package:sudict/modules/event_bus/events.dart';
import 'package:sudict/modules/event_bus/index.dart';
import 'package:sudict/modules/ui_comps/fish_audio_play_widget/controller.dart';
import 'package:sudict/modules/ui_comps/fish_audio_play_widget/index.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/jingyuan/xiguicidi_audio_mgr.dart';
import 'package:sudict/pages/router.dart';

class JingYuanPage extends StatefulWidget {
  const JingYuanPage({super.key});
  @override
  State<JingYuanPage> createState() => _JingYuanPageState();
}

class _JingYuanPageState extends State<JingYuanPage> with SingleTickerProviderStateMixin {
  var _authed = false;
  final _codeTextFieldController = TextEditingController();
  static const _code = 'JingYuan';

  final _audioPlayController = FishAudioPlayWidgetController();
  CatalogItem? _catalogItem;

  @override
  void dispose() {
    _codeTextFieldController.dispose();
    FishEventBus.offEvent<UpdateAudioCatalog>(_onUpdateAudioCatalog);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _onUpdateAudioCatalog(UpdateAudioCatalog event) {
    if (event.catalog == AudioVideoPlayCatalog.xiguicidi) {
      _loadCurrentPlayItem(play: event.play);
      setState(() {});
    }
  }

  _init() async {
    _authed = await LocalStorageUtils.getBool(LocalStorageKeys.jingyuanAuth) ?? false;
    _loadAudioData();

    FishEventBus.onEvent<UpdateAudioCatalog>(_onUpdateAudioCatalog);
    setState(() {});
  }

  _loadAudioData() async {
    if (_authed) {
      await XiguicidiAudioMgr.instance.init();

      _loadCurrentPlayItem();
    }
  }

  Widget _unauthWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('此處恭錄了佛教淨土宗相關音頻，若要訪問，請輸入確認碼「$_code」。'),
          const SizedBox(
            height: 16,
          ),
          MaterialTextField(
            hint: '請輸入確認碼',
            labelText: '確認碼',
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.mood),
            controller: _codeTextFieldController,
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
          ),
          const SizedBox(
            height: 26,
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (_codeTextFieldController.text != _code) {
                UiUtils.toast(content: '確認碼不正確');
                return;
              }

              _authed = true;
              _loadAudioData();

              LocalStorageUtils.setBool(LocalStorageKeys.jingyuanAuth, _authed);
            },
            label: const Text('進入'),
            icon: const Icon(Icons.check),
          )
        ],
      ),
    );
  }

  Widget _playWidget() {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(children: [
          Text(
            _catalogItem == null ? '' : _catalogItem!.name,
            style: const TextStyle(color: Colors.black26),
          ),
          Expanded(
              child: FishAudioPlayWidget(
            catalog: AudioVideoPlayCatalog.xiguicidi,
            controller: _audioPlayController,
            onPre: (isRandom) {
              _go(-1, isRandom);
            },
            onNext: (isRandom) {
              _go(1, isRandom);
            },
          ))
        ]));
  }

  _go(int step, bool isRandom) {
    if (isRandom) {
      _catalogItem?.random();
    } else {
      _catalogItem?.next(step);
    }

    _loadCurrentPlayItem(play: true);
  }

  _loadCurrentPlayItem({play = false}) async {
    _catalogItem = await XiguicidiAudioMgr.instance.currCatalog;
    final item = _catalogItem?.currItem;
    if (item == null) return;
    _audioPlayController.load(item.url, item.name, item.length, play);
    setState(() {});
  }

  _handlePop() {
    UiUtils.showConfirmDialog(context: context, content: '確定要退出嗎？').then((v) {
      if (v) {
        NavigatorUtils.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('淨緣'),
          actions: [
            IconButton(
                onPressed: () {
                  UiUtils.showAlertDialog(
                      context: context,
                      content:
                          '此處音頻數據來自《西歸次第》，感恩。\n\n更多資源請訪問：\n1. 慈光app \n2. www.amtb.tw\n3. 華藏數位法寶app\n4. 法水長流app');
                },
                icon: const Icon(Icons.info_outline)),
            IconButton(
                onPressed: () {
                  NavigatorUtils.go(context, AppRouteName.jingyuanXiguicidiCatalog, null);
                },
                icon: const Icon(Icons.category_outlined)),
            IconButton(
                onPressed: () {
                  NavigatorUtils.go(context, AppRouteName.jingyuanXiguicidiPlayList, null);
                },
                icon: const Icon(Icons.search)),
          ],
        ),
        body: _authed
            ? PopScope(
                canPop: false,
                onPopInvoked: (didPop) {
                  if (didPop) return;
                  _handlePop();
                },
                child: SafeArea(child: _playWidget()))
            : _unauthWidget());
  }
}
