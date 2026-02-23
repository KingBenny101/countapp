import "dart:convert";

import "package:archive/archive_io.dart";
import "package:countapp/utils/constants.dart";
import "package:flutter/foundation.dart";
import "package:hive_ce/hive.dart";
import "package:http/http.dart" as http;

/// Service for managing GitHub Gist backups
class GistBackupService {
  factory GistBackupService() => _instance;

  GistBackupService._();
  static const String _baseUrl = "https://api.github.com";
  static const String _defaultBackupFileName = "countapp_backup";
  static final GistBackupService _instance = GistBackupService._();

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
        _checkRateLimit(response.statusCode);
        throw Exception("Failed to validate token: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("[GistBackup] Token validation error: $e");
      rethrow;
    }
  }

  /// Get the current GitHub username
  Future<String> getCurrentUser() {
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
    final timestamp = DateTime.now().toIso8601String();
    final metadataContent = json.encode({
      "timestamp": timestamp,
      "appVersion": "1.6.0",
    });

    final response = await http.post(
      Uri.parse("$_baseUrl/gists"),
      headers: _getHeaders(),
      body: json.encode({
        "description": "Countapp backup data",
        "public": false, // Secret gist
        "files": {
          _backupFileName: {
            "content": metadataContent,
          },
          _backupFileNameWithExtension: {
            "content": json.encode([]),
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

  /// Check for API rate limiting and throw descriptive error
  void _checkRateLimit(int statusCode) {
    if (statusCode == 429) {
      throw Exception(
          "GitHub API rate limit exceeded. Please wait before trying again.");
    } else if (statusCode == 403) {
      throw Exception(
          "GitHub API access forbidden. Check your token permissions.");
    }
  }

  /// Upload backup data to the gist
  Future<void> uploadBackup(String jsonData) async {
    if (!isAuthenticated()) {
      throw Exception("Not authenticated. Please enter a GitHub token.");
    }

    final compressionEnabled = _settingsBox?.get(
      AppConstants.compressionEnabledSetting,
      defaultValue: false,
    ) as bool? ?? false;

    final String contentToUpload;
    if (compressionEnabled) {
      // Compress the JSON data and encode as base64
      final bytes = utf8.encode(jsonData);
      const encoder = GZipEncoder();
      final compressedBytes = encoder.encode(bytes);
      contentToUpload = base64Encode(compressedBytes);
    } else {
      contentToUpload = jsonData;
    }

    // Create metadata
    final timestamp = DateTime.now().toIso8601String();
    final metadataContent = json.encode({
      "timestamp": timestamp,
      "appVersion": "1.6.0",
    });

    final filesToUpsert = {
      _backupFileName: {
        "content": metadataContent,
      },
      _backupFileNameWithExtension: {
        "content": contentToUpload,
      },
    };

    // Try to update existing gist first (atomic operation)
    try {
      final existingGistId = await _findExistingBackupGistId();
      if (existingGistId != null) {
        // When updating, also delete the old format file (if it exists)
        // to prevent stale data after compression toggle
        final oldFormatFileName = _backupFileNameWithExtension.endsWith(".gz")
            ? "$_backupFileName.json"
            : "$_backupFileName.json.gz";

        // First check what files currently exist in the gist
        final getResponse = await http.get(
          Uri.parse("$_baseUrl/gists/$existingGistId"),
          headers: _getHeaders(),
        );

        if (getResponse.statusCode != 200) {
          _checkRateLimit(getResponse.statusCode);
          debugPrint(
              "[GistBackup] Failed to fetch existing gist, will create new one");
          _cachedGistId = null;
        } else {
          // Build files object with proper null handling for deletion
          final filesUpdateBody = <String, dynamic>{};
          filesUpdateBody[_backupFileName] = filesToUpsert[_backupFileName];
          filesUpdateBody[_backupFileNameWithExtension] =
              filesToUpsert[_backupFileNameWithExtension];

          // Only include deletion of old format file if it exists in the current gist
          final existingGistData =
              json.decode(getResponse.body) as Map<String, dynamic>;
          final existingFiles =
              existingGistData["files"] as Map<String, dynamic>;

          bool deletedOldFormat = false;
          if (existingFiles.containsKey(oldFormatFileName)) {
            filesUpdateBody[oldFormatFileName] =
                null; // This correctly deletes the file
            debugPrint("[GistBackup] Will delete old format file: $oldFormatFileName");
            deletedOldFormat = true;
          }

          final updateResponse = await http.patch(
            Uri.parse("$_baseUrl/gists/$existingGistId"),
            headers: _getHeaders(),
            body: json.encode({"files": filesUpdateBody}),
          );

          if (updateResponse.statusCode == 200) {
            _cachedGistId = existingGistId;
            if (deletedOldFormat) {
              debugPrint(
                  "[GistBackup] Updated existing gist: $existingGistId (cleaned old format)");
            } else {
              debugPrint("[GistBackup] Updated existing gist: $existingGistId");
            }
            return;
          } else if (updateResponse.statusCode == 404) {
            // Gist was deleted externally, fall through to create new one
            debugPrint("[GistBackup] Existing gist not found, creating new one");
            _cachedGistId = null;
          } else {
            // Check for rate limiting
            _checkRateLimit(updateResponse.statusCode);
            // Fall through to create new one for other errors
            debugPrint(
                "[GistBackup] Failed to update gist (${updateResponse.statusCode}), creating new one");
            _cachedGistId = null;
          }
        }
      }
    } catch (e) {
      debugPrint("[GistBackup] Error finding existing gist: $e, will create new one");
      _cachedGistId = null;
    }

    // Create new gist if update failed or didn't exist
    final createResponse = await http.post(
      Uri.parse("$_baseUrl/gists"),
      headers: _getHeaders(),
      body: json.encode({
        "description": "Countapp backup data",
        "public": false, // Secret gist
        "files": filesToUpsert,
      }),
    );

    if (createResponse.statusCode == 201) {
      final data = json.decode(createResponse.body) as Map<String, dynamic>;
      _cachedGistId = data["id"] as String;
      debugPrint("[GistBackup] Created new backup gist: $_cachedGistId");
    } else {
      // Check for rate limiting
      _checkRateLimit(createResponse.statusCode);
      throw Exception(
          "Failed to create backup gist: ${createResponse.statusCode}");
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

      // Find the data file (handles both .json and .json.gz)
      String? content;
      String? foundFileName;

      // First try to find the file with current compression setting
      for (final fileName in files.keys) {
        if (fileName == _backupFileNameWithExtension) {
          content =
              (files[fileName] as Map<String, dynamic>)["content"] as String;
          foundFileName = fileName;
          break;
        }
      }

      // If not found, try to find the other format (backward compatibility)
      if (content == null) {
        final otherFormat = _backupFileNameWithExtension.endsWith(".gz")
            ? "$_backupFileName.json"
            : "$_backupFileName.json.gz";
        if (files.containsKey(otherFormat)) {
          content =
              (files[otherFormat] as Map<String, dynamic>)["content"] as String;
          foundFileName = otherFormat;
        }
      }

      if (content == null) {
        throw Exception("Backup file not found in gist");
      }

      // Decompress if the file is compressed
      if (foundFileName?.endsWith(".gz") ?? false) {
        try {
          final decodedBytes = base64Decode(content);
          const decoder = GZipDecoder();
          final decompressedBytes = decoder.decodeBytes(decodedBytes);
          content = utf8.decode(decompressedBytes);
        } catch (e) {
          debugPrint("[GistBackup] Failed to decompress backup: $e");
          rethrow;
        }
      }

      debugPrint("[GistBackup] Backup downloaded successfully");
      return content;
    } else {
      _checkRateLimit(response.statusCode);
      throw Exception("Failed to download backup: ${response.statusCode}");
    }
  }

  /// Get backup metadata (timestamp) from metadata file
  Future<Map<String, dynamic>> getBackupMetadata() async {
    final gistId = await getExistingBackupGist();

    final response = await http.get(
      Uri.parse("$_baseUrl/gists/$gistId"),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final files = data["files"] as Map<String, dynamic>;
      final metadataFile = files[_backupFileName] as Map<String, dynamic>?;

      if (metadataFile == null) {
        return {};
      }

      final content = metadataFile["content"] as String;
      final metadata = json.decode(content) as Map<String, dynamic>;

      return {
        "timestamp": metadata["timestamp"] as String?,
        "appVersion": metadata["appVersion"] as String?,
      };
    } else {
      _checkRateLimit(response.statusCode);
      throw Exception("Failed to get backup metadata: ${response.statusCode}");
    }
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
      _checkRateLimit(response.statusCode);
      throw Exception("Failed to list gists: ${response.statusCode}");
    }

    final gists = json.decode(response.body) as List;

    for (final gist in gists) {
      final gistMap = gist as Map<String, dynamic>;
      final files = gistMap["files"] as Map<String, dynamic>?;
      if (files != null) {
        for (final fileName in files.keys) {
          if (_isBackupFile(fileName)) {
            return gistMap["id"] as String;
          }
        }
      }
    }

    return null;
  }

  String get _backupFileNameWithExtension {
    final compressionEnabled = _settingsBox?.get(
          AppConstants.compressionEnabledSetting,
          defaultValue: false,
        ) as bool? ??
        false;

    return compressionEnabled
        ? "$_backupFileName.json.gz"
        : "$_backupFileName.json";
  }

  bool _isBackupFile(String fileName) {
    return fileName == _backupFileName ||
        fileName == "$_backupFileName.json" ||
        fileName == "$_backupFileName.json.gz";
  }

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
