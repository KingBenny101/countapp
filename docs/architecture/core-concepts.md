# Core Concepts

Understanding the fundamental concepts behind Count App's architecture and design.

## The Counter Abstraction

At the heart of Count App is the concept of **counters as polymorphic objects**. Each counter is an instance of a class that extends the abstract `BaseCounter` class.

### Why Abstraction?

```mermaid
graph TD
    A[User wants to track something] --> B{What kind of counting?}
    B -->|Simple tap| C[TapCounter]
    B -->|Requires confirmation| D[TapCounter with confirmation]
    B -->|Future: Long press| E[LongPressCounter]
    B -->|Future: Gesture| F[SwipeCounter]

    C --> G[All extend BaseCounter]
    D --> G
    E --> G
    F --> G

    G --> H[Uniform interface for UI]
    H --> I[Easy to add new types]

    style G fill:#e1f5ff
```

**Benefits**:

- **Extensibility**: Add new counter types without changing existing code
- **Consistency**: All counters behave predictably
- **Maintainability**: Changes to base behavior propagate automatically
- **Testability**: Mock and test through common interface

## State Management

### Provider Pattern

Count App uses the Provider pattern for reactive state management:

```mermaid
sequenceDiagram
    participant UI as UI Widget
    participant Provider as CounterProvider
    participant Model as Counter Model
    participant Storage as Hive Storage

    UI->>Provider: Read counters
    Provider-->>UI: List<BaseCounter>

    UI->>Provider: updateCounter(index)
    Provider->>Model: onInteraction()
    Model-->>Provider: Updated
    Provider->>Storage: Persist
    Provider->>Provider: notifyListeners()
    Provider-->>UI: Rebuild with new state
```

**Key Principles**:

1. **Single Source of Truth**: Provider holds the authoritative state
2. **Reactive Updates**: UI rebuilds automatically on state changes
3. **Separation of Concerns**: Business logic in provider, presentation in widgets
4. **Immutability**: State changes create new references for change detection

### State Lifecycle

```dart
// 1. Provider initialization
final provider = Provider.of<CounterProvider>(context);

// 2. Load state from storage
await provider.loadCounters();

// 3. Update state
await provider.updateCounter(context, index);

// 4. Notify listeners (automatic)
// UI rebuilds with new state
```

## Data Persistence

### Hive CE Storage

Hive CE provides **NoSQL box-based storage** with type-safe serialization:

```mermaid
graph LR
    A[Counter Object] -->|TypeAdapter| B[Binary Data]
    B -->|Storage| C[Hive Box]
    C -->|TypeAdapter| D[Counter Object]

    style B fill:#e1ffe1
    style C fill:#e1ffe1
```

**Why Hive?**

- **Type Safety**: Generated adapters prevent serialization errors
- **Performance**: Binary format is fast and compact
- **Cross-Platform**: Works identically on all platforms
- **No Dependencies**: Pure Dart, no native code
- **Simple API**: Boxes work like key-value stores

### Type Adapters

Type adapters bridge the gap between Dart objects and binary storage:

```dart
@HiveType(typeId: 1)
class TapCounter extends BaseCounter {
  @HiveField(0)
  final int stepSize;

  @HiveField(1)
  final bool isIncrement;

  // ... more fields
}

// Generated adapter handles serialization
class TapCounterAdapter extends TypeAdapter<TapCounter> {
  @override
  TapCounter read(BinaryReader reader) { /* ... */ }

  @override
  void write(BinaryWriter writer, TapCounter obj) { /* ... */ }
}
```

**Type IDs**:

- Must be **unique** per type
- **Immutable** once in production
- Used to identify types during deserialization

## Factory Pattern

The `CounterFactory` enables **dynamic type instantiation** from JSON:

```dart
static BaseCounter fromJson(Map<String, dynamic> json) {
  final type = json["counterType"] as String?;

  switch (type) {
    case "tap":
      return TapCounter.fromJson(json);
    case "long_press":
      return LongPressCounter.fromJson(json);
    // More types...
    default:
      throw ArgumentError("Unknown counter type: $type");
  }
}
```

