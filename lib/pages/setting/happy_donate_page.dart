import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:sudict/modules/http/index.dart';
import 'package:sudict/modules/tab/tab_param.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/string.dart';
import 'package:sudict/modules/utils/ui.dart';

class HappyDonatePage extends StatefulWidget {
  const HappyDonatePage({super.key});
  @override
  State<HappyDonatePage> createState() => _HappyDonatePageState();
}

class _HappyDonatePageState extends State<HappyDonatePage> with SingleTickerProviderStateMixin {
  List<TabParam>? _tabsData;
  TabController? _tabController;
  final _weixinUrl = 'http://maiyuren.com/dict/assets/img/wx.32e7248.png';
  final _zhifubaoUrl = 'http://maiyuren.com/dict/assets/img/zfb.dcab600.png';

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _saveImg(String url) async {
    final imgData = await HttpUtils.request(url: url, parseJson: false);
    final saveResult = await ImageGallerySaver.saveImage(imgData, quality: 100);
    if (saveResult != null && saveResult['isSuccess'] == true) {
      UiUtils.toast(content: '保存成功');
    } else {
      UiUtils.toast(content: '保存失敗');
    }
  }

  Widget _weixinWidget() {
    return Column(
      children: [
        Image.network(_weixinUrl),
        const SizedBox(
          height: 4,
        ),
        const Text('姓名：林庆昌'),
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
            onPressed: () {
              _saveImg(_weixinUrl);
            },
            child: const Text('保存到相冊')),
        const Text('保存到相冊後，再用微信掃描'),
      ],
    );
  }

  Widget _zhifubaoWidget() {
    return Column(
      children: [
        Image.network(_zhifubaoUrl),
        const SizedBox(
          height: 4,
        ),
        const Text('姓名：林庆昌'),
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
            onPressed: () {
              _saveImg(_zhifubaoUrl);
            },
            child: const Text('保存到相冊')),
        const Text('保存到相冊後，再用支付寶掃描'),
      ],
    );
  }

  Widget _yinlianWidget() {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(
            children: [
              const Text('賬號：6214850202162084'),
              IconButton(
                  onPressed: () {
                    StringUtils.copyToClipboard('6214850202162084');
                  },
                  icon: const Icon(Icons.copy_outlined))
            ],
          ),
          Row(
            children: [
              const Text('銀行：招商银行'),
              IconButton(
                  onPressed: () {
                    StringUtils.copyToClipboard('招商银行');
                  },
                  icon: const Icon(Icons.copy_outlined))
            ],
          ),
          Row(
            children: [
              const Text('姓名：林庆昌'),
              IconButton(
                  onPressed: () {
                    StringUtils.copyToClipboard('林庆昌');
                  },
                  icon: const Icon(Icons.copy_outlined))
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          const Text('如需匯款到公司賬戶，并開發票，請單獨聯繫我：414078791@qq.com'),
          ElevatedButton(
              onPressed: () {
                StringUtils.copyToClipboard('414078791@qq.com');
              },
              child: const Text('拷貝郵箱'))
        ]));
  }

  _init() async {
    _tabsData = [
      TabParam(
        title: '微信',
        widget: _weixinWidget(),
      ),
      TabParam(
        title: '支付寶',
        widget: _zhifubaoWidget(),
      ),
      TabParam(
        title: '銀聯卡',
        widget: _yinlianWidget(),
      ),
    ];

    var lastTabIndex =
        await LocalStorageUtils.getInt(LocalStorageKeys.settingHappyDonateTabIndex) ?? 0;

    _tabController =
        TabController(initialIndex: lastTabIndex, length: _tabsData!.length, vsync: this);
    _tabController!.addListener(() {
      LocalStorageUtils.setInt(LocalStorageKeys.settingHappyDonateTabIndex, _tabController!.index);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: SafeArea(
              child: _tabsData == null || _tabController == null
                  ? Container()
                  : TabBar(
                      isScrollable: true,
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      tabs: _tabsData!.map((e) {
                        return Tab(text: e.title);
                      }).toList())),
          actions: [
            IconButton(
                onPressed: () {
                  UiUtils.showAlertDialog(
                      context: context,
                      content:
                          '素典目前是利用空閒時間開發。小子希望有一天能全職開發。您的捐助或有可能幫助我儘早實現這個願望。\n\n小子有幸在工作生活中遇到諸多業界精英，取其所長，故於APP便利性設計有所瞭解，亦能稍通C/C++、Java、Js、Dart、Object-C等諸多編程語言及其相關框架，故能開發諸多平臺的軟件。\n\n而小子又遇殊勝因緣，得聞傳統文化與圣賢教育，願竭微弱之力，不愧此身，漸完軟件，以助諸君。');
                },
                icon: const Icon(Icons.info_outline))
          ],
        ),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: _tabsData == null || _tabController == null
                  ? Container()
                  : TabBarView(
                      controller: _tabController,
                      children: _tabsData!.map((e) => e.widget).toList(),
                    )),
        ])));
  }
}
