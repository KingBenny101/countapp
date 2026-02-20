import "package:countapp/counters/base/counter_factory.dart";
import "package:countapp/counters/series_counter/series_counter.dart";
import "package:countapp/counters/tap_counter/tap_counter.dart";
import "package:countapp/models/leaderboard.dart";
import "package:countapp/providers/backup_provider.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/screens/about_page.dart";
import "package:countapp/screens/backups_page.dart";
import "package:countapp/screens/home_page.dart";
import "package:countapp/screens/options_page.dart";
import "package:countapp/screens/update_page.dart";
import "package:countapp/services/gist_backup_service.dart";
import "package:countapp/services/leaderboard_service.dart";
import "package:countapp/theme/theme_notifier.dart";
import "package:countapp/utils/constants.dart";
import "package:flutter/material.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:provider/provider.dart";

/// Syncs all counters to their attached leaderboards on app launch if enabled.
/// Runs asynchronously in the background without blocking the UI.
Future<void> _syncLeaderboardsOnLaunch() async {
  try {
    final settingsBox = Hive.box(AppConstants.settingsBox);
    final syncOnLaunch = settingsBox.get(
      AppConstants.leaderboardSyncOnLaunchSetting,
      defaultValue: false,
    ) as bool;

    if (!syncOnLaunch) {
      debugPrint("Sync on launch is disabled, skipping background sync.");
      return;
    }

    debugPrint("Starting background leaderboard sync on launch...");

    // Open counters box and load all counters
    final countersBox = await Hive.openBox(AppConstants.countersBox);
    final counters = countersBox.values
        .map((json) =>
            CounterFactory.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();

    debugPrint("Found ${counters.length} counters to sync.");

    // Get all leaderboards
    final allLeaderboards = LeaderboardService.getAll();

    // Sync each counter to its attached leaderboards
    for (final counter in counters) {
      final attachedLeaderboards = allLeaderboards
          .where((lb) => lb.attachedCounterId == counter.id)
          .toList();

      if (attachedLeaderboards.isEmpty) {
        debugPrint(
            "Counter ${counter.name} (${counter.id}) has no attached leaderboards.");
        continue;
      }

      debugPrint(
          "Syncing counter ${counter.name} (${counter.id}) to ${attachedLeaderboards.length} leaderboard(s)...");

      for (final lb in attachedLeaderboards) {
        // Check if the counter value has changed since last sync
        if (lb.lastSyncedValue != null &&
            lb.lastSyncedValue == counter.value.toInt()) {
          debugPrint(
              "Skipping sync for counter ${counter.name} to leaderboard ${lb.code} - no change (value: ${counter.value.toInt()})");
          continue;
        }

        debugPrint(
            "Counter ${counter.name} value changed from ${lb.lastSyncedValue} to ${counter.value.toInt()} - syncing to leaderboard ${lb.code}");

        // Fire and forget - don't block the UI
        LeaderboardService.postUpdate(lb: lb, counter: counter).then((ok) {
          if (ok) {
            debugPrint(
                "Successfully synced counter ${counter.name} to leaderboard ${lb.code}");
          } else {
            debugPrint(
                "Failed to sync counter ${counter.name} to leaderboard ${lb.code}");
          }
        }).catchError((error) {
          debugPrint(
              "Error syncing counter ${counter.name} to leaderboard ${lb.code}: $error");
        });
      }
    }

    debugPrint("Background leaderboard sync initiated for all counters.");
  } catch (e) {
    debugPrint("Error during background leaderboard sync: $e");
  }
}

/// Initialize backup provider and perform auto-backup if enabled
Future<void> _initializeBackup(
    BackupProvider backupProvider, CounterProvider counterProvider) async {
  try {
    final settingsBox = Hive.box(AppConstants.settingsBox);

    // Initialize GistBackupService with settings box
    GistBackupService().initialize(settingsBox);

    // Initialize BackupProvider with CounterProvider
    await backupProvider.initialize(counterProvider);

    // Check if auto-backup on start is enabled
    final backupOnStart = settingsBox.get(
      AppConstants.backupOnStartSetting,
      defaultValue: false,
    ) as bool;

    if (backupOnStart && backupProvider.isAuthenticated) {
      debugPrint("Auto-backup on start is enabled, creating backup...");
      backupProvider.createBackup().then((_) {
        debugPrint("Auto-backup completed successfully");
      }).catchError((error) {
        debugPrint("Auto-backup failed: $error");
      });
    }
  } catch (e) {
    debugPrint("Error during backup initialization: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.settingsBox);

  // Register adapters
  Hive.registerAdapter(TapCounterAdapter());
  Hive.registerAdapter(SeriesCounterAdapter());

  // Register leaderboard adapters
  Hive.registerAdapter(LeaderboardEntryAdapter());
  Hive.registerAdapter(LeaderboardAdapter());

  // Leaderboards storage (open after registering adapters)
  await Hive.openBox(AppConstants.leaderboardsBox);

  // Perform background sync if enabled
  _syncLeaderboardsOnLaunch();

  // Create providers
  final counterProvider = CounterProvider();
  final backupProvider = BackupProvider();

  // Initialize backup provider
  _initializeBackup(backupProvider, counterProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider.value(value: counterProvider),
        ChangeNotifierProvider.value(value: backupProvider),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        themeNotifier.updateSystemUiOverlay();
        return MaterialApp(
          theme: themeNotifier.getLightTheme(),
          darkTheme: themeNotifier.getDarkTheme(),
          themeMode: themeNotifier.themeMode,
          home: const HomePage(),
          routes: {
            "/updates": (context) => const UpdatePage(),
            "/options": (context) => const OptionsPage(),
            "/about": (context) => const AboutPage(),
            "/backups": (context) => const BackupsPage(),
          },
        );
      },
    );
  }
}