**Usage Pattern**:

```mermaid
graph LR
    A[JSON Data] -->|CounterFactory| B{Determine Type}
    B -->|"type: tap"| C[TapCounter]
    B -->|"type: long_press"| D[LongPressCounter]
    B -->|Unknown| E[Exception]

    C --> F[BaseCounter Instance]
    D --> F

    style B fill:#fff4e1
```

**Benefits**:

- Decouples deserialization from specific types
- Centralizes type registration
- Easy to extend with new types

## Counter Lifecycle

### Creation

```mermaid
graph TD
    A[User taps Add] --> B[Select Counter Type]
    B --> C[Fill Configuration Form]
    C --> D[Validate Input]
    D -->|Valid| E[Create Counter Instance]
    D -->|Invalid| C
    E --> F[Add to Provider]
    F --> G[Persist to Hive]
    G --> H[UI Updates]

    style E fill:#e1f5ff
```

### Update

```mermaid
graph TD
    A[User taps Counter] --> B[counter.onInteraction]
    B --> C{Needs Confirmation?}
    C -->|Yes| D[Show Dialog]
    C -->|No| E[Update Value]
    D -->|Confirmed| E
    D -->|Cancelled| F[Return false]
    E --> G[Update lastUpdated]
    G --> H[Add to updates list]
    H --> I[Return true]
    I --> J[Provider persists]
    J --> K[UI rebuilds]

    style E fill:#e1ffe1
```

### Deletion

```mermaid
graph TD
    A[User selects Counter] --> B[Tap Delete]
    B --> C[Confirm Deletion]
    C -->|Yes| D[Remove from Provider]
    C -->|No| A
    D --> E[Delete from Hive]
    E --> F[Notify Listeners]
    F --> G[UI Updates]
```

## Data Flow Architecture

### Unidirectional Data Flow

```mermaid
graph TB
    A[User Action] --> B[Event Handler]
    B --> C[Provider Method]
    C --> D[Update State]
    D --> E[Persist to Storage]
    E --> F[Notify Listeners]
    F --> G[UI Rebuilds]
    G --> H[Display New State]

    style C fill:#ffe1e1
    style D fill:#ffe1e1
```

**Rules**:

1. **Actions** trigger state changes through providers
2. **State** is updated in one place (provider)
3. **Persistence** happens automatically
4. **UI** reacts to state changes

### Read vs Write Operations

**Read Operations** (Fast):

```dart
// Direct access, no async
final counters = Provider.of<CounterProvider>(context).counters;
final counter = counters[index];
```

**Write Operations** (Async):

```dart
// Async for persistence
await provider.addCounter(counter);
await provider.updateCounter(context, index);
await provider.removeCounter(index);
```

## JSON Serialization

### Export Format

Counters are exported as JSON arrays:

```json
{
  "version": "1.4.0",
  "exportDate": "2025-12-10T15:30:00.000Z",
  "counters": [
    {
      "counterType": "tap",
      "id": "uuid-1",
      "name": "Water Intake",
      "value": 8,
      "stepSize": 1,
      "isIncrement": true,
      "requireConfirmation": true,
      "lastUpdated": "2025-12-10T15:30:00.000Z",
      "updates": ["2025-12-10T15:30:00.000Z", "2025-12-10T14:20:00.000Z"]
    }
  ]
}
```

### Import Process

```mermaid
sequenceDiagram
    participant User
    participant FilePicker
    participant ImportService
    participant Factory
    participant Provider
    participant Hive

    User->>FilePicker: Select JSON file
    FilePicker-->>ImportService: File path
    ImportService->>ImportService: Read & parse JSON
    ImportService->>Factory: fromJson() for each counter
    Factory-->>ImportService: Counter instances
    ImportService->>Provider: Replace counters
    Provider->>Hive: Clear & save all
    Provider->>Provider: notifyListeners()
    Provider-->>User: Success message
```

## Update Tracking

### Update History

Each counter maintains a chronological history:

