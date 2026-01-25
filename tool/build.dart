// ignore_for_file: avoid_print

import "dart:io";

const releaseFolder = "release";
const appName = "countapp";
const androidBuild = "build/app/outputs/flutter-apk/app-release.apk";
const windowsBuild = "build/windows/x64/runner/Release";
const linuxBuild = "build/linux/x64/release/bundle";

String version = "";

Future<void> getVersion() async {
  final pubspec = File("pubspec.yaml");
  final content = await pubspec.readAsString();

  final versionLine = content.split("\n").firstWhere(
        (line) => line.trim().startsWith("version:"),
        orElse: () => "",
      );

  if (versionLine.isEmpty) {
    print("Version not found in pubspec.yaml");
    exit(1);
  }

  version = versionLine.split(":")[1].trim();
  print("Extracted version: $version");
}

Future<void> generateEnvironment() async {
  print("\nRunning package_rename...");
  await _runCommand("dart", ["run", "package_rename"]);

  print("\nRunning flutter_launcher_icons...");
  await _runCommand("dart", ["run", "flutter_launcher_icons:main"]);
}

Future<void> cleanEnvironment() async {
  print("\nCleaning up previous builds...");
  await _runCommand("flutter", ["clean"]);

  final releaseDir = Directory(releaseFolder);

  if (await releaseDir.exists()) {
    await releaseDir.delete(recursive: true);
    print("\nCleaned release folder.");
  }

  await releaseDir.create();
  print("\nCreated release folder.");
}

Future<void> buildAndroid() async {
  print("\nBuilding for Android (Optimized)...");
  await _runCommand("flutter", [
    "build",
    "apk",
    "--release",
    "--obfuscate",
    "--split-debug-info=build/app/outputs/symbols",
  ]);

  // Ensure release folder exists
  final releaseDir = Directory(releaseFolder);
  await releaseDir.create(recursive: true);

  final apkFile = File(androidBuild);
  if (await apkFile.exists()) {
    final newName = "$appName-$version.apk";
    await apkFile.copy("$releaseFolder/$newName");
    print("\nAPK file copied and renamed to $newName.");
  } else {
    print("\nAPK file not found at $androidBuild");
  }
}

Future<void> buildWindows() async {
  print("\nBuilding for Windows...");
  await _runCommand("flutter", ["build", "windows", "--release"]);

  final windowsDir = Directory(windowsBuild);
  if (await windowsDir.exists()) {
    final targetDir = Directory("$releaseFolder/windows");
    await targetDir.create(recursive: true);
    await _copyDirectory(windowsDir, targetDir);
    print("\nWindows build copied successfully.");
  } else {
    print("\nWindows build not found.");
  }
}

Future<void> buildLinux() async {
  print("\nBuilding for Linux...");
  await _runCommand("flutter", ["build", "linux", "--release"]);

  final linuxDir = Directory(linuxBuild);
  if (await linuxDir.exists()) {
    final targetDir = Directory("$releaseFolder/linux");
    await targetDir.create(recursive: true);
    await _copyDirectory(linuxDir, targetDir);
    print("\nLinux build copied successfully.");
  } else {
    print("\nLinux build not found.");
  }
}

Future<void> buildAll() async {
  await getVersion();
  await cleanEnvironment();
  await buildAndroid();

  // Build for current platform
  if (Platform.isLinux) {
    await buildLinux();
  } else if (Platform.isWindows) {
    await buildWindows();
  } else if (Platform.isMacOS) {
    print("macOS build not configured");
  }
}

Future<void> _runCommand(String command, List<String> args) async {
  final result = await Process.run(
    command,
    args,
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    print("Command failed with exit code ${result.exitCode}");
    exit(result.exitCode);
  }
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  await for (final entity in source.list()) {
    final newPath = destination.path +
        Platform.pathSeparator +
        entity.path.split(Platform.pathSeparator).last;

    if (entity is File) {
      await entity.copy(newPath);
    } else if (entity is Directory) {
      final newDir = Directory(newPath);
      await newDir.create();
      await _copyDirectory(entity, newDir);
    }
  }
}

void printUsage() {
  print("Usage: dart run tool/build.dart <task>");
  print("Available tasks:");
  print("  clean          - Clean build artifacts");
  print("  generate       - Run code generators");
  print("  build_android  - Build Android APK");
  print("  build_windows  - Build Windows executable");
  print("  build_linux    - Build Linux executable");
  print("  all            - Clean and build for current platform + Android");
}

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    printUsage();
    exit(1);
  }

  final task = arguments[0];

  try {
    switch (task) {
      case "clean":
        await cleanEnvironment();
      case "generate":
        await generateEnvironment();
      case "build_android":
        await getVersion();
        await buildAndroid();
      case "build_windows":
        await getVersion();
        await buildWindows();
      case "build_linux":
        await getVersion();
        await buildLinux();
      case "all":
        await buildAll();
      default:
        print("Invalid task: $task");
        printUsage();
        exit(1);
    }
  } catch (e, stack) {
    print("Error: $e");
    print(stack);
    exit(1);
  }
}
