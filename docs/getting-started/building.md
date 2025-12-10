# Building for Release

This guide covers building Count App for production distribution.

## Build Script

Count App includes a Dart build script that handles version extraction, code generation, and platform builds:

```bash
# Generate environment (icons, package config)
dart run tool/build.dart generate

# Clean build artifacts
dart run tool/build.dart clean

# Build for Android
dart run tool/build.dart build_android

# Build for Windows
dart run tool/build.dart build_windows

# Build for Linux
dart run tool/build.dart build_linux

# Build all (current platform + Android)
dart run tool/build.dart all
```

## Android Build

Using the build script:

```bash
dart run tool/build.dart build_android
```

Or manually:

```bash
flutter build apk --release
```

**Output**: `release/countapp-{version}.apk`

## Windows Build

Using the build script:

```bash
dart run tool/build.dart build_windows
```

Or manually:

```bash
flutter build windows --release
```

**Output**: `release/windows/countapp/` (folder with executable and dependencies)

## Linux Build

Using the build script:

```bash
dart run tool/build.dart build_linux
```

Or manually:

```bash
flutter build linux --release
```

**Output**: `release/linux/countapp/` (folder with executable and dependencies)

## Build Artifacts

After running `dart run tool/build.dart all`:

```
release/
├── countapp-{version}.apk       # Android APK
├── windows/
│   └── countapp/                # Windows executable + deps
└── linux/
    └── countapp/                # Linux executable + deps
```

## Version Management

Update version in `pubspec.yaml`:

```yaml
version: 1.4.0 # MAJOR.MINOR.PATCH
```

The build script automatically extracts the version and names output files accordingly.
