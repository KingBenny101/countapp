import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/counter_model.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';


class AddCounterPage extends StatefulWidget {
  const AddCounterPage({super.key});

  @override
  AddCounterPageState createState() => AddCounterPageState();
}

class AddCounterPageState extends State<AddCounterPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _stepSize = 1;
  int _initialCount = 0;
  bool _isIncrement = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a New Counter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Counter Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                onChanged: (value) {
                  _name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Step Size',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add_circle_outline_rounded),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  _stepSize = int.tryParse(value) ?? 1;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Initial Count',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.looks_one),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  _initialCount = int.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Type: ${_isIncrement ? 'Increment' : 'Decrement'}',
                      style: const TextStyle(fontSize: 16)),
                  Switch(
                    value: _isIncrement,
                    onChanged: (value) {
                      setState(() {
                        _isIncrement = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final newCounter = Counter(
              name: _name,
              value: _initialCount,
              type: _isIncrement ? 'increment' : 'decrement',
              stepSize: _stepSize,
              lastUpdated: DateTime.now(),
            );
            Provider.of<CounterProvider>(context, listen: false)
                .addCounter(newCounter);
            Navigator.pop(context);
            Fluttertoast.showToast(
              msg: "Counter Added Successfully!",
              toastLength: Toast.LENGTH_SHORT, 
              gravity: ToastGravity.BOTTOM, 
              timeInSecForIosWeb: 1, 
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        },
        tooltip: 'Add Counter',
        child: const Icon(Icons.add),
      ),
    );
  }
}