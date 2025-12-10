import "dart:ui";

import "package:countapp/utils/constants.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hive_ce/hive.dart";

class ThemeNotifier extends ChangeNotifier {
  late final Box _settingsBox;
  late ThemeMode _themeMode;

  ThemeNotifier() {
    _settingsBox = Hive.box(AppConstants.settingsBox);
    _themeMode = _loadThemeMode();
  }

  ThemeMode _loadThemeMode() {
    final theme = _settingsBox.get(AppConstants.themeModeSetting);
    if (theme == "light") return ThemeMode.light;
    if (theme == "dark") return ThemeMode.dark;
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveThemeMode();
    updateSystemUiOverlay();
    notifyListeners();
  }

  void _saveThemeMode() {
    _settingsBox.put(AppConstants.themeModeSetting,
        _themeMode == ThemeMode.dark ? "dark" : "light");
  }

  void updateSystemUiOverlay() {
    final backgroundColor = _themeMode == ThemeMode.dark
        ? ThemeData.dark().scaffoldBackgroundColor
        : ThemeData.light().scaffoldBackgroundColor;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}
