import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/counters/base/counter_factory.dart";
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
    await box.deleteAt(index);
    _counters.removeAt(index);
    notifyListeners();
  }

  Future<void> removeCounters(List<int> indices) async {
    final box = await _getBox();

    // Sort in reverse to avoid index shifting issues
    final sortedIndices = indices.toList()..sort((a, b) => b.compareTo(a));

    for (final index in sortedIndices) {
      await box.deleteAt(index);
      _counters.removeAt(index);
    }

    notifyListeners();
  }

  Future<void> updateCounter(BuildContext context, int index) async {
    final counter = _counters[index];
    final success = await counter.onInteraction(context);

    if (success) {
      final box = await _getBox();
      await box.putAt(index, counter.toJson());
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildAppSnackBar("Counter Updated Successfully!"),
        );
      }
    }
  }
}
