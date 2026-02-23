import "dart:convert";
import "dart:io";

import "package:archive/archive_io.dart";
import "package:countapp/counters/base/counter_factory.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/permissions.dart";
import "package:flutter/foundation.dart";
import "package:hive_ce/hive.dart";

Future<bool> exportJSON(String exportFilePath) async {
  final bool hasPermission = await checkAndRequestStoragePermission();

  if (hasPermission) {
    try {
      final box = Hive.isBoxOpen(AppConstants.countersBox)
          ? Hive.box(AppConstants.countersBox)
          : await Hive.openBox(AppConstants.countersBox);
      
      // Safely get settings box with error handling
      Box? settingsBox;
      bool compressionEnabled = false;
      try {
        settingsBox = Hive.isBoxOpen(AppConstants.settingsBox)
            ? Hive.box(AppConstants.settingsBox)
            : await Hive.openBox(AppConstants.settingsBox);
        
        compressionEnabled = settingsBox.get(
          AppConstants.compressionEnabledSetting,
          defaultValue: false,
        ) as bool;
      } catch (e) {
        debugPrint("[Export] Warning: Failed to read compression setting: $e, defaulting to false");
        compressionEnabled = false;
      }

      final file = File(exportFilePath);
      final counters = box.values.toList();
      final jsonCounters = json.encode(counters);

      if (compressionEnabled) {
        // Compress the JSON data
        final bytes = utf8.encode(jsonCounters);
        const encoder = GZipEncoder();
        final compressedBytes = encoder.encode(bytes);
        await file.writeAsBytes(compressedBytes);
      } else {
        await file.writeAsString(jsonCounters);
      }
      return true;
    } catch (e) {
      debugPrint("[Export] Error during export: $e");
      return false;
    }
  } else {
    return false;
  }
}

Future<void> importJSON(
  CounterProvider counterProvider,
  String importFilePath,
) async {
  try {
    final box = Hive.isBoxOpen(AppConstants.countersBox)
        ? Hive.box(AppConstants.countersBox)
        : await Hive.openBox(AppConstants.countersBox);
    final file = File(importFilePath);

    // Try to detect if file is compressed
    String jsonCounters;
    try {
      // First try reading as compressed
      final bytes = await file.readAsBytes();

      // Check if file is gzip compressed (magic bytes: 1f 8b)
      if (bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
        // File is gzip compressed
        const decoder = GZipDecoder();
        try {
          final decompressedBytes = decoder.decodeBytes(bytes);
          jsonCounters = utf8.decode(decompressedBytes);
        } catch (e) {
          debugPrint("[Import] Gzip decompression failed: $e, trying raw read");
          throw Exception("File is corrupted or has invalid compression format.");
        }
      } else {
        // File is not compressed, try reading as string
        jsonCounters = await file.readAsString();
      }
    } catch (e) {
      if (e.toString().contains("corrupted")) {
        rethrow;
      }
      // If gzip decoding fails, fall back to reading as string
      debugPrint("[Import] Error reading file: $e, attempting fallback");
      jsonCounters = await file.readAsString();
    }

    // Validate JSON format
    late List<dynamic> countersData;
    try {
      countersData = json.decode(jsonCounters) as List<dynamic>;
    } catch (e) {
      throw Exception("Backup file contains invalid JSON data: $e");
    }

    // Validate before clearing
    if (countersData.isEmpty) {
      throw Exception("Backup file is empty.");
    }

    // Convert each JSON object to BaseCounter using factory
    final List<Map<String, dynamic>> counters = countersData.map((data) {
      // Convert dynamic map to proper Map<String, dynamic>
      final jsonMap = Map<String, dynamic>.from(data as Map);
      // Use factory to parse and re-serialize
      return CounterFactory.fromJson(jsonMap).toJson();
    }).toList();

    // Clear and restore to Hive
    await box.clear();
    await box.addAll(counters);
    await counterProvider.loadCounters();
  } catch (e) {
    debugPrint("[Import] Import failed: $e");
    rethrow;
  }
}
