import "dart:convert";
import "dart:io";

import "package:countapp/models/counter_model.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:hive_ce/hive.dart";

Future<void> exportJSON(String exportFilePath) async {
  final box = await Hive.openBox<Counter>("countersBox");
  final file = File(exportFilePath);
  final events = box.values.toList();
  final jsonEvents = json.encode(events);

  await file.writeAsString(jsonEvents);
}

Future<void> importJSON(
    CounterProvider counterProvider, String importFilePath) async {
  final box = await Hive.openBox<Counter>("countersBox");
  final file = File(importFilePath);
  final jsonEvents = await file.readAsString();
  final events = json.decode(jsonEvents) as List<dynamic>;
  final List<Counter> counters = events.map((data) {
    return Counter.fromJson(data as Map<String, dynamic>);
  }).toList();

  await box.clear();
  await box.addAll(counters);
  await counterProvider.loadCounters();
}
