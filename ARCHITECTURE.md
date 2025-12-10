# Counter Architecture Refactoring

## Overview

This refactoring introduces a clean, extensible architecture for different counter types. Each counter type is self-contained in a single file with all its logic, UI, and behavior.

## Architecture

### Base Classes (`lib/counters/base/`)

- **`base_counter.dart`**: Abstract base class defining the counter interface
- **`counter_factory.dart`**: Factory for deserializing counters with backward compatibility

### Counter Types (`lib/counters/`)

- **`tap_counter.dart`**: A counter that updates on tap (increment or decrement)
- Future types: `long_press_counter.dart`, `swipe_counter.dart`, etc.

### Key Features

1. **Polymorphic Design**: All counters extend `BaseCounter`
2. **Self-Contained Logic**: Each counter type encapsulates:
   - Update behavior (`onInteraction`)
   - UI presentation (`buildIcon`, `getSubtitle`, `getColor`)
   - Serialization (`toJson`, `fromJson`)
3. **Type-Agnostic UI**: Home page uses counter methods instead of type checks
4. **Backward Compatible**: Old JSON exports can be imported

## Adding New Counter Types

To add a new counter type (e.g., LongPressCounter):

1. **Create counter file** `lib/counters/long_press_counter.dart`:

```dart
@HiveType(typeId: 3) // Use next available typeId
class LongPressCounter extends BaseCounter {
  @HiveField(0)
  final Duration holdDuration;

  // Implement abstract methods
  @override
  String get counterType => 'long_press';

  @override
  Future<bool> onInteraction(BuildContext context) async {
    // Long press specific logic
  }

  @override
  Widget buildIcon() => CircleAvatar(...);

  @override
  String getSubtitle() => 'Hold: ${holdDuration.inSeconds}s';

  // ... rest of implementation
}
```

2. **Register in factory** `lib/counters/base/counter_factory.dart`:

```dart
static final Map<String, BaseCounter Function(Map<String, dynamic>)>
    _registry = {
  "tap": TapCounter.fromJson,
  "long_press": LongPressCounter.fromJson, // Add here
};
```

3. **Create config UI** `lib/screens/counter_creation/long_press_counter_config.dart`

4. **Register in type selection** `lib/screens/counter_creation/counter_type_selection.dart`

5. **Register Hive adapter** in `lib/main.dart`:

```dart
Hive.registerAdapter(LongPressCounterAdapter());
```

6. **Run build_runner**:

```bash
dart run build_runner build --delete-conflicting-outputs
```

That's it! No changes needed to:

- Home page
- Provider
- Export/Import logic
- Info page

## Migration

The app automatically migrates old `Counter` data to new `TapCounter` format on first run via `lib/utils/migration.dart`.

### Old Format (v1.3.9 and earlier):

```json
{
  "name": "My Counter",
  "value": 10,
  "type": "increment",
  "stepSize": 1,
  ...
}
```

### New Format:

```json
{
  "counterType": "tap",
  "id": "uuid-here",
  "name": "My Counter",
  "value": 10,
  "direction": "increment",
  "stepSize": 1,
  ...
}
```

## Benefits

1. **Easy to extend**: New counter types = 1 new file
2. **Type-safe**: No string comparisons
3. **Maintainable**: Logic localized to counter class
4. **Testable**: Each counter can be unit tested independently
5. **Clean UI code**: No conditional logic based on type
