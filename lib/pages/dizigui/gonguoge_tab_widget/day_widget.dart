import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:sudict/modules/ggg/common.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/common.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/mgr.dart';

// ignore: must_be_immutable
class DzgGggDayWidget extends StatefulWidget {
  DzgGggDayWidget({super.key, required this.day, this.onChanged});
  final DzgGggDay day;
  Function(int index, int value)? onChanged;
  @override
  State<DzgGggDayWidget> createState() => _DzgGggDayWidgetState();
}

class _DzgGggDayWidgetState extends State<DzgGggDayWidget> {
  var _readonly = false;
  final _editDoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    final now = DateTime.now();
    if (now.year != widget.day.year ||
        now.month != widget.day.month ||
        now.day != widget.day.date) {
      _readonly = true;
    } else {
      _readonly = false;
    }
    setState(() {});
  }

  bool get _trueReadonly {
    if (widget.day.status == GggStatus.done) return true;
    return _readonly;
  }

  String get _dayStr => '${widget.day.year}/${widget.day.month}/${widget.day.date}';

  Widget _summaryWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_outlined,
              color: Colors.green,
            ),
            Text(
              '${widget.day.okCount}',
              style: const TextStyle(color: Colors.green),
            )
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.close_outlined,
              color: Colors.red,
            ),
            Text(
              '${widget.day.notOkCount}',
              style: const TextStyle(color: Colors.red),
            )
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.circle_outlined,
            ),
            Text('${widget.day.middleCount}')
          ],
        ),
        if (widget.day.status != GggStatus.done)
          ElevatedButton(
              onPressed: () async {
                if (widget.day.middleCount > 0) {
                  await UiUtils.showAlertDialog(
                      context: context, content: '您當前還有未填寫的項，請謹慎完成該天功過格哦。');
                }
                MyDialog.popup(Column(
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                        child: TextField(
                      style: const TextStyle(fontSize: 18),
                      controller: _editDoneController,
                      maxLines: 99999999,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: OutlineInputBorder(),
                          hintText: '請輸入您的總結內容',
                          filled: true,
                          fillColor: Colors.white70),
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                            onPressed: () {
                              if (_editDoneController.text.isEmpty) {
                                UiUtils.toast(content: '請輸入內容');
                                return;
                              }
                              widget.day.remark = _editDoneController.text;
                              widget.day.status = GggStatus.done;
                              DzgGggMgr.instance.saveDay(widget.day);
                              setState(() {});
                              NavigatorUtils.pop(context);
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('完成'))
                      ],
                    ),
                  ],
                ));
              },
              child: const Text('完成')),
        if (widget.day.status == GggStatus.done)
          Row(
            children: [
              Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: Text(_dayStr)),
              FishInkwell(
                onTap: () {
                  UiUtils.showAlertDialog(
                      context: context, content: widget.day.remark ?? '', title: '總結內容');
                },
                child: const Icon(Icons.info_outline),
              )
            ],
          )
      ],
    );
  }

  _border() {
    return const BorderSide();
  }

  Widget _gggWidget() {
    return Expanded(
        child: FlutterListView.builder(
            itemCount: dzgGggDescItems.length,
            itemBuilder: (context, i) {
              final item = dzgGggDescItems[i];
              return Container(
                margin: i == dzgGggDescItems.length - 1
                    ? const EdgeInsets.only(bottom: 8)
                    : EdgeInsets.zero,
                decoration: BoxDecoration(
                    border: Border(
                        left: _border(),
                        top: _border(),
                        bottom: i == dzgGggDescItems.length - 1 ? _border() : BorderSide.none,
                        right: _border())),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                            fontWeight: item.special == true ? FontWeight.bold : FontWeight.normal),
                      ),
                    ),
                    Container(
                      width: 120,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 6),
                      decoration: BoxDecoration(border: Border(left: _border(), right: _border())),
                      child: Text(
                        item.content,
                        style: TextStyle(
                            fontWeight: item.special == true ? FontWeight.bold : FontWeight.normal),
                      ),
                    ),
                    Expanded(
                        child: FishInkwell(
                      onTap: () {
                        if (item.isGroup == true) {
                          UiUtils.toast(content: '當前行不是記錄項。');
                          return;
                        }
                        if (_trueReadonly) {
                          UiUtils.toast(content: '當前數據不允許修改：1. 不是當天數據。 2. 已完成。');
                          return;
                        }

                        widget.day.records[i] = (widget.day.records[i] + 1) % 3;
                        widget.day.recalcCount();
                        widget.day.status = GggStatus.doing;
                        DzgGggMgr.instance.saveDay(widget.day);

                        setState(() {});
                      },
                      child: Center(
                        child: widget.day.records[i] == 0
                            ? const Text('')
                            : Icon(
                                widget.day.records[i] == 1 ? Icons.check : Icons.close_outlined,
                                color: widget.day.records[i] == 1 ? Colors.green : Colors.red,
                              ),
                      ),
                    ))
                  ],
                ),
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _summaryWidget(),
        _gggWidget(),
      ],
    );
  }
}
