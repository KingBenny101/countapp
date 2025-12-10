# BaseCounter API Reference

`BaseCounter` is the abstract base class that all counter types must extend. It defines the contract for counter behavior and provides common functionality.

## Class Definition

```dart
abstract class BaseCounter {
  BaseCounter({
    required this.id,
    required this.name,
    required this.value,
    this.lastUpdated,
    List<DateTime>? updates,
  }) : updates = updates ?? [];

  // Properties and methods...
}
```

**Location**: `lib/counters/base/base_counter.dart`

**Package**: `countapp`

## Properties

### id

```dart
final String id;
```

Unique identifier for this counter instance, typically a UUID v4.

- **Type**: `String`
- **Required**: Yes
- **Immutable**: Yes
- **Generated**: Automatically via `Uuid().v4()` if not provided

**Example**:

```dart
"a1b2c3d4-e5f6-7890-abcd-ef1234567890"
```

---

### name

```dart
String name;
```

Display name of the counter shown in the UI.

- **Type**: `String`
- **Required**: Yes
- **Mutable**: Yes (can be renamed)
- **Validation**: Must not be empty

**Example**:

```dart
"Daily Water Intake"
```

---

### value

```dart
int value;
```

Current count value of the counter.

- **Type**: `int`
- **Required**: Yes
- **Mutable**: Yes (updated by interactions)
- **Default**: User-specified initial value

**Example**:

```dart
42
```

---

### lastUpdated

```dart
DateTime? lastUpdated;
```

Timestamp of the most recent update to this counter.

- **Type**: `DateTime?`
- **Required**: No
- **Nullable**: Yes
- **Updated**: Automatically on each interaction

**Example**:

```dart
DateTime(2025, 12, 10, 15, 30, 0)
```

---

### updates

```dart
List<DateTime> updates;
```

Complete history of all update timestamps in reverse chronological order (newest first).

- **Type**: `List<DateTime>`
- **Required**: No (defaults to empty list or `[lastUpdated]`)
- **Order**: Newest first
- **Usage**: Statistics, charts, history

**Example**:

```dart
[
  DateTime(2025, 12, 10, 15, 30),
  DateTime(2025, 12, 10, 14, 20),
  DateTime(2025, 12, 09, 18, 45),
]
```

## Abstract Properties

These must be implemented by subclasses:

### counterType

```dart
String get counterType;
```

Unique type identifier for this counter implementation.

- **Type**: `String` (getter)
- **Required**: Yes
- **Immutable**: Yes
- **Usage**: Serialization, factory pattern, type identification

**Example Implementation**:

```dart
@override
String get counterType => "tap";
```

**Naming Convention**: Use lowercase with underscores (e.g., `"tap"`, `"long_press"`, `"swipe"`).

## Abstract Methods

These must be implemented by subclasses:

### onInteraction

```dart
Future<bool> onInteraction(BuildContext context);
```

Handles user interaction with the counter. This is the core update logic.

**Parameters**:

- `context` (`BuildContext`): Flutter build context for showing dialogs, snackbars, etc.

**Returns**: `Future<bool>`

- `true`: Counter was successfully updated
- `false`: Update was cancelled or failed

**Responsibilities**:

- Show confirmation dialogs if needed
- Update `value` based on counter logic
- Update `lastUpdated` timestamp
- Add to `updates` list
- Return success/failure status

**Example Implementation**:

```dart
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
```

!!! warning "State Management"
Don't call `notifyListeners()` here. The `CounterProvider` handles state notifications after persistence.

---

### buildIcon

```dart
Widget buildIcon();
```

Builds the icon widget displayed in the counter list.

**Returns**: `Widget` - Icon representation of this counter type

**Responsibilities**:

- Create distinctive icon for counter type
- Use `getColor()` for consistent theming
- Return a widget (typically `CircleAvatar` with an `Icon`)

**Example Implementation**:

```dart
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
```

**Best Practices**:

- Use Material Icons
- Size icon appropriately (24-32px)
- Ensure good contrast
- Keep it simple and recognizable

---

### getSubtitle

```dart
String getSubtitle();
```

Returns the subtitle text displayed under the counter name.

**Returns**: `String` - Descriptive subtitle showing counter configuration

**Responsibilities**:

- Show relevant configuration details
- Keep text concise
- Provide useful information at a glance

**Example Implementation**:

```dart
@override
String getSubtitle() {
  final sign = isIncrement ? "+" : "-";
  return "Step Size: $sign$stepSize";
}
```

**Examples**:

- `"Step Size: +5"`
- `"Hold 500ms • Step: +1"`
- `"Swipe Left/Right • ±10"`

---

### getColor

```dart
Color getColor();
```

Returns the color used for this counter type in the UI.

**Returns**: `Color` - Theme color for this counter type

**Responsibilities**:

- Choose distinctive color per counter type
- Ensure accessibility (sufficient contrast)
- Use Material Design colors

**Example Implementation**:

```dart
@override
Color getColor() => Colors.blueAccent;
```

**Color Palette Suggestions**:

