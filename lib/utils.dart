import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

import 'models/counter_model.dart';
import 'providers/counter_provider.dart';

Widget buildStepCard(String step) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        step,
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}

Future<void> exportJSON(String exportDirPath) async {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd_HH-mm-ss');
  final exportFilePath = '$exportDirPath/counters_${formatter.format(now)}.json';
  final box = await Hive.openBox<Counter>('countersBox');
  final file = File(exportFilePath);
  final events = box.values.toList();
  final jsonEvents = json.encode(events);

  await file.writeAsString(jsonEvents);
}

Future<void> importJSON(CounterProvider counterProvider, importFilePath) async {
  final box = await Hive.openBox<Counter>('countersBox');
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
