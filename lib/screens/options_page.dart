import "package:countapp/theme/theme_notifier.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:provider/provider.dart";

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final settingsBox = Hive.box(AppConstants.settingsBox);
    final autoPost = settingsBox.get(AppConstants.leaderboardAutoPostSetting,
        defaultValue: true) as bool;
    final syncOnLaunch = settingsBox.get(
        AppConstants.leaderboardSyncOnLaunchSetting,
        defaultValue: false) as bool;
    final checkUpdates = settingsBox.get(
        AppConstants.checkUpdatesAtStartupSetting,
        defaultValue: true) as bool;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Options"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5,
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      themeNotifier.toggleTheme();
                    },
                  ),
                ),
                const Divider(height: 1),
                const ThemeSelector(),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                  title: const Text(
                    "Auto-sync Leaderboard",
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: syncOnLaunch
                      ? const Text(
                          "Disabled when Sync on Launch is enabled",
                          style: TextStyle(fontSize: 12),
                        )
                      : null,
                  trailing: Switch(
                    value: autoPost,
                    onChanged: syncOnLaunch
                        ? null
                        : (value) {
                            settingsBox.put(
                                AppConstants.leaderboardAutoPostSetting, value);
                            if (value) {
                              // Disable sync on launch when auto-sync is enabled
                              settingsBox.put(
                                  AppConstants.leaderboardSyncOnLaunchSetting,
                                  false);
                            }
                            setState(() {});
                          },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                  title: const Text(
                    "Sync Leaderboard on Launch",
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: autoPost
                      ? const Text(
                          "Disabled when Auto-sync is enabled",
                          style: TextStyle(fontSize: 12),
                        )
                      : null,
                  trailing: Switch(
                    value: syncOnLaunch,
                    onChanged: autoPost
                        ? null
                        : (value) {
                            settingsBox.put(
                                AppConstants.leaderboardSyncOnLaunchSetting,
                                value);
                            if (value) {
                              // Disable auto-sync when sync on launch is enabled
                              settingsBox.put(
                                  AppConstants.leaderboardAutoPostSetting,
                                  false);
                            }
                            setState(() {});
                          },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                  title: const Text(
                    "Check for Updates at Startup",
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: Switch(
                    value: checkUpdates,
                    onChanged: (value) {
                      settingsBox.put(
                          AppConstants.checkUpdatesAtStartupSetting, value);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
