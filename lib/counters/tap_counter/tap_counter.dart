import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/counters/tap_counter/tap_counter_statistics.dart";
import "package:countapp/utils/statistics.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:intl/intl.dart";
import "package:uuid/uuid.dart";

part "tap_counter.g.dart";

/// A counter that updates on tap with configurable step size and direction
@HiveType(typeId: 1)
class TapCounter extends BaseCounter {
  TapCounter({
    String? id,
    required this.name,
    required this.value,
    required this.stepSize,
    required this.isIncrement,
    this.requireConfirmation = true,
    this.lastUpdated,
    List<DateTime>? updates,
  })  : id = id ?? const Uuid().v4(),
        updates = updates ?? (lastUpdated != null ? [lastUpdated] : []),
        super(
          id: id ?? const Uuid().v4(),
          name: name,
          value: value,
          lastUpdated: lastUpdated,
          updates: updates,
        );

  /// Create TapCounter from JSON with backward compatibility
  factory TapCounter.fromJson(Map<String, dynamic> json) {
    // Backward compatibility with old format
    bool isInc;
    if (json.containsKey("type")) {
      // Old format: "type": "increment" or "decrement"
      isInc = json["type"] == "increment";
    } else if (json.containsKey("direction")) {
      // Old format: "direction": "increment" or "decrement"
      isInc = json["direction"] == "increment";
    } else {
      // New format: "isIncrement": true or false
      isInc = json["isIncrement"] as bool? ?? true;
    }

    final DateTime? lastUpdated = json["lastUpdated"] != null
        ? DateTime.parse(json["lastUpdated"] as String)
        : null;

    return TapCounter(
      id: json["id"] as String?,
      name: json["name"] as String,
      value: json["value"] as int,
      stepSize: json["stepSize"] as int,
      isIncrement: isInc,
      requireConfirmation: json["requireConfirmation"] as bool? ?? true,
      lastUpdated: lastUpdated,
      updates: (json["updates"] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          (lastUpdated != null ? [lastUpdated] : []),
    );
  }

  /// Step size for each update
  @HiveField(0)
  final int stepSize;

  /// Direction of updates (true = increment, false = decrement)
  @HiveField(1)
  final bool isIncrement;

  /// Whether to show confirmation dialog before updating
  @HiveField(2)
  final bool requireConfirmation;

  @HiveField(3)
  @override
  final String id;

  @HiveField(4)
  @override
  String name;

  @HiveField(5)
  @override
  num value;

  @HiveField(6)
  @override
  DateTime? lastUpdated;

  @HiveField(7)
  @override
  List<DateTime> updates;

  @override
  String get counterType => "tap";

  @override
  Future<bool> onInteraction(BuildContext context) async {
    if (requireConfirmation) {
      final confirmed = await _showConfirmationDialog(context);
      if (!confirmed) return false;
    }

    // Update logic
    if (isIncrement) {
      value += stepSize;
    } else {
      value -= stepSize;
    }

    final now = DateTime.now();
    lastUpdated = now;
    updates.insert(0, now);

    return true;
  }

  @override
  Widget buildIcon() {
    return CircleAvatar(
      backgroundColor: getColor(),
      child: Icon(
        isIncrement ? Icons.add : Icons.remove,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  @override
  String getSubtitle() {
    final sign = isIncrement ? "+" : "-";
    return "Step Size: $sign$stepSize";
  }

  @override
  Color getColor() => Colors.blueAccent;

  @override
  Map<String, dynamic> toJson() {
    return {
      "counterType": counterType,
      "id": id,
      "name": name,
      "value": value,
      "stepSize": stepSize,
      "isIncrement": isIncrement,
      "requireConfirmation": requireConfirmation,
      "lastUpdated": lastUpdated?.toIso8601String(),
      "updates": updates.map((e) => e.toIso8601String()).toList(),
    };
  }

  @override
  bool validate() {
    return super.validate() && stepSize > 0;
  }

  /// Show confirmation dialog before updating
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    final lastUpdatedParsed = lastUpdated != null
        ? DateFormat("E, MMM d, yyyy hh:mm a").format(lastUpdated!)
        : "Never";

    final bool? confirmUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Update"),
          content: Text(
            "${isIncrement ? 'Increase' : 'Decrease'} the $name Counter by $stepSize? \nLast Updated: $lastUpdatedParsed",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    return confirmUpdate ?? false;
  }

  /// Generate statistics widgets for TapCounter
  List<Widget> generateStatisticsWidgets() {
    if (updates.isEmpty) {
      return [
        const Center(
          child: Text("No statistics available - no updates yet"),
        ),
      ];
    }

    // Calculate basic statistics using generic utilities
    final updatesPerDay = DateStatistics.groupUpdatesByDay(updates);
    final totalDays = DateStatistics.calculateTotalDays(updates);

    final avgUpdatesPerDay =
        DateStatistics.calculateAverageUpdatesPerDay(updates, totalDays);

    final mostUpdatesDayData = DateStatistics.findMostUpdatesDay(updatesPerDay);
    final mostUpdatesDay = mostUpdatesDayData[0] as String;
    final mostUpdatesCount = mostUpdatesDayData[1] as int;

    final avgLast7Days =
        DateStatistics.calculateAverageLastNDays(updatesPerDay, 7);
    final avgLast30Days =
        DateStatistics.calculateAverageLastNDays(updatesPerDay, 30);

    final percentNoUpdates = DateStatistics.calculatePercentDaysWithNoUpdates(
        updatesPerDay, totalDays);

    // Calculate most active time windows
    final window60 = DateStatistics.findMostActiveTimeWindow(updates, 60);
    final window180 = DateStatistics.findMostActiveTimeWindow(updates, 180);
    final window360 = DateStatistics.findMostActiveTimeWindow(updates, 360);
    final window720 = DateStatistics.findMostActiveTimeWindow(updates, 720);
    final window1080 = DateStatistics.findMostActiveTimeWindow(updates, 1080);
    final window1440 = DateStatistics.findMostActiveTimeWindow(updates, 1440);

    // Build widgets
    return [
      buildInfoCard(
        "Average Updates per Day",
        avgUpdatesPerDay.toStringAsFixed(2),
      ),
      buildInfoCard("Most Updates Day", mostUpdatesDay),
      buildInfoCard("Most Updates Count", mostUpdatesCount.toString()),
      buildInfoCard(
        "Average over the Last 7 Days",
        avgLast7Days.toStringAsFixed(2),
      ),
      buildInfoCard(
        "Average over the Last 30 Days",
        avgLast30Days.toStringAsFixed(2),
      ),
      buildInfoCard(
        "Days with No Updates",
        "${percentNoUpdates.toStringAsFixed(2)}%",
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeWindowCard("1h Max", window60),
          _buildTimeWindowCard("3h Max", window180),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeWindowCard("6h Max", window360),
          _buildTimeWindowCard("12h Max", window720),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeWindowCard("18h Max", window1080),
          _buildTimeWindowCard("24h Max", window1440),
        ],
      ),
    ];
  }

  /// Build a summary card for time window statistics
  Widget _buildTimeWindowCard(String title, TimeWindowResult window) {
    final parts = window.toFormattedString().split("|");
    return buildSummaryCard(
      title: title,
      count: parts[0],
      date: parts[1],
      timeRange: parts[2],
    );
  }

  /// Get updates per day map for chart display
  Map<String, int> getUpdatesPerDay() {
    return DateStatistics.groupUpdatesByDay(updates);
  }

  /// Get days per update count map for histogram
  Map<int, int> getDaysPerUpdateCount() {
    final updatesPerDay = DateStatistics.groupUpdatesByDay(updates);
    return DateStatistics.countDaysByUpdateFrequency(updatesPerDay);
  }

  @override
  Widget? getStatisticsPage(int index) {
    return TapCounterStatisticsPage(index: index);
  }
}
