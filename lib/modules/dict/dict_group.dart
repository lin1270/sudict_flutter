import 'package:sudict/modules/dict/dict_item.dart';

class DictGroup {
  static DictGroup fromJson(dynamic json) {
    int id = json['id'];
    String name = json["name"];
    String? from = json['from'];

    dynamic jsonItems = json['items'];
    List<DictItem> items = [];
    for (dynamic jsonItem in jsonItems) {
      items.add(DictItem.fromJson(jsonItem));
    }

    return DictGroup(id, name, from ?? DictFrom.res, items);
  }

  DictGroup(this.id, this.name, this.from, this.items);

  int id;
  String name;
  String from;
  List<DictItem> items;

  dynamic toJson() {
    return {"id": id, "name": name, "from": from, "items": itemsJson()};
  }

  itemsJson() {
    var json = [];
    for (DictItem item in items) {
      json.add(item.toJson());
    }
    return json;
  }
}
