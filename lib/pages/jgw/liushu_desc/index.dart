import 'package:sudict/pages/jgw/liushu_desc/desc_0.dart';
import 'package:sudict/pages/jgw/liushu_desc/desc_huiyi.dart';
import 'package:sudict/pages/jgw/liushu_desc/desc_jiajie.dart';
import 'package:sudict/pages/jgw/liushu_desc/desc_xiangxing.dart';
import 'package:sudict/pages/jgw/liushu_desc/desc_xingsheng.dart';
import 'package:sudict/pages/jgw/liushu_desc/desc_zhishi.dart';
import 'package:sudict/pages/jgw/liushu_desc/desc_zhuanzhu.dart';

class LiuShuDesc {
  LiuShuDesc(this.name, this.descCallback);
  String name;
  Function() descCallback;
}

final liushuData = <LiuShuDesc>[
  LiuShuDesc('古文字引言', liushu_0),
  LiuShuDesc('象形', liushu_xiangxing),
  LiuShuDesc('指事', liushu_zhishi),
  LiuShuDesc('會意', liushu_huiyi),
  LiuShuDesc('形聲', liushu_xingsheng),
  LiuShuDesc('轉注', liushu_zhuanzhu),
  LiuShuDesc('假借', liushu_jiajie),
];
