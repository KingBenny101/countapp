# DateStatistics API Reference

`DateStatistics` provides static utility methods for analyzing `DateTime` data, primarily used for generating charts and insights from counter history.

## Class Definition

```dart
class DateStatistics {
  DateStatistics._(); // Private constructor
}
```

**Location**: `lib/utils/statistics.dart`

## Methods

### groupUpdatesByDay

```dart
static Map<String, int> groupUpdatesByDay(List<DateTime> updates)
```

Groups a list of timestamps by date (YYYY-MM-DD).

**Returns**: `Map<String, int>` where key is date string and value is count.

### findMostActiveTimeWindow

```dart
static TimeWindowResult findMostActiveTimeWindow(
  List<DateTime> updates,
  int windowSizeMinutes,
)
```

Finds the time window of a specified duration with the highest activity density.

**Parameters**:
- `updates`: List of timestamps
- `windowSizeMinutes`: Duration of window (e.g., 60 for 1 hour)

**Returns**: `TimeWindowResult` containing:
- `count`: Number of updates in window
- `windowStart`: Start time
- `windowEnd`: End time

### calculateAverageUpdatesPerDay

```dart
static double calculateAverageUpdatesPerDay(
  List<DateTime> updates,
  int totalDays,
)
```

Calculates basic daily average.

### calculateAverageLastNDays

```dart
static double calculateAverageLastNDays(
  Map<String, int> updatesPerDay,
  int days,
)
```

Calculates moving average over the last N days (e.g., 7-day or 30-day average).

## Usage Example

```dart
final updates = myCounter.updates;

// 1. Group by day
final dailyStats = DateStatistics.groupUpdatesByDay(updates);

// 2. Find busiest hour
final busiestHour = DateStatistics.findMostActiveTimeWindow(updates, 60);

print("Busiest time: ${busiestHour.toFormattedString()}");
// Output: "15|Dec 10, 2025|3:00 PM - 4:00 PM"
```
