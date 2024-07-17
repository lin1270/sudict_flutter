import 'package:flutter/material.dart';
import 'package:sudict/pages/thought_record/mgr.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ThoughtRecordChartPage extends StatefulWidget {
  const ThoughtRecordChartPage({super.key});
  @override
  State<ThoughtRecordChartPage> createState() => _ThoughtRecordChartPageState();
}

class _ThoughtRecordChartPageState extends State<ThoughtRecordChartPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    setState(() {});
  }

  List<ThoughtRecordItem> get chartData => ThoughtRecordMgr.instance.data;

  int get _goodCount {
    int count = 0;
    for (var i = 0; i < chartData.length; ++i) {
      final item = chartData[i];
      count += item.good;
    }
    return count;
  }

  int get _badCount {
    int count = 0;
    for (var i = 0; i < chartData.length; ++i) {
      final item = chartData[i];
      count += item.bad;
    }
    return count;
  }

  List<LineSeries<ThoughtRecordItem, num>> _getDefaultLineSeries() {
    return <LineSeries<ThoughtRecordItem, num>>[
      LineSeries<ThoughtRecordItem, num>(
          dataSource: chartData,
          xValueMapper: (ThoughtRecordItem item, index) => index + 1,
          yValueMapper: (ThoughtRecordItem item, _) => item.good,
          name: '善$_goodCount',
          color: Colors.green,
          markerSettings: const MarkerSettings(isVisible: true)),
      LineSeries<ThoughtRecordItem, num>(
          dataSource: chartData,
          name: '惡$_badCount',
          xValueMapper: (ThoughtRecordItem item, index) => index + 1,
          yValueMapper: (ThoughtRecordItem item, _) => item.bad,
          color: Colors.red,
          markerSettings: const MarkerSettings(isVisible: true))
    ];
  }

  var isCardView = false;
  Widget _chartWidget() {
    return SfCartesianChart(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('一旬記錄')),
        body: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: _chartWidget()));
  }
}
