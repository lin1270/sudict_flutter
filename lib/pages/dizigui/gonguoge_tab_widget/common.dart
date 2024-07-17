import 'package:flutter/material.dart';
import 'package:sudict/modules/ggg/common.dart';

class DzgGggDescItem {
  DzgGggDescItem(this.content, [this.special, this.isGroup]);
  final String content;
  final bool? special;
  final bool? isGroup;
}

final dzgGggDescItems = <DzgGggDescItem>[
  DzgGggDescItem('入則孝', false, true),
  DzgGggDescItem('父母呼 應勿緩'),
  DzgGggDescItem('父母命 行勿懶', true),
  DzgGggDescItem('父母教 須敬聽', true),
  DzgGggDescItem('父母責 須順承', true),
  DzgGggDescItem('冬則溫 夏則凊'),
  DzgGggDescItem('晨則省 昏則定'),
  DzgGggDescItem('出必告 反必面'),
  DzgGggDescItem('居有常 業無變'),
  DzgGggDescItem('事雖小 勿擅爲\n苟擅爲 子道虧'),
  DzgGggDescItem('物雖小 勿私藏\n苟私藏 親心傷'),
  DzgGggDescItem('親所好 力爲具', true),
  DzgGggDescItem('親所惡 謹爲去', true),
  DzgGggDescItem('身有傷 貽親憂', true),
  DzgGggDescItem('德有傷 貽親羞', true),
  DzgGggDescItem('親愛我 孝何難', true),
  DzgGggDescItem('親憎我 孝方賢', true),
  DzgGggDescItem('親有過 諫使更\n怡吾色 柔吾聲', true),
  DzgGggDescItem('諫不入 悅復諫\n號泣隨 撻無怨', true),
  DzgGggDescItem('親有疾 藥先嘗'),
  DzgGggDescItem('晝夜侍 不離床'),
  DzgGggDescItem('喪三年 常悲咽'),
  DzgGggDescItem('居處變 酒肉絕'),
  DzgGggDescItem('喪盡禮 祭盡誠', true),
  DzgGggDescItem('事死者 如事生', true),
  // --
  DzgGggDescItem('出則弟', false, true),
  DzgGggDescItem('兄道友 弟道恭\n兄弟睦 孝在中', true),
  DzgGggDescItem('財物輕 怨何生', true),
  DzgGggDescItem('言語忍 忿自泯', true),
  DzgGggDescItem('或飲食 或坐走\n長者先 幼者後'),
  DzgGggDescItem('長呼人 即代叫'),
  DzgGggDescItem('人不在 己即到'),
  DzgGggDescItem('稱尊長 勿呼名', true),
  DzgGggDescItem('對尊長 勿見能', true),
  DzgGggDescItem('路遇長 疾趨揖'),
  DzgGggDescItem('長無言 退恭立'),
  DzgGggDescItem('騎下馬 乘下車'),
  DzgGggDescItem('過猶待 百步餘'),
  DzgGggDescItem('長者立 幼勿坐'),
  DzgGggDescItem('長者坐 命乃坐'),
  DzgGggDescItem('尊長前 聲要低\n低不聞 卻非宜', true),
  DzgGggDescItem('進必趨 退必遲', true),
  DzgGggDescItem('問起對 視勿移'),
  DzgGggDescItem('事諸父 如事父', true),
  DzgGggDescItem('事諸兄 如事兄', true),
  // - -
  DzgGggDescItem('謹', false, true),
  DzgGggDescItem('朝起早 夜眠遲', true),
  DzgGggDescItem('老易至 惜此時', true),
  DzgGggDescItem('晨必盥 兼漱口'),
  DzgGggDescItem('便溺回 輒淨手'),
  DzgGggDescItem('冠必正 紐必結'),
  DzgGggDescItem('襪與履 俱緊切'),
  DzgGggDescItem('置冠服 有定位\n勿亂頓 致污穢'),
  DzgGggDescItem('衣貴潔 不貴華', true),
  DzgGggDescItem('上循分 下稱家', true),
  DzgGggDescItem('對飲食 勿揀擇'),
  DzgGggDescItem('食適可 勿過則'),
  DzgGggDescItem('年方少 勿飲酒\n飲酒醉 最爲醜'),
  DzgGggDescItem('步從容 立端正', true),
  DzgGggDescItem('揖深圓 拜恭敬', true),
  DzgGggDescItem('勿踐閾 勿跛倚'),
  DzgGggDescItem('勿箕踞 勿搖髀'),
  DzgGggDescItem('緩揭簾 勿有聲', true),
  DzgGggDescItem('寬轉彎 勿觸棱', true),
  DzgGggDescItem('執虛器 如執盈', true),
  DzgGggDescItem('入虛室 如有人', true),
  DzgGggDescItem('事勿忙 忙多錯', true),
  DzgGggDescItem('勿畏難 勿輕略', true),
  DzgGggDescItem('鬥鬧場 絕勿近', true),
  DzgGggDescItem('邪僻事 絕勿問', true),
  DzgGggDescItem('將入門 問孰存'),
  DzgGggDescItem('將上堂 聲必揚'),
  DzgGggDescItem('人問誰 對以名\n吾與我 不分明'),
  DzgGggDescItem('用人物 須明求'),
  DzgGggDescItem('倘不問 即爲偷'),
  DzgGggDescItem('借人物 及時還\n後有急 借不難'),
  // --
  DzgGggDescItem('信', false, true),
  DzgGggDescItem('凡出言 信爲先\n詐與妄 奚可焉', true),
  DzgGggDescItem('話說多 不如少\n惟其是 勿佞巧', true),
  DzgGggDescItem('奸巧語 穢污詞\n市井氣 切戒之', true),
  DzgGggDescItem('見未真 勿輕言'),
  DzgGggDescItem('知未的 勿輕傳'),
  DzgGggDescItem('事非宜 勿輕諾\n苟輕諾 進退錯'),
  DzgGggDescItem('凡道字 重且舒\n勿急疾 勿模糊'),
  DzgGggDescItem('彼說長 此說短\n不關己 莫閒管'),
  DzgGggDescItem('見人善 即思齊\n縱去遠 以漸躋', true),
  DzgGggDescItem('見人惡 即內省\n有則改 無加警', true),
  DzgGggDescItem('唯德學 唯才藝\n不如人 當自礪', true),
  DzgGggDescItem('若衣服 若飲食\n不如人 勿生慼'),
  DzgGggDescItem('聞過怒 聞譽樂\n損友來 益友卻', true),
  DzgGggDescItem('聞譽恐 聞過欣\n直諒士 漸相親', true),
  DzgGggDescItem('無心非 名爲錯\n有心非 名爲惡', true),
  DzgGggDescItem('過能改 歸於無\n倘掩飾 增一辜', true),
  // --
  DzgGggDescItem('汎愛衆', false, true),
  DzgGggDescItem('凡是人 皆須愛\n天同覆 地同載', true),
  DzgGggDescItem('行高者 名自高\n人所重 非貌高'),
  DzgGggDescItem('才大者 望自大\n人所服 非言大'),
  DzgGggDescItem('己有能 勿自私\n人所能 勿輕訾', true),
  DzgGggDescItem('勿諂富 勿驕貧', true),
  DzgGggDescItem('勿厭故 勿喜新', true),
  DzgGggDescItem('人不閒 勿事攪'),
  DzgGggDescItem('人不安 勿話擾'),
  DzgGggDescItem('人有短 切莫揭'),
  DzgGggDescItem('人有私 切莫說', true),
  DzgGggDescItem('道人善 即是善\n人知之 愈思勉', true),
  DzgGggDescItem('揚人惡 即是惡\n疾之甚 禍且作', true),
  DzgGggDescItem('善相勸 德皆建', true),
  DzgGggDescItem('過不規 道兩虧', true),
  DzgGggDescItem('凡取與 貴分曉\n與宜多 取宜少', true),
  DzgGggDescItem('將加人 先問己\n己不欲 即速已', true),
  DzgGggDescItem('恩欲報 怨欲忘\n報怨短 報恩長', true),
  DzgGggDescItem('待婢僕 身貴端\n雖貴端 慈而寬', true),
  DzgGggDescItem('勢服人 心不然\n理服人 方無言', true),
  // --
  DzgGggDescItem('親仁', false, true),
  DzgGggDescItem('同是人 類不齊\n流俗衆 仁者希', true),
  DzgGggDescItem('果仁者 人多畏\n言不諱 色不媚', true),
  DzgGggDescItem('能親仁 無限好\n德日進 過日少', true),
  DzgGggDescItem('不親仁 無限害\n小人進 百事壞', true),
  // --
  DzgGggDescItem('餘力學文', false, true),
  DzgGggDescItem('不力行 但學文\n長浮華 成何人'),
  DzgGggDescItem('但力行 不學文\n任己見 昧理真'),
  DzgGggDescItem('讀書法 有三到\n心眼口 信皆要', true),
  DzgGggDescItem('方讀此 勿慕彼\n此未終 彼勿起', true),
  DzgGggDescItem('寬爲限 緊用功\n工夫到 滯塞通', true),
  DzgGggDescItem('心有疑 隨札記\n就人問 求確義', true),
  DzgGggDescItem('房室清 牆壁淨\n几案潔 筆硯正'),
  DzgGggDescItem('墨磨偏 心不端\n字不敬 心先病'),
  DzgGggDescItem('列典籍 有定處'),
  DzgGggDescItem('讀看畢 還原處'),
  DzgGggDescItem('雖有急 卷束齊\n有缺壞 就補之'),
  DzgGggDescItem('非聖書 屏勿視\n蔽聰明 壞心志', true),
  // --
  DzgGggDescItem('結勸', false, true),
  DzgGggDescItem('勿自暴 勿自棄\n聖與賢 可馴致', true),
];

