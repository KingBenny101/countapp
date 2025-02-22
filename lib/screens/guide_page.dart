import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guide"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              "A simple guide to using Count App.",
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              "Adding Counters:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildStepCard(
              "You can add counters by pressing the floating action button on the home page.",
            ),
            const SizedBox(height: 10),
            const Text(
              "Updating Counters:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildStepCard(
              "You can update a counter by simply tapping on it. This will allow you to increment or decrement the value.",
            ),
            const SizedBox(height: 10),
            const Text(
              "Deleting Counters:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildStepCard(
              "To delete a counter, long-press on the counter, and it will become available for deletion.",
            ),
            const SizedBox(height: 20),
            const Text(
              "Exporting Counters:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildStepCard(
              "Use the Export option in the menu to save your counters to a JSON file. You can specify the file name or let the app create one for you.",
            ),
            const SizedBox(height: 10),
            const Text(
              "Importing Counters:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildStepCard(
              "Use the Import option in the menu to load counters from a JSON file. Ensure the file is correctly formatted.",
            ),const SizedBox(height: 10),
            const Text(
              "Counter Info:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildStepCard(
              "To see info for a counter, long-press on the counter, and press the info button on the appbar.",
            ),
          ],
        ),
      ),
    );
  }
}
