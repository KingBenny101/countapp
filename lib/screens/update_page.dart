import "package:countapp/utils/updates.dart";
import "package:flutter/material.dart";
import "package:pub_semver/pub_semver.dart";
import "package:url_launcher/url_launcher.dart";

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String updateText = "";
  bool isLoading = true;
  bool updateAvailable = false;

  @override
  void initState() {
    super.initState();
    _updateCheck();
  }

  Future<void> _updateCheck() async {
    setState(() {
      updateText = "Checking for updates...";
      isLoading = true;
      updateAvailable = false;
    });

    final checkInternet = await checkConnectivity();

    if (!checkInternet) {
      setState(() {
        updateText = "No internet connection. Please check your connection.";
      });
      isLoading = false;
      return;
    }

    final currentVersion = await getVersion();
    final latestVersion = await getLatestVersion();

    if (latestVersion == Version.parse("0.0.0")) {
      setState(() {
        updateText = "Failed to check for updates. Please try again later.";
      });
      isLoading = false;
      return;
    }

    if (currentVersion < latestVersion) {
      setState(() {
        updateText =
            "A newer version of the app is available. Please update to version $latestVersion.";
        updateAvailable = true;
      });
      isLoading = false;
      return;
    }

    setState(() {
      updateText =
          "You are running the latest version $currentVersion of the app.";
    });
    isLoading = false;
  }

  Future<void> _downloadUpdate() async {
    // Download the update
    print("Downloading update...");
    final url = Uri.parse("https://github.com/KingBenny101/countapp/releases");
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Updates"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading indicator or success icon based on the loading state
              if (isLoading)
                const CircularProgressIndicator()
              else
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 60,
                ),
              const SizedBox(height: 20),

              // Update text
              Text(
                updateText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),

              // Button to trigger update check
              ElevatedButton(
                onPressed: () {
                  if (updateAvailable) {
                    _downloadUpdate();
                  } else if (!isLoading) {
                    _updateCheck();
                  }
                },
                child: updateAvailable
                    ? const Text("Download")
                    : const Text("Check for Updates"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
