import "package:countapp/providers/backup_provider.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "package:url_launcher/url_launcher.dart";

class BackupsPage extends StatefulWidget {
  const BackupsPage({super.key});

  @override
  State<BackupsPage> createState() => _BackupsPageState();
}

class _BackupsPageState extends State<BackupsPage> {
  late TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    final backupProvider = Provider.of<BackupProvider>(context, listen: false);
    _tokenController =
        TextEditingController(text: backupProvider.storedToken ?? "");
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _openDocumentation() async {
    final uri = Uri.parse(AppConstants.backupDocsUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _handleUploadBackup(BackupProvider backupProvider) async {
    try {
      await backupProvider.createBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar(
            "Backup uploaded successfully",
            context: context,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar(
            "Backup failed: ${e.toString().replaceFirst('Exception: ', '')}",
            context: context,
            success: false,
          ),
        );
      }
    }
  }

  Future<void> _handleDownloadBackup(BackupProvider backupProvider) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Restore"),
          content: const Text(
            "This will replace all your current counters with the backup from GitHub Gist. Continue?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Restore"),
            ),
          ],
        ),
      );

      if (confirm != true) {
        return;
      }

      // Proceed with restore
      await backupProvider.restoreBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar(
            "Backup restored successfully",
            context: context,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar(
            "Restore failed: ${e.toString().replaceFirst('Exception: ', '')}",
            context: context,
            success: false,
          ),
        );
      }
    }
  }

  Future<void> _handleOpenGist(BackupProvider backupProvider) async {
    try {
      final gistUri = await backupProvider.getBackupGistUri();
      await launchUrl(gistUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar(
            "Failed to open gist: ${e.toString().replaceFirst('Exception: ', '')}",
            context: context,
            success: false,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backups"),
      ),
      body: Consumer<BackupProvider>(
        builder: (context, backupProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // GitHub Token Configuration Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "GitHub Personal Access Token",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.help_outline),
                            tooltip: "Setup Instructions",
                            onPressed: _openDocumentation,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _tokenController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Token",
                          hintText: "ghp_...",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          backupProvider.updateToken(value);
                        },
                      ),
                      const SizedBox(height: 8),
                      // Status message
                      if (backupProvider.githubUsername != null)
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Signed in as ${backupProvider.githubUsername}",
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        )
                      else if (backupProvider.errorMessage != null)
                        Row(
                          children: [
                            const Icon(Icons.error,
                                color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                backupProvider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Backup Actions Card
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_upload),
                      title: const Text("Upload Backup"),
                      subtitle: backupProvider.lastBackupTime != null
                          ? Text(
                              "Last backup: ${DateFormat("MMM d, yyyy h:mm a").format(backupProvider.lastBackupTime!)}",
                            )
                          : null,
                      trailing: backupProvider.isBusy
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.upload),
                              onPressed: backupProvider.isAuthenticated &&
                                      !backupProvider.isBusy
                                  ? () => _handleUploadBackup(backupProvider)
                                  : null,
                            ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.cloud_download),
                      title: const Text("Download Backup"),
                      subtitle: const Text("Restore from GitHub Gist"),
                      trailing: backupProvider.isBusy
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: backupProvider.isAuthenticated &&
                                      !backupProvider.isBusy
                                  ? () => _handleDownloadBackup(backupProvider)
                                  : null,
                            ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.open_in_new),
                      title: const Text("Open Gist"),
                      subtitle: const Text("Open backup gist in browser"),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: backupProvider.isAuthenticated &&
                                !backupProvider.isBusy
                            ? () => _handleOpenGist(backupProvider)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info Card
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "About Backups",
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• Backups are stored as secret gists on GitHub\n"
                        "• Use the same token on multiple devices to sync\n"
                        "• Your data is not encrypted in the gist\n"
                        "• Only counters are backed up (not settings)",
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
