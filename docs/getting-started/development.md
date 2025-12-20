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

Refer to the [Building](building.md) doc for platform-specific release steps.

## Troubleshooting

- If code generation fails, run `flutter clean` and re-run `build_runner`.
- If you see platform-specific permission or plugin errors on desktop, search the project issues or open a new issue with logs.

---

Helpful tips:

- Keep your local `dev` branch rebased on top of `origin/dev` regularly.
- Run `flutter analyze` and `dart format .` before opening PRs.