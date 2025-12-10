import "package:countapp/counters/tap_counter/tap_counter.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

class TapCounterConfigPage extends StatefulWidget {
  const TapCounterConfigPage({super.key});

  @override
  TapCounterConfigPageState createState() => TapCounterConfigPageState();
}

class TapCounterConfigPageState extends State<TapCounterConfigPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  int _stepSize = AppConstants.defaultStepSize;
  int _initialCount = AppConstants.defaultInitialValue;
  bool _isIncrement = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create a Tap Counter")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Counter Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                  onChanged: (value) {
                    _name = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Step Size",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add_circle_outline_rounded),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  initialValue: _stepSize.toString(),
                  onChanged: (value) {
                    _stepSize =
                        int.tryParse(value) ?? AppConstants.defaultStepSize;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Initial Count",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.looks_one),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  initialValue: _initialCount.toString(),
                  onChanged: (value) {
                    _initialCount =
                        int.tryParse(value) ?? AppConstants.defaultInitialValue;
                  },
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (MediaQuery.of(context).orientation ==
                        Orientation.landscape) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Direction: ${_isIncrement ? 'Increment' : 'Decrement'}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Switch(
                            value: _isIncrement,
                            onChanged: (value) {
                              setState(() {
                                _isIncrement = value;
                              });
                            },
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Direction: ${_isIncrement ? 'Increment' : 'Decrement'}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Switch(
                            value: _isIncrement,
                            onChanged: (value) {
                              setState(() {
                                _isIncrement = value;
                              });
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final newCounter = TapCounter(
              name: _name,
              value: _initialCount,
              stepSize: _stepSize,
              isIncrement: _isIncrement,
              lastUpdated: DateTime.now(),
            );
            Provider.of<CounterProvider>(context, listen: false)
                .addCounter(newCounter);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                buildAppSnackBar("Counter Added Successfully!"),
              );
              Navigator.pop(context);
            }
          }
        },
        tooltip: "Add Counter",
        child: const Icon(Icons.add),
      ),
    );
  }
}
