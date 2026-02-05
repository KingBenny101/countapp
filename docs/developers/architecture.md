# Technical Stack

Count App is built using modern, industry-standard technologies to ensure reliability, performance, and extensibility.

## Core Technologies

### Flutter 3.38.4
**Cross-platform UI framework**

Flutter enables Count App to run natively on Android, Windows, and Linux from a single codebase while maintaining native performance and platform-specific look and feel.

**Key benefits:**
- Hot reload for rapid development
- Beautiful, customizable widgets
- Native performance on all platforms
- Active community and extensive ecosystem

### Dart 3.10.3
**Programming language**

Dart is the language behind Flutter, designed for building fast apps on on any platform.

**Key benefits:**
- Strong typing with null safety
- Async/await for smooth async operations
- Just-in-time and ahead-of-time compilation
- Easy to learn and productive

## Data & State Management

### Hive
**Fast, lightweight local database**

Hive is a pure Dart database that stores data in a binary format for blazing-fast read/write operations.

**Why Hive:**
- No native dependencies
- Works on all platforms
- Type-safe with code generation
- Excellent performance for local data
- Built-in encryption support

**Used for:**
- Counter storage
- Settings persistence
- Leaderboard data caching

### Provider
**State management solution**

Provider is the recommended state management approach for Flutter apps, built on top of InheritedWidget.

**Why Provider:**
- Simple and intuitive API
- Minimal boilerplate
- Excellent performance
- Official Flutter team recommendation

**Used for:**
- CounterProvider - manages counter list state
- ThemeNotifier - manages app theme state

## Visualization & Charts

### Syncfusion Charts
**Professional data visualization**

Syncfusion provides rich, interactive charts with smooth animations and extensive customization options.

**Features used:**
- Line charts for Series Counter trends
- Interactive zooming and panning
- Time-range filtering
- Professional styling

### fl_chart
**Additional charting capabilities**

fl_chart complements Syncfusion with additional chart types and customization options.

**Features used:**
- Heatmap visualizations for Tap Counters
- Frequency histograms
- Custom chart interactions

## Additional Dependencies

### Network & HTTP
- **http** - HTTP client for API requests (leaderboards, updates)
- **url_launcher** - Open URLs and external links

### UI & Utilities
- **intl** - Internationalization and date formatting
- **file_picker** - Native file picker for import/export
- **font_awesome_flutter** - Icon library
- **uuid** - Generate unique identifiers for counters

### Platform-Specific
- **path_provider** - Access platform-specific directories
- **flutter_launcher_icons** - Generate app icons for all platforms

## Development Tools

### Build & Code Generation
- **build_runner** - Code generation orchestration
- **hive_generator** - Generate Hive type adapters

### Linting & Quality
- **flutter_lints** - Official Flutter linting rules
- **Very Good Analysis** - Strict linting for production-quality code

## Architecture

### Design Patterns

**Repository Pattern:**
- CounterProvider abstracts data access
- Services layer for API interactions

**Factory Pattern:**
- CounterFactory for creating counter instances
- Polymorphic counter types

**State Management:**
- Provider for dependency injection
- ChangeNotifier for reactive updates

### Project Structure

```
lib/
├── counters/                  # Counter domain logic
│   ├── base/                  # Abstract BaseCounter & Factory
│   ├── tap_counter/           # TapCounter implementation
│   └── series_counter/        # SeriesCounter implementation
├── models/                    # Data models (Leaderboard, etc.)
├── providers/                 # State management
│   └── counter_provider.dart  # Main provider
├── screens/                   # UI Pages
│   ├── home_page.dart         # Dashboard
│   ├── leaderboards_page.dart # Leaderboard list
│   └── ...                    # Configuration & detail pages
├── services/                  # Business logic & API
│   ├── leaderboard_service.dart
│   └── update_service.dart    # Check for app updates
├── theme/                     # Theming
│   └── theme_notifier.dart    # Theme state
└── utils/                     # Shared utilities
    ├── constants.dart         # App-wide constants
    ├── statistics.dart        # Data analysis logic
    └── widgets.dart           # Reusable UI components
```

## Platform Support

Count App is tested and optimized for:

- **Android** 5.0+ (API Level 21+)
- **Windows** 10+
- **Linux** (Ubuntu 20.04+, other distributions)

## Performance Considerations

- **Lazy loading** of counter statistics
- **Efficient database queries** with Hive
- **Minimal network requests** with smart caching
- **Optimized animations** at 60 FPS

## Security

- Local-first data storage
- No analytics or tracking
- Optional leaderboard feature with minimal data sharing
- User controls all data export/import

---

## See Also

- [Development Setup](setup.md) - Set up your development environment
- [Adding Counter Types](adding-counter-types.md) - Create custom counter types
- [API Reference](../api/base-counter.md) - Explore the codebase
