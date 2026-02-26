import "package:countapp/counters/tap_counter/tap_counter.dart";
import "package:countapp/counters/tap_counter/tap_counter_updates.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/services/leaderboard_service.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/widgets.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:ml_arima/ml_arima.dart" as ml_arima;
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
  int? _indexOfEndDate;
  bool _syncingLeaderboard = false;
  // Using Syncfusion's built-in zoom/pan; no manual windowing needed.

  @override
  void initState() {
    super.initState();
    // No manual window size; chart displays all points with zoom enabled.
  }

  Widget _buildPredictionCard(TapCounter counter, List<DateTime> updatesData,
      List<MapEntry<String, int>> updatesPerDay) {
    if (updatesData.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Not enough data to predict next update."),
        ),
      );
    }

    // Try ARIMA prediction first, fall back to simple average if it fails
    final nextUpdatePrediction =
        _predictNextUpdateWithArima(updatesData, updatesPerDay) ??
            _predictNextUpdateSimple(updatesData);

    final bool isToday =
        AppConstants.dateFormatYearMonthDay.format(nextUpdatePrediction) ==
            AppConstants.dateFormatYearMonthDay.format(DateTime.now());

    final dateStr = isToday
        ? "Today"
        : AppConstants.dateFormatMonthDayYear.format(nextUpdatePrediction);
    final timeStr = AppConstants.timeFormatHourMin.format(nextUpdatePrediction);

    final sortedUpdates = List<DateTime>.from(updatesData)..sort();
    final lastUpdate = sortedUpdates.last;
    final lastUpdateDateStr =
        AppConstants.dateFormatMonthDayYear.format(lastUpdate);
    final lastUpdateTimeStr = AppConstants.timeFormatHourMin.format(lastUpdate);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                const Text(
                  "Predicted Next Update",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$dateStr at $timeStr",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Column(
              children: [
                const Text(
                  "Last Update",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$lastUpdateDateStr at $lastUpdateTimeStr",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> _getHistogramData(
      List<MapEntry<int, int>> daysPerUpdateCount) {
    return daysPerUpdateCount
        .map((entry) => ChartData(entry.key.toString(), entry.value.toDouble()))
        .toList();
  }

  /// Predict the next update time using ARIMA forecasting
  DateTime? _predictNextUpdateWithArima(
      List<DateTime> updatesData, List<MapEntry<String, int>> updatesPerDay) {
    if (updatesData.length < 5) return null;

    try {
      // Get daily update counts as a time series
      final dailyUpdates =
          updatesPerDay.map((e) => e.value.toDouble()).toList();

      // Need at least 10 data points for meaningful ARIMA forecasting
      if (dailyUpdates.length < 10) {
        return null; // Fall back to simple average
      }

      // Fit ARIMA(1,0,1) model and forecast 1 step ahead
      final fit =
          ml_arima.Arima.fit(dailyUpdates, const ml_arima.ArimaOrder(1, 0, 1));
      final forecast = ml_arima.Arima.forecast(dailyUpdates, fit, 1);

      if (forecast.point.isEmpty) {
        return null;
      }

      // Get the last date and add one day
      final lastDate = DateTime.parse(updatesPerDay.last.key);
      final nextDate = lastDate.add(const Duration(days: 1));

      // Estimate time based on the pattern of last few days
      final sortedUpdates = List<DateTime>.from(updatesData)..sort();
      if (sortedUpdates.length < 2) return null;

      // Calculate average time of day for updates
      int totalMinutesOfDay = 0;
      int updateCount = 0;
      for (final update in sortedUpdates.sublist(
          (sortedUpdates.length - 20).clamp(0, sortedUpdates.length))) {
        totalMinutesOfDay += update.hour * 60 + update.minute;
        updateCount++;
      }

      final avgMinutesOfDay = totalMinutesOfDay ~/ updateCount;
      final avgHour = avgMinutesOfDay ~/ 60;
      final avgMinute = avgMinutesOfDay % 60;

      // Combine date and time
      return DateTime(
          nextDate.year, nextDate.month, nextDate.day, avgHour, avgMinute);
    } catch (e) {
      // If ARIMA fails, return null to fall back to simple average
      return null;
    }
  }

  /// Fallback simple moving average prediction
  DateTime _predictNextUpdateSimple(List<DateTime> updatesData) {
    final sortedUpdates = List<DateTime>.from(updatesData)..sort();
    final List<int> intervals = [];
    for (int i = 1; i < sortedUpdates.length; i++) {
      intervals
          .add(sortedUpdates[i].difference(sortedUpdates[i - 1]).inMinutes);
    }

    // Use last 20 intervals for prediction to capture recent behavior
    final recentIntervals = intervals.length > 20
        ? intervals.sublist(intervals.length - 20)
        : intervals;
    final avgIntervalInMinutes =
        recentIntervals.reduce((a, b) => a + b) / recentIntervals.length;

    return sortedUpdates.last
        .add(Duration(minutes: avgIntervalInMinutes.round()));
  }

  List<_DayPoint> _buildLinePoints(List<MapEntry<String, int>> updatesPerDay) {
    if (updatesPerDay.isEmpty) return [];

    final formatter = AppConstants.dateFormatMonthDay;

    // Get first and last dates
    final firstDate = DateTime.parse(updatesPerDay.first.key);
    final lastDate = DateTime.parse(updatesPerDay.last.key);

    // Create a map for quick lookup
    final Map<String, int> updatesMap = {
      for (final entry in updatesPerDay) entry.key: entry.value
    };

    // Generate all dates between first and last (including days with 0 updates)
    final List<_DayPoint> points = [];
    DateTime current = firstDate;
    int index = 0;

    while (current.isBefore(lastDate) || current.isAtSameMomentAs(lastDate)) {
      final dateStr = AppConstants.dateFormatYearMonthDay.format(current);
      final value = updatesMap[dateStr] ?? 0;

      points.add(_DayPoint(
        x: index,
        label: formatter.format(current),
        value: value.toDouble(),
      ));

      current = current.add(const Duration(days: 1));
      index++;
    }

    return points;
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

  Future<void> _syncAttachedLeaderboards(
      CounterProvider counterProvider, TapCounter counter) async {
    if (_syncingLeaderboard) return;

    setState(() => _syncingLeaderboard = true);

    if (widget.index < 0 || widget.index >= counterProvider.counters.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar("Counter no longer exists",
              success: false, context: context),
        );
      }
      setState(() => _syncingLeaderboard = false);
      return;
    }

    final attached = LeaderboardService.getAll()
        .where((lb) => lb.attachedCounterId == counter.id)
        .toList();

    if (attached.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar("No leaderboard attached to this counter",
              success: false, context: context),
        );
      }
      setState(() => _syncingLeaderboard = false);
      return;
    }

    bool allOk = true;
    for (final lb in attached) {
      final ok = await LeaderboardService.postUpdate(lb: lb, counter: counter);
      allOk = allOk && ok;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildAppSnackBar(
            allOk ? "Synced to leaderboard" : "Some leaderboard syncs failed",
            success: allOk,
            context: context),
      );
      setState(() => _syncingLeaderboard = false);
    } else {
      _syncingLeaderboard = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final counterProvider = context.watch<CounterProvider>();
    if (widget.index < 0 || widget.index >= counterProvider.counters.length) {
      return Scaffold(
        appBar: AppBar(title: const Text("Counter Not Found")),
        body: const Center(child: Text("This counter no longer exists.")),
      );
    }

    final counter = counterProvider.counters[widget.index] as TapCounter;
    final counterName = counter.name;
    final updatesData = counter.updates;
    final statsWidget = counter.generateStatisticsWidgets();
    final allLeaderboards = LeaderboardService.getAll(); // Cache once

    final updatesPerDay = Map<String, int>.fromEntries(
      counter.getUpdatesPerDay().entries.toList()
        ..sort(
          (MapEntry<String, int> a, MapEntry<String, int> b) =>
              a.key.compareTo(b.key),
        ),
    ).entries.toList();

    final daysPerUpdateCount = counter.getDaysPerUpdateCount().entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    _indexOfEndDate ??= updatesPerDay.length - 1;
    if (_indexOfEndDate! >= updatesPerDay.length) {
      _indexOfEndDate = updatesPerDay.length - 1;
    }
    if (_indexOfEndDate! < 0 && updatesPerDay.isNotEmpty) {
      _indexOfEndDate = 0;
    }

    final int startIndex =
        (_indexOfEndDate! - _numberOfDates + 1).clamp(0, updatesPerDay.length);

    final int endIndex = (_indexOfEndDate! + 1).clamp(0, updatesPerDay.length);

    final plotData = updatesPerDay.sublist(startIndex, endIndex);
    final chartData = _getHistogramData(daysPerUpdateCount);
    final bool hasAttachedLeaderboard =
        allLeaderboards.any((lb) => lb.attachedCounterId == counter.id);

    return Scaffold(
      appBar: AppBar(
        title: Text("Info for $counterName"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPredictionCard(counter, updatesData, updatesPerDay),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: updatesPerDay.isEmpty
                      ? null
                      : () {
                          setState(() {
                            _indexOfEndDate = _indexOfEndDate! - _numberOfDates;

                            if (_indexOfEndDate! < 0) {
                              _indexOfEndDate = 0;
                            }
                          });
                        },
                  child: const Text("Previous"),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: updatesPerDay.isEmpty
                      ? null
                      : () {
                          setState(() {
                            _indexOfEndDate = _indexOfEndDate! + _numberOfDates;

                            if (_indexOfEndDate! >= updatesPerDay.length) {
                              _indexOfEndDate = updatesPerDay.length - 1;
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
              child: plotData.isEmpty
                  ? const Center(child: Text("No activity data available"))
                  : BarChart(
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
            const Text(
              "Updates per Day",
              style: _sectionTitleStyle,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: Builder(builder: (context) {
                      final points = _buildLinePoints(updatesPerDay);
                      if (points.isEmpty) {
                        return const Center(child: Text("No data available"));
                      }
                      final totalPoints = points.length;
                      final minIndex = totalPoints > 14 ? totalPoints - 14 : 0;
                      final maxIndex = totalPoints > 0 ? totalPoints - 1 : 0;
                      return SfCartesianChart(
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
            Column(
              children: statsWidget,
            ),
            const SizedBox(height: _sectionSpacing),
            // Weekly Pro Heatmap
            _buildWeeklyProHeatmap(counter),
            const SizedBox(height: _sectionSpacing),
            // Monthly Activity
            _buildMonthlyProHeatmap(counter),
            const SizedBox(height: _sectionSpacing),
            const Text(
              "Updates Distribution",
              style: _sectionTitleStyle,
            ),
            const SizedBox(height: 16),
            Center(
              child: chartData.isEmpty
                  ? const Text("No distribution data available")
                  : SfCircularChart(
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
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TapCounterUpdatesPage(
                        name: counterName,
                        counterIndex: widget.index,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history_rounded),
                label: const Text("View All Updates"),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      _showEditCounterDialog(context, counterProvider, counter),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text("Edit"),
                ),
                if (hasAttachedLeaderboard) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _syncingLeaderboard
                        ? null
                        : () =>
                            _syncAttachedLeaderboards(counterProvider, counter),
                    icon: _syncingLeaderboard
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.sync),
                    label: Text(_syncingLeaderboard ? "Syncing..." : "Sync"),
                  ),
                ],
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showLockConfirmationDialog(
                      context, counterProvider, counter),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(
                      counter.isLocked ? Icons.lock_open : Icons.lock_outline),
                  label: Text(counter.isLocked ? "Unlock" : "Lock"),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _showLockConfirmationDialog(BuildContext context,
      CounterProvider counterProvider, TapCounter counter) async {
    final TextEditingController controller = TextEditingController();
    final bool isLocked = counter.isLocked;

    await showDialog(
      context: context,
      builder: (context) {
        String? errorMessage;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("${isLocked ? 'Unlock' : 'Lock'} Counter"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'To confirm, please type the name of the counter: "${counter.name}"',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Enter counter name",
                      errorText: errorMessage,
                    ),
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setState(() => errorMessage = null);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text == counter.name) {
                      counterProvider.toggleCounterLock(widget.index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        buildAppSnackBar(
                          "Counter ${isLocked ? 'Unlocked' : 'Locked'} successfully!",
                          context: context,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        errorMessage = "Name mismatch! Please try again.";
                      });
                    }
                  },
                  child: Text(
                    isLocked ? "Unlock" : "Lock",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditCounterDialog(BuildContext context,
      CounterProvider counterProvider, TapCounter counter) async {
    if (counter.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildAppSnackBar(
          "Please unlock the counter before editing its configuration.",
          context: context,
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: counter.name);
    final stepController =
        TextEditingController(text: counter.stepSize.toString());
    final valueController =
        TextEditingController(text: counter.value.toString());
    bool isIncrement = counter.isIncrement;

    await showDialog(
      context: context,
      builder: (context) {
        String? nameError;
        String? stepError;
        String? valueError;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Counter"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade600),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.amber.shade800, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Caution: Modifying counter configuration may result in data inconsistencies or unintended behavior. Proceed only if you are fully aware of the implications of these changes.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Counter Name",
                        prefixIcon: const Icon(Icons.edit),
                        border: const OutlineInputBorder(),
                        errorText: nameError,
                      ),
                      onChanged: (_) {
                        if (nameError != null) {
                          setState(() => nameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stepController,
                      decoration: InputDecoration(
                        labelText: "Step Size",
                        prefixIcon:
                            const Icon(Icons.add_circle_outline_rounded),
                        border: const OutlineInputBorder(),
                        errorText: stepError,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        if (stepError != null) {
                          setState(() => stepError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: valueController,
                      decoration: InputDecoration(
                        labelText: "Current Value",
                        prefixIcon: const Icon(Icons.looks_one),
                        border: const OutlineInputBorder(),
                        errorText: valueError,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) {
                        if (valueError != null) {
                          setState(() => valueError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.swap_vert, size: 20),
                        const SizedBox(width: 8),
                        const Text("Direction:"),
                        const Spacer(),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: true,
                              label: Text("Increment"),
                              icon: Icon(Icons.add),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text("Decrement"),
                              icon: Icon(Icons.remove),
                            ),
                          ],
                          selected: {isIncrement},
                          onSelectionChanged: (selected) {
                            setState(() => isIncrement = selected.first);
                          },
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final stepText = stepController.text.trim();
                    final valueText = valueController.text.trim();

                    if (name.isEmpty) {
                      setState(() => nameError = "Name cannot be empty.");
                      return;
                    }

                    final parsedStep = int.tryParse(stepText);
                    if (parsedStep == null || parsedStep <= 0) {
                      setState(
                          () => stepError = "Must be a positive whole number.");
                      return;
                    }

                    final parsedValue = num.tryParse(valueText);
                    if (parsedValue == null) {
                      setState(() => valueError = "Must be a valid number.");
                      return;
                    }

                    counter.name = name;
                    counter.stepSize = parsedStep;
                    counter.value = parsedValue;
                    counter.isIncrement = isIncrement;

                    counterProvider.saveCounterMetadata(widget.index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      buildAppSnackBar(
                        "Counter updated successfully.",
                        context: context,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
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

            final String formattedDate = AppConstants.dateFormatMonthDay
                .format(DateTime.parse(dates[index].key));
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

  Widget _buildWeeklyProHeatmap(TapCounter counter) {
    final weeklyData = counter.generateWeeklyHeatmapData();
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
            verticalScrollPhysics: const NeverScrollableScrollPhysics(),
            horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
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

  Widget _buildMonthlyProHeatmap(TapCounter counter) {
    final monthlyData = counter.generateMonthlyHeatmapData();
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
            verticalScrollPhysics: const NeverScrollableScrollPhysics(),
            horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
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
