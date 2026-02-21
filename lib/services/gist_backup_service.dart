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
  static const String _defaultBackupFileName = "countapp_backup";
  String? _token;
  Box? _settingsBox;
  String? _cachedGistId;
  String _backupFileName = _defaultBackupFileName;

  /// Initialize the service with settings box reference
  void initialize(Box settingsBox) {
    _settingsBox = settingsBox;
    _token = settingsBox.get(AppConstants.githubPatSetting) as String?;
    final storedFileName =
        settingsBox.get(AppConstants.gistBackupFileNameSetting) as String?;
    _backupFileName = _sanitizeBackupFileName(storedFileName);
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

  /// Get the configured backup file name (without extension)
  String getBackupFileName() {
    return _backupFileName;
  }

  /// Set the backup file name (without extension)
  void setBackupFileName(String fileName) {
    _backupFileName = _sanitizeBackupFileName(fileName);
    _settingsBox?.put(AppConstants.gistBackupFileNameSetting, _backupFileName);
    _cachedGistId = null;
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
      final existingGistId = await _findExistingBackupGistId();
      if (existingGistId != null) {
        _cachedGistId = existingGistId;
        debugPrint("[GistBackup] Found existing gist: $_cachedGistId");
        return _cachedGistId!;
      }

      // Gist doesn't exist, create it
      debugPrint("[GistBackup] Creating new secret gist");
      return await _createBackupGist();
    } catch (e) {
      debugPrint("[GistBackup] Error getting/creating gist: $e");
      rethrow;
    }
  }

  /// Get the backup gist if it exists
  Future<String> getExistingBackupGist() async {
    if (_cachedGistId != null) {
      return _cachedGistId!;
    }

    if (!isAuthenticated()) {
      throw Exception("Not authenticated");
    }

    final existingGistId = await _findExistingBackupGistId();
    if (existingGistId == null) {
      throw Exception(
          "No backup found for '$_backupFileNameWithExtension'. Upload a backup first.");
    }

    _cachedGistId = existingGistId;
    return _cachedGistId!;
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
          _backupFileNameWithExtension: {
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
          _backupFileNameWithExtension: {
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
    final gistId = await getExistingBackupGist();

    final response = await http.get(
      Uri.parse("$_baseUrl/gists/$gistId"),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final files = data["files"] as Map<String, dynamic>;
      final backupFile =
          files[_backupFileNameWithExtension] as Map<String, dynamic>?;
      if (backupFile == null) {
        throw Exception(
            "Backup file '$_backupFileNameWithExtension' not found in gist");
      }
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

  /// Get the URL of the backup gist
  Future<String> getBackupGistUrl() async {
    final gistId = await getExistingBackupGist();
    return "https://gist.github.com/$gistId";
  }

  Future<String?> _findExistingBackupGistId() async {
    final response = await http.get(
      Uri.parse("$_baseUrl/gists"),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to list gists: ${response.statusCode}");
    }

    final gists = json.decode(response.body) as List;

    for (final gist in gists) {
      final files = gist["files"] as Map<String, dynamic>?;
      if (files != null && files.containsKey(_backupFileNameWithExtension)) {
        return gist["id"] as String;
      }
    }

    return null;
  }

  String get _backupFileNameWithExtension => "$_backupFileName.json";

  String _sanitizeBackupFileName(String? fileName) {
    final trimmed = fileName?.trim() ?? "";
    if (trimmed.isEmpty) {
      return _defaultBackupFileName;
    }

    final withoutExtension =
        trimmed.replaceAll(RegExp(r"\.json$", caseSensitive: false), "");
    if (withoutExtension.isEmpty) {
      return _defaultBackupFileName;
    }

    return withoutExtension;
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
