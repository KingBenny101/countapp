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

  Counter({
    required this.name,
    required this.value,
    required this.type,
    required this.stepSize,
    required this.lastUpdated,
  });
}