enum DzgGggType { day, month, year }

class DzgGggYear {
  DzgGggYear({required this.type, required this.date, required this.status, this.remark});
  static DzgGggYear fromJson(dynamic json) {
    final typeIndex = json['type'] ?? 0;
    final statusIndex = json['status'] ?? 0;
    final obj = DzgGggYear(
        type: DzgGggType.values[typeIndex],
        date: json['date'],
        status: GggStatus.values[statusIndex],
        remark: json['remark']);
    final records = json['records'];
    for (final monthJson in records) {
      final monthObj = DzgGggMonth.fromJson(monthJson, obj.date);
      obj.records.add(monthObj);
    }
    return obj;
  }

  dynamic toJson() {
    var recordsJson = <dynamic>[];
    for (var e in records) {
      recordsJson.add(e.toJson());
    }

    var obj = {
      "type": type.index,
      "date": date,
      "status": status.index,
      "remark": remark ?? '',
      "records": recordsJson
    };

    return obj;
  }

  int _okCount = -1;
  int _notOkCount = -1;
  int _middleCount = -1;

  void recalcCount() {
    _okCount = 0;
    _notOkCount = 0;
    _middleCount = 0;
    for (int i = 0; i < records.length; ++i) {
      final item = records[i];
      item.recalcCount();

      _middleCount += item.middleCount;
      _okCount += item.okCount;
      _notOkCount += item.notOkCount;
    }
  }

