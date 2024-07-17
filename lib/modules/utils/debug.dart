import 'package:logger/logger.dart';

enum LogMode { debug, info, warning, error }

class FishDebugUtils {
  static final _logger = Logger();
  static log(String? str, {mode = LogMode.debug}) {
    switch (mode) {
      case LogMode.debug:
        return _logger.d(str);
      case LogMode.info:
        return _logger.i(str);
      case LogMode.warning:
        return _logger.w(str);
      case LogMode.error:
        return _logger.e(str);
    }
  }
}
