import "package:flutter/material.dart";

Widget buildStepCard(String step) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        step,
        style: const TextStyle(fontSize: 16),
      ),
    ),
  );
}

Widget buildInfoCard(String infoName, String infoValue) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            infoName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            infoValue,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}

Widget buildCustomListTile(DateTime date) {
  return Column(
    children: [
      ListTile(
        title: Text(
          date.toLocal().toString(),
        ),
      ),
      const Divider(
        indent: 16,
        endIndent: 16,
      ),
    ],
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
