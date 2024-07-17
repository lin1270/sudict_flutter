import 'package:flutter/material.dart';

class HistoryController extends ChangeNotifier {
  int notifyType = 0;
  clear() {
    notifyType = 0;
    notifyListeners();
  }

  share() {
    notifyType = 1;
    notifyListeners();
  }
}
