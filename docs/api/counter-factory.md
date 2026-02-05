# CounterFactory API Reference

The `CounterFactory` class provides factory methods for dynamically creating counter instances from JSON data.

## Class Definition

```dart
class CounterFactory {
  static BaseCounter fromJson(Map<String, dynamic> json);
  static List<String> getSupportedTypes();
}
```

**Location**: `lib/counters/base/counter_factory.dart`

## Methods

### fromJson

```dart
static BaseCounter fromJson(Map<String, dynamic> json)
```

Creates a counter instance from JSON data by determining the type and delegating to the appropriate constructor.

**Parameters**:

- `json` (`Map<String, dynamic>`): JSON representation of a counter

**Returns**: `BaseCounter` - Concrete counter instance

**Throws**: `ArgumentError` if counter type is unknown

**Example**:

```dart
final json = {
  "counterType": "tap",
  "id": "abc-123",
  "name": "Water",
  "value": 8,
  // ... more fields
};

final counter = CounterFactory.fromJson(json);
// Returns TapCounter instance
```

### getSupportedTypes

```dart
static List<String> getSupportedTypes()
```

Returns a list of all supported counter type identifiers.

**Returns**: `List<String>` - List of type identifiers

**Example**:

```dart
final types = CounterFactory.getSupportedTypes();
// Returns: ["tap", "long_press", ...]
```

## Implementation

The factory uses a switch statement to determine which counter type to instantiate:

```dart
static BaseCounter fromJson(Map<String, dynamic> json) {
  final type = json["counterType"] as String?;

  switch (type) {
    case "tap":
      return TapCounter.fromJson(json);
    case "long_press":
      return LongPressCounter.fromJson(json);
    // Add more types here
    default:
      throw ArgumentError("Unknown counter type: $type");
  }
}
```

## Adding New Counter Types

When adding a new counter type:

1. Import the counter class
2. Add a case to the switch statement
3. Add the type to `getSupportedTypes()`

**Example**:

```dart
import "package:countapp/counters/swipe_counter/swipe_counter.dart";

static BaseCounter fromJson(Map<String, dynamic> json) {
  final type = json["counterType"] as String?;

  switch (type) {
    case "tap":
      return TapCounter.fromJson(json);
    case "swipe":  // New type
      return SwipeCounter.fromJson(json);
    default:
      throw ArgumentError("Unknown counter type: $type");
  }
}
```

## Usage in Provider

The factory is used by `CounterProvider` when loading counters:

```dart
Future<void> loadCounters() async {
  final box = await _getBox();
  _counters = box.values
      .map((json) => CounterFactory.fromJson(
            Map<String, dynamic>.from(json as Map)
          ))
      .toList();
  notifyListeners();
}
```

## See Also

- [BaseCounter](base-counter.md) - Abstract base class
- [TapCounter](tap-counter.md) - Concrete implementation
- [Adding Counter Types](../developers/adding-counter-types.md) - Implementation guide
