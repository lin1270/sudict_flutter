import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sudict/config/path.dart';
import 'package:sudict/modules/dict/dict_item.dart';
import 'package:sudict/modules/dict/dict_mgr.dart';
import 'package:sudict/modules/dict/parser/fish_dict/index.dart';
import 'package:sudict/modules/dict/parser/mdict.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/path.dart';
import 'package:sudict/modules/utils/string.dart';
import 'package:sudict/modules/utils/ui.dart';

class _HandleResult {
  _HandleResult(this.path, this.success, this.msg);
  String path;
  String msg;
  bool success;
}

class AddUserLocalDictHandler {
  AddUserLocalDictHandler._();

  // 处理用户添加的辞典文件
  static Future<bool> handle(List<String> pathList, int groupIndex, bool isShared) async {
    if (NavigatorUtils.currContext == null) return false;

    final ret = <_HandleResult>[];
    final loadingController = UiUtils.loading();
    for (String path in pathList) {
      String lowerPath = path.toLowerCase();
      String ext = PathUtils.ext(lowerPath);
      if (ext == ".mdx" || ext == '.fishdict') {
        final dict = path.endsWith(".mdx") ? MDict(path) : FishDict(path);
        await dict.load();
        final loaded = dict.isLoaded;
        final fileName = PathUtils.fileName(path);
        final truePath = PathUtils.join(await PathConfig.userLocalDictDir, fileName);
        final alreadyExistFile = File(truePath);
        var successMsg = '添加成功。';

        final currDicts = DictMgr.instance.getDictByPath(truePath);
        if (currDicts.isNotEmpty) {
          for (DictItem ei in currDicts) {
            await ei.dict.release();
          }
        }
        if (await alreadyExistFile.exists()) {
          successMsg += '已覆蓋原來的辭典數據。';
          await alreadyExistFile.delete();
        }
        File srcFile = File(path);
        await srcFile.copy(truePath);
        await srcFile.delete();

        ret.add(_HandleResult(path, loaded, loaded ? successMsg : '解析辭典失敗！'));
        await dict.release();

        if (currDicts.isNotEmpty) {
          for (DictItem ei in currDicts) {
            await ei.dict.load();
          }
        }

        final currGroupDicts = DictMgr.instance.getDictByPath(truePath, groupIndex: groupIndex);
        if (currGroupDicts.isEmpty) {
          final dictItem = DictItem(
              StringUtils.uuid(), dict.title, truePath, DictType.mdict, DictFrom.user, true, false);
          DictMgr.instance.addDict(groupIndex, dictItem);
        }
      } else if (ext == '.mdd') {
        final dict = MDict(path);
        await dict.load();
        final loaded = dict.isLoaded;
        await dict.release();

        final fileName = PathUtils.fileName(path);
        final truePath = PathUtils.join(await PathConfig.userLocalDictDir, fileName);
        final alreadyExistFile = File(truePath);
        var successMsg = '添加成功。';
        if (await alreadyExistFile.exists()) {
          successMsg += '已覆蓋原來的辭典數據。';
          await alreadyExistFile.delete();
        }
        final srcFile = File(path);
        await srcFile.copy(truePath);
        await srcFile.delete();

        final mdxPath = PathUtils.changeExt(truePath, 'mdx');
        final mdxItems = DictMgr.instance.getDictByPath(mdxPath);
        // 重新加載，便會加載mdd文件了
        for (DictItem item in mdxItems) {
          if (item.visible) {
            await item.dict.release();
            item.dict.load();
          }
        }
        ret.add(_HandleResult(path, loaded, loaded ? successMsg : '解析辭典失敗！'));
      } else {
        ret.add(_HandleResult(path, false, '暫不能處理該類型文件：${PathUtils.ext(path)}'));
      }
    }

    loadingController.close();

    await _showAddResultDialog(ret);
    return ret.indexWhere((element) => element.success) >= 0;
  }

// todo:
  static test() {
    _showAddResultDialog([
      _HandleResult('xxxxxx', true, '添加成功'),
      _HandleResult('xxxxxx', true, '添加成功'),
      _HandleResult('xxxxxx', true, '添加成功'),
      _HandleResult('xxxxxx', true, '添加成功'),
      _HandleResult('xxxxxx', true, '添加成功'),
      _HandleResult('xxxxxx', true, '添加成功'),
      _HandleResult('xxxxxx', true, '添加成功'),
      _HandleResult('xxxxxx', true, '添加成功'),
      _HandleResult('xxxxxx', true, '添加成功'),
      _HandleResult('xxxxxx', true, '添加成功'),
      _HandleResult(
          'xfdskjfkdsjflkdsjflkdsjflkdsjflkdsjfdslkjflkdsjflkdsjfdslkjfdslkjflkdsjflkdsjflkdsjfxxxxx',
          false,
          '添加失败'),
      _HandleResult('xxxxxx', true, '添加成功'),
    ]);
  }

  static _showAddResultDialog(List<_HandleResult> ret) async {
    final context = NavigatorUtils.currContext;
    if (context == null) return;
    return await showDialog(
        context: context,
        useSafeArea: true,
        builder: (dialogContext) {
          return AlertDialog(
              title: const Text('辭典添加結果'),
              content: SingleChildScrollView(
                  child: ListBody(
                children: ret.map((e) {
                  return Card(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: e.success ? Colors.green : Colors.red,
                              borderRadius: const BorderRadius.all(Radius.circular(8))),
                          child: Row(children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Icon(
                                e.success ? Icons.done : Icons.error_outline,
                              ),
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  PathUtils.fileName(e.path),
                                  style: const TextStyle(
                                      fontSize: 18, overflow: TextOverflow.ellipsis),
                                ),
                                Text(
                                  e.msg,
                                  style: const TextStyle(color: Colors.black45),
                                )
                              ],
                            ))
                          ])));
                }).toList()
                  ..add(const Card(
                      child: Padding(
                          padding: EdgeInsets.only(top: 8, left: 12, bottom: 16, right: 12),
                          child: Column(children: [
                            Text(
                              '提示',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              '添加成功的辭典，可在設定中單獨修改哦。\n比如修改分組、名稱等。',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ])))),
              )));
        });
  }
}
