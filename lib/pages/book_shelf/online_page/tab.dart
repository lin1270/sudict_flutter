import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:sudict/pages/book_shelf/mgr.dart';
import 'package:sudict/pages/book_shelf/online_page/construct.dart';

// ignore: must_be_immutable
class OnlineBookTab extends StatefulWidget {
  OnlineBookTab({super.key, required this.catalog});

  OnlineBookCatalog catalog;

  @override
  State<OnlineBookTab> createState() => _OnlineBookTabState();
}

class _OnlineBookTabState extends State<OnlineBookTab> with AutomaticKeepAliveClientMixin {
  _addBookItem(OnlineBookItem book) {
    BookMgr.instance.addItem(book.name, "", BookFrom.online, url: book.url, count: book.count);
    book.isAdded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: FlutterListView(
        delegate: FlutterListViewDelegate((context, index) {
          final book = widget.catalog.books[index];
          return Row(
            children: [
              Expanded(
                  child: Text(
                '${index + 1} ${book.name}',
                style: TextStyle(
                    fontSize: 18,
                    color: book.isAdded ? Colors.black38 : Colors.black,
                    overflow: TextOverflow.ellipsis),
              )),
              TextButton(
                  onPressed: book.isAdded
                      ? null
                      : () {
                          _addBookItem(book);
                        },
                  child: book.isAdded
                      ? const Text('已添加')
                      : const Row(
                          children: [Icon(Icons.add), Text('添加')],
                        )),
            ],
          );
        }, childCount: widget.catalog.books.length),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
