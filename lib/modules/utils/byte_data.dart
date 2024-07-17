import 'dart:typed_data';

class ByteDataUtils {
  static int byteList2int({required Uint8List data, int begin = 0}) {
    int len = data[0 + begin];
    len = len | (data[1 + begin] << 8);
    len = len | (data[2 + begin] << 16);
    len = len | (data[3 + begin] << 24);

    return len;
  }
}
