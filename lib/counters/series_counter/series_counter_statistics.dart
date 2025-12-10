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
      case "1W":
        cutoffDate = now.subtract(const Duration(days: 7));
      case "1M":
        cutoffDate = now.subtract(const Duration(days: 30));
      case "3M":
        cutoffDate = now.subtract(const Duration(days: 90));
      case "1Y":
        cutoffDate = now.subtract(const Duration(days: 365));
      case "All":
        cutoffDate = DateTime(1970); // Far past date to include all
      default:
        cutoffDate = now.subtract(const Duration(days: 30));
    }

    final spots = <FlSpot>[];
    int spotIndex = 0;
    
    for (int i = _counter.updates.length - 1; i >= 0; i--) {
      if (_counter.updates[i].isAfter(cutoffDate)) {
        spots.add(FlSpot(
          spotIndex.toDouble(),
          _counter.seriesValues[i].toDouble(),
        ));
        spotIndex++;
      }
    }
    
    return spots;
  }

  List<DateTime> _getFilteredDates() {
    if (_counter.updates.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoffDate;
    
    switch (_selectedRange) {
      case "1W":
        cutoffDate = now.subtract(const Duration(days: 7));
      case "1M":
        cutoffDate = now.subtract(const Duration(days: 30));
      case "3M":
        cutoffDate = now.subtract(const Duration(days: 90));
      case "1Y":
        cutoffDate = now.subtract(const Duration(days: 365));
      case "All":
        cutoffDate = DateTime(1970);
      default:
        cutoffDate = now.subtract(const Duration(days: 30));
    }

    final filteredDates = <DateTime>[];
    for (int i = _counter.updates.length - 1; i >= 0; i--) {
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
    final weeklyAvg = _counter.getWeeklyAverage();
    final monthlyAvg = _counter.getMonthlyAverage();
    final weeklyHigh = _counter.getWeeklyHigh();
    final weeklyLow = _counter.getWeeklyLow();
    final allTimeHigh = _counter.getAllTimeHighest();
    final allTimeLow = _counter.getAllTimeLowest();

    return Scaffold(
      appBar: AppBar(title: Text("Statistics for $_counterName")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Value Trend",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
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
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: lineData,
                        isCurved: true,
                        color: Colors.deepPurple,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.deepPurple.withOpacity(0.3),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            final filteredDates = _getFilteredDates();
                            if (index < 0 || index >= filteredDates.length) {
                              return const Text("");
                            }
                            final date = filteredDates[index];
                            return RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                DateFormat("MM/dd").format(date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: const FlGridData(show: true),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Statistics",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
