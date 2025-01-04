import 'package:countapp/providers/counter_provider.dart';
import 'package:countapp/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget {
  final int index;

  const InfoPage({super.key, required this.index});

  @override
  InfoPageState createState() => InfoPageState();
}

class InfoPageState extends State<InfoPage> {
  final int numberOfDates = 7;
  late CounterProvider counterProvider;
  late int index;
  late String counterName;
  late List<DateTime> updatesData;
  late List<Widget> statsWidget;
  late List<MapEntry<String, int>> updatesPerDay;
  late int indexOfEndDate;

  @override
  void initState() {
    super.initState();
    counterProvider = Provider.of<CounterProvider>(context, listen: false);
    index = widget.index;
    counterName = counterProvider.counters[index].name;
    updatesData = counterProvider.counters[index].updates;
    final updateStatistics = generateUpdateStatistics(updatesData);
    statsWidget = generateStatsWidgets(updateStatistics);

    updatesPerDay = Map<String, int>.fromEntries(
      updateStatistics[7].entries.toList()
        ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
            a.key.compareTo(b.key)),
    ).entries.toList();

    indexOfEndDate = updatesPerDay.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    int startIndex =
        (indexOfEndDate - numberOfDates + 1).clamp(0, updatesPerDay.length);

    int endIndex = (indexOfEndDate + 1).clamp(0, updatesPerDay.length);

    final plotData = updatesPerDay.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(title: Text('Info for $counterName')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        indexOfEndDate -= numberOfDates;

                        if (indexOfEndDate < 0) {
                          indexOfEndDate += numberOfDates;
                        }
                      });
                    },
                    child: const Text('Previous')),
                const SizedBox(width: 30),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        indexOfEndDate += numberOfDates;

                        if (indexOfEndDate >= updatesPerDay.length) {
                          indexOfEndDate = updatesPerDay.length - 1;
                        }
                      });
                    },
                    child: const Text('Next')),
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
                            toY: plotData[index].value.toDouble(), width: 16)
                      ],
                    );
                  }),
                ),
              ),
            ),
            // Info cards section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: statsWidget,
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData customAxisTitles(List<MapEntry<String, int>> dates) {
    return FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (double value, TitleMeta meta) {
            if (value % 1 == 0) {
              // Show only integer values
              return Align(
                alignment:
                    Alignment.centerRight, // Align titles closer to the axis
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 0.0), // Adjust the padding
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }
            return const SizedBox(); // Hide non-integer values
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index < 0 || index >= dates.length) {
              return Container(); // Return an empty container if out of range
            }

            // Format the date to "MM/dd"
            String formattedDate =
                DateFormat('MMM dd').format(DateTime.parse(dates[index].key));
            return RotatedBox(
              quarterTurns: 3,
              child: Text(
                formattedDate,
                style: TextStyle(fontSize: 12),
              ),
            );
          },
          reservedSize: 45,
        ),
      ),
    );
  }

  List<Widget> generateStatsWidgets(List<dynamic> stats) {
    return [
      buildInfoCard("Average Updates per Day", stats[0].toStringAsFixed(2)),
      buildInfoCard("Most Updates Day", stats[1]),
      buildInfoCard("Most Updates Count", stats[2].toString()),
      buildInfoCard("Time with the Most Updates", stats[3]),
      buildInfoCard("Most Updates during", stats[6]),
      buildInfoCard(
          "Average over the Last 7 Days", stats[4].toStringAsFixed(2)),
      buildInfoCard("Days with No Updates", '${stats[5].toStringAsFixed(2)}%'),
    ];
  }
}
