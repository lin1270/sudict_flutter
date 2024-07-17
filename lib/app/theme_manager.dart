import 'package:flutter/material.dart';

class ThemeManager {
  ThemeManager._();

  static final _innerInstance = _InnerThemeManager();

  static ThemeData getTheme() {
    return _innerInstance.getCurrentTheme();
  }
}

class _InnerThemeManager {
  final int _index = 0;
  final _data = [];

  _InnerThemeManager() {
    var defaultTheme = ThemeData(
      colorScheme: const ColorScheme.light(
        surface: Color.fromARGB(255, 0xef, 0xef, 0xf3),
        primary: Color.fromARGB(255, 80, 80, 80),
      ),
      textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 18)))),
      scaffoldBackgroundColor: const Color.fromARGB(255, 0xef, 0xef, 0xf3),
      tabBarTheme: const TabBarTheme(
          dividerColor: Colors.black12,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black38),
      iconTheme: const IconThemeData(color: Color.fromARGB(192, 0, 0, 0), size: 28),
      sliderTheme: const SliderThemeData(
          inactiveTrackColor: Colors.black12, disabledActiveTickMarkColor: Colors.black12),
      appBarTheme: const AppBarTheme(backgroundColor: Color.fromARGB(255, 0xcd, 0xcd, 0xcd)),
      useMaterial3: true,
    );
    _data.add(defaultTheme);
  }

  ThemeData getCurrentTheme() {
    return _data[_index];
  }
}
