import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sudict/app/theme_manager.dart';
import 'package:sudict/config/path.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/menu/menu_item.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/file.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/path.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/book_shelf/mgr.dart';
import 'package:sudict/pages/router.dart';

class BookShelfPage extends StatefulWidget {
  const BookShelfPage({super.key});
  @override
  State<BookShelfPage> createState() => _BookShelfPageState();
}

class _BookShelfPageState extends State<BookShelfPage> with SingleTickerProviderStateMixin {
  final _addMenuItems = <MenuItem>[];
  final _addMenuController = CustomPopupMenuController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _addMenuController.dispose();
    super.dispose();
  }

  _init() async {
    _addMenuItems.addAll([
      MenuItem('線上古書', Icons.public, _onAddNetBook, null),
      MenuItem('本地文檔(pdf、epub)', Icons.file_open_outlined, _onAddLocalFile, null),
    ]);
    await BookMgr.instance.init();

    setState(() {});
  }

  _onAddNetBook(MenuItem item) async {
    int preCount = BookMgr.instance.books.length;
    await NavigatorUtils.go(context, AppRouteName.bookShelfOnlineBook, null);
    if (preCount != BookMgr.instance.books.length) {
      setState(() {});
    }
  }

  _onAddLocalFile(MenuItem item) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, allowMultiple: true, allowCompression: false,
      // allowedExtensions: ['epub'],
    );
    if (result == null) return;

    String resultStr = '';
    for (final item in result.files) {
      if (item.path != null && item.path?.isNotEmpty == true) {
        String lowerPath = item.path!.toLowerCase();
        String fileNameWithDot = PathUtils.fileName(item.path!);
        if (lowerPath.endsWith('.pdf') || lowerPath.endsWith('.epub')) {
          String md5 = await FileUtils.md5String(item.path!);
          String ext = PathUtils.ext(lowerPath);
          String fileName = PathUtils.fileName(item.path!, hasExt: false);

          String destPath = PathUtils.join(await PathConfig.userLocalBookDir, '$md5$ext');
          if (FileUtils.exists(destPath)) {
            if (BookMgr.instance.isItemExist(destPath)) {
              resultStr += '* $fileNameWithDot 添加成功：重複導入項。\n';
            } else {
              BookMgr.instance.addItem(fileName, destPath, BookFrom.local);
              resultStr += '* $fileNameWithDot 添加成功。\n';
            }
          } else {
            bool copyResult = await FileUtils.copy(item.path!, destPath);
            if (!copyResult) {
              resultStr += '* $fileNameWithDot 添加失敗：複製失敗。\n';
              continue;
            }

            BookMgr.instance.addItem(fileName, destPath, BookFrom.local);
            resultStr += '* $fileNameWithDot 添加成功。\n';
          }
        } else {
          resultStr += '* $fileNameWithDot 添加失敗：不支持該文件類型。\n';
        }
        File(item.path!).delete();
      }
    }
    _alert(resultStr);
    setState(() {});
  }

  _alert(String str) {
    UiUtils.showAlertDialog(context: context, content: str);
  }

  Widget _buildAddMenu() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
            color: const Color(0xFF4C4C4C),
            constraints: const BoxConstraints(minWidth: 120),
            child: IntrinsicWidth(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _addMenuItems
                  .map(
                    (item) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        item.onClicked!(item);
                        _addMenuController.hideMenu();
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              item.icon,
                              size: 18,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ))));
  }

  _showBook(BookItem book) {
    if (book.from == BookFrom.online) {
      _showOnlineChaptersDialog(book);
    } else {
      _showBookReadPage(book.path);
    }
  }

  _showOnlineBook(BookItem item, int num) async {
    var url = item.url;
    if (url.endsWith('/')) {
      url += '$num.pdf';
    } else {
      url += '/$num.pdf';
    }

    _showBookReadPage(url);
  }

  _showOnlineChaptersDialog(BookItem book) {
    // 僅有一頁時，直接顯示
    if (book.count == 1) {
      _showOnlineBook(book, 1);
      return;
    }

    const pageSize = 10;
    final pageCount = (book.count / pageSize).ceil();
    final size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (statefullContext, setState) {
            return AlertDialog(
                content: SizedBox(
                    width: size.width,
                    height: size.height * 0.7,
                    child: Swiper(
                      itemBuilder: (BuildContext swiperContext, int index) {
                        final begin = pageSize * index;
                        var end = begin + pageSize;
                        if (end >= book.count) end = book.count;
                        return Container(
                            decoration: const BoxDecoration(color: Colors.white),
                            child: Column(children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: FishInkwell(
                                          onTap: () {
                                            _showOnlineBook(book, book.lastReadIndex);
                                          },
                                          child: Text(
                                              '上次閱讀：${book.lastReadIndex == -1 ? '無' : ('卷${book.lastReadIndex}')}')))
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                  child: ListView.builder(
                                      itemCount: end - begin,
                                      itemBuilder: (lvContext, index) {
                                        final pageNum = begin + index + 1;
                                        return FishInkwell(
                                          onTap: () {
                                            setState(() {
                                              book.lastReadIndex = pageNum;
                                              BookMgr.instance.saveCfg();
                                            });
                                            _showOnlineBook(book, pageNum);
                                          },
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(color: Colors.black12)),
                                              ),
                                              padding: const EdgeInsets.only(
                                                  top: 8, bottom: 8, left: 8, right: 8),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    '卷$pageNum',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: book.lastReadIndex == pageNum
                                                            ? UIConfig.userColor
                                                            : Colors.black),
                                                  )),
                                                  const Icon(Icons.keyboard_arrow_right)
                                                ],
                                              )),
                                        );
                                      }))
                            ]));
                      },
                      itemCount: pageCount,
                      pagination:
                          pageCount > 1 ? const SwiperPagination(margin: EdgeInsets.all(0)) : null,
                      itemWidth: size.width,
                      loop: false,
                    )));
          });
        });
  }

  _showBookReadPage(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.pdf')) {
      NavigatorUtils.go(context, AppRouteName.pdfReader, path);
    } else if (lowerPath.endsWith('.epub')) {
      NavigatorUtils.go(context, AppRouteName.epubReader, path);
    } else {
      UiUtils.toast(content: '無法預覽該種類型書籍。');
    }
  }

  List<Widget> _bookWidgetList() {
    if (BookMgr.instance.books.isEmpty) {
      return [
        const Text(
          '暫無書籍，請於右上角添加。',
          style: TextStyle(fontSize: 24),
        )
      ];
    }
    return List.generate(BookMgr.instance.books.length, (index) {
      final book = BookMgr.instance.books[index];
      final nameChars = book.name.characters;
      return FishInkwell(
        onTap: () {
          BookMgr.instance.lastIndex = index;
          _showBook(book);
          setState(() {});
        },
        onLongPress: () {
          _showContextMenu(book);
        },
        child: Container(
            padding: const EdgeInsets.only(left: 16, right: 10, top: 8, bottom: 16),
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0xa0, 0x74, 0x24),
                boxShadow: [BoxShadow(color: Colors.black45, offset: Offset(4, 4), blurRadius: 4)]),
            height: 110,
            width: 70,
            child: Wrap(
              direction: Axis.vertical,
              textDirection: TextDirection.rtl,
              children: List.generate(nameChars.length, (i) {
                return Text(
                  nameChars.elementAt(i),
                  style: TextStyle(
                      color: index == BookMgr.instance.lastIndex ? Colors.purple : Colors.black54,
                      fontWeight: FontWeight.bold),
                );
              }),
            )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        appBar: AppBar(
          title: const Text('我的書架'),
          actions: [
            CustomPopupMenu(
              menuBuilder: _buildAddMenu,
              barrierColor: Colors.transparent,
              pressType: PressType.singleClick,
              controller: _addMenuController,
              child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.add)),
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(spacing: 16, runSpacing: 16, children: _bookWidgetList())));
  }

  void _showContextMenu(BookItem book) {
    showMaterialModalBottomSheet(
      context: context,
      duration: const Duration(milliseconds: 100),
      builder: (context) => Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(color: ThemeManager.getTheme().scaffoldBackgroundColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(book.name),
              const SizedBox(
                height: 16,
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                child: FishInkwell(
                  onTap: () async {
                    NavigatorUtils.pop(context);
                    final ok = await UiUtils.showConfirmDialog(
                        context: context, content: '確定要刪除 ${book.name} 嗎?');
                    if (ok) {
                      BookMgr.instance
                          .removeItem(book.from == BookFrom.online ? book.url : book.path);
                      setState(() {});
                    }
                  },
                  child: const Row(
                    children: [Icon(Icons.delete_outline), Expanded(child: Text('刪除'))],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 1),
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                child: FishInkwell(
                  onTap: () {
                    NavigatorUtils.pop(context);
                  },
                  child: const Row(
                    children: [Icon(Icons.close_outlined), Expanded(child: Text('取消'))],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
