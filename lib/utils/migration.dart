import "package:countapp/counters/tap_counter/tap_counter.dart";
import "package:countapp/models/counter_model.dart";
import "package:countapp/utils/constants.dart";
import "package:flutter/foundation.dart";
import "package:hive_ce/hive.dart";

/// Utility to migrate old Counter data to new TapCounter format
class CounterMigration {
  CounterMigration._();

  /// Check if migration is needed and perform it
  static Future<void> migrateIfNeeded() async {
    try {
      // Check if old box exists and has data
      final oldBox = await Hive.openBox<Counter>("countersBox");

      if (oldBox.isEmpty) {
        // No old data to migrate
        await oldBox.close();
        return;
      }

      debugPrint("Found ${oldBox.length} counters to migrate...");

      // Open new box
      final newBox = await Hive.openBox(AppConstants.countersBox);

      if (newBox.isNotEmpty) {
        // Migration already done
        debugPrint("Migration already completed.");
        await oldBox.close();
        return;
      }

      // Migrate each counter
      for (final oldCounter in oldBox.values) {
        final tapCounter = TapCounter(
          name: oldCounter.name,
          value: oldCounter.value,
          stepSize: oldCounter.stepSize,
          isIncrement: oldCounter.type == "increment",
          lastUpdated: oldCounter.lastUpdated,
          updates: oldCounter.updates,
        );

        await newBox.add(tapCounter.toJson());
      }

      debugPrint("Successfully migrated ${oldBox.length} counters!");

      // Clear old box after successful migration
      await oldBox.clear();
      await oldBox.close();
    } catch (e) {
      debugPrint("Migration error: $e");
      // Don't rethrow - allow app to continue
    }
  }
}
