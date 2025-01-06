import "package:countapp/utils.dart";
import "package:flutter/material.dart";

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final tmp = await getVersion();
    setState(() {
      version = tmp.canonicalizedVersion; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: const Text("About"),
  ),
  body: Padding(
    padding: const EdgeInsets.all(24.0),
    child: ListView(
      children: [
        const Text(
          "A simple application to help users keep track of their counts effortlessly.",
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),
        buildStepCard(
          "Developed almost without any human-written Dart code, utilizing AI assistance from ChatGPT for all code generation.",
        ),
        buildStepCard(
          "Create an arbitrary number of counters that can be added, accessed, and deleted from the main home page.",
        ),
        buildStepCard(
          "Configurable options for each counter, such as increment or decrement type and step size.",
        ),
        buildStepCard(
          "Future versions may incorporate local storage, with potential Google Firebase integration.",
        ),
        const SizedBox(height: 20),
        Align(
          child: Card(
            elevation: 0, // Removed shadow effect
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(15), // Increased padding for the card
              child: Column(
                children: [
                  Text(
                    "Version: $version", // Display the dynamically fetched version
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "© 2024 KingBenny101. All rights reserved.",
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
