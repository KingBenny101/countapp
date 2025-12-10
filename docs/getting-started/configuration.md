# Configuration

Count App configuration options and customization settings.

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

## Build Configuration

### pubspec.yaml

Main application configuration:

```yaml
name: countapp
description: 'A simple application to help users keep track of their counts effortlessly.'
version: 1.4.0

environment:
  sdk: '>=3.3.3 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  hive_ce: ^2.7.0+1
  provider: ^6.1.2
  # ... more dependencies
```

**Key Sections**:

- **name**: Package identifier (lowercase, underscores)
- **version**: Semantic version (MAJOR.MINOR.PATCH)
- **environment**: Dart SDK constraints
- **dependencies**: Runtime dependencies
- **dev_dependencies**: Development tools

### Icons Configuration

Configured in `flutter_launcher_icons.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: 'assets/icon/android/icon.png'

  adaptive_icon_background: '#ffffff'
  adaptive_icon_foreground: 'assets/icon/android/icon.png'
```

**Customization**:

1. Replace `assets/icon/android/icon.png` with your icon
2. Run: `dart run flutter_launcher_icons:main`
3. Rebuild the app

### Package Rename

Configured in `package_rename_config.yaml`:

```yaml
package_rename_config:
  android:
    app_name: 'Count App'
    package_name: 'com.kingbenny101.countapp'
    override_old_package: 'com.example.countapp'

  windows:
    application_name: 'Count App'
    organization: 'com.kingbenny101'
```

**Usage**:

```bash
dart run package_rename
```

## Platform-Specific Configuration

### Android

#### Minimum SDK

In `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        minSdk = 21  // Android 5.0
        targetSdk = 34
    }
}
```

#### Permissions

In `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

    <application>
        <!-- ... -->
    </application>
</manifest>
```

#### App Name

In `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="Count App"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

### Windows

#### Display Name

In `windows/runner/Runner.rc`:

```cpp
VS_VERSION_INFO VERSIONINFO
 FILEVERSION 1,4,0,0
 PRODUCTVERSION 1,4,0,0
 FILEFLAGSMASK 0x3fL
 FILEFLAGS 0x0L
 FILEOS VOS_NT_WINDOWS32
 FILETYPE VFT_APP
 FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904b0"
        BEGIN
            VALUE "CompanyName", "KingBenny101"
            VALUE "FileDescription", "Count App"
            VALUE "FileVersion", "1.4.0.0"
            VALUE "ProductName", "Count App"
            VALUE "ProductVersion", "1.4.0.0"
        END
    END
END
```

#### MSIX Configuration

In `pubspec.yaml`:

```yaml
msix_config:
  display_name: Count App
  publisher_display_name: KingBenny101
  identity_name: com.kingbenny101.countapp
  logo_path: assets/icon/windows/icon.png
  capabilities: 'internetClient'
```

### Linux

#### Desktop Entry

Create `linux/countapp.desktop`:

```ini
[Desktop Entry]
Name=Count App
Comment=Track your counts effortlessly
Exec=countapp
Icon=countapp
Type=Application
Categories=Utility;
```

## Theme Configuration

### Default Themes

Defined in `lib/main.dart`:

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  ),
  themeMode: themeNotifier.themeMode,
)
```

### Customizing Theme Colors

To change the app's color scheme:

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,  // Change primary color
      brightness: Brightness.light,
    ),
    // Custom overrides
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
    ),
  ),
)
```

## Storage Configuration

### Hive Boxes

Configured in `lib/main.dart`:

```dart
await Hive.initFlutter();
await Hive.openBox(AppConstants.settingsBox);

// Counters box opened lazily by provider
final box = await Hive.openBox(AppConstants.countersBox);
```

### Storage Location

Default storage paths:

- **Android**: `/data/data/com.kingbenny101.countapp/`
- **Windows**: `%APPDATA%\countapp\`
- **Linux**: `~/.local/share/countapp/`

### Changing Storage Path

To customize storage location:

```dart
await Hive.initFlutter('custom_directory');
```

## Code Generation

### build_runner Configuration

In `build.yaml`:

```yaml
targets:
  $default:
    builders:
      hive_ce_generator:hive_type_adapter_generator:
        enabled: true
        options:
          generate_for:
            - lib/**/*.dart
```

### Generation Commands

```bash
# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
dart run build_runner watch
```

## Lint Configuration

Configured in `analysis_options.yaml`:

```yaml
include: package:lint/analysis_options.yaml

analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'

  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    prefer_const_constructors: true
    prefer_final_fields: true
    unnecessary_this: true
```

### Customizing Lint Rules

Add or disable rules:

```yaml
linter:
  rules:
    # Enable stricter rules
    always_declare_return_types: true
    avoid_print: true

    # Disable rules
    prefer_single_quotes: false
```

## Build Script Configuration

### Custom Build Commands

Edit `tool/build.dart` to add custom build logic:

```dart
Future<void> customBuild() async {
  print("Running custom build...");

  // Pre-build steps
  await generateEnvironment();

  // Custom logic here

  // Build
  await buildAndroid();
}
```

### Environment Variables

Set environment variables for builds:

```bash
# Android signing
export ANDROID_KEYSTORE_PATH=/path/to/keystore.jks
export ANDROID_KEYSTORE_PASSWORD=secret
export ANDROID_KEY_ALIAS=upload

# Build
dart run tool/build.dart build_android
```

## Feature Flags

To add feature flags, create `lib/config/feature_flags.dart`:

```dart
class FeatureFlags {
  static const bool enableExperimentalFeatures = false;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  static const bool debugMode = bool.fromEnvironment('DEBUG', defaultValue: false);
}
```

Usage:

```dart
if (FeatureFlags.enableExperimentalFeatures) {
  // Show experimental feature
}
```

## Environment-Specific Configuration

### Development

```dart
const bool isProduction = bool.fromEnvironment('dart.vm.product');

if (!isProduction) {
  // Development-only code
  print("Running in development mode");
}
```

### Production

Build with production flag:

```bash
flutter build apk --release --dart-define=dart.vm.product=true
```

## Next Steps

- **[Building →](building.md)** - Build for release
- **[Development →](../development/build-system.md)** - Build system details
- **[Contributing →](../guides/contributing.md)** - Contribute to the project
