import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:sudict/modules/ggg/common.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/modules/utils/navigator.dart';
import 'package:sudict/modules/utils/ui.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/common.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/mgr.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/month_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DzgGggYearWidget extends StatefulWidget {
  const DzgGggYearWidget({super.key, this.year});

  final DzgGggYear? year;

  @override
  State<DzgGggYearWidget> createState() => _DzgGggYearWidgetState();
}

class _DzgGggYearWidgetState extends State<DzgGggYearWidget> {
  final _editDoneController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    setState(() {});
  }

  int get _monthSize {
    return 12;
  }

  List<DzgGggMonth>? _chartData;
  List<DzgGggMonth> get chartData {
    if (_chartData == null) {
      _chartData = [];
      for (var i = 1; i <= _monthSize; ++i) {
        var found = false;
        for (var j = 0; j < widget.year!.records.length; ++j) {
          final item = widget.year!.records[j];
          if (item.date == i) {
            _chartData!.add(item);
            found = true;
            break;
          }
        }
        if (!found) {
          final emptyItem = DzgGggMonth(date: i, type: DzgGggType.month, status: GggStatus.none);
          _chartData!.add(emptyItem);
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

  List<LineSeries<DzgGggMonth, num>> _getDefaultLineSeries() {
    return <LineSeries<DzgGggMonth, num>>[
      LineSeries<DzgGggMonth, num>(
          dataSource: chartData,
          xValueMapper: (DzgGggMonth month, _) => month.date,
          yValueMapper: (DzgGggMonth month, _) => month.okCount,
          name: '功$_okCount',
          color: Colors.green.withAlpha(128),
          markerSettings: const MarkerSettings(isVisible: false)),
      LineSeries<DzgGggMonth, num>(
          dataSource: chartData,
          name: '過$_notOkCount',
          xValueMapper: (DzgGggMonth month, _) => month.date,
          yValueMapper: (DzgGggMonth month, _) => month.notOkCount,
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
                  interval: 1,
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
                      widget.year?.recalcCount();
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh_outlined))),
            if (widget.year?.status == GggStatus.done)
              Positioned(
                  right: 0,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          UiUtils.showAlertDialog(
                              context: context, content: widget.year?.remark ?? '', title: '總結內容');
                        },
                        icon: const Icon(Icons.info_outline),
                      ),
                      Text('${widget.year?.date}年'),
                    ],
                  )),
            if (widget.year?.status == GggStatus.doing)
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

                                      widget.year!.remark = _editDoneController.text;
                                      widget.year!.status = GggStatus.done;
                                      DzgGggMgr.instance.saveYearRemark(
                                          year: widget.year!.date, remark: widget.year!.remark!);
                                      DzgGggMgr.instance.saveYearStatus(
                                          year: widget.year!.date, status: widget.year!.status);
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
    DzgGggMonth? month;
    for (var j = 0; j < widget.year!.records.length; ++j) {
      final item = widget.year!.records[j];
      if (item.date == i) {
        month = item;
        break;
      }
    }

    final okCount = month?.okCount ?? 0;
    final notOkCount = month?.notOkCount ?? 0;
    const widgetWidth = 80.0;
    const widgetHeight = 64.0;
    final isGray = month == null || month.status == GggStatus.none;
    final okWidth = okCount / (okCount + notOkCount);

    return FishInkwell(
      onTap: () {
        if (month == null) {
          UiUtils.toast(content: '無記錄，無法查看哦');
          return;
        }
        MyDialog.popup(DzgGggMonthWidget(month: month), isScrollControlled: true);
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
            if (month != null) Text('$okCount/$notOkCount')
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (widget.year == null)
        ? const Padding(padding: EdgeInsets.all(16), child: Text('暫無數據'))
        : Column(
            children: [
              _chartWidget(),
              Expanded(
                  child: SingleChildScrollView(
                      child: Wrap(
                children: List.generate(_monthSize, (i) {
                  return _itemWidget(i + 1);
                }),
              )))
            ],
          );
  }
}
