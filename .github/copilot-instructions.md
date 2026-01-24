# Countapp Copilot Instructions

## Project Overview

**Countapp** is an unnecessarily complex Flutter counter application featuring multiple counter types, leaderboard integration, theme customization, and statistics tracking. The app uses provider pattern for state management and Hive for local persistence.

## Architecture & Key Components

### Counter Type System (Polymorphic)

- **Base class**: [BaseCounter](lib/counters/base/base_counter.dart) - Abstract class defining counter interface
- **Types**:
  - `TapCounter` ([lib/counters/tap_counter/](lib/counters/tap_counter/)) - Simple increment/decrement with configurable step size and confirmation dialog
  - `SeriesCounter` ([lib/counters/series_counter/](lib/counters/series_counter/)) - Tracks multiple values over time with charting
- **Factory pattern**: [CounterFactory](lib/counters/base/counter_factory.dart) creates instances from JSON, handles backward compatibility with old format ("type" field → "tap" counter)
- **Adding new counter types**: Register in `CounterFactory._registry` map, create Hive adapter with unique `typeId`

### State Management & Persistence

- **Provider**: [CounterProvider](lib/providers/counter_provider.dart) - `ChangeNotifierProvider` managing counter list via Hive
  - CRUD operations: `addCounter()`, `removeCounter()`, `updateCounter()`
  - Hive box: "counters" (persists serialized JSON)
  - Auto-posts to leaderboard if `leaderboardAutoPostSetting` enabled
- **Models**:
  - [CounterModel](lib/models/counter_model.dart) - Legacy model (for migration reference)
  - [Leaderboard](lib/models/leaderboard.dart) - Leaderboard entry/score models with Hive adapters
- **Hive storage**: Three boxes: "counters", "settings", "leaderboards"

### Data Flow

```
User Action → HomePageUI → CounterProvider.updateCounter()
→ BaseCounter.onInteraction() → counter.value updated
→ Hive box.putAt() → Provider notifies listeners → UI rebuilds
→ (optional) auto-post to LeaderboardService
```

### Leaderboard Integration

- [LeaderboardService](lib/services/leaderboard_service.dart) - Static methods posting scores to Google Sheets API
- Endpoint: Google Apps Script macro (hardcoded URL in service)
- Requires internet connectivity check via `connectivity_plus` before API calls
- Returns `Map<String, dynamic>` with `success`, `leaderboard`, `message` keys
- Data flow: counter.value → `counterType` & value posted → API returns leaderboard data → cached in Hive

### Theming System

- [ThemeNotifier](lib/theme/theme_notifier.dart) - `ChangeNotifierProvider` managing theme state
- Supports 6 themes: blue, purple, green, red, orange, pink
- Persists in settings box: `themeModeSetting` (light/dark/system), `currentThemeSetting` (theme name)
- Updates system UI overlay on build

### Navigation & Screens

- Named routes in [main.dart](lib/main.dart): `/updates`, `/options`, `/about`, `/leaderboards`
- Key screens: [HomePage](lib/screens/home_page.dart), [OptionsPage](lib/screens/options_page.dart), [LeaderboardsPage](lib/screens/leaderboards_page.dart)
- Stats page support: `BaseCounter.getStatisticsPage(index)` returns widget if implemented (TapCounter has [TapCounterStatistics](lib/counters/tap_counter/tap_counter_statistics.dart))

## Code Patterns & Conventions

### Dart/Flutter Best Practices

- **Imports**: Use relative imports within lib (`import "package:countapp/..."`), absolute elsewhere
- **Null safety**: Strict typing with required/nullable fields (SDK >=3.3.3)
- **Naming**: Double quotes preferred, constructors first in class, prefer explicit types
- **Analysis**: Uses `package:lint/strict.yaml` with custom rules (sort_constructors_first, prefer_double_quotes)
- **Auto-generated files**: Excluded from analysis (`**.g.dart`, `**.freezed.dart`), generated via `build_runner`

### Hive Serialization Pattern

```dart
@HiveType(typeId: N)
class MyModel {
  @HiveField(0) String name;
  @HiveField(1) int value;

  factory MyModel.fromJson(Map<String, dynamic> json) { /*...*/ }
  Map<String, dynamic> toJson() { /*...*/ }
}
```

- Each model needs adapter with unique typeId
- Both fromJson/toJson AND Hive adapters required for dual serialization support
- Adapters auto-generated via `hive_ce_generator` (part "file.g.dart")

### Migration Strategy

- [migration.dart](lib/utils/migration.dart) - One-time data migration on app startup
- Old counter format: `{"type": "increment", "value": 5, ...}` → new: `{"counterType": "tap", "value": 5, ...}`
- Factory.fromJson() detects old format via field presence and maps to appropriate type

### UI Utilities

- [widgets.dart](lib/utils/widgets.dart) - Custom widgets and common UI utilities
- [statistics.dart](lib/utils/statistics.dart) - Analytics/statistics calculations
- Icons via `font_awesome_flutter` and Material `Icons`

## Build & Development

### Commands

- **Get dependencies**: `flutter pub get` or `flutter pub upgrade`
- **Code generation**: `dart run build_runner build` (generates .g.dart files)
- **Generate launcher icons**: `dart run flutter_launcher_icons` (iOS/Android/Windows)
- **Type checking**: `dart analyze` (runs strict linter rules)
- **Format**: `dart format lib/` (uses double-quote preference)

### Key Dependencies

- **State**: `provider` (ChangeNotifier pattern)
- **Persistence**: `hive_ce` (embedded database), `hive_ce_flutter` (Flutter support)
- **UI**: Material Design, `fl_chart` (charts), `syncfusion_flutter_charts`
- **Networking**: `http`, `connectivity_plus` (check online status)
- **Utilities**: `uuid` (ID generation), `intl` (i18n/date formatting), `url_launcher`

## Important Patterns

### Counter Interaction Pattern

Every counter subclass must implement:

- `onInteraction(BuildContext context)` - Async method returning success bool (user may cancel)
- `buildIcon()` - Returns display icon
- `getSubtitle()` - Returns step info text
- `getColor()` - Returns Material color
- `toJson()` / `fromJson()` - Serialization

### Leaderboard Attachment

- Leaderboards can attach to counters via `attachedCounterId` field
- When counter deleted, all attached leaderboards are detached: `CounterProvider._detachLeaderboards()`
- Auto-post fires if counter `onInteraction()` succeeds and setting enabled

### Error Handling

- `BaseCounter.onInteraction()` returns false for user cancellation (no data update)
- `LeaderboardService` returns success/message map; check `success` bool before using leaderboard data
- Validation: `BaseCounter.validate()` checks non-empty name before operations

## Documentation

Full technical docs available in [mkdocs.yml](mkdocs.yml) → https://kingbenny101.github.io/countapp/

## When Adding Features

1. New counter type? Create in `lib/counters/{type}/`, implement BaseCounter, register in factory, add Hive adapter with unique typeId
2. New settings? Add key to AppConstants, read/write to settingsBox in Hive, wire through ThemeNotifier or new provider
3. New screen? Add route in main.dart, create file in lib/screens/, use existing providers via Consumer/Provider
4. Local storage? Use Hive boxes (declared in main.dart), register adapters before openBox()
5. API call? Follow LeaderboardService pattern: check connectivity, handle Map response, persist in Hive
