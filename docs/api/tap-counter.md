# TapCounter API Reference

`TapCounter` is a concrete implementation of `BaseCounter` that updates its value when tapped, with configurable step size and direction.

## Class Definition

```dart
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
  });

  factory TapCounter.fromJson(Map<String, dynamic> json);
}
```

**Location**: `lib/counters/tap_counter/tap_counter.dart`

**Hive TypeId**: `1`

## Properties

### stepSize

```dart
@HiveField(0)
final int stepSize;
```

The amount by which the counter value changes on each update.

- **Type**: `int`
- **Required**: Yes
- **Validation**: Must be > 0
- **Example**: `1`, `5`, `10`, `100`

### isIncrement

```dart
@HiveField(1)
final bool isIncrement;
```

Direction of updates. `true` for increment, `false` for decrement.

- **Type**: `bool`
- **Required**: Yes
- **Default**: `true` (increment)
- **Behavior**:
  - `true`: Adds `stepSize` to value
  - `false`: Subtracts `stepSize` from value

### requireConfirmation

```dart
@HiveField(2)
final bool requireConfirmation;
```

Whether to show a confirmation dialog before updating.

- **Type**: `bool`
- **Required**: No
- **Default**: `true`
- **UI Impact**: When `true`, shows dialog before each update

## Methods

### onInteraction

```dart
@override
Future<bool> onInteraction(BuildContext context) async
```

Handles tap interaction, optionally showing confirmation dialog, then updates the counter value.

**Behavior**:

1. Show confirmation dialog if `requireConfirmation` is true
2. Update `value` by `stepSize` (add if increment, subtract if decrement)
3. Update `lastUpdated` timestamp
4. Add timestamp to `updates` list
5. Return success status

**Example**:

```dart
final success = await counter.onInteraction(context);
if (success) {
  print("Counter updated to ${counter.value}");
}
```

### buildIcon

```dart
@override
Widget buildIcon()
```

Returns a blue CircleAvatar with plus or minus icon based on direction.

**Icon Selection**:

- `isIncrement == true`: `Icons.add`
- `isIncrement == false`: `Icons.remove`

### getSubtitle

```dart
@override
String getSubtitle()
```

Returns a string showing step size with direction sign.

**Format**: `"Step Size: +X"` or `"Step Size: -X"`

**Examples**:

- `"Step Size: +1"`
- `"Step Size: -5"`

### getColor

```dart
@override
Color getColor()
```

Returns `Colors.blueAccent` for TapCounter.

### toJson

```dart
@override
Map<String, dynamic> toJson()
```

Serializes the counter to JSON format.

**JSON Schema**:

```json
{
  "counterType": "tap",
  "id": "string",
  "name": "string",
  "value": 0,
  "stepSize": 0,
  "isIncrement": true,
  "requireConfirmation": true,
  "lastUpdated": "ISO8601 string or null",
  "updates": ["ISO8601 strings"]
}
```

### validate

```dart
@override
bool validate()
```

Validates that name is not empty and stepSize is positive.

**Returns**: `true` if valid, `false` otherwise

### getStatisticsPage

```dart
@override
Widget? getStatisticsPage(int index)
```

Returns a `TapCounterStatisticsPage` with detailed analytics.

## Factory Constructor

### fromJson

```dart
factory TapCounter.fromJson(Map<String, dynamic> json)
```

Creates a TapCounter from JSON with backward compatibility.

**Backward Compatibility**:

- Supports old `"type"` field (v1.3.9 and earlier)
- Supports old `"direction"` field (enum format)
- Supports new `"isIncrement"` field (boolean format)

**Example**:

```dart
// Old format (still supported)
final oldJson = {
  "counterType": "tap",
  "type": "increment",  // Old field
  // ...
};

// New format
final newJson = {
  "counterType": "tap",
  "isIncrement": true,  // New field
  // ...
};

final counter1 = TapCounter.fromJson(oldJson);
final counter2 = TapCounter.fromJson(newJson);
```

## Usage Examples

### Creating a Counter

```dart
final counter = TapCounter(
  name: "Daily Steps",
  value: 0,
  stepSize: 100,
  isIncrement: true,
  requireConfirmation: false,
  lastUpdated: DateTime.now(),
);
```

### Increment Counter

```dart
final incrementCounter = TapCounter(
  name: "Glasses of Water",
  value: 0,
  stepSize: 1,
  isIncrement: true,
);
```

### Decrement Counter

```dart
final decrementCounter = TapCounter(
  name: "Days Until Deadline",
  value: 30,
  stepSize: 1,
  isIncrement: false,
);
```

### Quick Update (No Confirmation)

```dart
final quickCounter = TapCounter(
  name: "Quick Count",
  value: 0,
  stepSize: 1,
  isIncrement: true,
  requireConfirmation: false,  // No dialog
);
```

## Statistics Page

The `TapCounterStatisticsPage` provides:

- Daily update frequency chart
- Total updates count
- Average updates per day
- Most active day
- Day-of-week analysis
- Time window analysis
- Update history timeline

Access via:

```dart
final statsPage = counter.getStatisticsPage(index);
Navigator.push(context, MaterialPageRoute(builder: (_) => statsPage!));
```

## See Also

- [BaseCounter](base-counter.md) - Base class documentation
- [CounterFactory](counter-factory.md) - Factory pattern
- [Adding Counter Types](../developers/adding-counter-types.md) - Create custom counters
