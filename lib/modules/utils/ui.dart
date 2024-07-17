import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:sudict/config/ui.dart';
import 'package:sudict/modules/http/index.dart';
import 'package:sudict/modules/ui_comps/dict_wrapper_widget/index.dart';
import 'package:sudict/modules/ui_comps/dict_wrapper_widget/type.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/navigator.dart';

enum _DownloadStatus { notDownload, downloading, completed }

class UiUtils {
  UiUtils._();

  static Future<bool> showConfirmDialog(
      {required BuildContext context, String? title, required String content}) async {
    // 显示确认对话框
    bool result = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title ?? '提示'),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // 返回false
                  },
                ),
                TextButton(
                  child: const Text('確認'),
                  onPressed: () {
                    Navigator.of(context).pop(true); // 返回true
                  },
                ),
              ],
            );
          },
        ) ??
        false;
    return result;
  }

  static Future<bool?> showAlertDialog(
      {required BuildContext context, String? title, required String content}) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? '提示'),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('確認'),
              onPressed: () {
                Navigator.of(context).pop(true); // 返回true
              },
            ),
          ],
        );
      },
    );
  }

  static toast({required String content, showMs = 1500}) {
    MyDialog.toast(content,
        duration: Duration(milliseconds: showMs), style: MyDialog.theme.toastStyle?.top());
  }

  static ProgressController loading({String content = '加載中...', bool showProgress = false}) {
    return MyDialog.loading(content, showProgress: showProgress);
  }

  static Future<String?> showDownloadingDialog(String url) async {
    String? downloadedPath = await HttpUtils.getUrlDownloadedPath(url);
    if (downloadedPath != null) {
      return downloadedPath;
    }

    var downloadState = _DownloadStatus.notDownload;
    var downloadingProgress = 0.0;
    const width = 150.0;
    const height = 150.0;
    return await showDialog(
        context: NavigatorUtils.currContext!,
        builder: (dlgContext) {
          return StatefulBuilder(builder: (context, setState) {
            return PopScope(
                canPop: downloadState != _DownloadStatus.downloading,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    CircularStepProgressIndicator(
                      totalSteps: 100,
                      currentStep: downloadingProgress.toInt(),
                      stepSize: 1,
                      selectedColor: Colors.greenAccent,
                      unselectedColor: Colors.grey[200],
                      padding: 0,
                      width: width,
                      height: height,
                      selectedStepSize: 15,
                      roundedCap: (_, __) => true,
                    ),
                    Positioned(
                        width: width,
                        height: height,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(width / 2),
                          child: FishInkwell(
                            onTap: () async {
                              if (downloadState == _DownloadStatus.notDownload) {
                                downloadState = _DownloadStatus.downloading;
                                HttpUtils.download(
                                  url: url,
                                  onProgress: (progress) {
                                    setState(() {
                                      downloadingProgress = progress * 100;
                                    });
                                  },
                                  onFailed: () {
                                    UiUtils.toast(content: '下載失敗!');

                                    setState(() {
                                      downloadState = _DownloadStatus.notDownload;
                                    });
                                  },
                                  onSuccess: (path) {
                                    downloadState = _DownloadStatus.completed;

                                    NavigatorUtils.pop(dlgContext, path);
                                  },
                                );
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: width,
                              height: height,
                              child: Text(
                                downloadState == _DownloadStatus.notDownload
                                    ? '點擊下載'
                                    : (downloadState == _DownloadStatus.downloading
                                        ? '下載中...'
                                        : '下載成功'),
                                style: const TextStyle(fontSize: 24, color: Colors.white),
                              ),
                            ),
                          ),
                        ))
                  ],
                ));
          });
        });
  }

  static showTempDictDialog(BuildContext context, String word) {
    showDialog(
        context: context,
        useSafeArea: false,
        builder: (dlgContext) {
          return Stack(
            children: [
              Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  left: 80,
                  child: Material(
                      color: UIConfig.dictWrapperBkColor,
                      child: SafeArea(
                        child: DictWrapperWidget(initWord: word, type: DictWrapperType.temp),
                      )))
            ],
          );
        });
  }
}
