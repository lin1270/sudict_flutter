import 'package:flutter/material.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/thought_record/mgr.dart';

class RecordWidget extends StatefulWidget {
  const RecordWidget({super.key, required this.isGood});

  final bool isGood;
  @override
  State<RecordWidget> createState() => _RecordWidgetState();
}

class _RecordWidgetState extends State<RecordWidget> {
  ThoughtRecordItem? _today;
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _today = ThoughtRecordMgr.instance.today;
    setState(() {});
  }

  int get _count {
    if (_today == null) return 0;
    return widget.isGood ? _today!.good : _today!.bad;
  }

  static const _badFontColor = Colors.white54;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: widget.isGood ? Colors.white : Colors.black87),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.isGood ? '善' : '惡',
            style: TextStyle(fontSize: 56, color: widget.isGood ? Colors.black : _badFontColor),
          ),
          const SizedBox(
            height: 80,
          ),
          IconButton(
              onPressed: () {
                if (_today == null) return;
                if (widget.isGood) {
                  if (_today!.good > 1) --_today?.good;
                } else {
                  if (_today!.bad > 1) --_today?.bad;
                }
                ThoughtRecordMgr.instance.save();
                setState(() {});
              },
              icon: Icon(
                Icons.do_not_disturb_on_outlined,
                color: widget.isGood ? Colors.black : _badFontColor,
              )),
          IconButton(
              onPressed: () {
                UiUtils.toast(content: widget.isGood ? '善念+1' : '惡念+1');
                if (widget.isGood) {
                  ++_today?.good;
                } else {
                  ++_today?.bad;
                }
                ThoughtRecordMgr.instance.save();
                setState(() {});
              },
              icon: Icon(
                Icons.add_circle_outline,
                size: 72,
                color: widget.isGood ? Colors.black : _badFontColor,
              )),
          Text(
            '$_count',
            style: TextStyle(color: widget.isGood ? Colors.black : _badFontColor),
          ),
        ],
      ),
    );
  }
}
