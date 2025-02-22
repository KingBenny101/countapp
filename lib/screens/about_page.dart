import "package:countapp/utils/updates.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = "Loading...";
  String repoUrl = "https://github.com/KingBenny101/countapp";

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

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(repoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Handle the error accordingly
      throw "Could not launch $repoUrl";
    }
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
            Align(
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 10),
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
                        "© 2024 KingBenny101. All rights reserved.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                  onTap: _launchURL,
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.github,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "View Source on GitHub",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
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
