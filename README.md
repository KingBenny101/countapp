# Count App

[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

A Flutter-based counter tracking application with an extensible architecture for multiple counter types.

## Features

- Create and manage multiple customizable counters
- Track update history with timestamps
- Visualize counter data with charts
- Import/Export counter data (JSON)
- Dark/light theme support
- Backward compatible with v1.3.9 exports

## Architecture

The app uses a clean, extensible architecture where each counter type is self-contained. See [ARCHITECTURE.md](ARCHITECTURE.md) for details.

## Platforms

- Android
- Windows
- Linux

## Development

1. **Install dependencies:**

   ```bash
   flutter pub get
   ```

2. **Generate required files:**

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

   Or use the build script:

   ```bash
   dart run tool/build.dart generate
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Building for Release

Use the cross-platform build script:

```bash
# Clean build artifacts
dart run tool/build.dart clean

# Build for Android
dart run tool/build.dart build_android

# Build for Windows
dart run tool/build.dart build_windows

# Build for Linux
dart run tool/build.dart build_linux

# Build for current platform + Android
dart run tool/build.dart all
```

Builds will be output to the `release/` folder.

## Adding New Counter Types

See [ARCHITECTURE.md](ARCHITECTURE.md) for step-by-step instructions on adding new counter types.
