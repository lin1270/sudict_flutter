// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sudict/modules/http/misc.dart';
import 'package:sudict/modules/utils/local_storage.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/string.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/modules/utils/version.dart';

class VersionUpdate {
  VersionUpdate._();
  static VersionUpdate? _instance;
  static VersionUpdate get instance {
    _instance ??= VersionUpdate._();
    return _instance!;
  }

  String _newVersion = '';
  bool _isForceUpdate = false;
  String _newVersionDownloadUrl = '';
  String _newVersionDesc = '';

  String get downloadUrl => _newVersionDownloadUrl;

  Future<void> detect(BuildContext context, {showEqualToast = false}) async {
    return await _handleVersionUpdate(context, showEqualToast: showEqualToast);
  }

  _handleVersionUpdate(BuildContext context, {showEqualToast = false}) async {
    final versionRes = await MiscHttpApi.getUpdateVersion();
    if (versionRes == null) return;
    _newVersion = versionRes['version'];
    _newVersionDownloadUrl = versionRes['url'];
    _isForceUpdate = versionRes['force'];
    _newVersionDesc = versionRes['desc'];

    String currVersion = await VersionUtils.appVersion;
    final cmpRestult = StringUtils.compareVersion(_newVersion, currVersion);
    if (cmpRestult > 0) {
      if (!_isForceUpdate) {
        final donotMindVersion =
            await LocalStorageUtils.getString(LocalStorageKeys.donotMindVersion);
        if (donotMindVersion != null &&
            StringUtils.compareVersion(_newVersion, donotMindVersion) == 0) {
          return;
        }
      }

      return await _showUpdateDialog(context);
    } else {
      if (showEqualToast) {
        UiUtils.toast(content: '當前已是最新版本');
      }
    }
  }

  _showUpdateDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (cc) {
          return PopScope(
            canPop: !_isForceUpdate,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '新版本$_newVersion',
                  style: const TextStyle(
                      fontSize: 32, color: Colors.white, decoration: TextDecoration.none),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  _newVersionDesc,
                  style: const TextStyle(
                      fontSize: 18, color: Colors.white54, decoration: TextDecoration.none),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Visibility(
                      visible: !_isForceUpdate,
                      child: OutlinedButton.icon(
                          onPressed: () {
                            LocalStorageUtils.setString(
                                LocalStorageKeys.donotMindVersion, _newVersion);
                            NavigatorUtils.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text(
                            '不再提醒',
                            style: TextStyle(color: Colors.white38),
                          ))),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        NavigatorUtils.goBrowserUrl(_newVersionDownloadUrl);
                      },
                      icon: const Icon(Icons.upgrade),
                      label: const Text("升級"))
                ]),
              ],
            ),
          );
        });
  }
}
