import "package:countapp/utils/updates.dart";
import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:url_launcher/url_launcher.dart";

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = "Loading...";
  String repoUrl = "https://github.com/KingBenny101/countapp";
  String docsUrl = "https://kingbenny101.github.io/countapp/";

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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            "A simple application to help users keep track of their counts effortlessly.",
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          Align(
            child: ElevatedButton(
              onPressed: () => _launchURL(docsUrl),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "View Documentation",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      "Version: $version",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "© 2025 KingBenny101. All rights reserved.",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            child: ElevatedButton(
              onPressed: () => _launchURL(repoUrl),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.github,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "View Source on GitHub",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
