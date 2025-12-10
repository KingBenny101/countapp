import "package:countapp/counters/tap_counter.dart";
import "package:countapp/models/counter_model.dart";
import "package:countapp/utils/constants.dart";
import "package:hive_ce/hive.dart";

/// Utility to migrate old Counter data to new TapCounter format
class CounterMigration {
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

      print("Found ${oldBox.length} counters to migrate...");

      // Open new box
      final newBox = await Hive.openBox(AppConstants.countersBox);

      if (newBox.isNotEmpty) {
        // Migration already done
        print("Migration already completed.");
        await oldBox.close();
        return;
      }

      // Migrate each counter
      for (final oldCounter in oldBox.values) {
        final tapCounter = TapCounter(
          name: oldCounter.name,
          value: oldCounter.value,
          stepSize: oldCounter.stepSize,
          direction: oldCounter.type == "increment"
              ? TapDirection.increment
              : TapDirection.decrement,
          lastUpdated: oldCounter.lastUpdated,
          updates: oldCounter.updates,
        );

        await newBox.add(tapCounter.toJson());
      }

      print("Successfully migrated ${oldBox.length} counters!");

      // Clear old box after successful migration
      await oldBox.clear();
      await oldBox.close();
    } catch (e) {
      print("Migration error: $e");
      // Don't rethrow - allow app to continue
    }
  }
}
