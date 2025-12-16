import "package:countapp/counters/series_counter/series_counter.dart";
import "package:countapp/counters/series_counter/series_counter_updates.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";

class SeriesCounterStatisticsPage extends StatefulWidget {
  const SeriesCounterStatisticsPage({super.key, required this.index});
  final int index;

  @override
  SeriesCounterStatisticsPageState createState() =>
      SeriesCounterStatisticsPageState();
}

class SeriesCounterStatisticsPageState
    extends State<SeriesCounterStatisticsPage> {
  late CounterProvider _counterProvider;
  late SeriesCounter _counter;
  late String _counterName;
  String _selectedRange = "1M"; // Default to 1 month

  // Minimal chart state
  DateTime? _chartFirstDate;
  List<DateTime> _chartDates = [];

  @override
  void initState() {
    super.initState();
    _counterProvider = Provider.of<CounterProvider>(context, listen: false);
    _counter = _counterProvider.counters[widget.index] as SeriesCounter;
    _counterName = _counter.name;
  }

  List<FlSpot> _getLineChartData() {
    if (_counter.seriesValues.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedRange) {
      case "1D":
        cutoffDate = now.subtract(const Duration(days: 1));
        break;
      case "1W":
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case "1M":
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case "3M":
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case "1Y":
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      case "All":
        cutoffDate = DateTime.fromMillisecondsSinceEpoch(0);
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 30));
    }

    // Collect matching updates (date, value) then sort chronologically (oldest -> newest)
    final entries = <MapEntry<DateTime, double>>[];
    for (int i = 0; i < _counter.updates.length; i++) {
      final dt = _counter.updates[i];
      if (dt.isAfter(cutoffDate)) {
        entries.add(MapEntry(dt, _counter.seriesValues[i].toDouble()));
      }
    }

    entries.sort((a, b) => a.key.compareTo(b.key));

    final spots = <FlSpot>[];
    final filteredDates = <DateTime>[];
    for (int i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value));
      filteredDates.add(entries[i].key);
    }

    // Save first date and full date list for label conversion (chronological)
    _chartFirstDate = filteredDates.isNotEmpty ? filteredDates.first : null;
    _chartDates = filteredDates;

    return spots;
  }

  List<DateTime> _getFilteredDates() {
    if (_counter.updates.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedRange) {
      case "1D":
        cutoffDate = now.subtract(const Duration(days: 1));
        break;
      case "1W":
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case "1M":
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case "3M":
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case "1Y":
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      case "All":
        cutoffDate = DateTime.fromMillisecondsSinceEpoch(0);
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 30));
    }

    final filteredDates = <DateTime>[];
    for (int i = 0; i < _counter.updates.length; i++) {
      if (_counter.updates[i].isAfter(cutoffDate)) {
        filteredDates.add(_counter.updates[i]);
      }
    }

    return filteredDates;
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

    // If the selected range filters out all updates, show a helpful message
    if (lineData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Statistics for $_counterName")),
        body: const Center(
          child: Text(
            "No data in the selected time range.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // compute axis bounds and tick indices for bottom axis
    final minX = lineData.first.x;
    final maxX = lineData.length > 1 ? lineData.last.x : lineData.first.x + 1.0;
    final n = lineData.length;
    final tickIndices = <int>[];
    if (n > 0) {
      tickIndices.add(0);
      if (n > 2) tickIndices.add(((n - 1) ~/ 2));
      if (n > 1) tickIndices.add(n - 1);
    }

    final weeklyAvg = _counter.getWeeklyAverage();
    final monthlyAvg = _counter.getMonthlyAverage();
    final weeklyHigh = _counter.getWeeklyHigh();
    final weeklyLow = _counter.getWeeklyLow();
    final allTimeHigh = _counter.getAllTimeHighest();
    final allTimeLow = _counter.getAllTimeLowest();

    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics for $_counterName"),
        actions: [
          IconButton(
            tooltip: 'Last 1 day',
            icon: const Icon(Icons.access_time),
            onPressed: () {
              setState(() {
                _selectedRange = '1D';
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildRangeButton("1D"),
                  _buildRangeButton("1W"),
                  _buildRangeButton("1M"),
                  _buildRangeButton("3M"),
                  _buildRangeButton("1Y"),
                  _buildRangeButton("All"),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LineChart(
                  LineChartData(
                    // Use time-based x axis and automatic y bounds with padding
                    minX: lineData.first.x,
                    maxX: lineData.length > 1
                        ? lineData.last.x
                        : lineData.first.x + 1.0,
                    minY: (() {
                      final ys = lineData.map((s) => s.y).toList();
                      double minY = ys.reduce((a, b) => a < b ? a : b);
                      double maxY = ys.reduce((a, b) => a > b ? a : b);
                      final range = maxY - minY;
                      if (range == 0) {
                        return minY - 1.0;
                      }
                      return minY - range * 0.1;
                    })(),
                    maxY: (() {
                      final ys = lineData.map((s) => s.y).toList();
                      double minY = ys.reduce((a, b) => a < b ? a : b);
                      double maxY = ys.reduce((a, b) => a > b ? a : b);
                      final range = maxY - minY;
                      if (range == 0) {
                        return maxY + 1.0;
                      }
                      return maxY + range * 0.1;
                    })(),
                    lineBarsData: [
                      LineChartBarData(
                        spots: lineData,
                        isCurved:
                            false, // use linear segments to avoid smoothing artifacts
                        dotData:
                            FlDotData(show: true), // show points for clarity
                        color: Colors.deepPurple,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.deepPurple.withOpacity(0.3),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1.0,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) {
                            final idx = value.round();
                            if (_chartDates.isEmpty)
                              return const SizedBox.shrink();
                            if (idx < 0 || idx >= _chartDates.length)
                              return const SizedBox.shrink();

                            // only show labels for the selected tick indices
                            if (!tickIndices.contains(idx))
                              return const SizedBox.shrink();

                            final dt = _chartDates[idx];

                            if (_selectedRange == "1D") {
                              final time = DateFormat("HH:mm").format(dt);
                              final date = DateFormat("dd/MM").format(dt);
                              return SizedBox(
                                width: 80,
                                child: Text(
                                  "$time\n$date",
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              );
                            } else {
                              final date = DateFormat("dd/MM").format(dt);
                              return SizedBox(
                                width: 80,
                                child: Text(
                                  date,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildStatCard("Weekly Average", weeklyAvg.toStringAsFixed(2)),
              _buildStatCard("Monthly Average", monthlyAvg.toStringAsFixed(2)),
              _buildStatCard("Weekly High", weeklyHigh.toStringAsFixed(2)),
              _buildStatCard("Weekly Low", weeklyLow.toStringAsFixed(2)),
              _buildStatCard(
                  "All Time Highest", allTimeHigh.toStringAsFixed(2)),
              _buildStatCard("All Time Lowest", allTimeLow.toStringAsFixed(2)),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeButton(String range) {
    final isSelected = _selectedRange == range;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedRange = range;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurple : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      child: Text(range),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      elevation: 2,
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
