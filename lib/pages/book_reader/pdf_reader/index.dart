import 'package:flutter/material.dart';
import 'package:sudict/modules/ui_comps/pdfview/index.dart';

// ignore: must_be_immutable
class PdfReaderPage extends StatefulWidget {
  PdfReaderPage({super.key, required this.arguments});
  String arguments;

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        body: SafeArea(
      left: false,
      bottom: false,
      right: false,
      child: PdfView(
        path: widget.arguments,
        showBackButton: true,
      ),
    ));
  }
}
