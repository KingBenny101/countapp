import 'package:hive_ce/hive.dart';
import 'package:countapp/models/counter_model.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(CounterAdapter());
  }
}
