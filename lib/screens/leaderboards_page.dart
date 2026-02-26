import "dart:async";

import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/models/leaderboard.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/screens/leaderboard_detail_page.dart";
import "package:countapp/services/leaderboard_service.dart";
import "package:countapp/utils/constants.dart";
import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:provider/provider.dart";

class LeaderboardsPage extends StatefulWidget {
  const LeaderboardsPage({super.key});

  @override
  State<LeaderboardsPage> createState() => _LeaderboardsPageState();
}

class _LeaderboardsPageState extends State<LeaderboardsPage> {
  StreamSubscription? _watchSub;

  @override
  void initState() {
    super.initState();
    // Watch the leaderboards box and refresh list on any change
    try {
      _watchSub =
          Hive.box(AppConstants.leaderboardsBox).watch().listen((event) {
        setState(() {});
      });
    } catch (e) {
      debugPrint("Hive watch not available for leaderboards: $e");
    }
  }

  @override
  void dispose() {
    _watchSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final counterProvider = Provider.of<CounterProvider>(context);

    final items = LeaderboardService.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboards"),
      ),
      body: items.isEmpty
          ? const Center(child: Text("Add a Leaderboard"))
          : ReorderableListView.builder(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) async {
                await LeaderboardService.reorderLeaderboards(
                    oldIndex, newIndex);
                setState(() {});
              },
              itemBuilder: (context, index) {
                final lb = items[index];
                return Container(
                  key: ValueKey(lb.code),
                  child: Card(
                    elevation: 4,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: const Icon(Icons.leaderboard, size: 36),
                      title: Text(
                        lb.leaderboardName.isNotEmpty
                            ? lb.leaderboardName
                            : lb.code,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text("${lb.code} - ${lb.leaderboard.length} Joined"),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Center(
                            child: Icon(
                              Icons.drag_handle,
                              size: 20,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        if (!context.mounted) return;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LeaderboardDetailPage(code: lb.code),
                          ),
                        );
                        // Rebuild after returning to ensure any changes are reflected
                        if (context.mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showChoiceDialog(context, counterProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showChoiceDialog(
      BuildContext context, CounterProvider counterProvider) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Add Leaderboard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text("Join Leaderboard"),
              subtitle: const Text("Enter an existing code to join"),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showJoinDialog(context, counterProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box_outlined),
              title: const Text("Create Leaderboard"),
              subtitle: const Text("Start a new leaderboard and get a code"),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showCreateDialog(context, counterProvider);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> _showJoinDialog(
      BuildContext context, CounterProvider counterProvider) async {
    final codeController = TextEditingController();
    final userController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    BaseCounter? selected;
    if (counterProvider.counters.isNotEmpty) {
      selected = counterProvider.counters.first;
    }

    bool isLoading = false;
    final parentContext = context;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Join Leaderboard"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: "Code (6 chars, A-Z0-9)",
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required";
                      }
                      final v = value.toUpperCase().trim();
                      if (!RegExp(r"^[A-Z0-9]{6}$").hasMatch(v)) {
                        return "Code must be 6 uppercase letters or digits";
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: userController,
                    decoration: const InputDecoration(
                      labelText: "Your Name",
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 12),
                  if (counterProvider.counters.isEmpty)
                    const Text("No counters available. Create a counter first.")
                  else
                    DropdownButtonFormField<BaseCounter>(
                      initialValue: selected,
                      items: counterProvider.counters
                          .map((c) => DropdownMenuItem<BaseCounter>(
                                value: c,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (v) {
                              selected = v;
                            },
                      validator: (value) {
                        if (value == null) return "Must select a counter";
                        return null;
                      },
                      decoration:
                          const InputDecoration(
                        labelText: "Attach Counter",
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    isLoading ? null : () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        if (selected == null) return;

                        final code = codeController.text.toUpperCase().trim();
                        final user = userController.text.trim();

                        // Prevent duplicate local leaderboards with same code
                        final existing = LeaderboardService.getByCode(code);
                        if (existing != null) {
                          if (parentContext.mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              buildAppSnackBar(
                                  "A leaderboard with code $code already exists",
                                  success: false,
                                  context: parentContext),
                            );
                          }
                          return;
                        }

                        setState(() => isLoading = true);

                        final resultMap =
                            await LeaderboardService.addLeaderboard(
                          code: code,
                          userName: user,
                          counter: selected!,
                          attachedCounterId: selected?.id,
                        );

                        setState(() => isLoading = false);

                        if (resultMap["success"] == true &&
                            resultMap["leaderboard"] != null) {
                          if (parentContext.mounted) {
                            Navigator.of(parentContext).pop(true);
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              buildAppSnackBar("Joined/Created leaderboard",
                                  context: parentContext),
                            );
                          }
                        } else {
                          final msg = resultMap["message"] as String? ??
                              "Failed to create/join leaderboard";
                          // Debug print for server message
                          debugPrint(
                              "Leaderboard add failed for code $code: $msg");
                          if (parentContext.mounted) {
                            Navigator.of(parentContext).pop(false);
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              buildAppSnackBar(msg,
                                  success: false, context: parentContext),
                            );
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Confirm"),
              ),
            ],
          );
        });
      },
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _showCreateDialog(
      BuildContext context, CounterProvider counterProvider) async {
    final nameController = TextEditingController();
    final joiningNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    BaseCounter? selected;
    if (counterProvider.counters.isNotEmpty) {
      selected = counterProvider.counters.first;
    }

    bool isLoading = false;
    final parentContext = context;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Create Leaderboard"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Leaderboard Name",
                      prefixIcon: Icon(Icons.label_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: joiningNameController,
                    decoration: const InputDecoration(
                      labelText: "Your Name",
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 12),
                  if (counterProvider.counters.isEmpty)
                    const Text("No counters available. Create a counter first.")
                  else
                    DropdownButtonFormField<BaseCounter>(
                      initialValue: selected,
                      items: counterProvider.counters
                          .map((c) => DropdownMenuItem<BaseCounter>(
                                value: c,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (v) {
                              setState(() => selected = v);
                            },
                      validator: (value) {
                        if (value == null) return "Must select a counter";
                        return null;
                      },
                      decoration:
                          const InputDecoration(
                        labelText: "Attach Counter",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    "Counter type will be locked to the selected counter's type.",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        if (selected == null) return;

                        setState(() => isLoading = true);

                        final resultMap =
                            await LeaderboardService.createLeaderboard(
                          leaderboardName: nameController.text.trim(),
                          joiningName: joiningNameController.text.trim(),
                          counter: selected!,
                          attachedCounterId: selected?.id,
                        );

                        setState(() => isLoading = false);

                        if (resultMap["success"] == true &&
                            resultMap["leaderboard"] != null) {
                          final lb = resultMap["leaderboard"] as Leaderboard;
                          final code = lb.code;
                          if (parentContext.mounted) {
                            Navigator.of(parentContext).pop();
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              buildAppSnackBar(
                                  "Leaderboard created! Code: $code",
                                  context: parentContext),
                            );
                          }
                        } else {
                          final msg = resultMap["message"] as String? ??
                              "Failed to create leaderboard";
                          debugPrint("Create leaderboard failed: $msg");
                          if (parentContext.mounted) {
                            Navigator.of(parentContext).pop();
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              buildAppSnackBar(msg,
                                  success: false, context: parentContext),
                            );
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Create"),
              ),
            ],
          );
        });
      },
    );
  }
}
