import 'package:flutter/material.dart';

class ContactMePage extends StatefulWidget {
  const ContactMePage({super.key});
  @override
  State<ContactMePage> createState() => _ContactMePageState();
}

class _ContactMePageState extends State<ContactMePage> {
  final _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  _init() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('聯絡我'),
          actions: [
            IconButton(
                onPressed: () async {
                  // todo:
                },
                icon: const Icon(Icons.send_outlined))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(fontSize: 18),
                  controller: _editController,
                  maxLines: 99999999,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(16),
                      border: OutlineInputBorder(),
                      hintText: '請輸入內容',
                      filled: true,
                      fillColor: Colors.white70),
                ),
              )
            ],
          ),
        ));
  }
}
