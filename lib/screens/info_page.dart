import "package:countapp/utils/updates.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:url_launcher/url_launcher.dart";

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage>
    with SingleTickerProviderStateMixin {
  String version = "Loading...";
  String repoUrl = "https://github.com/KingBenny101/countapp";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVersion();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    final tmp = await getVersion();
    setState(() {
      version = tmp.canonicalizedVersion;
    });
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(repoUrl);
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Info"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Guide"),
            Tab(text: "About"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGuidePage(),
          _buildAboutPage(),
        ],
      ),
    );
  }

  Widget _buildGuidePage() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
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
        ),
        const SizedBox(height: 10),
        const Text(
          "Counter Info:",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        buildStepCard(
          "To see info for a counter, long-press on the counter, and press the info button on the appbar.",
        ),
      ],
    );
  }

  Widget _buildAboutPage() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text(
          "A simple application to help users keep track of their counts effortlessly.",
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),
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
        Align(
          child: ElevatedButton(
            onPressed: _launchURL,
            child: const Row(
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
      ],
    );
  }
}
