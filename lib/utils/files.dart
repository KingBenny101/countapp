import "dart:convert";
import "dart:io";

import "package:countapp/counters/base/counter_factory.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/permissions.dart";
import "package:hive_ce/hive.dart";

Future<bool> exportJSON(String exportFilePath) async {
  final bool hasPermission = await checkAndRequestStoragePermission();

  if (hasPermission) {
    final box = await Hive.openBox(AppConstants.countersBox);
    final file = File(exportFilePath);
    final counters = box.values.toList();
    final jsonCounters = json.encode(counters);

    await file.writeAsString(jsonCounters);
    return true;
  } else {
    return false;
  }
}

Future<void> importJSON(
  CounterProvider counterProvider,
  String importFilePath,
) async {
  final box = await Hive.openBox(AppConstants.countersBox);
  final file = File(importFilePath);
  final jsonCounters = await file.readAsString();
  final countersData = json.decode(jsonCounters) as List<dynamic>;

  // Convert each JSON object to BaseCounter using factory
  final List<Map<String, dynamic>> counters = countersData.map((data) {
    // Convert dynamic map to proper Map<String, dynamic>
    final jsonMap = Map<String, dynamic>.from(data as Map);
    // Use factory to parse and re-serialize
    return CounterFactory.fromJson(jsonMap).toJson();
  }).toList();

  await box.clear();
  await box.addAll(counters);
  await counterProvider.loadCounters();
}
