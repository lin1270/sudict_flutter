import 'package:sudict/pages/san_qian/handler.dart';

class SanQianLinkItem {
  SanQianLinkItem(this.title, this.fullTitle, this.index);
  String title;
  String fullTitle;
  int index;
}

class SanQianItem {
  SanQianItem({this.isDesc = false});
  List<SanQianLinkItem> items = [];
  bool isDesc;
}

class SanQianReadParam {
  SanQianReadParam(this.handler);
  SanQianDataHandler handler;
}
