import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:sudict/modules/ggg/common.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/common.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/day_widget.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/mgr.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DzgGggMonthWidget extends StatefulWidget {
  const DzgGggMonthWidget({super.key, this.month});

  final DzgGggMonth? month;

  @override
  State<DzgGggMonthWidget> createState() => _DzgGggMonthWidgetState();
}

class _DzgGggMonthWidgetState extends State<DzgGggMonthWidget> {
  final _editDoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    setState(() {});
  }

  final _dayComputer = {
    1: () => 31,
    2: (int year) {
      if (year % 400 == 0) return 29;
      if (year % 4 == 0 && year % 100 != 0) return 29;
      return 28;
    },
    3: () => 31,
    4: () => 30,
    5: () => 31,
    6: () => 30,
    7: () => 31,
    8: () => 31,
    9: () => 30,
    10: () => 31,
    11: () => 30,
    12: () => 31,
  };

  int get _daySize {
    if (widget.month == null) return 0;
    if (widget.month!.date == 2) return _dayComputer[widget.month!.date]!(widget.month!.year ?? 0);
    return _dayComputer[widget.month!.date]!();
  }

  List<DzgGggDay>? _chartData;
  List<DzgGggDay> get chartData {
    if (_chartData == null) {
      _chartData = [];
      for (var i = 1; i <= _daySize; ++i) {
        var found = false;
        for (var j = 0; j < widget.month!.records.length; ++j) {
          final item = widget.month!.records[j];
          if (item.date == i) {
            _chartData!.add(item);
            found = true;
            break;
          }
        }
        if (!found) {
          final emptyDay = DzgGggDay(date: i, type: DzgGggType.day, status: GggStatus.none);
          _chartData!.add(emptyDay);
        }
      }
    }

    return _chartData!;
  }

  int get _okCount {
    int count = 0;
    for (var i = 0; i < chartData.length; ++i) {
      final item = chartData[i];
      count += item.okCount;
    }
    return count;
  }

  int get _notOkCount {
    int count = 0;
    for (var i = 0; i < chartData.length; ++i) {
      final item = chartData[i];
      count += item.notOkCount;
    }
    return count;
  }

  List<LineSeries<DzgGggDay, num>> _getDefaultLineSeries() {
    return <LineSeries<DzgGggDay, num>>[
      LineSeries<DzgGggDay, num>(
          dataSource: chartData,
          xValueMapper: (DzgGggDay day, _) => day.date,
          yValueMapper: (DzgGggDay day, _) => day.okCount,
          name: '功$_okCount',
          color: Colors.green.withAlpha(128),
          markerSettings: const MarkerSettings(isVisible: false)),
      LineSeries<DzgGggDay, num>(
          dataSource: chartData,
          name: '過$_notOkCount',
          xValueMapper: (DzgGggDay day, _) => day.date,
          yValueMapper: (DzgGggDay day, _) => day.notOkCount,
          color: Colors.red.withAlpha(128),
          markerSettings: const MarkerSettings(isVisible: false))
    ];
  }

  var isCardView = false;
  Widget _chartWidget() {
    return SizedBox(
        height: 200,
        child: Stack(
          children: [
            SfCartesianChart(
              backgroundColor: Colors.white.withAlpha(128),
              plotAreaBorderWidth: 0,
              title: ChartTitle(text: isCardView ? '記錄曲線' : ''),
              legend: const Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: const NumericAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 2,
                  majorGridLines: MajorGridLines(width: 1)),
              primaryYAxis: const NumericAxis(
                  labelFormat: '{value}',
                  axisLine: AxisLine(width: 1),
                  majorTickLines: MajorTickLines(color: Colors.black)),
              series: _getDefaultLineSeries(),
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
            Positioned(
                child: IconButton(
                    onPressed: () {
                      widget.month?.recalcCount();
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh_outlined))),
            if (widget.month?.status == GggStatus.done)
              Positioned(
                  right: 0,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          UiUtils.showAlertDialog(
                              context: context, content: widget.month?.remark ?? '', title: '總結內容');
                        },
                        icon: const Icon(Icons.info_outline),
                      ),
                      Text('${widget.month?.date}月'),
                    ],
                  )),
            if (widget.month?.status == GggStatus.doing)
              Positioned(
                  right: 0,
                  child: ElevatedButton(
                      onPressed: () {
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

                                      widget.month!.remark = _editDoneController.text;
                                      widget.month!.status = GggStatus.done;
                                      DzgGggMgr.instance.saveMonthRemark(
                                          year: widget.month!.year!,
                                          month: widget.month!.date,
                                          remark: widget.month!.remark!);
                                      DzgGggMgr.instance.saveMonthStatus(
                                          year: widget.month!.year!,
                                          month: widget.month!.date,
                                          status: widget.month!.status);
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
                      child: const Text('完成'))),
          ],
        ));
  }

  Widget _itemWidget(int i) {
    DzgGggDay? day;
    for (var j = 0; j < widget.month!.records.length; ++j) {
      final item = widget.month!.records[j];
      if (item.date == i) {
        day = item;
        break;
      }
    }

    final okCount = day?.okCount ?? 0;
    final notOkCount = day?.notOkCount ?? 0;
    const widgetWidth = 80.0;
    const widgetHeight = 64.0;
    final isGray = day == null || day.status == GggStatus.none;
    final okWidth = okCount / (okCount + notOkCount);

    return FishInkwell(
      onTap: () {
        if (day == null) {
          UiUtils.toast(content: '無記錄，無法查看哦');
          return;
        }
        MyDialog.popup(DzgGggDayWidget(day: day), isScrollControlled: true);
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            gradient: isGray
                ? null
                : LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.0, okWidth, okWidth, 1.0],
                    colors: [
                      Colors.green,
                      Colors.green,
                      Colors.red.withAlpha(100),
                      Colors.red.withAlpha(100),
                    ],
                  ),
            color: isGray ? Colors.black38 : null),
        width: widgetWidth,
        height: widgetHeight,
        child: Column(
          children: [
            Text(
              '$i',
              style: const TextStyle(fontSize: 24),
            ),
            if (day != null) Text('$okCount/$notOkCount')
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.month == null)
        ? const Padding(padding: EdgeInsets.all(16), child: Text('暫無數據'))
        : Column(
            children: [
              _chartWidget(),
              Expanded(
                  child: SingleChildScrollView(
                      child: Wrap(
                children: List.generate(_daySize, (i) {
                  return _itemWidget(i + 1);
                }),
              )))
            ],
          );
  }
}
