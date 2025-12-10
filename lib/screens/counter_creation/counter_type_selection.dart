import "package:countapp/counters/base/counter_factory.dart";
import "package:countapp/screens/counter_creation/tap_counter_config.dart";
import "package:flutter/material.dart";

class CounterTypeSelectionPage extends StatelessWidget {
  const CounterTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final availableTypes = CounterFactory.getAvailableTypes();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Counter Type"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: availableTypes.length,
        itemBuilder: (context, index) {
          final counterType = availableTypes[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(
                  counterType.icon,
                  color: Colors.white,
                ),
              ),
              title: Text(
                counterType.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  counterType.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _navigateToConfig(context, counterType.type);
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToConfig(BuildContext context, String type) {
    Widget configPage;

    switch (type) {
      case "tap":
        configPage = const TapCounterConfigPage();
        break;
      // Future counter types will be added here:
      // case "long_press":
      //   configPage = const LongPressCounterConfigPage();
      //   break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => configPage),
    );
  }
}
