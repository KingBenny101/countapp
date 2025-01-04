import 'package:hive_ce/hive.dart';

part 'counter_model.g.dart'; // Generates the adapter

@HiveType(typeId: 0) // Unique ID for this model
class Counter {
  @HiveField(0) // Index of this field in Hive
  String name;

  @HiveField(1)
  int value;

  @HiveField(2)
  String type;

  @HiveField(3)
  int stepSize;

  @HiveField(4)
  DateTime? lastUpdated;

  @HiveField(5)
  List<DateTime> updates; // New field to track update timestamps

  Counter({
    required this.name,
    required this.value,
    required this.type,
    required this.stepSize,
    required this.lastUpdated,
    List<DateTime>? updates,
  }) : updates = updates ?? (lastUpdated != null ? [lastUpdated] : []);

  // Convert Counter to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'type': type,
      'stepSize': stepSize,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'updates': updates.map((e) => e.toIso8601String()).toList(),
    };
  }

  // Create Counter from JSON
  factory Counter.fromJson(Map<String, dynamic> json) {
    DateTime? lastUpdated = json['lastUpdated'] != null
        ? DateTime.parse(json['lastUpdated'])
        : null;
    return Counter(
      name: json['name'],
      value: json['value'],
      type: json['type'],
      stepSize: json['stepSize'],
      lastUpdated: lastUpdated,
      updates: (json['updates'] as List<dynamic>?)?.map((e) => DateTime.parse(e)).toList() ?? (lastUpdated != null ? [lastUpdated] : []),
    );
  }
}
