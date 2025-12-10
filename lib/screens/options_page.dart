import "package:countapp/theme/theme_notifier.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Options"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5,
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      themeNotifier.toggleTheme();
                    },
                  ),
                ),
                const Divider(height: 1),
                const ThemeSelector(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
