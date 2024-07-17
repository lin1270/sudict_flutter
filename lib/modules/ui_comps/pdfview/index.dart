import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:sudict/app/theme_manager.dart';
import 'package:sudict/modules/share/index.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/ui_comps/pdfview/outline_view.dart';
import 'package:sudict/modules/ui_comps/third/animated_visibility/animated_visibility.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/path.dart';
import 'package:sudict/modules/utils/ui.dart';

// ignore: must_be_immutable
class PdfView extends StatefulWidget {
  PdfView({super.key, required this.path, this.showBackButton = false});

  String path;
  bool showBackButton;

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  String _localPath = '';
  var _showTitleBar = false;
  var _showLeftBar = false;
  // var _isTopToDown = true;
  final _controller = PdfViewerController();
  PdfDocument? _document;
  List<PdfOutlineNode>? _outline;
  int _pageNum = 0;
  ProgressController? _loadingCtrl;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    if (widget.path.startsWith('http://') || widget.path.startsWith('https://')) {
      // url download
      _downloadPdf();
    } else {
      // file system
      _setLocalPath(widget.path);
    }
  }

  _downloadPdf() async {
    Timer(const Duration(milliseconds: 1), () async {
      String? path = await UiUtils.showDownloadingDialog(widget.path);
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
    _pageNum = await LocalStorageUtils.getInt(_currPageKey) ?? 1;
    _loadingCtrl = UiUtils.loading();
    setState(() {});
  }

  Future<String?> _passwordDialog() async {
    final textController = TextEditingController();
    return await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('請輸入密碼'),
          content: TextField(
            controller: textController,
            autofocus: true,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(textController.text),
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }

  Widget _linkWidgetBuilder(BuildContext context, PdfLink link, Size size) {
    return FishInkwell(
      onTap: () async {
        // handle URL or Dest
        if (link.url != null) {
          if (await UiUtils.showConfirmDialog(
              context: context, content: '確定要打開 ${link.url?.path} 嗎?')) {
            NavigatorUtils.goBrowserUrl(link.url?.path ?? '');
          }
        } else if (link.dest != null) {
          _controller.goToDest(link.dest);
        }
      },
      hoverColor: Colors.blue.withOpacity(0.2),
    );
  }

  Widget _titlebarWidget() {
    return Positioned(
        child: AnimatedVisibility(
      visible: _showTitleBar,
      maintainState: true,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
            color: ThemeManager.getTheme().scaffoldBackgroundColor,
            border: const Border(bottom: BorderSide(color: Colors.black12))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (widget.showBackButton)
                  IconButton(
                      onPressed: () {
                        NavigatorUtils.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back)),
                IconButton(
                    onPressed: () async {
                      _showLeftBar = !_showLeftBar;
                      _outline ??= await _document?.loadOutline();
                      setState(() {});
                    },
                    icon: const Icon(Icons.menu)),
              ],
            ),
            Row(
              children: [
                // IconButton(
                //   onPressed: () {
                //     setState(() {
                //       _isTopToDown = !_isTopToDown;
                //       _controller.relayout();
                //     });
                //   },
                //   icon: Icon(_isTopToDown
                //       ? Icons.keyboard_double_arrow_down_outlined
                //       : Icons.keyboard_double_arrow_left_outlined),
                //   color: Colors.blue,
                // ),
                IconButton(
                    onPressed: () async {
                      final pdfImg = await _document?.pages[_controller.pageNumber ?? 0].render();
                      if (pdfImg != null) {
                        final img = await pdfImg.createImage();
                        final bytes = await img.toByteData(format: ImageByteFormat.png);
                        if (bytes != null) {
                          final path = await PathUtils.randomTempFilePathWithDotExt('.png');
                          await File(path).writeAsBytes(bytes.buffer.asUint8List());
                          ShareMgr.instance.shareFile(path);
                        }

                        pdfImg.dispose();
                      }
                    },
                    icon: const Icon(Icons.photo_camera_outlined)),
                IconButton(
                    onPressed: () {
                      if (_localPath.isEmpty) {
                        ShareMgr.instance.shareUrl(widget.path);
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
            )
          ],
        ),
      ),
    ));
  }

  String get _currPageKey => '${LocalStorageKeys.bookCurrPagePre}_$_localPath';
  String get _scaleKey => '${LocalStorageKeys.bookCurrScalePre}_$_localPath';

  Offset? _lastTapPosition;
  List<Widget> _views() {
    final vs = <Widget>[];
    if (_localPath.isEmpty) {
      vs.add(Container());
    } else {
      final param = PdfViewerParams(
        useAlternativeFitScaleAsMinScale: false,
        pageAnchor: PdfPageAnchor.topCenter,
        pageAnchorEnd: PdfPageAnchor.bottomCenter,
        minScale: 0.5,
        enableTextSelection: true,
        linkWidgetBuilder: _linkWidgetBuilder,
        onViewerReady: (document, controller) async {
          _document = document;
          dynamic cfg = await LocalStorageUtils.getJson(_scaleKey);
          if (cfg != null) {
            final pos = Offset(cfg['x'] ?? 0.0, cfg['y'] ?? 0.0);
            final zoom = cfg['zoom'] ?? 1.0;
            controller.setZoom(pos, zoom);
          }
          _loadingCtrl?.close();
        },
        onInteractionEnd: (details) {
          LocalStorageUtils.setJson(_scaleKey, {
            "zoom": _controller.currentZoom,
            "x": _controller.centerPosition.dx,
            "y": _controller.centerPosition.dy
          });
        },
        onPageChanged: (pageNumber) {
          LocalStorageUtils.setInt(_currPageKey, pageNumber ?? 1);
        },
        // layoutPages: (pages, params) {
        //   if (_isTopToDown) {
        //     final width =
        //         pages.fold(0.0, (prev, page) => max(prev, page.width)) + params.margin * 2;
        //     final pageLayouts = <Rect>[];
        //     double y = params.margin;
        //     for (var page in pages) {
        //       pageLayouts.add(
        //         Rect.fromLTWH(
        //           (width - page.width) / 2, // center vertically
        //           y,
        //           page.width,
        //           page.height,
        //         ),
        //       );
        //       y += page.height + params.margin;
        //     }
        //     return PdfPageLayout(
        //       pageLayouts: pageLayouts,
        //       documentSize: Size(width, y),
        //     );
        //   } else {
        //     final height =
        //         pages.fold(0.0, (prev, page) => max(prev, page.height)) + params.margin * 2;
        //     final pageLayouts = <Rect>[];
        //     double x = params.margin;
        //     for (var page in pages) {
        //       pageLayouts.add(
        //         Rect.fromLTWH(
        //           x,
        //           (height - page.height) / 2, // center vertically
        //           page.width,
        //           page.height,
        //         ),
        //       );
        //       x += page.width + params.margin;
        //     }
        //     return PdfPageLayout(
        //       pageLayouts: pageLayouts,
        //       documentSize: Size(x, height),
        //     );
        //   }
        // }
      );
      var pdfCreateFun = _localPath.startsWith('assets/') ? PdfViewer.asset : PdfViewer.file;

      vs.add(
        Listener(
            onPointerDown: (PointerDownEvent event) {
              _lastTapPosition = event.position;
            },
            onPointerMove: (event) {
              setState(() {
                _showLeftBar = false;
                _showTitleBar = false;
              });
            },
            onPointerUp: (event) {
              if (_lastTapPosition == null) return;
              if ((event.position.dx - _lastTapPosition!.dx).abs() <= 1 &&
                  (event.position.dy - _lastTapPosition!.dy).abs() <= 1) {
                setState(() {
                  _showLeftBar = false;
                  _showTitleBar = !_showTitleBar;
                });
              }
            },
            child: pdfCreateFun(
              _localPath,
              passwordProvider: _passwordDialog,
              params: param,
              controller: _controller,
              initialPageNumber: _pageNum,
            )),
      );

      // title bar
      vs.add(_titlebarWidget());

      // catalog
      vs.add(Positioned(
          top: 48,
          left: 0,
          width: 200,
          bottom: 0,
          child: AnimatedVisibility(
            visible: _showLeftBar,
            maintainState: true,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                  color: ThemeManager.getTheme().scaffoldBackgroundColor,
                  border: const Border(
                      right: BorderSide(color: Colors.black12),
                      bottom: BorderSide(color: Colors.black12))),
              child: OutlineView(
                controller: _controller,
                outline: _outline,
              ),
            ),
          )));

      // page button
      vs.add(Positioned(
          bottom: 96,
          right: 0,
          child: AnimatedVisibility(
              visible: _showTitleBar,
              maintainState: true,
              child: Container(
                  decoration: BoxDecoration(
                      color: ThemeManager.getTheme().scaffoldBackgroundColor,
                      border: const Border(
                        left: BorderSide(color: Colors.purple, width: 3),
                        top: BorderSide(color: Colors.purple, width: 3),
                        bottom: BorderSide(color: Colors.purple, width: 3),
                      ),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4), bottomLeft: Radius.circular(4))),
                  child: FishInkwell(
                    onTap: () {
                      MyDialog.prompt(
                        title: '跳轉頁碼',
                        builder: (context, editController) {
                          return TextField(
                            keyboardType: TextInputType.number,
                            controller: editController,
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                                border: const OutlineInputBorder(),
                                hintText: '頁碼 1-${_controller.pageCount}',
                                filled: true,
                                fillColor: Colors.white70),
                          );
                        },
                        onConfirm: (v) {
                          final s = int.tryParse(v);
                          if (s == null || s <= 0 || s > _controller.pageCount) {
                            MyDialog.toast(
                              '请输入正確的頁碼',
                              style: MyDialog.theme.toastStyle?.top(),
                            );
                            return false;
                          }
                          return true;
                        },
                      ).then((v) {
                        if (v != null) {
                          final s = int.tryParse(v);
                          if (s != null && s >= 1 && s <= _controller.pageCount) {
                            _controller.goToPage(
                                pageNumber: s,
                                anchor: PdfPageAnchor.topCenter,
                                duration: Duration.zero);

                            LocalStorageUtils.setInt(_currPageKey, s);
                            setState(() {});
                          }
                        }
                      });
                    },
                    child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                        child: Text(
                          '${_controller.isReady ? _controller.pageNumber ?? 0 : 0}',
                          textAlign: TextAlign.center,
                        )),
                  )))));
    }
    return vs;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _views(),
    );
  }
}
