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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildOptionsCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    IconData? icon,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      leading: icon == null ? null : Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 12),
              ),
            ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      leading: icon == null ? null : Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: onPressed,
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _buildSectionTitle("Appearance"),
          _buildOptionsCard([
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                themeNotifier.toggleTheme();
              },
            ),
            const Divider(height: 1),
            const ThemeSelector(),
          ]),
          const SizedBox(height: 16),
          _buildSectionTitle("Leaderboard"),
          _buildOptionsCard([
            _buildSwitchTile(
              icon: Icons.leaderboard_outlined,
              title: "Auto-Sync Leaderboard",
              subtitle: syncOnLaunch
                  ? "Disabled when Sync Leaderboard at Launch is enabled"
                  : null,
              value: autoPost,
              onChanged: syncOnLaunch
                  ? null
                  : (value) {
                      settingsBox.put(
                        AppConstants.leaderboardAutoPostSetting,
                        value,
                      );
                      if (value) {
                        settingsBox.put(
                          AppConstants.leaderboardSyncOnLaunchSetting,
                          false,
                        );
                      }
                      setState(() {});
                    },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.sync_outlined,
              title: "Sync Leaderboard at Launch",
              subtitle: autoPost
                  ? "Disabled when Auto-Sync Leaderboard is enabled"
                  : null,
              value: syncOnLaunch,
              onChanged: autoPost
                  ? null
                  : (value) {
                      settingsBox.put(
                        AppConstants.leaderboardSyncOnLaunchSetting,
                        value,
                      );
                      if (value) {
                        settingsBox.put(
                          AppConstants.leaderboardAutoPostSetting,
                          false,
                        );
                      }
                      setState(() {});
                    },
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionTitle("Updates"),
          _buildOptionsCard([
            _buildSwitchTile(
              icon: Icons.system_update_alt_outlined,
              title: "Check for Updates at Launch",
              value: checkUpdates,
              onChanged: (value) {
                settingsBox.put(
                    AppConstants.checkUpdatesAtStartupSetting, value);
                setState(() {});
              },
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionTitle("Backup"),
          _buildOptionsCard([
            _buildSwitchTile(
              icon: Icons.backup_outlined,
              title: "Backup at Launch",
              value: backupOnStart,
              onChanged: (value) {
                settingsBox.put(AppConstants.backupOnStartSetting, value);
                setState(() {});
              },
            ),
            const Divider(height: 1),
            _buildActionTile(
              icon: Icons.description_outlined,
              title: "Backup Gist File Name",
              subtitle: backupProvider.backupFileName,
              onPressed: () => _editGistBackupFileName(backupProvider),
            ),
          ]),
        ],
      ),
    );
  }
}
