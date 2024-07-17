import 'package:flutter/services.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:uuid/uuid.dart';

class StringUtils {
  StringUtils._();

  static String trim(String str, RegExp reg) {
    String ret = str;
    bool canGo = true;
    while (canGo) {
      canGo = false;
      if (str.startsWith(reg)) {
        ret = ret.replaceFirst(reg, '');
        canGo = true;
      }

      String e = '${reg.pattern}\$';
      RegExp endReg = RegExp(e);
      var endIndex = str.indexOf(endReg);
      if (endIndex >= 0) {
        ret = ret.substring(0, endIndex);
        canGo = true;
      }
    }

    return ret;
  }

  static int compareVersion(String version1, String version2) {
    if (version1 == version2) {
      return 0; //版本相同
    }
    final v1Array = version1.split(".");
    final v2Array = version2.split(".");
    int v1Len = v1Array.length;
    int v2Len = v2Array.length;
    int baseLen = 0; //基础版本号位数（取长度小的）
    if (v1Len > v2Len) {
      baseLen = v2Len;
    } else {
      baseLen = v1Len;
    }

    for (int i = 0; i < baseLen; i++) {
      //基础版本号比较
      if (v1Array[i] == v2Array[i]) {
        //同位版本号相同
        continue; //比较下一位
      } else {
        return int.parse(v1Array[i]) > int.parse(v2Array[i]) ? 1 : -1;
      }
    }
    //基础版本相同，再比较子版本号
    if (v1Len != v2Len) {
      return v1Len > v2Len ? 1 : -1;
    }

    //基础版本相同，无子版本号
    return 0;
  }

  static String uuid() {
    return const Uuid().v4();
  }

  static copyToClipboard(String str) {
    Clipboard.setData(ClipboardData(text: str));
    UiUtils.toast(content: '已拷貝');
  }
}
