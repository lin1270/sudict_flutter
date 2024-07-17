import 'package:flutter/material.dart';

typedef TOnMenuItemClicked = Function(MenuItem item);

enum MenuItemType {
  seperator,
  clickable,
}

class MenuItem {
  String title = '';
  IconData? icon;
  TOnMenuItemClicked? onClicked;
  dynamic param;
  MenuItemType type = MenuItemType.clickable;

  MenuItem(this.title, this.icon, this.onClicked, this.param);
  MenuItem.seperator() {
    type = MenuItemType.seperator;
  }
}
