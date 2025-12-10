import "package:countapp/counters/base/base_counter.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:intl/intl.dart";
import "package:uuid/uuid.dart";

part "tap_counter.g.dart";

/// Direction for tap counter updates
@HiveType(typeId: 2)
enum TapDirection {
  @HiveField(0)
  increment,
  @HiveField(1)
  decrement,
}

/// A counter that updates on tap with configurable step size and direction
@HiveType(typeId: 1)
class TapCounter extends BaseCounter {
  /// Step size for each update
  @HiveField(0)
  final int stepSize;

  /// Direction of updates (increment or decrement)
  @HiveField(1)
  final TapDirection direction;

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
  int value;

  @HiveField(6)
  @override
  DateTime? lastUpdated;

  @HiveField(7)
  @override
  List<DateTime> updates;

  TapCounter({
    String? id,
    required this.name,
    required this.value,
    required this.stepSize,
    required this.direction,
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

  @override
  String get counterType => "tap";

  @override
  Future<bool> onInteraction(BuildContext context) async {
    if (requireConfirmation) {
      final confirmed = await _showConfirmationDialog(context);
      if (!confirmed) return false;
    }

    // Update logic
    if (direction == TapDirection.increment) {
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
        direction == TapDirection.increment ? Icons.add : Icons.remove,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  @override
  String getSubtitle() {
    final sign = direction == TapDirection.increment ? "+" : "-";
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
      "direction": direction.name,
      "requireConfirmation": requireConfirmation,
      "lastUpdated": lastUpdated?.toIso8601String(),
      "updates": updates.map((e) => e.toIso8601String()).toList(),
    };
  }

  /// Create TapCounter from JSON with backward compatibility
  factory TapCounter.fromJson(Map<String, dynamic> json) {
    // Backward compatibility with old format
    TapDirection dir;
    if (json.containsKey("type")) {
      // Old format: "type": "increment" or "decrement"
      dir = json["type"] == "increment"
          ? TapDirection.increment
          : TapDirection.decrement;
    } else {
      // New format: "direction": "increment" or "decrement"
      dir = json["direction"] == "increment"
          ? TapDirection.increment
          : TapDirection.decrement;
    }

    final DateTime? lastUpdated = json["lastUpdated"] != null
        ? DateTime.parse(json["lastUpdated"] as String)
        : null;

    return TapCounter(
      id: json["id"] as String?,
      name: json["name"] as String,
      value: json["value"] as int,
      stepSize: json["stepSize"] as int,
      direction: dir,
      requireConfirmation: json["requireConfirmation"] as bool? ?? true,
      lastUpdated: lastUpdated,
      updates: (json["updates"] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          (lastUpdated != null ? [lastUpdated] : []),
    );
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
            "${direction == TapDirection.increment ? 'Increase' : 'Decrease'} the $name Counter by $stepSize? \nLast Updated: $lastUpdatedParsed",
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
}
