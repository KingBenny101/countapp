import 'package:flutter/material.dart';
import 'utils.dart';


class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A simple application to help users keep track of their counts effortlessly.',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),
            buildStepCard(
              '• Developed purely without any human-written Dart code, utilizing AI assistance from ChatGPT for all code generation.',
              
            ),
            buildStepCard(
              '• Create an arbitrary number of counters that can be added, accessed, and deleted from the main home page.',
              
            ),
            buildStepCard(
              '• Configurable options for each counter, such as increment or decrement type and step size.',
              
            ),
            buildStepCard(
              '• Future versions may incorporate local storage, with potential Google Firebase integration.',
              
            ),
            SizedBox(height: 20),
            Spacer(),
            Align(
              alignment: Alignment.center,
              child: Card(
                elevation: 0, // Removed shadow effect
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.all(15), // Increased padding for the card
                  child: Column(
                    children: [
                      Text(
                        'Version: 1.0.0',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '© 2024 KingBenny101. All rights reserved.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
