import "dart:convert";

import "package:countapp/utils/updates.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:pub_semver/pub_semver.dart";
import "package:url_launcher/url_launcher.dart";

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  String _updateText = "";
  bool _isLoading = true;
  bool _updateAvailable = false;
  bool _checkFailed = false;

  @override
  void initState() {
    super.initState();
    _updateCheck();
  }

  Future<void> _updateCheck() async {
    setState(() {
      _updateText = "Checking for updates...";
      _isLoading = true;
      _updateAvailable = false;
      _checkFailed = false;
    });

    final checkInternet = await checkConnectivity();

    if (!checkInternet) {
      setState(() {
        _updateText = "No internet connection. Please check your connection!";
      });
      _isLoading = false;
      _checkFailed = true;
      return;
    }

    final currentVersion = await getVersion();
    final latestVersion = await getLatestVersion();

    if (latestVersion == Version.parse("0.0.0")) {
      setState(() {
        _updateText = "Failed to check for updates. Please try again later!";
      });
      _isLoading = false;
      _checkFailed = true;
      return;
    }

    if (currentVersion < latestVersion) {
      setState(() {
        _updateText =
            "A newer version $latestVersion is available. Always export your counters before updating!";
        _updateAvailable = true;
      });
      _isLoading = false;
      return;
    }

    setState(() {
      _updateText = "You are running the latest version $currentVersion";
    });
    _isLoading = false;
  }

  Future<void> _downloadUpdate() async {
    final url = Uri.parse(
        "https://api.github.com/repos/KingBenny101/countapp/releases/latest");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final downloadUrl = Uri.parse(data["html_url"] as String);
      await launchUrl(downloadUrl);
    } else {
      setState(() {
        _updateText = "Failed to download update. Please try again later";
      });
      _isLoading = false;
      _checkFailed = true;
    }
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
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_checkFailed)
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                )
              else
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 60,
                ),
              const SizedBox(height: 20),
              Text(
                _updateText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_updateAvailable) {
                    _downloadUpdate();
                  } else if (!_isLoading) {
                    _updateCheck();
                  }
                },
                child: _updateAvailable
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
