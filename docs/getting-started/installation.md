# Installation

## Prerequisites

- Flutter SDK 3.3.3+
- Dart SDK 3.3.3+ (bundled with Flutter)
- Git

### Platform Requirements

- **Android**: Android Studio with SDK (API 21+)
- **Windows**: Visual Studio 2022 with C++ desktop development
- **Linux**: Standard development tools (`build-essential`, `libgtk-3-dev`)

## Setup

1. **Clone the repository**:

   ```bash
   git clone https://github.com/KingBenny101/countapp.git
   cd countapp
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Generate code**:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:

   ```bash
   flutter run
   ```

## Verify Installation

```bash
flutter doctor
```

All required components should show checkmarks for your target platform.

    **Dependencies for Linux desktop**:

    ```bash
    # Ubuntu/Debian
    sudo apt-get update
    sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

    # Fedora
    sudo dnf install clang cmake ninja-build gtk3-devel

    # Arch Linux
    sudo pacman -S clang cmake ninja gtk3
    ```

#### 4. Git

Install Git for version control:

=== "Windows"

    Download from [git-scm.com](https://git-scm.com/download/win)

=== "Linux"

    ```bash
    sudo apt-get install git  # Ubuntu/Debian
    sudo dnf install git       # Fedora
    sudo pacman -S git         # Arch Linux
    ```

=== "macOS"

    ```bash
    brew install git
    ```

## Verify Installation

Run Flutter doctor to check your setup:

```bash
flutter doctor -v
```

Expected output should show:

```
[✓] Flutter (Channel stable, 3.16.0, on Microsoft Windows...)
[✓] Android toolchain - develop for Android devices
[✓] Windows version (Installed)
[✓] VS Code (version 1.85.0)
[✓] Connected device (1 available)
[✓] Network resources
```

## Clone the Repository

Clone the Count App repository:

```bash
git clone https://github.com/KingBenny101/countapp.git
cd countapp
```

## Install Dependencies

Install all required Flutter packages:

```bash
flutter pub get
```

This will install all dependencies listed in `pubspec.yaml`, including:

- **hive_ce**: Local storage
- **provider**: State management
- **fl_chart**: Chart visualizations
- **syncfusion_flutter_charts**: Advanced charts
- **And more...**

## Generate Required Files

Generate Hive adapters and other code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or use the build script:

```bash
dart run tool/build.dart generate
```

This generates:

- Hive type adapters (`*.g.dart`)
- Hive registrar (`hive_registrar.g.dart`)

## IDE Setup

### Visual Studio Code

1. **Install Extensions**:

   - Flutter
   - Dart
   - Flutter Widget Snippets (optional)

2. **Configure Settings**: Create `.vscode/settings.json`:

   ```json
   {
     "dart.flutterSdkPath": "C:\\path\\to\\flutter",
     "dart.lineLength": 80,
     "editor.formatOnSave": true,
     "editor.rulers": [80]
   }
   ```

### Android Studio / IntelliJ IDEA

1. **Install Plugins**:

   - Flutter
   - Dart

2. **Configure Flutter SDK**:
   - File → Settings → Languages & Frameworks → Flutter
   - Set Flutter SDK path

## Verify Setup

Test your setup by running the app:

```bash
flutter run
```

Or use the debug configuration in your IDE.

## Troubleshooting

### Common Issues

#### Issue: `build_runner` fails

**Solution**:

```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### Issue: Android licenses not accepted

**Solution**:

```bash
flutter doctor --android-licenses
```

#### Issue: Windows build fails

**Solution**: Ensure Visual Studio 2022 with C++ desktop development is installed.

#### Issue: Hive errors

**Solution**: Delete Hive boxes and regenerate:

```bash
# Clear app data or delete Hive files
flutter clean
dart run build_runner build --delete-conflicting-outputs
```

### Getting Help

If you encounter issues:

1. Check [Flutter Doctor](https://docs.flutter.dev/get-started/install)
2. Review [GitHub Issues](https://github.com/KingBenny101/countapp/issues)
3. Open a new issue with details

## Next Steps

Now that you have everything installed:

- **[Quick Start →](quick-start.md)** - Run the app and explore features
- **[Building →](building.md)** - Create release builds
- **[Architecture →](../architecture/overview.md)** - Understand the codebase

!!! success "Setup Complete!"
Your development environment is ready! Proceed to the Quick Start guide to run the app.
