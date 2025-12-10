import "dart:convert";
import "dart:io";

import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/counters/base/counter_factory.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/permissions.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:toastification/toastification.dart";

Future<void> exportJSON(String exportFilePath) async {
  final bool hasPermission = await checkAndRequestStoragePermission();

  if (hasPermission) {
    final box = await Hive.openBox(AppConstants.countersBox);
    final file = File(exportFilePath);
    final counters = box.values.toList();
    final jsonCounters = json.encode(counters);

    await file.writeAsString(jsonCounters);

    toastification.show(
      type: ToastificationType.success,
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.simple,
      title: const Text("Counters Exported Successfully!"),
      autoCloseDuration: const Duration(seconds: 2),
      closeOnClick: true,
    );
  } else {
    toastification.show(
      type: ToastificationType.error,
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.simple,
      title: const Text("No permission!"),
      autoCloseDuration: const Duration(seconds: 2),
    );
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
    // If it's already a counter object, convert to JSON
    if (data is BaseCounter) {
      return data.toJson();
    }
    // Otherwise, use factory to parse and re-serialize
    return CounterFactory.fromJson(data as Map<String, dynamic>).toJson();
  }).toList();

  await box.clear();
  await box.addAll(counters);
  await counterProvider.loadCounters();
}
