import "dart:async";

import "package:countapp/models/leaderboard.dart";
import "package:countapp/services/leaderboard_service.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:intl/intl.dart";

class LeaderboardDetailPage extends StatefulWidget {
  const LeaderboardDetailPage({super.key, required this.code});
  final String code;

  @override
  State<LeaderboardDetailPage> createState() => _LeaderboardDetailPageState();
}

class _LeaderboardDetailPageState extends State<LeaderboardDetailPage> {
  Leaderboard? _board;
  bool _loading = false;
  StreamSubscription? _watchSub;

  @override
  void initState() {
    super.initState();
    // Load local data only (do not fetch on open)
    _board = LeaderboardService.getByCode(widget.code);

    // Watch for changes to this leaderboard in Hive and update UI
    try {
      _watchSub = Hive.box(AppConstants.leaderboardsBox)
          .watch(key: widget.code)
          .listen((event) {
        setState(() {
          _board = LeaderboardService.getByCode(widget.code);
        });
      });
    } catch (e) {
      // If watch not supported, ignore; UI can be refreshed manually
      debugPrint("Leaderboard watch not available: $e");
    }
  }

  @override
  void dispose() {
    _watchSub?.cancel();
    super.dispose();
  }

  // Return a background color for top ranks (1=gold, 2=silver, 3=bronze) and
  // the default primary color for the rest. These colors are slightly muted
  // for better appearance and contrast.
  Color _rankColor(int index, BuildContext context) {
    switch (index) {
      case 0:
        return const Color(0xFFDAA520); // Goldenrod (muted gold)
      case 1:
        return const Color(0xFFB0BEC5); // Blue-grey (muted silver)
      case 2:
        return const Color(0xFFB87333); // Copper (warmer bronze)
      default:
        return Theme.of(context).primaryColor;
    }
  }

  // Pick a text color that contrasts with the rank background.
  Color _rankTextColor(int index) {
    // Use black for lighter gold/silver, white for darker bronze and default.
    return (index == 0 || index == 1) ? Colors.black : Colors.white;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final lb = await LeaderboardService.fetchLeaderboard(widget.code);
    setState(() {
      _board = lb ?? _board; // keep local if fetch failed
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _board != null
        ? (_board!.leaderboardName.isNotEmpty
            ? _board!.leaderboardName
            : _board!.code)
        : widget.code;

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        actions: [
          IconButton(
            onPressed: () async {
              await _load();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  buildAppSnackBar("Leaderboard refreshed", context: context),
                );
              }
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete Leaderboard"),
                    content: const Text(
                        "Are you sure you want to delete this leaderboard locally?"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel")),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Delete")),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await LeaderboardService.deleteLeaderboard(widget.code);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    buildAppSnackBar("Leaderboard deleted", context: context),
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _board == null
              ? const Center(child: Text("No data available"))
              : ListView.builder(
                  itemCount: _board!.leaderboard.length,
                  itemBuilder: (context, index) {
                    final e = _board!.leaderboard[index];
                    final dateStr = DateFormat("yyyy-MM-dd HH:mm")
                        .format(e.timestamp.toLocal());
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: _rankColor(index, context),
                          child: Text("${index + 1}",
                              style: TextStyle(
                                  color: _rankTextColor(index),
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text(e.userName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(dateStr),
                        trailing: Text("${e.counterValue}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30)),
                      ),
                    );
                  },
                ),
    );
  }
}
