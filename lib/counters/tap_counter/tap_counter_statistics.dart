import "package:countapp/counters/tap_counter/tap_counter.dart";
import "package:countapp/counters/tap_counter/tap_counter_updates.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/services/leaderboard_service.dart";
import "package:countapp/utils/widgets.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "package:syncfusion_flutter_charts/charts.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class _DayPoint {
  _DayPoint({required this.x, required this.label, required this.value});
  final int x;
  final String label;
  final double value;
}

class WeeklyHeatmapSource extends DataGridSource {
  WeeklyHeatmapSource({
    required List<List<double>> weeklyData,
    required double maxValue,
    required Color Function(double, double) colorMapper,
  }) {
    _weeklyData = weeklyData;
    _maxValue = maxValue;
    _colorMapper = colorMapper;
    _buildDataGridRows();
  }

  late List<List<double>> _weeklyData;
  late double _maxValue;
  late Color Function(double, double) _colorMapper;
  List<DataGridRow> _dataGridRows = [];

  void _buildDataGridRows() {
    // 24 rows for 24 hours
    _dataGridRows = List.generate(24, (hourIndex) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: "hour", value: hourIndex),
        // 7 columns for 7 days
        ...List.generate(7, (dayIndex) {
          return DataGridCell<double>(
            columnName: "d$dayIndex",
            value: _weeklyData[dayIndex][hourIndex],
          );
        }),
      ]);
    });
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final hourIndex = row.getCells()[0].value as int;

    return DataGridRowAdapter(
      cells: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Text(
            hourIndex.toString().padLeft(2, "0"),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        ...row.getCells().skip(1).map<Widget>((dataGridCell) {
          final val = dataGridCell.value as double;
          return Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: _colorMapper(val, _maxValue),
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: val > 0
                ? Text(
                    val.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 7,
                      color: ThemeData.estimateBrightnessForColor(
                                  _colorMapper(val, _maxValue)) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          );
        }),
      ],
    );
  }
}

class MonthlyHeatmapSource extends DataGridSource {
  MonthlyHeatmapSource({
    required List<List<double>> monthlyData,
    required double maxValue,
    required Color Function(double, double) colorMapper,
  }) {
    _monthlyData = monthlyData;
    _maxValue = maxValue;
    _colorMapper = colorMapper;
    _buildDataGridRows();
  }

  late List<List<double>> _monthlyData;
  late double _maxValue;
  late Color Function(double, double) _colorMapper;
  List<DataGridRow> _dataGridRows = [];

  void _buildDataGridRows() {
    // 31 rows for 31 days
    _dataGridRows = List.generate(31, (dayIndex) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: "day", value: dayIndex + 1),
        // 12 columns for 12 months
        ...List.generate(12, (monthIndex) {
          return DataGridCell<double>(
            columnName: "m$monthIndex",
            value: _monthlyData[monthIndex][dayIndex],
          );
        }),
      ]);
    });
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final dayLabel = row.getCells()[0].value as int;

    return DataGridRowAdapter(
      cells: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Text(
            dayLabel.toString().padLeft(2, "0"),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        ...row.getCells().skip(1).map<Widget>((dataGridCell) {
          final val = dataGridCell.value as double;
          return Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: _colorMapper(val, _maxValue),
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: val > 0
                ? Text(
                    val < 1 ? val.toStringAsFixed(1) : val.toInt().toString(),
                    style: TextStyle(
                      fontSize: 8,
                      color: ThemeData.estimateBrightnessForColor(
                                  _colorMapper(val, _maxValue)) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          );
        }),
      ],
    );
  }
}

class TapCounterStatisticsPage extends StatefulWidget {
  const TapCounterStatisticsPage({super.key, required this.index});
  final int index;

  @override
  TapCounterStatisticsPageState createState() =>
      TapCounterStatisticsPageState();
}

