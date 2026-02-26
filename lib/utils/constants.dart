import "package:intl/intl.dart";

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
  static const String lastBackupTimeSetting = "lastBackupTime";
  static const String gistBackupFileNameSetting = "gistBackupFileName";
  static const String compressionEnabledSetting = "compressionEnabled";

  // URLs
  static const String backupDocsUrl =
      "https://kingbenny101.github.io/countapp/guides/backups/#step-by-step-instructions";

  // Hive type IDs
  static const int tapCounterTypeId = 1;
  static const int seriesCounterTypeId = 2;
  static const int leaderboardEntryTypeId = 10;
  static const int leaderboardTypeId = 11;

  // UI constants
  static const int defaultStepSize = 1;
  static const int defaultInitialValue = 0;

  // DateFormat patterns (cached to avoid repeated instantiation)
  static final DateFormat dateTimeFullFormat =
      DateFormat("MMM d, yyyy (EEEE) - h:mm a");
  static final DateFormat dateFormatYearMonthDay = DateFormat("yyyy-MM-dd");
  static final DateFormat dateFormatMonthDay = DateFormat("MMM dd");
  static final DateFormat dateFormatMonthDayYear = DateFormat("MMM dd, yyyy");
  static final DateFormat timeFormatHourMin = DateFormat("h:mm a");
  static final DateFormat dateTimeFullDateOnly =
      DateFormat("E, MMM d, yyyy hh:mm a");
  static final DateFormat timeFormat24Hour = DateFormat("HH:mm");
  static final DateFormat dateFormatMonthDaySingle = DateFormat("MMM d");
  static final DateFormat dateFormatDayMonthYear = DateFormat("dd/MM/yy");
  static final DateFormat backupFileFormat = DateFormat("yyyy-MM-dd_HH-mm-ss");
  static final DateFormat leaderboardDateTimeFormat =
      DateFormat("yyyy-MM-dd HH:mm");
  static final DateFormat dateFormatMonthDayYearWithTime =
      DateFormat("MMM d, yyyy h:mm a");
}
