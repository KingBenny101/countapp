import "dart:convert";
import "package:connectivity_plus/connectivity_plus.dart";
import "package:countapp/utils/constants.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:http/http.dart" as http;
import "package:package_info_plus/package_info_plus.dart";
import "package:pub_semver/pub_semver.dart";
import "package:url_launcher/url_launcher.dart";

class UpdateService {
  UpdateService._();

  static const String _latestReleaseUrl =
      "https://api.github.com/repos/KingBenny101/countapp/releases/latest";

  /// Checks for new version updates in the background.
  /// Shows a dialog if a newer version is available and auto-check is enabled.
  static Future<void> checkUpdates(BuildContext context) async {
    final settingsBox = Hive.box(AppConstants.settingsBox);
    final bool autoCheck = settingsBox.get(
        AppConstants.checkUpdatesAtStartupSetting,
        defaultValue: true) as bool;

    if (!autoCheck) return;

    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return;

    try {
      final response = await http.get(Uri.parse(_latestReleaseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final String latestVersionStr =
            data["tag_name"].toString().replaceAll("v", "");
        final String downloadUrl = data["html_url"] as String;

        final packageInfo = await PackageInfo.fromPlatform();
        final String currentVersionStr = packageInfo.version;

        final Version latestVersion = Version.parse(latestVersionStr);
        final Version currentVersion = Version.parse(currentVersionStr);

        if (latestVersion > currentVersion) {
          if (context.mounted) {
            _showUpdateDialog(context, latestVersionStr, downloadUrl);
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking for updates: $e");
    }
  }

  static void _showUpdateDialog(
      BuildContext context, String version, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Update Available"),
        content: Text(
            "A new version ($version) of Count App is available. Would you like to download it?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () async {
              final Uri uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Download"),
          ),
        ],
      ),
    );
  }
}