class TapCounterStatisticsPageState extends State<TapCounterStatisticsPage> {
  static const double _sectionSpacing = 32.0;
  static const TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  final int _numberOfDates = 7;
  late CounterProvider _counterProvider;
  late TapCounter _counter;
  late String _counterName;
  late List<DateTime> _updatesData;
  late List<Widget> _statsWidget;
  late List<MapEntry<String, int>> _updatesPerDay;
  late List<MapEntry<int, int>> _daysPerUpdateCount;
  late int _indexOfEndDate;
  bool _syncingLeaderboard = false;
  // Using Syncfusion's built-in zoom/pan; no manual windowing needed.

  @override
  void initState() {
    super.initState();
    _counterProvider = Provider.of<CounterProvider>(context, listen: false);
    _counter = _counterProvider.counters[widget.index] as TapCounter;
    _counterName = _counter.name;
    _updatesData = _counter.updates;

    _statsWidget = _counter.generateStatisticsWidgets();

    _updatesPerDay = Map<String, int>.fromEntries(
      _counter.getUpdatesPerDay().entries.toList()
        ..sort(
          (MapEntry<String, int> a, MapEntry<String, int> b) =>
              a.key.compareTo(b.key),
        ),
    ).entries.toList();

    _indexOfEndDate = _updatesPerDay.length - 1;
    _daysPerUpdateCount = _counter.getDaysPerUpdateCount().entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // No manual window size; chart displays all points with zoom enabled.
  }

  List<ChartData> _getHistogramData() {
    return _daysPerUpdateCount
        .map((entry) => ChartData(entry.key.toString(), entry.value.toDouble()))
        .toList();
  }

  List<_DayPoint> _buildLinePoints() {
    final formatter = DateFormat("MMM dd");
    return List<_DayPoint>.generate(_updatesPerDay.length, (index) {
      final entry = _updatesPerDay[index];
      final date = DateTime.parse(entry.key);
      return _DayPoint(
        x: index,
        label: formatter.format(date),
        value: entry.value.toDouble(),
      );
    });
  }

