import "package:countapp/providers/backup_provider.dart";
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
  Future<void> _editGistBackupFileName(BackupProvider backupProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Advanced Setting"),
        content: const Text(
          "You usually do not need to change the backup gist file name. "
          "Only change this if you really know what you are doing, since it can point backups to a different gist file. "
          "The .json extension is added automatically.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Continue"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final controller =
        TextEditingController(text: backupProvider.backupFileName);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Backup Gist File Name"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "File name",
            hintText: "countapp_backup",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    controller.dispose();

    if (value == null) {
      return;
    }

    backupProvider.updateBackupFileName(value);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      buildAppSnackBar(
        "Backup gist file name updated",
        context: context,
        success: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final backupProvider = Provider.of<BackupProvider>(context);
    final settingsBox = Hive.box(AppConstants.settingsBox);
    final autoPost = settingsBox.get(AppConstants.leaderboardAutoPostSetting,
        defaultValue: true) as bool;
    final syncOnLaunch = settingsBox.get(
        AppConstants.leaderboardSyncOnLaunchSetting,
        defaultValue: false) as bool;
    final checkUpdates = settingsBox.get(
        AppConstants.checkUpdatesAtStartupSetting,
        defaultValue: true) as bool;
    final backupOnStart = settingsBox.get(AppConstants.backupOnStartSetting,
        defaultValue: false) as bool;

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
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                  title: const Text(
                    "Backup on App Start",
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: const Text(
                    "Automatically upload to GitHub when app launches",
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Switch(
                    value: backupOnStart,
                    onChanged: (value) {
                      settingsBox.put(AppConstants.backupOnStartSetting, value);
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
                    "Backup Gist File Name",
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    backupProvider.backupFileName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editGistBackupFileName(backupProvider),
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