  int get okCount {
    if (_okCount == -1) recalcCount();
    return _okCount;
  }

  int get notOkCount {
    if (_notOkCount == -1) recalcCount();
    return _notOkCount;
  }

  int get middleCount {
    if (_middleCount == -1) recalcCount();
    return _middleCount;
  }

  DzgGggType type;
  int date;
  GggStatus status;
  String? remark;
  List<DzgGggMonth> records = [];
}

class DzgGggMonth {
  DzgGggMonth({required this.type, required this.date, required this.status, this.remark});
  static DzgGggMonth fromJson(dynamic json, int year) {
    final typeIndex = json['type'] ?? 0;
    final statusIndex = json['status'] ?? 0;
    final obj = DzgGggMonth(
        type: DzgGggType.values[typeIndex],
        date: json['date'],
        status: GggStatus.values[statusIndex],
        remark: json['remark']);
    obj.year = year;

    final records = json['records'];
    for (final dayJson in records) {
      final dayObj = DzgGggDay.fromJson(dayJson, obj.date, year);
      obj.records.add(dayObj);
    }
    return obj;
  }

  dynamic toJson() {
    var recordsJson = <dynamic>[];
    for (var e in records) {
      recordsJson.add(e.toJson());
    }

    var obj = {
      "type": type.index,
      "date": date,
      "status": status.index,
      "remark": remark ?? '',
      "records": recordsJson
    };

    return obj;
  }

