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

class TapCounterStatisticsPage extends StatefulWidget {
  const TapCounterStatisticsPage({super.key, required this.index});
  final int index;

  @override
  TapCounterStatisticsPageState createState() =>
      TapCounterStatisticsPageState();
}

class TapCounterStatisticsPageState extends State<TapCounterStatisticsPage> {
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
  int _visibleCount = 14;
  int _windowStart = 0;
  double _panAccumulator = 0;

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

    final totalPoints = _updatesPerDay.length;
    _visibleCount = totalPoints < 14 ? totalPoints : 14;
    _windowStart =
        totalPoints > _visibleCount ? totalPoints - _visibleCount : 0;
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
            const SizedBox(height: 16),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16.0),
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
            Container(
              height: 300,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Updates per Day",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Builder(builder: (context) {
                      final points = _buildLinePoints();
                      final totalPoints = points.length;

                      _visibleCount = totalPoints == 0
                          ? 0
                          : _visibleCount.clamp(1, totalPoints);
                      _windowStart = totalPoints == 0
                          ? 0
                          : _windowStart.clamp(
                              0,
                              (totalPoints - _visibleCount)
                                  .clamp(0, totalPoints));

                      final windowEnd = totalPoints == 0
                          ? 0
                          : (_windowStart + _visibleCount)
                              .clamp(0, totalPoints);
                      final windowPoints = totalPoints == 0
                          ? <_DayPoint>[]
                          : points.sublist(_windowStart, windowEnd);

                      return GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          if (totalPoints == 0) return;
                          _panAccumulator += details.delta.dx;
                          const threshold = 18.0;
                          if (_panAccumulator.abs() >= threshold) {
                            final step = _panAccumulator > 0 ? -1 : 1;
                            _panAccumulator = 0;
                            setState(() {
                              _windowStart = (_windowStart + step).clamp(
                                  0,
                                  (totalPoints - _visibleCount)
                                      .clamp(0, totalPoints));
                            });
                          }
                        },
                        onScaleUpdate: (details) {
                          if (totalPoints == 0) return;
                          final newCount = (14 / details.scale)
                              .round()
                              .clamp(5, totalPoints);
                          final windowEndCurrent = _windowStart + _visibleCount;
                          setState(() {
                            _visibleCount = newCount;
                            final newStart = (windowEndCurrent - _visibleCount)
                                .clamp(
                                    0,
                                    (totalPoints - _visibleCount)
                                        .clamp(0, totalPoints));
                            _windowStart = newStart;
                          });
                        },
                        child: SfCartesianChart(
                          primaryXAxis: const CategoryAxis(
                            labelRotation: -65,
                            majorGridLines: MajorGridLines(width: 0),
                            labelIntersectAction:
                                AxisLabelIntersectAction.rotate45,
                          ),
                          primaryYAxis: const NumericAxis(
                            minimum: 0,
                            majorGridLines: MajorGridLines(width: 0.5),
                            axisLine: AxisLine(width: 0),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                          ),
                          series: <CartesianSeries<_DayPoint, String>>[
                            _buildLineSeries(windowPoints),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
                        const SizedBox(height: 16),
            Center(
              child: SfCircularChart(
                  title: const ChartTitle(
                    text: "Updates Pie",
                    textStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: _statsWidget,
              ),
            ),
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
}
