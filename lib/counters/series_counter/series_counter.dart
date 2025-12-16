import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/counters/series_counter/series_counter_statistics.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hive_ce/hive.dart";
import "package:intl/intl.dart";
import "package:uuid/uuid.dart";

part "series_counter.g.dart";

/// A counter that stores a series of numeric values over time
@HiveType(typeId: 2)
class SeriesCounter extends BaseCounter {
  SeriesCounter({
    String? id,
    required this.name,
    required this.value,
    this.description = "",
    this.lastUpdated,
    super.updates,
    List<double>? seriesValues,
  })  : id = id ?? const Uuid().v4(),
        updates = updates ?? (lastUpdated != null ? [lastUpdated] : []),
        seriesValues = seriesValues ?? [],
        super(
          id: id ?? const Uuid().v4(),
          name: name,
          value: value,
          lastUpdated: lastUpdated,
        );

  /// Create SeriesCounter from JSON
  factory SeriesCounter.fromJson(Map<String, dynamic> json) {
    final DateTime? lastUpdated = json["lastUpdated"] != null
        ? DateTime.parse(json["lastUpdated"] as String)
        : null;

    return SeriesCounter(
      id: json["id"] as String?,
      name: json["name"] as String,
      value: (json["value"] as num).toDouble(),
      description: json["description"] as String? ?? "",
      lastUpdated: lastUpdated,
      updates: (json["updates"] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          (lastUpdated != null ? [lastUpdated] : []),
      seriesValues: (json["seriesValues"] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }

  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  String name;

  @HiveField(2)
  @override
  num value;

  @HiveField(3)
  @override
  DateTime? lastUpdated;

  @HiveField(4)
  @override
  List<DateTime> updates;

  /// List of all values in the series
  @HiveField(5)
  List<double> seriesValues;

  /// Optional description for the counter
  @HiveField(6)
  String description;

  @override
  String get counterType => "series";

  @override
  Future<bool> onInteraction(BuildContext context) async {
    final result = await _showInputDialog(context);
    if (result == null) return false;

    // Update with new value
    value = result;
    seriesValues.insert(0, result);

    final now = DateTime.now();
    lastUpdated = now;
    updates.insert(0, now);

    return true;
  }

  @override
  Widget buildIcon() {
    return CircleAvatar(
      backgroundColor: getColor(),
      child: const Icon(
        Icons.show_chart,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  @override
  String getSubtitle() {
    if (seriesValues.isEmpty) {
      return "No values recorded";
    }
    return description;
  }

  @override
  Color getColor() => Colors.deepPurple;

  @override
  Map<String, dynamic> toJson() {
    return {
      "counterType": counterType,
      "id": id,
      "name": name,
      "value": value,
      "description": description,
      "lastUpdated": lastUpdated?.toIso8601String(),
      "updates": updates.map((e) => e.toIso8601String()).toList(),
      "seriesValues": seriesValues,
    };
  }


  /// Show input dialog for entering a new number
  Future<double?> _showInputDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final lastUpdatedParsed = lastUpdated != null
        ? DateFormat("E, MMM d, yyyy hh:mm a").format(lastUpdated!)
        : "Never";

    final double? result = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter New Value"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Last Updated: $lastUpdatedParsed",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: "Value",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                  ],
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a value";
                    }
                    if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final value = double.parse(controller.text);
                  Navigator.of(context).pop(value);
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    return result;
  }

  /// Calculate weekly average
  double getWeeklyAverage() {
    if (seriesValues.isEmpty) return 0.0;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekValues = <double>[];
    for (int i = 0; i < updates.length && i < seriesValues.length; i++) {
      if (updates[i].isAfter(weekAgo)) {
        weekValues.add(seriesValues[i]);
      }
    }

    if (weekValues.isEmpty) return 0.0;
    return weekValues.reduce((a, b) => a + b) / weekValues.length;
  }

  /// Calculate monthly average
  double getMonthlyAverage() {
    if (seriesValues.isEmpty) return 0.0;

    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final monthValues = <double>[];
    for (int i = 0; i < updates.length && i < seriesValues.length; i++) {
      if (updates[i].isAfter(monthAgo)) {
        monthValues.add(seriesValues[i]);
      }
    }

    if (monthValues.isEmpty) return 0.0;
    return monthValues.reduce((a, b) => a + b) / monthValues.length;
  }

  /// Get weekly high
  double getWeeklyHigh() {
    if (seriesValues.isEmpty) return 0.0;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekValues = <double>[];
    for (int i = 0; i < updates.length && i < seriesValues.length; i++) {
      if (updates[i].isAfter(weekAgo)) {
        weekValues.add(seriesValues[i]);
      }
    }

    if (weekValues.isEmpty) return 0.0;
    return weekValues.reduce((a, b) => a > b ? a : b);
  }

  /// Get weekly low
  double getWeeklyLow() {
    if (seriesValues.isEmpty) return 0.0;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekValues = <double>[];
    for (int i = 0; i < updates.length && i < seriesValues.length; i++) {
      if (updates[i].isAfter(weekAgo)) {
        weekValues.add(seriesValues[i]);
      }
    }

    if (weekValues.isEmpty) return 0.0;
    return weekValues.reduce((a, b) => a < b ? a : b);
  }

  /// Get all time highest value
  double getAllTimeHighest() {
    if (seriesValues.isEmpty) return 0.0;
    return seriesValues.reduce((a, b) => a > b ? a : b);
  }

  /// Get all time lowest value
  double getAllTimeLowest() {
    if (seriesValues.isEmpty) return 0.0;
    return seriesValues.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget? getStatisticsPage(int index) {
    return SeriesCounterStatisticsPage(index: index);
  }
}
