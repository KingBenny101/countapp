import "package:countapp/theme/theme_notifier.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";

Widget buildStepCard(String step) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        step,
        style: const TextStyle(fontSize: 16),
      ),
    ),
  );
}

Widget buildInfoCard(String infoName, String infoValue) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            infoName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            infoValue,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}

Widget buildCustomListTile(DateTime date) {
  final formattedDate =
      DateFormat("MMM d, yyyy (EEEE) - h:mm a").format(date.toLocal());

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Column(
      children: [
        ListTile(
          title: Text(
            formattedDate,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        ),
        const Divider(
          indent: 16,
          endIndent: 16,
          thickness: 1,
        ),
      ],
    ),
  );
}

SnackBar buildAppSnackBar(String message, {bool success = true}) {
  return SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    backgroundColor: success ? Colors.green : Colors.red,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    duration: const Duration(seconds: 2),
    margin: const EdgeInsets.symmetric(horizontal: 96, vertical: 8),
  );
}

Widget buildSummaryCard({
  required String title,
  required String count,
  required String date,
  required String timeRange,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4.0),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$date • $timeRange",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 20.0,
      ),
      title: const Text(
        "Color Theme",
        style: TextStyle(fontSize: 18),
      ),
      subtitle: Text(
        _getThemeName(themeNotifier.currentTheme),
        style: const TextStyle(fontSize: 14),
      ),
      trailing: DropdownButton<AppTheme>(
        value: themeNotifier.currentTheme,
        underline: const SizedBox(),
        focusColor: Colors.transparent,
        items: AppTheme.values.map((theme) {
          return DropdownMenuItem(
            value: theme,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getThemeColor(theme),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(_getThemeName(theme)),
              ],
            ),
          );
        }).toList(),
        onChanged: (theme) {
          if (theme != null) {
            themeNotifier.setTheme(theme);
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  Color _getThemeColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.blue:
        return Colors.blue;
      case AppTheme.purple:
        return Colors.purple;
      case AppTheme.green:
        return Colors.green;
      case AppTheme.red:
        return Colors.red;
      case AppTheme.orange:
        return Colors.orange;
      case AppTheme.pink:
        return Colors.pink;
    }
  }

  String _getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.blue:
        return "Blue";
      case AppTheme.purple:
        return "Purple";
      case AppTheme.green:
        return "Green";
      case AppTheme.red:
        return "Red";
      case AppTheme.orange:
        return "Orange";
      case AppTheme.pink:
        return "Pink";
    }
  }
}
