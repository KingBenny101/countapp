# Configuration

Application configuration and constants used across Count App.

## Application Configuration

### Constants

Application-wide constants are defined in `lib/utils/constants.dart`:

```dart
class AppConstants {
  // Storage
  static const String countersBox = 'counters_box';
  static const String settingsBox = 'settings_box';

  // Settings Keys
  static const String themeModeSetting = 'theme_mode';

  // Defaults
  static const int defaultStepSize = 1;
  static const int defaultInitialValue = 0;
}
```

### Modifying Defaults

To change default values, edit `lib/utils/constants.dart` and rebuild the app.

Examples:

```dart
class AppConstants {
  static const int defaultStepSize = 5;  // Changed
  static const int defaultInitialValue = 100;  // Changed
}
```

After modifying constants, run a release or debug build to apply the changes.

## See also

- [BaseCounter API](base-counter.md)
- [Configuration alternatives](../developers/setup.md) - building and release notes
