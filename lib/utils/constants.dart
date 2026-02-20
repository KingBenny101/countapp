/// Application-wide constants
class AppConstants {
  // Hive box names
  static const String countersBox = "counters";
  static const String settingsBox = "settings";
  static const String leaderboardsBox = "leaderboards";

  // Settings keys
  static const String themeModeSetting = "themeMode";
  static const String currentThemeSetting = "currentTheme";
  static const String leaderboardAutoPostSetting = "leaderboardAutoPost";
  static const String leaderboardSyncOnLaunchSetting =
      "leaderboardSyncOnLaunch";
  static const String checkUpdatesAtStartupSetting = "checkUpdatesAtStartup";
  static const String githubPatSetting = "githubPat";
  static const String backupOnStartSetting = "backupOnStart";

  // URLs
  static const String backupDocsUrl =
      "https://kingbenny101.github.io/countapp/guides/backups/#step-by-step-instructions";

  // Hive type IDs
  static const int tapCounterTypeId = 1;
  static const int leaderboardEntryTypeId = 10;
  static const int leaderboardTypeId = 11;

  // UI constants
  static const int defaultStepSize = 1;
  static const int defaultInitialValue = 0;
}
