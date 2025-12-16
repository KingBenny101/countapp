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
  String _selectedRange = "1W"; // Default to 1 week

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
      final ms = entries[i].key.millisecondsSinceEpoch.toDouble();
      spots.add(FlSpot(ms, entries[i].value));
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
    final hasData = lineData.isNotEmpty;

    // compute axis bounds and tick interval (use real timestamps as x)
    // We guard calculations when there is no data so we can still render the
    // rest of the page (stats/cards) and only hide the chart area itself.

    double minX = 0.0;
    double maxX = 1.0;
    final n = lineData.length;
    final tickIndices = <int>[];
    double interval = 1.0;

    if (hasData) {
      minX = lineData.first.x;
      maxX = lineData.length > 1
          ? lineData.last.x
          : lineData.first.x + 1000.0; // +1s if single point

      // limit ticks to a maximum of 4 (and at least 2 if there are points)
      final int tickCount = n <= 4 ? n : 4;
      final int effectiveTickCount = (tickCount <= 1 && n > 0) ? 2 : tickCount;
      interval = (maxX - minX) / (effectiveTickCount - 1);

      if (n > 0) {
        tickIndices.add(0);
        if (n > 2) tickIndices.add(((n - 1) ~/ 2));
        if (n > 1) tickIndices.add(n - 1);
      }
    }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Range:',
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
              const SizedBox(height: 8),
              Container(
                height: 300,
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: hasData ? LineChart(
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
                          reservedSize: 32,
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
                          interval: interval,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            // value is a timestamp (ms since epoch). Format for display.
                            final millis = value.round();
                            final dt =
                                DateTime.fromMillisecondsSinceEpoch(millis);

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
                )
                    : const Center(
                        child: Text(
                          "No data in the selected time range.",
                          style: TextStyle(fontSize: 14),
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
