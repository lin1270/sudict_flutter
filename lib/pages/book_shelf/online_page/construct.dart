import 'package:sudict/pages/book_shelf/mgr.dart';

class OnlineBookItem {
  OnlineBookItem({required this.name, required this.count, required this.url});
  static OnlineBookItem fromJson(dynamic json, String catalogUrl) {
    String url = json['url'];
    String fullUrl = '';
    if (catalogUrl.endsWith('/')) {
      if (url.startsWith('/')) {
        fullUrl = catalogUrl + url.substring(1);
      } else {
        fullUrl = catalogUrl + url;
      }
    } else {
      if (url.startsWith('/')) {
        fullUrl = catalogUrl + url;
      } else {
        fullUrl = '$catalogUrl/$url';
      }
    }

    return OnlineBookItem(name: json['name'], url: fullUrl, count: json['count']);
  }

  String name;
  int count;
  String url;
  bool isAdded = false;
}

class OnlineBookCatalog {
  OnlineBookCatalog({required this.name});
  static OnlineBookCatalog fromJson(dynamic json) {
    final r = OnlineBookCatalog(name: json['name']);
    final items = json['items'];
    String url = json['url'];
    if (items != null) {
      for (var i = 0; i < items.length; ++i) {
        final bookItem = OnlineBookItem.fromJson(items[i], url);
        bookItem.isAdded = BookMgr.instance.isItemExist(bookItem.url);
        r.books.add(bookItem);
      }
    }
    return r;
  }

  String name;
  final books = <OnlineBookItem>[];
}
