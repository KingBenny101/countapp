# Adding New Counter Types

This comprehensive guide walks you through creating a new counter type in Count App. The app's extensible architecture makes it straightforward to add custom counter implementations.

## Overview

Adding a new counter type involves:

1. Creating a counter class that extends `BaseCounter`
2. Implementing required methods and properties
3. Adding Hive persistence annotations
4. Creating UI pages (config, statistics, updates)
5. Registering the counter type in the factory
6. Generating code and testing

## Built-in counters

Count App ships with a set of ready-to-use counter types. The most common are:

- **Tap Counter** — quick increment/decrement counter with configurable step size and confirmation option.
- **Series Counter** — record numeric values (e.g., measurements) with timestamps and view charts/statistics.

These are examples you can follow when creating new types.

## Prerequisites

Before you begin:

- Complete the [Installation](../getting-started/installation.md) guide
- Familiarize yourself with [BaseCounter](../api/base-counter.md) API

## Step-by-Step Guide

### Step 1: Plan Your Counter Type

Define the counter's behavior and properties:

**Example: Long Press Counter**

- Requires long press (500ms+) to update
- Configurable hold duration
- Visual feedback during press
- Haptic feedback on update

**Required Decisions:**

- Type identifier (e.g., "long_press")
- Hive typeId (unique integer, e.g., 3)
- Configuration parameters
- Update trigger mechanism
- Statistics to track

### Step 2: Create Counter Directory

Create a new directory for your counter type:

```bash
lib/counters/long_press_counter/
```

This keeps counter-specific code isolated and maintainable.

### Step 3: Implement the Counter Class

Create the main counter class file:

```dart title="lib/counters/long_press_counter/long_press_counter.dart"
import "package:countapp/counters/base/base_counter.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:uuid/uuid.dart";

part "long_press_counter.g.dart";

/// A counter that requires long press to update
@HiveType(typeId: 3)  // Choose unique typeId
class LongPressCounter extends BaseCounter {
  LongPressCounter({
    String? id,
    required this.name,
    required this.value,
    required this.stepSize,
    required this.holdDuration,
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

  /// Create from JSON
  factory LongPressCounter.fromJson(Map<String, dynamic> json) {
    final DateTime? lastUpdated = json["lastUpdated"] != null
        ? DateTime.parse(json["lastUpdated"] as String)
        : null;

    return LongPressCounter(
      id: json["id"] as String?,
      name: json["name"] as String,
      value: json["value"] as int,
      stepSize: json["stepSize"] as int,
      holdDuration: json["holdDuration"] as int,
      lastUpdated: lastUpdated,
      updates: (json["updates"] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          (lastUpdated != null ? [lastUpdated] : []),
    );
  }

  @HiveField(0)
  final int stepSize;

  @HiveField(1)
  final int holdDuration; // milliseconds

  @HiveField(2)
  @override
  final String id;

  @HiveField(3)
  @override
  String name;

  @HiveField(4)
  @override
  int value;

  @HiveField(5)
  @override
  DateTime? lastUpdated;

  @HiveField(6)
  @override
  List<DateTime> updates;

  @override
  String get counterType => "long_press";

  @override
  Future<bool> onInteraction(BuildContext context) async {
    // Show dialog with long press gesture detector
    final confirmed = await _showLongPressDialog(context);

    if (!confirmed) return false;

    // Update counter
    value += stepSize;
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
        Icons.touch_app,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  @override
  String getSubtitle() {
    return "Hold ${holdDuration}ms • Step: +$stepSize";
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
      "stepSize": stepSize,
      "holdDuration": holdDuration,
      "lastUpdated": lastUpdated?.toIso8601String(),
      "updates": updates.map((e) => e.toIso8601String()).toList(),
    };
  }

  @override
  bool validate() {
    return super.validate() && stepSize > 0 && holdDuration > 0;
  }

  @override
  Widget? getStatisticsPage(int index) {
    // Return custom statistics page if needed
    return null;
  }

  Future<bool> _showLongPressDialog(BuildContext context) async {
    bool wasHeld = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Hold to Update $name"),
          content: GestureDetector(
            onLongPress: () {
              wasHeld = true;
              Navigator.pop(context);
            },
            onLongPressStart: (_) {
              // Visual feedback
            },
            child: Container(
              height: 100,
              alignment: Alignment.center,
              child: const Text("Press and hold..."),
            ),
          ),
        );
      },
    );

    return wasHeld;
  }
}
```

