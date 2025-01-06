import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:hive_ce/hive.dart";

class ThemeNotifier extends ChangeNotifier {

  ThemeNotifier()
      : _themeMode = _loadThemeMode();
  ThemeMode _themeMode;
  final Box _settingsBox = Hive.box("settings");

  static ThemeMode _loadThemeMode() {
    // Load theme mode from Hive, default to system brightness if unset
    final theme = Hive.box("settings").get("themeMode");
    if (theme == "light") return ThemeMode.light;
    if (theme == "dark") return ThemeMode.dark;
    return SchedulerBinding.instance.window.platformBrightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveThemeMode();
    _updateSystemUiOverlay();
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeMode();
    _updateSystemUiOverlay();
    notifyListeners();
  }

  void _saveThemeMode() {
    // Save the current theme mode to Hive
    _settingsBox.put("themeMode", _themeMode == ThemeMode.dark ? "dark" : "light");
  }

  void _updateSystemUiOverlay() {
    // Update system UI colors based on theme mode
    final backgroundColor = _themeMode == ThemeMode.dark
        ? ThemeData.dark().scaffoldBackgroundColor
        : ThemeData.light().scaffoldBackgroundColor;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),);
  }
}
