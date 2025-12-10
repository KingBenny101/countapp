# Building for Release

This guide covers building Count App for production distribution across all supported platforms.

## Prerequisites

- Complete [Installation](installation.md) setup
- Platform-specific build tools configured
- Source code cloned and dependencies installed

## Build Script

Count App includes a comprehensive Dart-based build script that handles:

- Version extraction from `pubspec.yaml`
- Environment setup (package rename, icons)
- Code generation
- Platform-specific builds
- Output organization in `release/` folder
- Automatic file naming with version numbers

### Available Commands

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

### Configure Signing

For release builds, configure app signing:

1. **Create keystore** (if you don't have one):

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

2. **Create `android/app/key.properties`**:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

3. **Add to `.gitignore`**:

```gitignore
android/app/key.properties
*.jks
*.keystore
```

### Build APK

Using the build script:

```bash
dart run tool/build.dart build_android
```

Or manually:

```bash
flutter build apk --release
```

### Output Location

```
release/countapp-1.4.0.apk
```

### Build Configuration

The build script runs:

1. Extract version from `pubspec.yaml`
2. Run `flutter build apk --release`
3. Copy APK from `build/app/outputs/flutter-apk/`
4. Rename to `countapp-{version}.apk`
5. Move to `release/` folder

### APK Size Optimization

Current APK includes:

- **ARM 32-bit** (armeabi-v7a)
- **ARM 64-bit** (arm64-v8a)
- **x86** (for emulators)
- **x86_64**

To build separate APKs per ABI:

```bash
flutter build apk --split-per-abi --release
```

This creates:

- `app-armeabi-v7a-release.apk` (~20MB)
- `app-arm64-v8a-release.apk` (~22MB)
- `app-x86_64-release.apk` (~24MB)

## Windows Build

### Prerequisites

- Visual Studio 2022 with C++ desktop development
- Windows 10 SDK

### Build MSIX

Using the build script:

```bash
dart run tool/build.dart build_windows
```

Or manually:

```bash
flutter build windows --release
```

### Output Location

```
release/windows/countapp/
├── countapp.exe
├── flutter_windows.dll
├── data/
└── other dependencies
```

### MSIX Package (Optional)

To create an installable MSIX package:

1. **Install MSIX tooling**:

```bash
dart pub global activate msix
```

2. **Configure in `pubspec.yaml`**:

```yaml
msix_config:
  display_name: Count App
  publisher_display_name: KingBenny101
  identity_name: com.kingbenny101.countapp
  logo_path: assets/icon/windows/icon.png
  capabilities: 'internetClient'
```

3. **Build MSIX**:

```bash
dart run msix:create
```

Output: `build/windows/runner/Release/countapp.msix`

### Distribution

Distribute the entire `release/windows/countapp/` folder as a ZIP:

```powershell
Compress-Archive -Path release/windows/* -DestinationPath countapp-1.4.0-windows.zip
```

## Linux Build

### Prerequisites

Ubuntu/Debian:

```bash
sudo apt-get install clang cmake ninja-build pkg-config \
  libgtk-3-dev liblzma-dev
```

Fedora:

```bash
sudo dnf install clang cmake ninja-build gtk3-devel
```

### Build

Using the build script:

```bash
dart run tool/build.dart build_linux
```

Or manually:

```bash
flutter build linux --release
```

### Output Location

```
release/linux/countapp/
├── countapp
├── lib/
└── data/
```

### Distribution

Create a tarball:

```bash
cd release/linux
tar -czf countapp-1.4.0-linux.tar.gz countapp/
```

### AppImage (Optional)

To create a portable AppImage:

1. Install `appimagetool`
2. Create AppDir structure
3. Package with `appimagetool`

## Build Artifacts Summary

After running `dart run tool/build.dart all`:

```
release/
├── countapp-1.4.0.apk           # Android APK
├── windows/
│   └── countapp/                # Windows executable + deps
└── linux/
    └── countapp/                # Linux executable + deps
```

## Version Management

### Update Version

Edit `pubspec.yaml`:

```yaml
version: 1.4.0 # Change this
```

The build script automatically:

- Extracts version
- Names outputs with version number
- Includes version in artifacts

### Version Format

Follow semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes

## Optimization

### Flutter Build Optimizations

All release builds automatically include:

- **Tree Shaking**: Remove unused code
- **Obfuscation**: Protect source code
- **Minification**: Reduce size
- **AOT Compilation**: Ahead-of-time native compilation

### Additional Flags

For further optimization:

```bash
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --target-platform android-arm64
```

### Size Analysis

Analyze APK size:

```bash
flutter build apk --analyze-size --release
```

## Continuous Integration

See [CI/CD Pipeline](../development/cicd.md) for automated builds via GitHub Actions.

### CI Build Matrix

The GitHub Actions workflow builds:

- **Android**: Ubuntu runner
- **Windows**: Windows runner
- **Linux**: Ubuntu runner

All builds run in parallel for faster releases.

## Troubleshooting

### Issue: Android build fails with signing error

**Solution**: Ensure `key.properties` exists and paths are correct.

### Issue: Windows build missing DLLs

**Solution**: Ensure all dependencies in `build/windows/runner/Release/` are included.

### Issue: Linux build fails with GTK errors

**Solution**: Install missing GTK development packages:

```bash
sudo apt-get install libgtk-3-dev
```

### Issue: Build script fails to find version

**Solution**: Ensure `pubspec.yaml` has correct `version:` field.

### Issue: APK too large

**Solution**: Use `--split-per-abi` for smaller APKs per architecture.

## Testing Release Builds

### Android

Install and test on device:

```bash
adb install release/countapp-1.4.0.apk
adb shell am start -n com.kingbenny101.countapp/.MainActivity
```

### Windows

Run executable:

```powershell
.\release\windows\countapp\countapp.exe
```

### Linux

Run executable:

```bash
./release/linux/countapp/countapp
```

## Distribution Channels

### Android

- **Google Play Store**: Upload APK/AAB
- **Direct Download**: Host APK on GitHub Releases
- **F-Droid**: Submit for open-source distribution

### Windows

- **Microsoft Store**: Upload MSIX package
- **Direct Download**: Provide ZIP on GitHub Releases
- **Chocolatey**: Create package for package manager

### Linux

- **Snap Store**: Create snap package
- **Flathub**: Submit flatpak
- **AppImage**: Distribute portable binary
- **Direct Download**: Provide tarball on GitHub Releases

## Next Steps

- **[CI/CD Pipeline →](../development/cicd.md)** - Automated builds
- **[Release Process →](../development/release-process.md)** - How to release
- **[Configuration →](configuration.md)** - Build configuration details

!!! tip "Automated Builds"
Use GitHub Actions for automated builds on every release. See the [CI/CD documentation](../development/cicd.md).
