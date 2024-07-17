import 'package:flutter/material.dart';

class TabParam {
  TabParam({required this.title, required this.widget, this.param});

  String title;
  Widget widget;
  dynamic param;
}
