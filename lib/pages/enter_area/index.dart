import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:sudict/modules/http/misc.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/string.dart';
import 'package:sudict/modules/utils/ui.dart';

class EnterAreaPage extends StatefulWidget {
  const EnterAreaPage({super.key});
  @override
  State<EnterAreaPage> createState() => _EnterAreaPageState();
}

class _Item {
  _Item(
      {required this.name,
      required this.logo,
      required this.author,
      required this.isVideo,
      required this.url,
      required this.desc});

  static _Item fromJson(dynamic json) {
    return _Item(
        name: json['name'],
        logo: json['logo'],
        author: json['author'],
        isVideo: json['isVideo'] ?? false,
        url: json['url'] ?? '',
        desc: json['desc']);
  }

  String name;
  String logo;
  String author;
  String url;
  bool isVideo;
  String desc;
}

class _EnterAreaPageState extends State<EnterAreaPage> with SingleTickerProviderStateMixin {
  // ignore: non_constant_identifier_names
  static dynamic _s_data;
  final _data = <_Item>[];

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _reload();
  }

  _reload() async {
    _s_data ??= await MiscHttpApi.getEnterAreaInfo();

    _data.clear();
    if (_s_data != null) {
      final dislikes = await LocalStorageUtils.getJson(LocalStorageKeys.enterAreaDislikeList);
      for (dynamic json in _s_data) {
        final item = _Item.fromJson(json);
        bool found = false;
        if (dislikes != null && dislikes.length > 0) {
          for (String nameAuthor in dislikes) {
            if ('${item.name}_${item.author}' == nameAuthor) {
              found = true;
              break;
            }
          }
        }

        if (!found) _data.add(item);
      }
      // 亂序
      _data.shuffle();
    }
    setState(() {});
  }

  _restore() async {
    bool ok = await UiUtils.showConfirmDialog(context: context, content: '確定要原始配置嗎?');
    if (ok) {
      await LocalStorageUtils.setJson(LocalStorageKeys.enterAreaDislikeList, []);
      _reload();
    }
  }

  _logoWidget(_Item item) {
    if (item.logo.isEmpty) {
      return Container(
        width: 200,
        height: 300,
        decoration: const BoxDecoration(color: Color.fromARGB(255, 0xa0, 0x74, 0x24)),
        alignment: Alignment.topRight,
        padding: const EdgeInsets.only(top: 20, right: 20),
        child: Column(
          children: item.name.characters.map((e) {
            return ClipRect(
                child: SizedBox(
                    height: 34,
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 28,
                      ),
                    )));
          }).toList(),
        ),
      );
    }

    return Image.network(
      item.logo,
      fit: BoxFit.fill,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0x1e, 0x1e, 0x1e),
        body: SafeArea(
            child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            final item = _data[index];
            return Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 0x33, 0x33, 0x33),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Opacity(
                    opacity: 0.8,
                    child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        NavigatorUtils.pop(context);
                                      },
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.black54,
                                      )),
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            if (item.isVideo) {
                                              NavigatorUtils.goBrowserUrl(item.url);
                                            } else {
                                              StringUtils.copyToClipboard(
                                                  '${item.name} ${item.author}');
                                            }
                                          },
                                          icon: Icon(
                                            item.isVideo
                                                ? Icons.play_arrow_outlined
                                                : Icons.copy_outlined,
                                            color: Colors.black54,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            _restore();
                                          },
                                          icon: const Icon(
                                            Icons.restore_outlined,
                                            color: Colors.black54,
                                          )),
                                      IconButton(
                                          onPressed: () async {
                                            if (_data.length <= 3) {
                                              UiUtils.toast(content: '不允許移除了');
                                              return;
                                            }
                                            final temp = await LocalStorageUtils.getJson(
                                                    LocalStorageKeys.enterAreaDislikeList) ??
                                                [];
                                            temp.add('${item.name}_${item.author}');
                                            await LocalStorageUtils.setJson(
                                                LocalStorageKeys.enterAreaDislikeList, temp);
                                            _reload();
                                          },
                                          icon: const Icon(
                                            Icons.playlist_remove_outlined,
                                            color: Colors.black54,
                                          ))
                                    ],
                                  )
                                ],
                              ),
                              _logoWidget(item),
                              Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [Text('${item.author} 著')],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                                child: Text(
                                  item.desc,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              )
                            ],
                          ),
                        ))));
          },
          itemCount: _data.length,
          itemWidth: size.width * 0.9,
          itemHeight: size.height * 0.9,
          layout: SwiperLayout.STACK,
        )));
  }
}
