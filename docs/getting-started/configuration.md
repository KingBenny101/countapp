# Configuration

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

To change default values, edit `lib/utils/constants.dart`:

```dart
class AppConstants {
  // Change default step size
  static const int defaultStepSize = 5;  // Changed from 1

  // Change default initial value
  static const int defaultInitialValue = 100;  // Changed from 0
}
```

After modifying constants, rebuild the app for changes to take effect.
