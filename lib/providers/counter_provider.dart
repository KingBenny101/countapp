import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/counters/base/counter_factory.dart";
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
          buildAppSnackBar("Counter is locked, unlock counter to update."),
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
          buildAppSnackBar("Counter Updated Successfully!"),
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