### Step 4: Create Configuration Page

Create a UI for users to configure your counter:

```dart title="lib/counters/long_press_counter/long_press_counter_config.dart"
import "package:countapp/counters/long_press_counter/long_press_counter.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

class LongPressCounterConfigPage extends StatefulWidget {
  const LongPressCounterConfigPage({super.key});

  @override
  LongPressCounterConfigPageState createState() =>
      LongPressCounterConfigPageState();
}

class LongPressCounterConfigPageState
    extends State<LongPressCounterConfigPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  int _stepSize = AppConstants.defaultStepSize;
  int _initialCount = AppConstants.defaultInitialValue;
  int _holdDuration = 500; // Default 500ms

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Long Press Counter")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Counter Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                onChanged: (value) => _name = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Step Size",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: _stepSize.toString(),
                onChanged: (value) {
                  _stepSize = int.tryParse(value) ?? AppConstants.defaultStepSize;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Hold Duration (ms)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                  helperText: "How long to hold (milliseconds)",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: _holdDuration.toString(),
                onChanged: (value) {
                  _holdDuration = int.tryParse(value) ?? 500;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Initial Count",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.looks_one),
                ),
                keyboardType: TextInputType.number,
                initialValue: _initialCount.toString(),
                onChanged: (value) {
                  _initialCount =
                      int.tryParse(value) ?? AppConstants.defaultInitialValue;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final newCounter = LongPressCounter(
              name: _name,
              value: _initialCount,
              stepSize: _stepSize,
              holdDuration: _holdDuration,
              lastUpdated: DateTime.now(),
            );

            Provider.of<CounterProvider>(context, listen: false)
                .addCounter(newCounter);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                buildAppSnackBar("Counter Added Successfully!"),
              );
              Navigator.pop(context);
            }
          }
        },
        tooltip: "Add Counter",
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Step 5: Register in Counter Factory

Update the `CounterFactory` to recognize your new counter type:

```dart title="lib/counters/base/counter_factory.dart"
import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/counters/tap_counter/tap_counter.dart";
import "package:countapp/counters/long_press_counter/long_press_counter.dart";

class CounterFactory {
  static BaseCounter fromJson(Map<String, dynamic> json) {
    final type = json["counterType"] as String?;

    switch (type) {
      case "tap":
        return TapCounter.fromJson(json);
      case "long_press":  // Add your counter type
        return LongPressCounter.fromJson(json);
      default:
        throw ArgumentError("Unknown counter type: $type");
    }
  }

