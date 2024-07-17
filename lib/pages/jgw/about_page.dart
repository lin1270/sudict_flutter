import 'package:flutter/material.dart';

class JgwAboutPage extends StatelessWidget {
  const JgwAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('甲骨文小記')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('''引用：\n
        《說文解字研讀》視頻——萬獻初
        《說文解字十二講》——萬獻初、劉會龍
        《古文字學》——黃德寬
        《字源》——李學勤
        《古文字詁林》——李圃
        《漢語大詞典》
        《康熙字典》
        《說文解字注》
        《國語辭典》'''),
        ));
  }
}
