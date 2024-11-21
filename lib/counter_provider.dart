import 'package:hive_ce/hive.dart';
import 'counter_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class CounterProvider with ChangeNotifier {
  List<Counter> _counters = [];

  List<Counter> get counters => _counters;

  Future<void> loadCounters() async {
    final box = await Hive.openBox<Counter>('countersBox');
    _counters = box.values.toList();
    notifyListeners();
  }

  Future<void> addCounter(Counter counter) async {
    final box = await Hive.openBox<Counter>('countersBox');
    await box.add(counter);
    _counters.add(counter);
    notifyListeners();
  }

  Future<void> removeCounter(int index) async {
    final box = await Hive.openBox<Counter>('countersBox');
    await box.deleteAt(index);
    _counters.removeAt(index);
    notifyListeners();
  }

  Future<void> updateCounter(BuildContext context, int index) async {
    final name = _counters[index].name;
    final type = _counters[index].type;
    final stepSize = _counters[index].stepSize;
    final lastUpdatedParsed = DateFormat('E, MMM d, yyyy hh:mm a')
        .format(_counters[index].lastUpdated!);

    // Show confirmation dialog before updating
    bool? confirmUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Update'),
          content: Text(
            '${type == 'increment' ? 'Increase' : 'Decrease'} the $name Counter by $stepSize? \nLast Updated: $lastUpdatedParsed',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel update
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Proceed with update
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmUpdate == true) {
      // Proceed with the update if the user confirmed
      if (type == 'increment') {
        _counters[index].value = _counters[index].value + stepSize;
      } else {
        _counters[index].value = _counters[index].value - stepSize;
      }

      _counters[index].lastUpdated = DateTime.now();
      final box = await Hive.openBox<Counter>('countersBox');
      await box.putAt(index, _counters[index]);
      notifyListeners();

      // Show a toast message for successful update
      Fluttertoast.showToast(
        msg: 'Counter Updated Successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