  static List<String> getSupportedTypes() {
    return ["tap", "long_press"];  // Add to list
  }
}
```

### Step 6: Update Type Selection UI

If you have a counter type selection page, update it to include your new type:

```dart title="lib/screens/add_counter_page.dart" hl_lines="8-16"
// In your counter type selection page
final counterTypes = [
  {
    "type": "tap",
    "name": "Tap Counter",
    "icon": Icons.touch_app,
  },
  {
    "type": "long_press",
    "name": "Long Press Counter",
    "icon": Icons.touch_app,
  },
];
```

### Step 7: Generate Code

Generate Hive adapters for your new counter:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This creates:

- `long_press_counter.g.dart` with the `LongPressCounterAdapter`
- Updates `hive_registrar.g.dart` to register the adapter

### Step 8: Update Main Registration

The Hive registrar automatically includes your adapter, but verify in `main.dart`:

```dart title="lib/main.dart"
import "package:countapp/hive_registrar.g.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Automatic registration via generated code
  Hive.registerAdapters();

  // ... rest of initialization
}
```

### Step 9: Test Your Counter

Run comprehensive tests:

```dart title="test/long_press_counter_test.dart"
import "package:countapp/counters/long_press_counter/long_press_counter.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("LongPressCounter", () {
    test("creates with correct properties", () {
      final counter = LongPressCounter(
        name: "Test",
        value: 0,
        stepSize: 5,
        holdDuration: 1000,
      );

      expect(counter.name, "Test");
      expect(counter.value, 0);
      expect(counter.stepSize, 5);
      expect(counter.holdDuration, 1000);
      expect(counter.counterType, "long_press");
    });

    test("serializes to JSON correctly", () {
      final counter = LongPressCounter(
        name: "Test",
        value: 10,
        stepSize: 5,
        holdDuration: 1000,
      );

      final json = counter.toJson();

      expect(json["counterType"], "long_press");
      expect(json["name"], "Test");
      expect(json["value"], 10);
      expect(json["stepSize"], 5);
      expect(json["holdDuration"], 1000);
    });

    test("deserializes from JSON correctly", () {
      final json = {
        "counterType": "long_press",
        "id": "test-id",
        "name": "Test",
        "value": 10,
        "stepSize": 5,
        "holdDuration": 1000,
        "lastUpdated": null,
        "updates": [],
      };

      final counter = LongPressCounter.fromJson(json);

      expect(counter.name, "Test");
      expect(counter.value, 10);
      expect(counter.stepSize, 5);
      expect(counter.holdDuration, 1000);
    });

    test("validates correctly", () {
      final validCounter = LongPressCounter(
        name: "Valid",
        value: 0,
        stepSize: 1,
        holdDuration: 500,
      );
      expect(validCounter.validate(), true);

      final invalidCounter = LongPressCounter(
        name: "",
        value: 0,
        stepSize: 0,
        holdDuration: 0,
      );
      expect(invalidCounter.validate(), false);
    });
  });
}
```

### Step 10: Add Statistics (Optional)

If your counter needs custom statistics:

```dart title="lib/counters/long_press_counter/long_press_counter_statistics.dart"
import "package:countapp/counters/long_press_counter/long_press_counter.dart";
import "package:countapp/utils/statistics.dart";
import "package:flutter/material.dart";

class LongPressCounterStatisticsPage extends StatelessWidget {
  const LongPressCounterStatisticsPage({
    super.key,
    required this.counter,
    required this.index,
  });

  final LongPressCounter counter;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Use DateStatistics utilities
    final stats = DateStatistics.groupUpdatesByDay(counter.updates);

