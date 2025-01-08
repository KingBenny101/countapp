import "package:countapp/providers/counter_provider.dart";
import "package:countapp/screens/all_updates.dart";
import "package:countapp/utils/statistics.dart";
import "package:countapp/utils/widgets.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";

class InfoPage extends StatefulWidget {
  const InfoPage({super.key, required this.index});
  final int index;

  @override
  InfoPageState createState() => InfoPageState();
}

class InfoPageState extends State<InfoPage> {
  final int _numberOfDates = 7;
  late CounterProvider _counterProvider;
  late String _counterName;
  late List<DateTime> _updatesData;
  late List<Widget> _statsWidget;
  late List<MapEntry<String, int>> _updatesPerDay;
  late int _indexOfEndDate;

  @override
  void initState() {
    super.initState();
    _counterProvider = Provider.of<CounterProvider>(context, listen: false);
    _counterName = _counterProvider.counters[widget.index].name;
    _updatesData = _counterProvider.counters[widget.index].updates;
    final updateStatistics = generateUpdateStatistics(_updatesData);
    _statsWidget = generateStatsWidgets(updateStatistics);

    _updatesPerDay = Map<String, int>.fromEntries(
      (updateStatistics[7] as Map<String, int>).entries.toList()
        ..sort(
          (MapEntry<String, int> a, MapEntry<String, int> b) =>
              a.key.compareTo(b.key),
        ),
    ).entries.toList();

    _indexOfEndDate = _updatesPerDay.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final int startIndex =
        (_indexOfEndDate - _numberOfDates + 1).clamp(0, _updatesPerDay.length);

    final int endIndex = (_indexOfEndDate + 1).clamp(0, _updatesPerDay.length);

    final plotData = _updatesPerDay.sublist(startIndex, endIndex);

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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: _statsWidget,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllUpdatesPage(
                      name: _counterName,
                      data: _updatesData,
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

  List<Widget> generateStatsWidgets(List<dynamic> stats) {
    final stats0 = stats[0] as double;
    final stats1 = stats[1] as String;
    final stats2 = stats[2] as int;
    final stats3 = stats[3] as String;
    final stats4 = stats[4] as double;
    final stats5 = stats[5] as double;
    final stats6 = stats[6] as String;
    final stats8 = stats[8] as double;

    return [
      buildInfoCard("Average Updates per Day", stats0.toStringAsFixed(2)),
      buildInfoCard("Most Updates Day", stats1),
      buildInfoCard("Most Updates Count", stats2.toString()),
      buildInfoCard("Time with the Most Updates", stats3),
      buildInfoCard("Most Updates during", stats6),
      buildInfoCard(
        "Average over the Last 7 Days",
        stats4.toStringAsFixed(2),
      ),
      buildInfoCard("Average over the Last 30 Days", stats8.toStringAsFixed(2)),
      buildInfoCard("Days with No Updates", "${stats5.toStringAsFixed(2)}%"),
    ];
  }
}
