import "package:countapp/models/counter_model.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:intl/intl.dart";
import "package:toastification/toastification.dart";

class CounterProvider with ChangeNotifier {
  List<Counter> _counters = [];

  List<Counter> get counters => _counters;

  Future<void> loadCounters() async {
    final box = await Hive.openBox<Counter>("countersBox");
    _counters = box.values.toList();
    notifyListeners();
  }

  Future<void> addCounter(Counter counter) async {
    final box = await Hive.openBox<Counter>("countersBox");
    await box.add(counter);
    _counters.add(counter);
    notifyListeners();
  }

  Future<void> removeCounter(int index) async {
    final box = await Hive.openBox<Counter>("countersBox");
    await box.deleteAt(index);
    _counters.removeAt(index);
    notifyListeners();
  }

  Future<void> updateCounter(BuildContext context, int index) async {
    final name = _counters[index].name;
    final type = _counters[index].type;
    final stepSize = _counters[index].stepSize;
    final lastUpdatedParsed = DateFormat("E, MMM d, yyyy hh:mm a")
        .format(_counters[index].lastUpdated!);

    // Show confirmation dialog before updating
    final bool? confirmUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Update"),
          content: Text(
            '${type == 'increment' ? 'Increase' : 'Decrease'} the $name Counter by $stepSize? \nLast Updated: $lastUpdatedParsed',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel update
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Proceed with update
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirmUpdate == true) {
      // Proceed with the update if the user confirmed
      if (type == "increment") {
        _counters[index].value = _counters[index].value + stepSize;
      } else {
        _counters[index].value = _counters[index].value - stepSize;
      }

      final currTime = DateTime.now();
      _counters[index].lastUpdated = currTime;
      _counters[index].updates.insert(0, currTime);
      final box = await Hive.openBox<Counter>("countersBox");
      await box.putAt(index, _counters[index]);
      notifyListeners();

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
}