```dart
List<DateTime> updates = [
  DateTime(2025, 12, 10, 15, 30),  // Most recent
  DateTime(2025, 12, 10, 14, 20),
  DateTime(2025, 12, 09, 18, 45),
  // ... older updates
];
```

**Usage**:

- Statistics calculations
- Chart generation
- Activity patterns
- History display

### Statistics Computation

Using the `DateStatistics` utility class:

```dart
// Group by day
final byDay = DateStatistics.groupUpdatesByDay(updates);

// Count frequency
final frequency = DateStatistics.countDaysByUpdateFrequency(updates);

// Calculate averages
final avgPerDay = DateStatistics.calculateAverageUpdatesPerDay(updates);

// Find patterns
final mostActive = DateStatistics.findMostActiveTimeWindow(updates);
```

## Theme System

### Dynamic Theming

```mermaid
graph LR
    A[System Theme] -->|Detect| B[ThemeNotifier]
    A2[User Toggle] -->|Update| B
    B -->|Notify| C[MaterialApp]
    C -->|Apply| D[Light Theme]
    C -->|Apply| E[Dark Theme]
    D --> F[UI]
    E --> F

    B -->|Persist| G[Hive Settings]

    style B fill:#ffe1e1
```

**Features**:

- Auto-detect system theme
- Manual toggle
- Persisted preference
- Smooth transitions

## Error Handling

### Validation Layers

```mermaid
graph TD
    A[User Input] --> B[UI Validation]
    B -->|Valid| C[Model Validation]
    B -->|Invalid| D[Show Error]
    C -->|Valid| E[Persist]
    C -->|Invalid| D
    E -->|Success| F[Update UI]
    E -->|Error| G[Show Error & Rollback]

    style C fill:#fff4e1
```

**Validation Points**:

1. **UI Level**: Form validators, input formatters
2. **Model Level**: `validate()` method
3. **Storage Level**: Hive type checking

### Error Recovery

```dart
try {
  await provider.updateCounter(context, index);
} catch (e) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Error: $e")),
  );
  // State remains unchanged
}
```

## Performance Optimization

### Efficient Rendering

**ListView.builder**:

```dart
// Only builds visible items
ListView.builder(
  itemCount: counters.length,
  itemBuilder: (context, index) {
    return CounterTile(counter: counters[index]);
  },
)
```

**Selective Rebuilds**:

```dart
// Only rebuild when counters change
Consumer<CounterProvider>(
  builder: (context, provider, child) {
    return CounterList(counters: provider.counters);
  },
)
```

### Lazy Loading

```dart
// Hive boxes opened only when needed
Future<Box> _getBox() async {
  _box ??= await Hive.openBox(AppConstants.countersBox);
  return _box!;
}
```

## Migration Strategy

### Backward Compatibility

Supporting old data formats:

```dart
factory TapCounter.fromJson(Map<String, dynamic> json) {
  // Support multiple field names
  bool isInc;
  if (json.containsKey("type")) {
    isInc = json["type"] == "increment";  // Old format
  } else if (json.containsKey("direction")) {
    isInc = json["direction"] == "increment";  // Older format
  } else {
    isInc = json["isIncrement"] as bool;  // Current format
  }
  // ...
}
```

### Migration Process

```mermaid
graph TD
    A[App Start] --> B{Old Data Exists?}
    B -->|No| C[Normal Start]
    B -->|Yes| D[Run Migration]
    D --> E[Convert Old Format]
    E --> F[Save New Format]
    F --> G[Clear Old Data]
    G --> C

    style D fill:#fff4e1
    style E fill:#fff4e1
```

## Key Takeaways

1. **Abstraction** enables extensibility and maintainability
2. **Provider** manages state reactively and predictably
3. **Hive** provides fast, type-safe persistence
4. **Factory** pattern enables dynamic type creation
5. **Validation** happens at multiple layers for robustness
6. **Performance** is optimized through lazy loading and selective rendering

## Next Steps

- **[Counter System →](counter-system.md)** - Deep dive into counter architecture
- **[State Management →](state-management.md)** - Provider pattern details
- **[Data Persistence →](data-persistence.md)** - Hive storage internals