    return Scaffold(
      appBar: AppBar(
        title: Text("${counter.name} Statistics"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildChartCard(stats),
          // Add more custom statistics
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    // Custom statistics implementation
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Updates: ${counter.updates.length}",
              style: const TextStyle(fontSize: 18),
            ),
            // Add more summary stats
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(Map<DateTime, int> stats) {
    // Chart implementation
    return Card(
      child: Container(),
    );
  }
}
```

Then update your counter class:

```dart
@override
Widget? getStatisticsPage(int index) {
  return LongPressCounterStatisticsPage(counter: this, index: index);
}
```

## Files You Need to Modify

Summary of all files involved:

### New Files to Create

| File                                                                 | Purpose                    |
| -------------------------------------------------------------------- | -------------------------- |
| `lib/counters/long_press_counter/long_press_counter.dart`            | Main counter class         |
| `lib/counters/long_press_counter/long_press_counter_config.dart`     | Configuration UI           |
| `lib/counters/long_press_counter/long_press_counter_statistics.dart` | Statistics page (optional) |
| `lib/counters/long_press_counter/long_press_counter_updates.dart`    | Updates history (optional) |
| `test/long_press_counter_test.dart`                                  | Unit tests                 |

### Files to Modify

| File                                     | Changes Required              |
| ---------------------------------------- | ----------------------------- |
| `lib/counters/base/counter_factory.dart` | Add case for new counter type |
| `lib/screens/add_counter_page.dart`      | Add to type selection list    |

### Auto-Generated Files

| File                                                        | Generated By           |
| ----------------------------------------------------------- | ---------------------- |
| `lib/counters/long_press_counter/long_press_counter.g.dart` | build_runner           |
| `lib/hive_registrar.g.dart`                                 | build_runner (updated) |

## Best Practices

### Naming Conventions

```dart
// Good
class TapCounter extends BaseCounter { }
class LongPressCounter extends BaseCounter { }
class SwipeCounter extends BaseCounter { }

// Bad
class Counter1 extends BaseCounter { }
class MyCounter extends BaseCounter { }
```

### Type IDs

Choose unique Hive typeIds:

```dart
// Reserve typeId ranges
// 0: CounterAdapter (legacy)
// 1: TapCounter
// 2: (previously TapDirection, now unused)
// 3-10: Future counter types
// 11-20: Custom adapters
```

### Validation

Always validate in both UI and model:

```dart
@override
bool validate() {
  return super.validate() &&
         stepSize > 0 &&
         holdDuration > 0 &&
         holdDuration < 10000; // Reasonable limits
}
```

### Error Handling

```dart
@override
Future<bool> onInteraction(BuildContext context) async {
  try {
    // Counter logic
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    return false;
  }
}
```

## Advanced Features

### Custom Animations

```dart
@override
Widget buildIcon() {
  return TweenAnimationBuilder(
    tween: Tween<double>(begin: 0.8, end: 1.0),
    duration: const Duration(milliseconds: 300),
    builder: (context, value, child) {
      return Transform.scale(
        scale: value,
        child: CircleAvatar(
          backgroundColor: getColor(),
          child: const Icon(Icons.touch_app),
        ),
      );
    },
  );
}
```

### Platform-Specific Behavior

```dart
import "dart:io";

@override
Future<bool> onInteraction(BuildContext context) async {
  if (Platform.isAndroid || Platform.isIOS) {
    // Mobile-specific behavior
    await HapticFeedback.mediumImpact();
  }
  // Standard behavior
  return true;
}
```

### Custom Serialization

```dart
@override
Map<String, dynamic> toJson() {
  final json = super.toJson();
  json.addAll({
    "customField": _customValue,
    "metadata": {
      "createdAt": _createdAt.toIso8601String(),
      "version": "2.0",
    },
  });
  return json;
}
```

## Troubleshooting

### Issue: Type adapter not found

**Cause**: Code generation not run or adapter not registered

**Solution**:

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Issue: Factory doesn't recognize type

**Cause**: Counter type string mismatch

**Solution**: Ensure `counterType` getter matches factory case:

```dart
@override
String get counterType => "long_press"; // Must match factory
```

### Issue: JSON deserialization fails

**Cause**: Missing fields or type mismatch

**Solution**: Add null safety and defaults:

```dart
factory LongPressCounter.fromJson(Map<String, dynamic> json) {
  return LongPressCounter(
    stepSize: json["stepSize"] as int? ?? 1, // Default value
    // ...
  );
}
```

## Complete Checklist

- [ ] Create counter class extending `BaseCounter`
- [ ] Add Hive annotations with unique typeId
- [ ] Implement all required methods
- [ ] Create configuration page UI
- [ ] Add to `CounterFactory`
- [ ] Run code generation
- [ ] Write unit tests
- [ ] Test serialization/deserialization
- [ ] Test with Hive persistence
- [ ] Add to type selection UI
- [ ] Create statistics page (optional)
- [ ] Document the counter type
- [ ] Update CHANGELOG

## Next Steps

- **[API Reference →](../api/base-counter.md)** - Detailed BaseCounter API

!!! success "Counter Type Added!"
You've successfully added a new counter type! Test thoroughly and consider contributing it back to the project.
