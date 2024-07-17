import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudict/app/index.dart';

void main() {
  runApp(const SudictApp());
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
}
