import 'package:flutter/material.dart';

class FishAudioPlayWidgetController extends ChangeNotifier {
  String url = '';
  String? name;
  int? length;
  bool? play;
  load(String url, [String? name, int? length, bool? play]) {
    this.url = url;
    this.name = name;
    this.length = length;
    this.play = play;
    notifyListeners();
  }
}
