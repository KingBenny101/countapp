# Development setup (using `dev` branch)

This page describes how to set up a local development environment using the `dev` branch.

> Note: The Releases page contains pre-built APKs and platform binaries for users. The development guide below is for contributors or for building locally.

## 1. Clone and switch to `dev`

```bash
git clone https://github.com/KingBenny101/countapp.git
cd countapp
git fetch origin
git checkout dev
```

Keeping on `dev` lets you work on the latest in-progress features and tests.

## 2. Prerequisites

- Flutter SDK (stable channel recommended): https://docs.flutter.dev/get-started/install
- Dart SDK (bundled with Flutter)
- Git

## 3. Install dependencies

```bash
flutter pub get
```

## 4. Generate code (Hive adapters)

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 5. Run locally

- Linux / Windows / macOS (desktop):

```bash
flutter run -d linux
# or
flutter run -d windows
```

- Android:

```bash
flutter run -d <your-android-device-id>
```

## 6. Build release artifacts

Count App provides a helper build script and standard Flutter build commands to produce release artifacts for each platform.

### Build script

The project includes `tool/build.dart` which wraps common tasks:

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

### Platform-specific alternatives

Android:

```bash
flutter build apk --release
```

Windows:

```bash
flutter build windows --release
```

Linux:

```bash
flutter build linux --release
```

### Output

- `release/countapp-{version}.apk` (Android)
- `release/windows/countapp/` (Windows executable + deps)
- `release/linux/countapp/` (Linux executable + deps)

### Version management

Set `version` in `pubspec.yaml`:

```yaml
version: 1.4.0 # MAJOR.MINOR.PATCH
```

The build script extracts the version and names output files accordingly.


## Troubleshooting

- If code generation fails, run `flutter clean` and re-run `build_runner`.
- If you see platform-specific permission or plugin errors on desktop, search the project issues or open a new issue with logs.

---

Helpful tips:

- Keep your local `dev` branch rebased on top of `origin/dev` regularly.
- Run `flutter analyze` and `dart format .` before opening PRs.