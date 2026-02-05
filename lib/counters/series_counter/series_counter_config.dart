import "package:countapp/counters/series_counter/series_counter.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

class SeriesCounterConfigPage extends StatefulWidget {
  const SeriesCounterConfigPage({super.key});

  @override
  SeriesCounterConfigPageState createState() => SeriesCounterConfigPageState();
}

class SeriesCounterConfigPageState extends State<SeriesCounterConfigPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _description = "";
  double _initialValue = AppConstants.defaultInitialValue.toDouble();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create a Series Counter")),
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
                    labelText: "Description (Optional)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  onChanged: (value) {
                    _description = value;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Initial Value",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.looks_one),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                  ],
                  initialValue: _initialValue.toString(),
                  onChanged: (value) {
                    _initialValue = double.tryParse(value) ??
                        AppConstants.defaultInitialValue.toDouble();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a value";
                    }
                    if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final counterProvider =
                Provider.of<CounterProvider>(context, listen: false);

            final counter = SeriesCounter(
              name: _name,
              value: _initialValue,
              description: _description,
              seriesValues: [_initialValue],
              lastUpdated: DateTime.now(),
              updates: [DateTime.now()],
            );

            await counterProvider.addCounter(counter);

            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                buildAppSnackBar("Counter Added Successfully!",
                    context: context),
              );
            }
          }
        },
        tooltip: "Add Counter",
        child: const Icon(Icons.add),
      ),
    );
  }
}
