# SeriesCounter API Reference

`SeriesCounter` is a concrete implementation of `BaseCounter` that stores a series of numeric values over time, allowing users to track trends and view statistics.

## Class Definition

```dart
@HiveType(typeId: 2)
class SeriesCounter extends BaseCounter {
  SeriesCounter({
    String? id,
    required this.name,
    required this.value,
    this.description = "",
    this.lastUpdated,
    List<DateTime>? updates,
    List<double>? seriesValues,
  });

  factory SeriesCounter.fromJson(Map<String, dynamic> json);
}
```

**Location**: `lib/counters/series_counter/series_counter.dart`

**Hive TypeId**: `2`

## Properties

### seriesValues

```dart
@HiveField(5)
List<double> seriesValues;
```

List of all numeric values recorded in the series.

- **Type**: `List<double>`
- **Required**: No (defaults to empty list)
- **Storage**: Values stored in chronological order (most recent first)
- **Precision**: Supports decimal values (e.g., `5.5`, `12.75`, `100.2`)

### description

```dart
@HiveField(6)
String description;
```

Optional description for the counter, displayed as subtitle.

- **Type**: `String`
- **Required**: No (defaults to empty string)
- **UI Impact**: Shown as subtitle in counter list
- **Example**: "Daily weight tracking", "Monthly revenue"

### value

```dart
@HiveField(2)
@override
num value;
```

The most recently recorded value in the series.

- **Type**: `num` (supports both int and double)
- **Required**: Yes
- **Behavior**: Updated each time a new value is added

## Methods

### onInteraction

```dart
@override
Future<bool> onInteraction(BuildContext context) async
```

Handles user interaction by showing an input dialog for entering a new numeric value.

**Behavior**:

1. Display input dialog with last update timestamp
2. Accept numeric input (supports decimals)
3. Validate input is a valid number
4. On confirmation:
   - Update `value` to new input
   - Add value to `seriesValues` list (at index 0)
   - Update `lastUpdated` timestamp
   - Add timestamp to `updates` list
5. Return success status

**Example**:

```dart
final success = await counter.onInteraction(context);
if (success) {
  print("New value recorded: ${counter.value}");
}
```

### buildIcon

```dart
@override
Widget buildIcon()
```

Returns a circular avatar with chart icon in deep purple.

**Returns**: `CircleAvatar` with `Icons.show_chart`

### getSubtitle

```dart
@override
String getSubtitle()
```

Returns the subtitle text for display in counter list.

**Returns**:

- If no values recorded: `"No values recorded"`
- If description exists: Returns the description
- If description is empty: Returns empty string

### getColor

```dart
@override
Color getColor()
```

Returns the color associated with series counters.

**Returns**: `Colors.deepPurple`

### toJson

```dart
@override
Map<String, dynamic> toJson()
```

Serializes the counter to JSON format for export.

**Returns**:

```dart
{
  "counterType": "series",
  "id": "uuid-string",
  "name": "Counter Name",
  "value": 123.45,
  "description": "Optional description",
  "lastUpdated": "2024-01-01T12:00:00.000Z",
  "updates": ["2024-01-01T12:00:00.000Z", ...],
  "seriesValues": [123.45, 100.0, 95.5, ...]
}
```

### validate

```dart
@override
bool validate()
```

Validates the counter's configuration.

**Returns**: `true` if name is not empty

## Statistics Methods

### getWeeklyAverage

```dart
double getWeeklyAverage()
```

Calculates the average of values recorded in the last 7 days.

**Returns**: Average value or `0.0` if no values in range

### getMonthlyAverage

```dart
double getMonthlyAverage()
```

Calculates the average of values recorded in the last 30 days.

**Returns**: Average value or `0.0` if no values in range

### getWeeklyHigh

```dart
double getWeeklyHigh()
```

Finds the highest value recorded in the last 7 days.

**Returns**: Highest value or `0.0` if no values in range

### getWeeklyLow

```dart
double getWeeklyLow()
```

Finds the lowest value recorded in the last 7 days.

**Returns**: Lowest value or `0.0` if no values in range

### getAllTimeHighest

