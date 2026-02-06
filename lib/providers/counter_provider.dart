import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/counters/base/counter_factory.dart";
import "package:countapp/counters/series_counter/series_counter.dart";
import "package:countapp/counters/tap_counter/tap_counter.dart";
import "package:countapp/services/leaderboard_service.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";

class CounterProvider with ChangeNotifier {
  List<BaseCounter> _counters = [];
  Box? _box;

  List<BaseCounter> get counters => _counters;

  Future<Box> _getBox() async {
    _box ??= await Hive.openBox(AppConstants.countersBox);
    return _box!;
  }

  Future<void> loadCounters() async {
    final box = await _getBox();
    _counters = box.values
        .map((json) =>
            CounterFactory.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
    notifyListeners();
  }

  Future<void> addCounter(BaseCounter counter) async {
    final box = await _getBox();
    await box.add(counter.toJson());
    _counters.add(counter);
    notifyListeners();
  }

  Future<void> removeCounter(int index) async {
    final box = await _getBox();
    final counter = _counters[index];

    // Detach all leaderboards from this counter
    await _detachLeaderboards(counter.id);

    await box.deleteAt(index);
    _counters.removeAt(index);
    notifyListeners();
  }

  Future<void> removeCounters(List<int> indices) async {
    final box = await _getBox();

    // Sort in reverse to avoid index shifting issues
    final sortedIndices = indices.toList()..sort((a, b) => b.compareTo(a));

    for (final index in sortedIndices) {
      final counter = _counters[index];
      // Detach all leaderboards from this counter
      await _detachLeaderboards(counter.id);

      await box.deleteAt(index);
      _counters.removeAt(index);
    }

    notifyListeners();
  }

  Future<void> updateCounter(BuildContext context, int index) async {
    final counter = _counters[index];

    if (counter.isLocked) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar("Counter is locked, unlock counter to update.",
              context: context),
        );
      }
      return;
    }

    final success = await counter.onInteraction(context);

    if (success) {
      final box = await _getBox();
      await box.putAt(index, counter.toJson());
      notifyListeners();

      // Auto-post to leaderboards if enabled
      final settingsBox = Hive.box(AppConstants.settingsBox);
      final autoPost = settingsBox.get(AppConstants.leaderboardAutoPostSetting,
          defaultValue: true) as bool;

      if (autoPost) {
        final lbs = LeaderboardService.getAll()
            .where((l) => l.attachedCounterId == counter.id)
            .toList();
        for (final lb in lbs) {
          // Fetch fresh counter from storage to avoid stale reference
          final freshBox = await _getBox();
          final freshJson = freshBox.getAt(index) as Map<String, dynamic>?;
          if (freshJson != null) {
            final freshCounter = CounterFactory.fromJson(freshJson);
            // Fire and forget; don't block the UI — log result for debugging
            LeaderboardService.postUpdate(lb: lb, counter: freshCounter)
                .then((ok) {
              if (!ok) {
                debugPrint(
                    "Auto-post to leaderboard ${lb.code} failed for counter ${freshCounter.id}");
              } else {
                debugPrint(
                    "Auto-post to leaderboard ${lb.code} succeeded for counter ${freshCounter.id}");
              }
            });
          }
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar("Counter Updated Successfully!", context: context),
        );
      }
    }
  }

  /// Reorder counters and persist the new order to Hive
  Future<void> reorderCounters(int oldIndex, int newIndex) async {
    final box = await _getBox();

    // Adjust newIndex when moving down the list (as per ReorderableListView behaviour)
    final int targetIndex = (newIndex > oldIndex) ? newIndex - 1 : newIndex;

    final item = _counters.removeAt(oldIndex);
    _counters.insert(targetIndex, item);

    // Rebuild the box to reflect the new order
    await box.clear();
    for (final counter in _counters) {
      await box.add(counter.toJson());
    }

    notifyListeners();
  }

  Future<void> deleteCounterUpdates(
      int counterIndex, List<int> updateIndices) async {
    final counter = _counters[counterIndex];
    final sortedIndices = updateIndices.toList()
      ..sort((a, b) => b.compareTo(a));

    if (counter is TapCounter) {
      for (final index in sortedIndices) {
        if (index < counter.updates.length) {
          counter.updates.removeAt(index);
          if (counter.isIncrement) {
            counter.value -= counter.stepSize;
          } else {
            counter.value += counter.stepSize;
          }
        }
      }
      if (counter.updates.isNotEmpty) {
        counter.lastUpdated = counter.updates.first;
      } else {
        counter.lastUpdated = null;
      }
    } else if (counter is SeriesCounter) {
      for (final index in sortedIndices) {
        if (index < counter.updates.length &&
            index < counter.seriesValues.length) {
          counter.updates.removeAt(index);
          counter.seriesValues.removeAt(index);
        }
      }
      if (counter.updates.isNotEmpty) {
        counter.lastUpdated = counter.updates.first;
        counter.value = counter.seriesValues.first;
      } else {
        counter.lastUpdated = null;
        counter.value = 0;
      }
    }

    final box = await _getBox();
    await box.putAt(counterIndex, counter.toJson());
    notifyListeners();
  }

  Future<void> editCounterUpdate(int counterIndex, int updateIndex,
      {DateTime? newDate, double? newValue}) async {
    final counter = _counters[counterIndex];

    if (counter is TapCounter) {
      if (newDate != null && updateIndex < counter.updates.length) {
        counter.updates[updateIndex] = newDate;
        // Sort updates descending (newest first)
        counter.updates.sort((a, b) => b.compareTo(a));
        counter.lastUpdated =
            counter.updates.isNotEmpty ? counter.updates.first : null;
      }
    } else if (counter is SeriesCounter) {
      bool changed = false;
      if (newDate != null && updateIndex < counter.updates.length) {
        counter.updates[updateIndex] = newDate;
        changed = true;
      }
      if (newValue != null && updateIndex < counter.seriesValues.length) {
        counter.seriesValues[updateIndex] = newValue;
        changed = true;
      }

      if (changed) {
        // Zip updates and values to maintain relationship during sort
        final zipped = List.generate(
          counter.updates.length,
          (i) => MapEntry(counter.updates[i], counter.seriesValues[i]),
        );

        // Sort by date descending
        zipped.sort((a, b) => b.key.compareTo(a.key));

        // Unzip back into counter lists
        counter.updates = zipped.map((e) => e.key).toList();
        counter.seriesValues = zipped.map((e) => e.value).toList();

        // Update current value and last updated timestamp to reflect the new newest entry
        if (counter.updates.isNotEmpty) {
          counter.lastUpdated = counter.updates.first;
          counter.value = counter.seriesValues.first;
        } else {
          counter.lastUpdated = null;
          counter.value = 0;
        }
      }
    }

    final box = await _getBox();
    await box.putAt(counterIndex, counter.toJson());
    notifyListeners();
  }

  /// Detach all leaderboards from a counter when it is deleted
  Future<void> _detachLeaderboards(String counterId) async {
    final attachedLbs = LeaderboardService.getAll()
        .where((lb) => lb.attachedCounterId == counterId)
        .toList();

    for (final lb in attachedLbs) {
      lb.attachedCounterId = null;
      await LeaderboardService.updateLeaderboardMetadata(lb);
    }
  }

  /// Toggle the lock status of a counter
  Future<void> toggleCounterLock(int index) async {
    if (index < 0 || index >= _counters.length) return;

    final counter = _counters[index];
    counter.isLocked = !counter.isLocked;

    final box = await _getBox();
    await box.putAt(index, counter.toJson());
    notifyListeners();
  }
}
