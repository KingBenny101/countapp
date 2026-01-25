import "package:countapp/counters/series_counter/series_counter.dart";
import "package:countapp/counters/series_counter/series_counter_updates.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/services/leaderboard_service.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "package:syncfusion_flutter_charts/charts.dart";

class _SeriesDataPoint {
  _SeriesDataPoint(this.date, this.value);
  final DateTime date;
  final double value;
}

class SeriesCounterStatisticsPage extends StatefulWidget {
  const SeriesCounterStatisticsPage({super.key, required this.index});
  final int index;

  @override
  SeriesCounterStatisticsPageState createState() =>
      SeriesCounterStatisticsPageState();
}

class SeriesCounterStatisticsPageState
    extends State<SeriesCounterStatisticsPage> {
  static const double _sectionSpacing = 32.0;
  static const TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  late CounterProvider _counterProvider;
  late SeriesCounter _counter;
  late String _counterName;
  String _selectedRange = "1W"; // Default to 1 week
  bool _syncingLeaderboard = false;

  // Minimal chart state

  @override
  void initState() {
    super.initState();
    _counterProvider = Provider.of<CounterProvider>(context, listen: false);
    _counter = _counterProvider.counters[widget.index] as SeriesCounter;
    _counterName = _counter.name;
  }

  List<_SeriesDataPoint> _getLineChartData() {
    if (_counter.seriesValues.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedRange) {
      case "1D":
        cutoffDate = now.subtract(const Duration(days: 1));
      case "1W":
        cutoffDate = now.subtract(const Duration(days: 7));
      case "1M":
        cutoffDate = now.subtract(const Duration(days: 30));
      case "3M":
        cutoffDate = now.subtract(const Duration(days: 90));
      case "1Y":
        cutoffDate = now.subtract(const Duration(days: 365));
      case "All":
        cutoffDate = DateTime.fromMillisecondsSinceEpoch(0);
      default:
        cutoffDate = now.subtract(const Duration(days: 30));
    }

    // Collect matching updates (date, value) then sort chronologically (oldest -> newest)
    final entries = <_SeriesDataPoint>[];
    for (int i = 0; i < _counter.updates.length; i++) {
      final dt = _counter.updates[i];
      if (dt.isAfter(cutoffDate)) {
        entries.add(_SeriesDataPoint(dt, _counter.seriesValues[i]));
      }
    }

    entries.sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  Future<void> _syncAttachedLeaderboards() async {
    if (_syncingLeaderboard) return;

    setState(() => _syncingLeaderboard = true);

    // Validate index bounds and refresh the counter instance
    if (widget.index < 0 || widget.index >= _counterProvider.counters.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar("Counter no longer exists", success: false),
        );
      }
      setState(() => _syncingLeaderboard = false);
      return;
    }

    _counter = _counterProvider.counters[widget.index] as SeriesCounter;

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
    if (_counter.seriesValues.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Statistics for $_counterName")),
        body: const Center(
          child: Text(
            "No data available yet.\nAdd values to see statistics.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final lineData = _getLineChartData();
    final hasData = lineData.isNotEmpty;
    final bool hasAttachedLeaderboard = LeaderboardService.getAll()
        .any((lb) => lb.attachedCounterId == _counter.id);

    final weeklyAvg = _counter.getWeeklyAverage();
    final monthlyAvg = _counter.getMonthlyAverage();
    final weeklyHigh = _counter.getWeeklyHigh();
    final weeklyLow = _counter.getWeeklyLow();
    final allTimeHigh = _counter.getAllTimeHighest();
    final allTimeLow = _counter.getAllTimeLowest();

    return Scaffold(
      appBar: AppBar(
        title: Text("Info for $_counterName"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "History Profile",
                  style: _sectionTitleStyle,
                ),
                Row(
                  children: [
                    Text(
                      "Range:",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRange,
                        items: <String>["1D", "1W", "1M", "3M", "1Y", "All"]
                            .map((r) => DropdownMenuItem<String>(
                                  value: r,
                                  child: Text(r),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _selectedRange = v;
                          });
                        },
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 350,
              child: hasData
                  ? SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        labelRotation: -65,
                        dateFormat: _selectedRange == "1D"
                            ? DateFormat("HH:mm")
                            : (_selectedRange == "1W" || _selectedRange == "1M")
                                ? DateFormat("MMM d")
                                : DateFormat("dd/MM/yy"),
                        majorGridLines: const MajorGridLines(width: 0.5),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        labelIntersectAction: AxisLabelIntersectAction.rotate45,
                      ),
                      primaryYAxis: const NumericAxis(
                        majorGridLines: MajorGridLines(width: 0.5),
                        axisLine: AxisLine(width: 0),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                      ),
                      trackballBehavior: TrackballBehavior(
                        enable: true,
                        activationMode: ActivationMode.singleTap,
                        tooltipSettings: const InteractiveTooltip(
                          enable: true,
                          format: "point.x : point.y",
                        ),
                        lineType: TrackballLineType.vertical,
                      ),
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true,
                        enablePanning: true,
                        enableDoubleTapZooming: true,
                        zoomMode: ZoomMode.x,
                      ),
                      series: <CartesianSeries<_SeriesDataPoint, DateTime>>[
                        AreaSeries<_SeriesDataPoint, DateTime>(
                          dataSource: lineData,
                          xValueMapper: (point, _) => point.date,
                          yValueMapper: (point, _) => point.value,
                          color: Colors.deepPurple,
                          borderColor: Colors.deepPurple,
                          borderWidth: 3,
                          animationDuration: 1000,
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.withValues(alpha: 0.3),
                              Colors.deepPurple.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            shape: DataMarkerType.circle,
                            height: 4,
                            width: 4,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        "No data in the selected time range.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
            ),
            const SizedBox(height: _sectionSpacing),
            const Text(
              "Key Statistics",
              style: _sectionTitleStyle,
            ),
            const SizedBox(height: 16),
            _buildStatCard("Weekly Average", weeklyAvg.toStringAsFixed(2)),
            _buildStatCard("Monthly Average", monthlyAvg.toStringAsFixed(2)),
            _buildStatCard("Weekly High", weeklyHigh.toStringAsFixed(2)),
            _buildStatCard("Weekly Low", weeklyLow.toStringAsFixed(2)),
            _buildStatCard("All Time Highest", allTimeHigh.toStringAsFixed(2)),
            _buildStatCard("All Time Lowest", allTimeLow.toStringAsFixed(2)),
            const SizedBox(height: _sectionSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeriesCounterUpdatesPage(
                          name: _counterName,
                          updates: _counter.updates,
                          values: _counter.seriesValues,
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

  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