- `Colors.blueAccent` - Tap Counter
- `Colors.deepPurple` - Long Press Counter
- `Colors.green` - Swipe Counter
- `Colors.orange` - Time-based Counter

---

### toJson

```dart
Map<String, dynamic> toJson();
```

Serializes the counter to JSON format for persistence and export.

**Returns**: `Map<String, dynamic>` - JSON representation

**Responsibilities**:

- Include `counterType` for factory deserialization
- Serialize all properties
- Convert `DateTime` to ISO 8601 strings
- Handle nested objects

**Example Implementation**:

```dart
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
```

**JSON Schema Example**:

```json
{
  "counterType": "tap",
  "id": "uuid-here",
  "name": "Water Intake",
  "value": 8,
  "stepSize": 1,
  "isIncrement": true,
  "requireConfirmation": true,
  "lastUpdated": "2025-12-10T15:30:00.000",
  "updates": ["2025-12-10T15:30:00.000", "2025-12-10T14:20:00.000"]
}
```

## Virtual Methods

These have default implementations but can be overridden:

### validate

```dart
bool validate();
```

Validates the counter's configuration.

**Returns**: `bool`

- `true`: Counter is valid
- `false`: Counter has invalid configuration

**Default Implementation**:

```dart
bool validate() {
  return name.isNotEmpty;
}
```

**Override Example**:

```dart
@override
bool validate() {
  return super.validate() && stepSize > 0 && stepSize <= 1000;
}
```

**Validation Rules**:

- Always call `super.validate()`
- Add type-specific validation
- Check ranges and constraints
- Return false for invalid state

---

### getStatisticsPage

```dart
Widget? getStatisticsPage(int index);
```

Returns a custom statistics page for this counter type, or null for default behavior.

**Parameters**:

- `index` (`int`): Counter's index in the provider list

**Returns**: `Widget?`

- Custom statistics widget
- `null` to use default statistics or no statistics

**Default Implementation**:

```dart
Widget? getStatisticsPage(int index) {
  return null; // No custom statistics
}
```

**Override Example**:

```dart
@override
Widget? getStatisticsPage(int index) {
  return TapCounterStatisticsPage(counter: this, index: index);
}
```

## Constructor Pattern

Typical constructor implementation:

```dart
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
```

**Key Points**:

- Generate UUID if `id` not provided
- Initialize `updates` list appropriately
- Call `super()` with base properties
- Use named parameters
- Provide sensible defaults

## Factory Pattern

Each counter must have a `fromJson` factory:

```dart
factory TapCounter.fromJson(Map<String, dynamic> json) {
  // Parse DateTime fields
  final DateTime? lastUpdated = json["lastUpdated"] != null
      ? DateTime.parse(json["lastUpdated"] as String)
      : null;

  return TapCounter(
    id: json["id"] as String?,
    name: json["name"] as String,
    value: json["value"] as int,
    stepSize: json["stepSize"] as int,
    isIncrement: json["isIncrement"] as bool,
    requireConfirmation: json["requireConfirmation"] as bool? ?? true,
    lastUpdated: lastUpdated,
    updates: (json["updates"] as List<dynamic>?)
            ?.map((e) => DateTime.parse(e as String))
            .toList() ??
        (lastUpdated != null ? [lastUpdated] : []),
  );
}
```

**Best Practices**:

- Handle null values with defaults
- Parse DateTime strings correctly
- Support backward compatibility
- Use type casts safely (`as`, `as?`)

## Usage Examples

### Creating a Counter

```dart
final counter = TapCounter(
  name: "Daily Steps",
  value: 0,
  stepSize: 100,
  isIncrement: true,
  lastUpdated: DateTime.now(),
);
```

### Updating a Counter

```dart
final success = await counter.onInteraction(context);
if (success) {
  // Persist to storage
  await provider.saveCounter(index, counter);
}
```

### Serialization

```dart
// To JSON
final json = counter.toJson();
final jsonString = jsonEncode(json);

// From JSON
final decoded = jsonDecode(jsonString);
final counter = CounterFactory.fromJson(decoded);
```

### Validation

```dart
if (counter.validate()) {
  await provider.addCounter(counter);
} else {
  showErrorDialog("Invalid counter configuration");
}
```

## See Also

- [CounterFactory](counter-factory.md) - Dynamic counter instantiation
- [TapCounter](tap-counter.md) - Concrete implementation example
- [Adding Counter Types](../guides/adding-counter-types.md) - Implementation guide
- [Architecture](../architecture/counter-system.md) - System design

## Related Types

- `CounterProvider` - State management for counters
- `DateStatistics` - Utility for date-based analytics
- `Uuid` - ID generation

## Version History

| Version | Changes                                                |
| ------- | ------------------------------------------------------ |
| 1.4.0   | Added `getStatisticsPage()` for polymorphic statistics |
| 1.3.0   | Refactored to abstract base class pattern              |
| 1.2.0   | Added `updates` list for history tracking              |
| 1.0.0   | Initial implementation                                 |
