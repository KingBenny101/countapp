import "package:countapp/utils/updates.dart";
import "package:flutter/material.dart";

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String updateText = "Checking for updates...";

  @override
  void initState() {
    super.initState();
    _updateCheck();
  }

  Future<void> _updateCheck() async {
    await Future.delayed(const Duration(seconds: 5));
    final currentVersion = await getVersion();
    final latestVersion = await getLatestVersion();

    if (currentVersion != latestVersion) {
      setState(() {
        updateText = "A new version of the app is available. Please update to version $latestVersion.";
      });
      return;
    }

    setState(() {
      updateText = "You are running the latest version $currentVersion of the app.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Check"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(
              updateText,
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