  int _okCount = -1;
  int _notOkCount = -1;
  int _middleCount = -1;

  void recalcCount() {
    _okCount = 0;
    _notOkCount = 0;
    _middleCount = 0;
    for (int i = 0; i < records.length; ++i) {
      final item = records[i];
      item.recalcCount();

      _middleCount += item.middleCount;
      _okCount += item.okCount;
      _notOkCount += item.notOkCount;
    }
  }

  int get okCount {
    if (_okCount == -1) recalcCount();
    return _okCount;
  }

  int get notOkCount {
    if (_notOkCount == -1) recalcCount();
    return _notOkCount;
  }

  int get middleCount {
    if (_middleCount == -1) recalcCount();
    return _middleCount;
  }

  DzgGggType type;
  int date;
  int? year;
  GggStatus status;
  String? remark;
  List<DzgGggDay> records = [];
}

class DzgGggDay {
  DzgGggDay({required this.type, required this.date, required this.status, this.remark});
  static DzgGggDay fromJson(dynamic json, int month, int year) {
    final typeIndex = json['type'] ?? 0;
    final statusIndex = json['status'] ?? 0;
    final obj = DzgGggDay(
        type: DzgGggType.values[typeIndex],
        date: json['date'],
        status: GggStatus.values[statusIndex],
        remark: json['remark']);
    obj.year = year;
    obj.month = month;
    final records = json['records'] as String?;
    if (records != null) {
      for (String c in records.characters) {
        obj.records.add(int.tryParse(c) ?? 0);
      }
    }

    return obj;
  }

  dynamic toJson() {
    var obj = {
      "type": type.index,
      "date": date,
      "status": status.index,
      "remark": remark ?? '',
      "records": records.join()
    };

    return obj;
  }

  int _okCount = -1;
  int _notOkCount = -1;
  int _middleCount = -1;

  void recalcCount() {
    _okCount = 0;
    _notOkCount = 0;
    _middleCount = 0;
    for (int i = 0; i < records.length; ++i) {
      final item = records[i];
      if (item == 0 && dzgGggDescItems[i].isGroup != true) {
        ++_middleCount;
      } else if (item == 1) {
        ++_okCount;
      } else if (item == 2) {
        ++_notOkCount;
      }
    }
  }

  int get okCount {
    if (_okCount == -1) recalcCount();
    return _okCount;
  }

  int get notOkCount {
    if (_notOkCount == -1) recalcCount();
    return _notOkCount;
  }

  int get middleCount {
    if (_middleCount == -1) recalcCount();
    return _middleCount;
  }

  DzgGggType type;
  int date;
  int? month;
  int? year;
  GggStatus status;
  String? remark;

  List<int> records = [];
}
