import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:sudict/modules/ggg/common.dart';
import 'package:sudict/modules/ui_comps/fish_inkwell/index.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/common.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/mgr.dart';
import 'package:sudict/pages/dizigui/gonguoge_tab_widget/year_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DzgGggAllWidget extends StatefulWidget {
  const DzgGggAllWidget({super.key});

  @override
  State<DzgGggAllWidget> createState() => _DzgGggAllWidgetState();
}

class _DzgGggAllWidgetState extends State<DzgGggAllWidget> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    setState(() {});
  }

  int get _yearSize {
    return DzgGggMgr.instance.data.length;
  }

  List<DzgGggYear>? _chartData;
  List<DzgGggYear> get chartData {
    if (_chartData == null) {
      _chartData = [];
      for (var i = 0; i < _yearSize; ++i) {
        final item = DzgGggMgr.instance.data[i];
        _chartData!.add(item);
      }
    }

    return _chartData!;
  }

  int get _okCount {
    int count = 0;
    for (var i = 0; i < _yearSize; ++i) {
      final item = DzgGggMgr.instance.data[i];
      count += item.okCount;
    }
    return count;
  }

  int get _notOkCount {
    int count = 0;
    for (var i = 0; i < _yearSize; ++i) {
      final item = DzgGggMgr.instance.data[i];
      count += item.notOkCount;
    }
    return count;
  }

  List<LineSeries<DzgGggYear, num>> _getDefaultLineSeries() {
    return <LineSeries<DzgGggYear, num>>[
      LineSeries<DzgGggYear, num>(
          dataSource: chartData,
          xValueMapper: (DzgGggYear year, _) => year.date,
          yValueMapper: (DzgGggYear year, _) => year.okCount,
          name: '功$_okCount',
          color: Colors.green.withAlpha(128),
          markerSettings: const MarkerSettings(isVisible: true)),
      LineSeries<DzgGggYear, num>(
          dataSource: chartData,
          name: '過$_notOkCount',
          xValueMapper: (DzgGggYear year, _) => year.date,
          yValueMapper: (DzgGggYear year, _) => year.notOkCount,
          color: Colors.red.withAlpha(128),
          markerSettings: const MarkerSettings(isVisible: true))
    ];
  }

  var isCardView = false;
  Widget _chartWidget() {
    if (chartData.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('暫無數據'));
    return SizedBox(
        height: 200,
        child: Stack(
          children: [
            SfCartesianChart(
              backgroundColor: Colors.white.withAlpha(128),
              plotAreaBorderWidth: 0,
              title: ChartTitle(text: isCardView ? '記錄曲線' : ''),
              legend: const Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: NumericAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  minimum: (chartData[0].date - 1).toDouble(),
                  maximum: (chartData[chartData.length - 1].date + 1).toDouble(),
                  interval: 1,
                  majorGridLines: const MajorGridLines(width: 1)),
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
                      for (var i = 0; i < DzgGggMgr.instance.data.length; ++i) {
                        final item = DzgGggMgr.instance.data[i];
                        item.recalcCount();
                      }
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh_outlined))),
          ],
        ));
  }

  Widget _itemWidget(int i) {
    DzgGggYear year = DzgGggMgr.instance.data[i];

    final okCount = year.okCount;
    final notOkCount = year.notOkCount;
    const widgetWidth = 80.0;
    const widgetHeight = 64.0;
    final isGray = year.status == GggStatus.none;
    final okWidth = okCount / (okCount + notOkCount);

    return FishInkwell(
      onTap: () {
        MyDialog.popup(DzgGggYearWidget(year: year), isScrollControlled: true);
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
              '${year.date}',
              style: const TextStyle(fontSize: 24),
            ),
            Text('$okCount/$notOkCount')
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _chartWidget(),
        Expanded(
            child: SingleChildScrollView(
                child: Wrap(
          children: List.generate(_yearSize, (i) {
            return _itemWidget(i);
          }),
        )))
      ],
    );
  }
}
