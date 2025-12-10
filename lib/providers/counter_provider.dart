import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/counters/base/counter_factory.dart";
import "package:countapp/utils/constants.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:toastification/toastification.dart";

class CounterProvider with ChangeNotifier {
  List<BaseCounter> _counters = [];

  List<BaseCounter> get counters => _counters;

  Future<void> loadCounters() async {
    final box = await Hive.openBox(AppConstants.countersBox);
    _counters = box.values
        .map((json) => CounterFactory.fromJson(json as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> addCounter(BaseCounter counter) async {
    final box = await Hive.openBox(AppConstants.countersBox);
    await box.add(counter.toJson());
    _counters.add(counter);
    notifyListeners();
  }

  Future<void> removeCounter(int index) async {
    final box = await Hive.openBox(AppConstants.countersBox);
    await box.deleteAt(index);
    _counters.removeAt(index);
    notifyListeners();
  }

  Future<void> removeCounters(List<int> indices) async {
    final box = await Hive.openBox(AppConstants.countersBox);

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
      final box = await Hive.openBox(AppConstants.countersBox);
      await box.putAt(index, counter.toJson());
      notifyListeners();

      _showSuccessToast();
    }
  }

  void _showSuccessToast() {
    toastification.show(
      type: ToastificationType.success,
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.simple,
      title: const Text("Counter Updated Successfully!"),
      autoCloseDuration: const Duration(seconds: 2),
      closeOnClick: true,
    );
  }
}
