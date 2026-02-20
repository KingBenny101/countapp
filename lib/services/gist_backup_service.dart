import "dart:convert";

import "package:countapp/utils/constants.dart";
import "package:flutter/foundation.dart";
import "package:hive_ce/hive.dart";
import "package:http/http.dart" as http;

/// Service for managing GitHub Gist backups
class GistBackupService {
  GistBackupService._();

  static final GistBackupService _instance = GistBackupService._();

  factory GistBackupService() => _instance;

  static const String _baseUrl = "https://api.github.com";
  String? _token;
  Box? _settingsBox;
  String? _cachedGistId;

  /// Initialize the service with settings box reference
  void initialize(Box settingsBox) {
    _settingsBox = settingsBox;
    _token = settingsBox.get(AppConstants.githubPatSetting) as String?;
  }

  /// Store the GitHub Personal Access Token
  void setToken(String token) {
    _token = token.trim();
    _settingsBox?.put(AppConstants.githubPatSetting, _token);
    _cachedGistId = null; // Clear cache when token changes
  }

  /// Get the stored token
  String? getStoredToken() {
    return _token;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _token != null && _token!.isNotEmpty;
  }

  /// Validate the token and return the GitHub username
  Future<String> validateToken() async {
    if (!isAuthenticated()) {
      throw Exception("No token configured");
    }

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/user"),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data["login"] as String;
      } else if (response.statusCode == 401) {
        throw Exception("Invalid or expired token");
      } else {
        throw Exception("Failed to validate token: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("[GistBackup] Token validation error: $e");
      rethrow;
    }
  }

  /// Get the current GitHub username
  Future<String> getCurrentUser() async {
    return validateToken();
  }

  /// Get or create the backup gist
  Future<String> getOrCreateBackupGist() async {
    if (_cachedGistId != null) {
      return _cachedGistId!;
    }

    if (!isAuthenticated()) {
      throw Exception("Not authenticated");
    }

    try {
      // Search for existing gist
      final response = await http.get(
        Uri.parse("$_baseUrl/gists"),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final gists = json.decode(response.body) as List;

        // Look for our backup gist
        for (final gist in gists) {
          final files = gist["files"] as Map<String, dynamic>?;
          if (files != null && files.containsKey("countapp_backup.json")) {
            _cachedGistId = gist["id"] as String;
            debugPrint("[GistBackup] Found existing gist: $_cachedGistId");
            return _cachedGistId!;
          }
        }

        // Gist doesn't exist, create it
        debugPrint("[GistBackup] Creating new secret gist");
        return await _createBackupGist();
      } else {
        throw Exception("Failed to list gists: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("[GistBackup] Error getting/creating gist: $e");
      rethrow;
    }
  }

  /// Create a new secret backup gist
  Future<String> _createBackupGist() async {
    final response = await http.post(
      Uri.parse("$_baseUrl/gists"),
      headers: _getHeaders(),
      body: json.encode({
        "description": "Countapp backup data",
        "public": false, // Secret gist
        "files": {
          "countapp_backup.json": {
            "content": json.encode({
              "timestamp": DateTime.now().toIso8601String(),
              "appVersion": "1.6.0",
              "counters": [],
            }),
          },
        },
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      _cachedGistId = data["id"] as String;
      debugPrint("[GistBackup] Created new gist: $_cachedGistId");
      return _cachedGistId!;
    } else {
      throw Exception("Failed to create gist: ${response.statusCode}");
    }
  }

  /// Upload backup data to the gist
  Future<void> uploadBackup(String jsonData) async {
    final gistId = await getOrCreateBackupGist();

    final response = await http.patch(
      Uri.parse("$_baseUrl/gists/$gistId"),
      headers: _getHeaders(),
      body: json.encode({
        "files": {
          "countapp_backup.json": {
            "content": jsonData,
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      debugPrint("[GistBackup] Backup uploaded successfully");
    } else {
      throw Exception("Failed to upload backup: ${response.statusCode}");
    }
  }

  /// Download backup data from the gist
  Future<String> downloadBackup() async {
    final gistId = await getOrCreateBackupGist();

    final response = await http.get(
      Uri.parse("$_baseUrl/gists/$gistId"),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final files = data["files"] as Map<String, dynamic>;
      final backupFile = files["countapp_backup.json"] as Map<String, dynamic>;
      final content = backupFile["content"] as String;
      debugPrint("[GistBackup] Backup downloaded successfully");
      return content;
    } else {
      throw Exception("Failed to download backup: ${response.statusCode}");
    }
  }

  /// Get backup metadata (timestamp)
  Future<Map<String, dynamic>> getBackupMetadata() async {
    final jsonData = await downloadBackup();
    final data = json.decode(jsonData) as Map<String, dynamic>;
    return {
      "timestamp": data["timestamp"] as String?,
      "appVersion": data["appVersion"] as String?,
    };
  }

  /// Get request headers with authorization
  Map<String, String> _getHeaders() {
    return {
      "Authorization": "Bearer $_token",
      "Accept": "application/vnd.github+json",
      "Content-Type": "application/json",
    };
  }
}