  LineSeries<_DayPoint, String> _buildLineSeries(List<_DayPoint> points) {
    return LineSeries<_DayPoint, String>(
      dataSource: points,
      xValueMapper: (point, _) => point.label,
      yValueMapper: (point, _) => point.value,
      markerSettings: const MarkerSettings(isVisible: true),
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Future<void> _syncAttachedLeaderboards() async {
    if (_syncingLeaderboard) return;

    setState(() => _syncingLeaderboard = true);

    if (widget.index < 0 || widget.index >= _counterProvider.counters.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar("Counter no longer exists", success: false),
        );
      }
      setState(() => _syncingLeaderboard = false);
      return;
    }

    _counter = _counterProvider.counters[widget.index] as TapCounter;

    final attached = LeaderboardService.getAll()
        .where((lb) => lb.attachedCounterId == _counter.id)
        .toList();

    if (attached.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar("No leaderboard attached to this counter",
              success: false),
        );
      }
      setState(() => _syncingLeaderboard = false);
      return;
    }

    bool allOk = true;
    for (final lb in attached) {
      final ok = await LeaderboardService.postUpdate(lb: lb, counter: _counter);
      allOk = allOk && ok;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildAppSnackBar(
            allOk ? "Synced to leaderboard" : "Some leaderboard syncs failed",
            success: allOk),
      );
      setState(() => _syncingLeaderboard = false);
    } else {
      _syncingLeaderboard = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int startIndex =
        (_indexOfEndDate - _numberOfDates + 1).clamp(0, _updatesPerDay.length);

    final int endIndex = (_indexOfEndDate + 1).clamp(0, _updatesPerDay.length);

    final plotData = _updatesPerDay.sublist(startIndex, endIndex);
    final chartData = _getHistogramData();
    final bool hasAttachedLeaderboard = LeaderboardService.getAll()
        .any((lb) => lb.attachedCounterId == _counter.id);

    return Scaffold(
      appBar: AppBar(title: Text("Info for $_counterName")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _indexOfEndDate -= _numberOfDates;

                      if (_indexOfEndDate < 0) {
                        _indexOfEndDate += _numberOfDates;
                      }
                    });
                  },
                  child: const Text("Previous"),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _indexOfEndDate += _numberOfDates;

                      if (_indexOfEndDate >= _updatesPerDay.length) {
                        _indexOfEndDate = _updatesPerDay.length - 1;
                      }
                    });
                  },
                  child: const Text("Next"),
                ),
              ],
            ),
            const SizedBox(height: _sectionSpacing),
            const Text(
              "Recent Activity",
              style: _sectionTitleStyle,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  titlesData: customAxisTitles(plotData),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(plotData.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: plotData[index].value.toDouble(),
                          width: 16,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: _sectionSpacing),
            SizedBox(
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: Builder(builder: (context) {
                      final points = _buildLinePoints();
                      final totalPoints = points.length;
                      final minIndex = totalPoints > 14 ? totalPoints - 14 : 0;
                      final maxIndex = totalPoints > 0 ? totalPoints - 1 : 0;
                      return SfCartesianChart(
                        title: const ChartTitle(
                          text: "Updates per Day",
                          textStyle: _sectionTitleStyle,
                        ),
                        primaryXAxis: CategoryAxis(
                          labelRotation: -65,
                          majorGridLines: const MajorGridLines(width: 0),
                          labelIntersectAction:
                              AxisLabelIntersectAction.rotate45,
                          initialVisibleMinimum: minIndex.toDouble(),
                          initialVisibleMaximum: maxIndex.toDouble(),
                        ),
                        primaryYAxis: const NumericAxis(
                          minimum: 0,
                          majorGridLines: MajorGridLines(width: 0.5),
                          axisLine: AxisLine(width: 0),
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                        ),
                        zoomPanBehavior: ZoomPanBehavior(
                          enablePinching: true,
                          enablePanning: true,
                          enableDoubleTapZooming: true,
                          zoomMode: ZoomMode.x,
                        ),
                        series: <CartesianSeries<_DayPoint, String>>[
                          _buildLineSeries(points),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _sectionSpacing),
            // Weekly Pro Heatmap
            _buildWeeklyProHeatmap(),
            const SizedBox(height: _sectionSpacing),
            // Monthly Activity
            _buildMonthlyProHeatmap(),
            const SizedBox(height: _sectionSpacing),
            Center(
              child: SfCircularChart(
                  title: const ChartTitle(
                    text: "Updates Distribution",
                    textStyle: _sectionTitleStyle,
                  ),
                  legend: const Legend(isVisible: true),
                  series: <CircularSeries>[
                    PieSeries<ChartData, String>(
                        explode: true,
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelMapper: (ChartData data, _) =>
                            data.y.toInt().toString(),
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true)),
                  ]),
            ),
            const SizedBox(height: _sectionSpacing),
            Column(
              children: _statsWidget,
            ),
            const SizedBox(height: _sectionSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TapCounterUpdatesPage(
                          name: _counterName,
                          data: _updatesData,
                        ),
                      ),
                    );
                  },
                  child: const Text("View All Updates"),
                ),
                if (hasAttachedLeaderboard) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed:
                        _syncingLeaderboard ? null : _syncAttachedLeaderboards,
                    icon: _syncingLeaderboard
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.sync),
                    label: Text(_syncingLeaderboard
                        ? "Syncing..."
                        : "Sync Leaderboard"),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  FlTitlesData customAxisTitles(List<MapEntry<String, int>> dates) {
    final maxValue =
        dates.reduce((a, b) => a.value > b.value ? a : b).value.toDouble();
    const maxTiles = 5;
    final interval = maxValue ~/ maxTiles;

    return FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (double value, TitleMeta meta) {
            if (maxValue <= maxTiles) {
              if (value % 1 == 0) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }
            } else {
              if (value % interval == 0) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }
            }
            return const SizedBox();
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final int index = value.toInt();
            if (index < 0 || index >= dates.length) {
              return Container();
            }

            final String formattedDate =
                DateFormat("MMM dd").format(DateTime.parse(dates[index].key));
            return RotatedBox(
              quarterTurns: 3,
              child: Text(
                formattedDate,
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
          reservedSize: 45,
        ),
      ),
    );
  }

  Widget _buildWeeklyProHeatmap() {
    final weeklyData = _counter.generateWeeklyHeatmapData();
    const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    double maxValue = 0;
    for (var d = 0; d < 7; d++) {
      for (var h = 0; h < 24; h++) {
        if (weeklyData[d][h] > maxValue) maxValue = weeklyData[d][h];
      }
    }

    final heatmapSource = WeeklyHeatmapSource(
      weeklyData: weeklyData,
      maxValue: maxValue,
      colorMapper: _getColorForValue,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            "Weekly Activity",
            style: _sectionTitleStyle,
          ),
        ),
        _buildHeatmapLegend(maxValue, isWeekly: true, leftPadding: 30),
        const SizedBox(height: 8),
        SizedBox(
          height: 650, // 24 rows * 26px + header
          child: SfDataGrid(
            source: heatmapSource,
            headerRowHeight: 30,
            rowHeight: 25,
            gridLinesVisibility: GridLinesVisibility.none,
            headerGridLinesVisibility: GridLinesVisibility.none,
            columnWidthMode: ColumnWidthMode.fill,
            columns: [
              GridColumn(
                columnName: "hour",
                width: 30,
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: const Text("H",
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              ...List.generate(7, (index) {
                return GridColumn(
                  columnName: "d$index",
                  label: Container(
                    padding: const EdgeInsets.all(2.0),
                    alignment: Alignment.center,
                    child: Text(
                      dayNames[index],
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyProHeatmap() {
    final monthlyData = _counter.generateMonthlyHeatmapData();
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    double maxValue = 0;
    for (var m = 0; m < 12; m++) {
      for (var d = 0; d < 31; d++) {
        if (monthlyData[m][d] > maxValue) maxValue = monthlyData[m][d];
      }
    }

    final heatmapSource = MonthlyHeatmapSource(
      monthlyData: monthlyData,
      maxValue: maxValue,
      colorMapper: _getColorForValue,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            "Monthly Activity",
            style: _sectionTitleStyle,
          ),
        ),
        _buildHeatmapLegend(maxValue, leftPadding: 30),
        const SizedBox(height: 8),
        SizedBox(
          height: 840, // 31 rows * row height + header
          child: SfDataGrid(
            source: heatmapSource,
            headerRowHeight: 30,
            rowHeight: 25,
            gridLinesVisibility: GridLinesVisibility.none,
            headerGridLinesVisibility: GridLinesVisibility.none,
            columnWidthMode: ColumnWidthMode.fill,
            columns: [
              GridColumn(
                columnName: "day",
                width: 30,
                label: Container(
                  padding: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  child: const Text("D",
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              ...List.generate(12, (index) {
                return GridColumn(
                  columnName: "m$index",
                  label: Container(
                    padding: const EdgeInsets.all(2.0),
                    alignment: Alignment.center,
                    child: Text(
                      monthNames[index],
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForValue(double value, double maxValue) {
    if (value == 0) return Colors.grey.withValues(alpha: 0.1);
    final double ratio = maxValue > 0 ? value / maxValue : 0;
    // Multi-color spectrum: Green -> Yellow -> Orange -> Red
    if (ratio < 0.25) {
      return Color.lerp(Colors.green[200], Colors.green[600], ratio / 0.25)!;
    } else if (ratio < 0.5) {
      return Color.lerp(
          Colors.green[600], Colors.yellow[600], (ratio - 0.25) / 0.25)!;
    } else if (ratio < 0.75) {
      return Color.lerp(
          Colors.yellow[600], Colors.orange[600], (ratio - 0.5) / 0.25)!;
    } else {
      return Color.lerp(
          Colors.orange[600], Colors.red[600], (ratio - 0.75) / 0.25)!;
    }
  }

  Widget _buildHeatmapLegend(double maxValue,
      {bool isWeekly = false, double leftPadding = 0}) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: leftPadding),
      child: Column(
        children: [
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _getColorForValue(0, 1),
                  _getColorForValue(0.25, 1),
                  _getColorForValue(0.5, 1),
                  _getColorForValue(0.75, 1),
                  _getColorForValue(1, 1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("0",
                  style: TextStyle(fontSize: 9, color: Colors.grey)),
              Text(
                isWeekly
                    ? maxValue.toStringAsFixed(2)
                    : maxValue.toStringAsFixed(1),
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
