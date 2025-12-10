# Setup

Get Count App running on your local machine.

## Prerequisites

- [Flutter SDK 3.3.3+](https://docs.flutter.dev/get-started/install)
- Git

## Installation Steps

### 1. Clone Repository

```bash
git clone https://github.com/KingBenny101/countapp.git
cd countapp
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

Required for Hive adapters:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

```bash
flutter run
```

## Troubleshooting

### Common Issues

#### `build_runner` fails

```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### Android licenses not accepted

```bash
flutter doctor --android-licenses
```

#### Hive errors

Delete Hive boxes and regenerate:

```bash
flutter clean
dart run build_runner build --delete-conflicting-outputs
```

### Getting Help

If issues persist:

1. Run `flutter doctor -v` for detailed diagnostics
2. Check [GitHub Issues](https://github.com/KingBenny101/countapp/issues)
3. Open a new issue with error details

## Next Steps

- [Building](building.md) - Create release builds
- [Configuration](configuration.md) - Customize app settings
