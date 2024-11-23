import 'package:flutter/material.dart';
import '../utils.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use'),
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A simple guide to using the features of Count App.',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 20),
            Text(
              'Adding Counters:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildStepCard('• You can add counters by pressing the floating action button on the home page.'),
            const SizedBox(height: 10),
            Text(
              'Updating Counters:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildStepCard('• You can update a counter by simply tapping on it. This will allow you to increment or decrement the value.'),
            const SizedBox(height: 10),
            Text(
              'Deleting Counters:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildStepCard('• To delete a counter, long-press on the counter, and it will become available for deletion.'),
          ],
        ),
      ),
    );
  }

}
