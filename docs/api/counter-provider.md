# CounterProvider API Reference

`CounterProvider` is the state management provider for counters, handling loading, saving, and updates.

## Class Definition

```dart
class CounterProvider with ChangeNotifier {
  List<BaseCounter> _counters = [];
  Box? _box;

  List<BaseCounter> get counters => _counters;
}
```

**Location**: `lib/providers/counter_provider.dart`

**Pattern**: Provider (ChangeNotifier)

## Properties

### counters

```dart
List<BaseCounter> get counters => _counters;
```

Read-only access to the current list of counters.

- **Type**: `List<BaseCounter>`
- **Usage**: Access via `Provider.of<CounterProvider>(context).counters`

## Methods

### loadCounters

```dart
Future<void> loadCounters() async
```

Loads all counters from Hive storage using the factory pattern.

**Example**:

```dart
await provider.loadCounters();
```

### addCounter

```dart
Future<void> addCounter(BaseCounter counter) async
```

Adds a new counter to the list and persists to storage.

**Parameters**:

- `counter` (`BaseCounter`): Counter to add

**Side Effects**:

- Adds to `_counters` list
- Persists to Hive box
- Calls `notifyListeners()`

### updateCounter

```dart
Future<void> updateCounter(BuildContext context, int index) async
```

Triggers counter interaction and persists changes if successful.

**Parameters**:

- `context` (`BuildContext`): For showing dialogs/snackbars
- `index` (`int`): Index of counter in list

**Behavior**:

1. Calls `counter.onInteraction(context)`
2. If successful, persists to storage
3. Notifies listeners
4. Shows success snackbar

### removeCounter

```dart
Future<void> removeCounter(int index) async
```

Removes a single counter at the specified index.

### removeCounters

```dart
Future<void> removeCounters(List<int> indices) async
```

Removes multiple counters efficiently.

**Note**: Indices are sorted in reverse to prevent shifting issues.

## Usage Examples

### Loading Counters

```dart
final provider = Provider.of<CounterProvider>(context, listen: false);
await provider.loadCounters();
```

### Adding a Counter

```dart
final newCounter = TapCounter(
  name: "Water",
  value: 0,
  stepSize: 1,
  isIncrement: true,
);

await provider.addCounter(newCounter);
```

### Updating a Counter

```dart
await provider.updateCounter(context, 0);
```

### Accessing Counters

```dart
Consumer<CounterProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.counters.length,
      itemBuilder: (context, index) {
        final counter = provider.counters[index];
        return ListTile(title: Text(counter.name));
      },
    );
  },
)
```

## See Also

- [BaseCounter](base-counter.md)
- [State Management](../architecture/state-management.md)
