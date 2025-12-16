import "dart:ui";

import "package:countapp/utils/constants.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hive_ce/hive.dart";

enum AppTheme {
  blue,
  purple,
  green,
  red,
  orange,
  pink,
}

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier() {
    _settingsBox = Hive.box(AppConstants.settingsBox);
    _themeMode = _loadThemeMode();
    _currentTheme = _loadCurrentTheme();
  }

  late final Box _settingsBox;
  late ThemeMode _themeMode;
  late AppTheme _currentTheme;

  ThemeMode _loadThemeMode() {
    final theme = _settingsBox.get(AppConstants.themeModeSetting);
    if (theme == "light") return ThemeMode.light;
    if (theme == "dark") return ThemeMode.dark;
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  AppTheme _loadCurrentTheme() {
    final themeName = _settingsBox.get(AppConstants.currentThemeSetting,
        defaultValue: "blue");
    return AppTheme.values.firstWhere(
      (theme) => theme.name == themeName,
      orElse: () => AppTheme.blue,
    );
  }

  ThemeMode get themeMode => _themeMode;
  AppTheme get currentTheme => _currentTheme;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveThemeMode();
    updateSystemUiOverlay();
    notifyListeners();
  }

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    _saveCurrentTheme();
    updateSystemUiOverlay();
    notifyListeners();
  }

  void _saveThemeMode() {
    _settingsBox.put(
      AppConstants.themeModeSetting,
      _themeMode == ThemeMode.dark ? "dark" : "light",
    );
  }

  void _saveCurrentTheme() {
    _settingsBox.put(AppConstants.currentThemeSetting, _currentTheme.name);
  }

  Color getThemeSeedColor() {
    switch (_currentTheme) {
      case AppTheme.blue:
        return Colors.blue;
      case AppTheme.purple:
        return Colors.purple;
      case AppTheme.green:
        return Colors.green;
      case AppTheme.red:
        return Colors.red;
      case AppTheme.orange:
        return Colors.orange;
      case AppTheme.pink:
        return Colors.pink;
    }
  }

  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: getThemeSeedColor(),
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: getThemeSeedColor(),
        brightness: Brightness.dark,
      ),
    );
  }

  void updateSystemUiOverlay() {
    final backgroundColor = _themeMode == ThemeMode.dark
        ? getDarkTheme().scaffoldBackgroundColor
        : getLightTheme().scaffoldBackgroundColor;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}
