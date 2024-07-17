import 'dart:async';
import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:sudict/modules/share/index.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';

// ignore: must_be_immutable
class EpubReaderPage extends StatefulWidget {
  EpubReaderPage({super.key, required this.arguments});
  String arguments;

  @override
  State<EpubReaderPage> createState() => _EpubReaderPageState();
}

class _EpubReaderPageState extends State<EpubReaderPage> {
  EpubController? _epubController;
  String _localPath = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _epubController?.dispose();
    super.dispose();
  }

  _init() async {
    if (widget.arguments.startsWith('http://') || widget.arguments.startsWith('https://')) {
      // url download
      _download();
    } else {
      // file system
      _setLocalPath(widget.arguments);
    }
  }

  _download() async {
    Timer(const Duration(milliseconds: 1), () async {
      String? path = await UiUtils.showDownloadingDialog(widget.arguments);
      if (path == null) {
        _pop();
        return;
      }
      _setLocalPath(path);
    });
  }

  _pop() {
    NavigatorUtils.pop(context);
  }

  _setLocalPath(String path) async {
    _localPath = path;

    final cfi = await LocalStorageUtils.getString(_currPageKey);

    _epubController = EpubController(
        // Load document
        document: EpubDocument.openFile(File(_localPath)),
        epubCfi: cfi);

    setState(() {});
  }

  String get _currPageKey => '${LocalStorageKeys.bookCurrPagePre}_$_localPath';

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        appBar: _epubController == null
            ? null
            : AppBar(
                // Show actual chapter name
                title: EpubViewActualChapter(
                    controller: _epubController!,
                    builder: (chapterValue) => Text(
                          chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
                          textAlign: TextAlign.start,
                        )),
                actions: [
                  IconButton(
                      onPressed: () {
                        if (_localPath.isEmpty) {
                          ShareMgr.instance.shareUrl(widget.arguments);
                        } else {
                          ShareMgr.instance.shareFile(_localPath);
                        }
                      },
                      icon: const Icon(
                        Icons.share_outlined,
                        size: 20,
                      )),
                  TextButton(
                      onPressed: () {
                        UiUtils.showTempDictDialog(context, '');
                      },
                      child: const Text('辭典'))
                ],
              ),
        drawer: _epubController == null
            ? null
            : Drawer(
                child: EpubViewTableOfContents(
                  controller: _epubController!,
                ),
              ),
        body: SafeArea(
          left: false,
          bottom: false,
          right: false,
          child: _epubController == null
              ? Container()
              : EpubView(
                  controller: _epubController!,
                  onChapterChanged: (value) {
                    final cfi = _epubController!.generateEpubCfi();
                    if (cfi != null) {
                      LocalStorageUtils.setString(_currPageKey, cfi);
                    }
                  },
                  onExternalLinkPressed: (href) async {
                    if (await UiUtils.showConfirmDialog(
                        context: context, content: '確定要打開 $href 嗎?')) {
                      NavigatorUtils.goBrowserUrl(href);
                    }
                  },
                ),
        ));
  }
}
