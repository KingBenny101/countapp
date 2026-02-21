import "dart:convert";

import "package:countapp/counters/base/counter_factory.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/services/gist_backup_service.dart";
import "package:countapp/utils/constants.dart";
import "package:flutter/foundation.dart";
import "package:hive_ce/hive.dart";

/// Provider for managing GitHub Gist backups
class BackupProvider with ChangeNotifier {
  final GistBackupService _gistService = GistBackupService();
  CounterProvider? _counterProvider;
  Box? _settingsBox;

  String? githubUsername;
  bool isBusy = false;
  DateTime? lastBackupTime;
  String? errorMessage;

  /// Initialize the backup provider
  Future<void> initialize(
      CounterProvider counterProvider, Box settingsBox) async {
    _counterProvider = counterProvider;
    _settingsBox = settingsBox;

    // Load last backup time from settings
    final storedTime =
        settingsBox.get(AppConstants.lastBackupTimeSetting) as String?;
    if (storedTime != null) {
      try {
        lastBackupTime = DateTime.parse(storedTime);
      } catch (e) {
        debugPrint("[BackupProvider] Failed to parse stored backup time: $e");
      }
    }

    // Try to fetch username if token exists
    if (_gistService.isAuthenticated()) {
      try {
        githubUsername = await _gistService.getCurrentUser();
        errorMessage = null;
      } catch (e) {
        debugPrint("[BackupProvider] Failed to get username: $e");
        errorMessage = "Invalid token";
        githubUsername = null;
      }
      notifyListeners();
    }
  }

  /// Update the GitHub Personal Access Token
  Future<void> updateToken(String token) async {
    if (token.trim().isEmpty) {
      _gistService.setToken("");
      githubUsername = null;
      errorMessage = null;
      notifyListeners();
      return;
    }

    _gistService.setToken(token);

    // Validate token and fetch username
    try {
      githubUsername = await _gistService.validateToken();
      errorMessage = null;
    } catch (e) {
      debugPrint("[BackupProvider] Token validation failed: $e");
      githubUsername = null;
      errorMessage = e.toString().replaceFirst("Exception: ", "");
    }
    notifyListeners();
  }

  /// Create a backup and upload to GitHub Gist
  Future<void> createBackup() async {
    if (_counterProvider == null) {
      throw Exception("CounterProvider not initialized");
    }

    if (!_gistService.isAuthenticated()) {
      throw Exception("Not authenticated. Please enter a GitHub token.");
    }

    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Validate token first
      await _gistService.validateToken();

      // Serialize counters
      final counters =
          _counterProvider!.counters.map((c) => c.toJson()).toList();

      // Wrap with metadata
      final backupData = {
        "timestamp": DateTime.now().toIso8601String(),
        "appVersion": "1.6.0",
        "counters": counters,
      };

      // Upload to gist
      await _gistService.uploadBackup(json.encode(backupData));

      lastBackupTime = DateTime.now();
      // Persist last backup time
      await _settingsBox?.put(
        AppConstants.lastBackupTimeSetting,
        lastBackupTime!.toIso8601String(),
      );
      debugPrint("[BackupProvider] Backup created successfully");
    } catch (e) {
      debugPrint("[BackupProvider] Backup failed: $e");
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  /// Restore backup from GitHub Gist
  Future<void> restoreBackup() async {
    if (_counterProvider == null) {
      throw Exception("CounterProvider not initialized");
    }

    if (!_gistService.isAuthenticated()) {
      throw Exception("Not authenticated. Please enter a GitHub token.");
    }

    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Download backup
      final jsonData = await _gistService.downloadBackup();
      final backupData = json.decode(jsonData) as Map<String, dynamic>;

      // Extract counters array
      final countersData = backupData["counters"] as List<dynamic>;

      // Convert to proper format using factory
      final List<Map<String, dynamic>> counters = countersData.map((data) {
        final jsonMap = Map<String, dynamic>.from(data as Map);
        return CounterFactory.fromJson(jsonMap).toJson();
      }).toList();

      // Clear and restore to Hive box
      final box = Hive.isBoxOpen(AppConstants.countersBox)
          ? Hive.box(AppConstants.countersBox)
          : await Hive.openBox(AppConstants.countersBox);

      await box.clear();
      await box.addAll(counters);

      // Reload counters in provider
      await _counterProvider!.loadCounters();

      debugPrint("[BackupProvider] Backup restored successfully");
    } catch (e) {
      debugPrint("[BackupProvider] Restore failed: $e");
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  /// Get the most recent local modification time
  DateTime? getLocalLastModified() {
    if (_counterProvider == null || _counterProvider!.counters.isEmpty) {
      return null;
    }

    DateTime? mostRecent;
    for (final counter in _counterProvider!.counters) {
      if (counter.lastUpdated != null) {
        if (mostRecent == null || counter.lastUpdated!.isAfter(mostRecent)) {
          mostRecent = counter.lastUpdated;
        }
      }
    }

    return mostRecent;
  }

  /// Get the remote backup timestamp
  Future<DateTime?> getRemoteLastModified() async {
    try {
      final metadata = await _gistService.getBackupMetadata();
      final timestampStr = metadata["timestamp"] as String?;
      if (timestampStr != null) {
        return DateTime.parse(timestampStr);
      }
    } catch (e) {
      debugPrint("[BackupProvider] Failed to get remote timestamp: $e");
    }
    return null;
  }

  /// Check if local data is newer than remote backup
  Future<bool> isLocalNewer() async {
    final localTime = getLocalLastModified();
    if (localTime == null) {
      return false; // No local data
    }

    final remoteTime = await getRemoteLastModified();
    if (remoteTime == null) {
      return true; // No remote backup exists
    }

    return localTime.isAfter(remoteTime);
  }

  /// Check if authenticated
  bool get isAuthenticated => _gistService.isAuthenticated();

  /// Get stored token
  String? get storedToken => _gistService.getStoredToken();

  /// Get configured backup file name
  String get backupFileName => _gistService.getBackupFileName();

  /// Update configured backup file name
  void updateBackupFileName(String fileName) {
    _gistService.setBackupFileName(fileName);
    notifyListeners();
  }

  /// Get backup gist URL
  Future<Uri> getBackupGistUri() async {
    final gistUrl = await _gistService.getBackupGistUrl();
    return Uri.parse(gistUrl);
  }
}