```dart
double getAllTimeHighest()
```

Finds the highest value ever recorded.

**Returns**: Highest value or `0.0` if no values

### getAllTimeLowest

```dart
double getAllTimeLowest()
```

Finds the lowest value ever recorded.

**Returns**: Lowest value or `0.0` if no values

### getStatisticsPage

```dart
@override
Widget? getStatisticsPage(int index)
```

Returns the statistics page widget for this counter.

**Returns**: `SeriesCounterStatisticsPage` instance

## UI Components

### SeriesCounterConfigPage

Configuration page for creating a new series counter.

**Location**: `lib/counters/series_counter/series_counter_config.dart`

**Fields**:

- Counter Name (required)
- Description (optional)
- Initial Value (required, supports decimals)

**Action**: Floating Action Button to create counter

### SeriesCounterStatisticsPage

Statistics and visualization page showing value trends and analytics.

**Location**: `lib/counters/series_counter/series_counter_statistics.dart`

**Features**:

- Line chart with time-range filters (1W, 1M, 3M, 1Y, All)
- Statistics cards:
  - Weekly Average
  - Monthly Average
  - Weekly High
  - Weekly Low
  - All Time Highest
  - All Time Lowest
- "View All Updates" button

**Time Range Filters**:

- **1W**: Last 7 days
- **1M**: Last 30 days (default)
- **3M**: Last 90 days
- **1Y**: Last 365 days
- **All**: All recorded values

### SeriesCounterUpdatesPage

Page displaying all recorded values with timestamps in a searchable list.

**Location**: `lib/counters/series_counter/series_counter_updates.dart`

**Features**:

- List of all values with timestamps
- Search functionality (by date or value)
- Format: Value (2 decimal places) | Date/Time

## JSON Format

### Import/Export Format

```json
{
  "counterType": "series",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Daily Weight",
  "value": 75.5,
  "description": "Track my weight daily",
  "lastUpdated": "2024-12-11T08:30:00.000Z",
  "updates": [
    "2024-12-11T08:30:00.000Z",
    "2024-12-10T08:30:00.000Z",
    "2024-12-09T08:30:00.000Z"
  ],
  "seriesValues": [75.5, 76.0, 75.8]
}
```

### Backward Compatibility

The `fromJson` factory handles various formats:

- Supports `value` as either `int` or `num` (converted to double)
- Defaults `description` to empty string if missing
- Handles missing `seriesValues` (defaults to empty list)

## Usage Examples

### Creating a Counter

```dart
final counter = SeriesCounter(
  name: "Body Temperature",
  value: 98.6,
  description: "Track daily temperature",
  seriesValues: [98.6],
  lastUpdated: DateTime.now(),
  updates: [DateTime.now()],
);
```

### Adding to Provider

```dart
await Provider.of<CounterProvider>(context, listen: false)
    .addCounter(counter);
```

### Accessing Statistics

```dart
final weeklyAvg = counter.getWeeklyAverage();
final allTimeHigh = counter.getAllTimeHighest();
print("Weekly average: ${weeklyAvg.toStringAsFixed(2)}");
print("All-time high: ${allTimeHigh.toStringAsFixed(2)}");
```

### Navigation to Statistics

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SeriesCounterStatisticsPage(index: 0),
  ),
);
```

## Related Documentation

- [BaseCounter](base-counter.md) - Base class interface
- [CounterFactory](counter-factory.md) - Factory pattern for counter creation
- [CounterProvider](counter-provider.md) - State management
- [TapCounter](tap-counter.md) - Alternative counter type

## Integration

### Factory Registration

```dart
// In counter_factory.dart
static final Map<String, BaseCounter Function(Map<String, dynamic>)>
    _registry = {
  "series": SeriesCounter.fromJson,
  // ...
};
```

### Type Info

```dart
CounterTypeInfo(
  type: "series",
  name: "Series Counter",
  description: "Track a series of values over time",
  icon: Icons.show_chart,
)
```

### Hive Adapter

Generated via `build_runner`:

```bash
dart run build_runner build
```

Registers as:

```dart
Hive.registerAdapter(SeriesCounterAdapter());
```
