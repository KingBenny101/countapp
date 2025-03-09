import "package:countapp/models/counter_model.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:countapp/screens/add_counter_page.dart";
import "package:countapp/screens/info_page.dart";
import "package:countapp/utils/files.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:hive_ce/hive.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "package:toastification/toastification.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<bool> _selectedCounters = [];
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    final counterProvider =
        Provider.of<CounterProvider>(context, listen: false);
    counterProvider.loadCounters();
  }

  @override
  Widget build(BuildContext context) {
    final counterProvider = Provider.of<CounterProvider>(context);

    bool isUpdating = false;

    if (_selectedCounters.length != counterProvider.counters.length) {
      _selectedCounters =
          List<bool>.filled(counterProvider.counters.length, false);
    }

    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return GestureDetector(
      onTap: () {
        if (_isSelecting) {
          setState(() {
            _isSelecting = false;
            _selectedCounters = List<bool>.filled(
              counterProvider.counters.length,
              false,
            );
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Count App"),
          actions: _isSelecting
              ? [
                  if (_selectedCounters.where((selected) => selected).length ==
                      1)
                    IconButton(
                      icon: const Icon(Icons.bar_chart),
                      onPressed: () {
                        _isSelecting = false;
                        final index = _selectedCounters
                            .indexWhere((selected) => selected);
                        _selectedCounters = List<bool>.filled(
                          counterProvider.counters.length,
                          false,
                        );
                        FocusScope.of(context).unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InfoPage(index: index),
                          ),
                        );
                      },
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSelecting = false;
                        _selectedCounters = List<bool>.filled(
                          counterProvider.counters.length,
                          false,
                        );
                      });
                    },
                  ),
                ]
              : null,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: counterProvider.counters.length,
                itemBuilder: (context, index) {
                  final counter = counterProvider.counters[index];
                  return GestureDetector(
                    onTap: () async {
                      if (_isSelecting) {
                        setState(() {
                          _selectedCounters[index] = !_selectedCounters[index];
                        });
                      } else if (!isUpdating) {
                        setState(() {
                          isUpdating = true;
                        });

                        await Provider.of<CounterProvider>(
                          context,
                          listen: false,
                        ).updateCounter(context, index);

                        setState(() {
                          isUpdating = false;
                        });
                      }
                    },
                    onLongPress: () {
                      _selectedCounters[index] = true;
                      setState(() {
                        _isSelecting = true;
                      });
                    },
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: animation,
                                    axis: Axis.horizontal,
                                    child: child,
                                  ),
                                );
                              },
                              child: _isSelecting
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Checkbox(
                                        value: _selectedCounters[index],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCounters[index] = value!;
                                          });
                                        },
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 8,
                                    ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              width: _isSelecting ? 40 : 48,
                              height: _isSelecting ? 40 : 48,
                              child: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(
                                  counter.type == "increment"
                                      ? Icons.add
                                      : Icons.remove,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        title: Text(
                          counter.name,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        subtitle: Text(
                          counter.type == "increment"
                              ? "Step Size: +${counter.stepSize}"
                              : "Step Size: -${counter.stepSize}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${counter.value}",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: textColor),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isSelecting && _selectedCounters.any((selected) => selected))
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    // Show confirmation dialog before deleting
                    final bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm Deletion"),
                          content: const Text(
                            "Delete the selected Counters?",
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(false); // Cancel delete
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(true); // Proceed with delete
                              },
                              child: const Text("Confirm"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      final selectedCount = _selectedCounters
                          .where((selected) => selected)
                          .length;

                      if (selectedCount > 0) {
                        // Get the Hive box
                        final box = Hive.box<Counter>("countersBox");

                        // Remove selected counters from the Hive box and in-memory list
                        for (int index = counterProvider.counters.length - 1;
                            index >= 0;
                            index--) {
                          if (_selectedCounters[index]) {
                            // Remove from Hive
                            box.deleteAt(index);
                            // Remove from the in-memory list
                            counterProvider.counters.removeAt(index);
                          }
                        }

                        setState(() {
                          _selectedCounters = List<bool>.filled(
                            counterProvider.counters.length,
                            false,
                          );
                          _isSelecting = false;
                        });

                        toastification.show(
                          type: ToastificationType.success,
                          alignment: Alignment.bottomCenter,
                          style: ToastificationStyle.simple,
                          title: Text(
                            "$selectedCount Counters Deleted Successfully!",
                          ),
                          autoCloseDuration: const Duration(seconds: 2),
                          closeOnClick: true,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.delete, size: 30),
                ),
              ),
          ],
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: [
                DrawerHeader(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            "assets/icon/android/icon.png",
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Count App",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.update),
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Text("Updates",
                        style: TextStyle(fontSize: 18, color: textColor)),
                  ),
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    await Navigator.pushNamed(context, "/updates");
                  },
                  splashColor: Colors.transparent,
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Text("Options",
                        style: TextStyle(fontSize: 18, color: textColor)),
                  ),
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    await Navigator.pushNamed(context, "/options");
                  },
                  splashColor: Colors.transparent,
                ),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Text("Import",
                        style: TextStyle(fontSize: 18, color: textColor)),
                  ),
                  onTap: () async {
                    final FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ["json"],
                    );

                    if (result != null) {
                      final String filePath = result.files.single.path!;
                      await importJSON(counterProvider, filePath);

                      toastification.show(
                        type: ToastificationType.success,
                        alignment: Alignment.bottomCenter,
                        style: ToastificationStyle.simple,
                        title: const Text("Counters Imported Successfully!"),
                        autoCloseDuration: const Duration(seconds: 2),
                        closeOnClick: true,
                      );
                    }
                  },
                  splashColor: Colors.transparent,
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Text("Export",
                        style: TextStyle(fontSize: 18, color: textColor)),
                  ),
                  onTap: () async {
                    final String? selectedDirectory =
                        await FilePicker.platform.getDirectoryPath();

                    if (selectedDirectory != null) {
                      final TextEditingController fileNameController =
                          TextEditingController();
                      final formKey = GlobalKey<FormState>();

                      final DateTime now = DateTime.now();
                      final DateFormat formatter =
                          DateFormat("yyyy-MM-dd_HH-mm-ss");
                      final String fileNameLabel = formatter.format(now);

                      if (!context.mounted) return;

                      final bool? confirmExport = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Export Counters to JSON"),
                            content: Form(
                              key: formKey,
                              child: TextFormField(
                                controller: fileNameController,
                                decoration: InputDecoration(
                                  labelText: "File Name",
                                  hintText: "$fileNameLabel.json",
                                ),
                                validator: (value) {
                                  final invalidCharacters =
                                      RegExp(r'[<>:"/\\|?*]');
                                  if (value != null &&
                                      invalidCharacters.hasMatch(value)) {
                                    return "Invalid characters in file name";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(false); // User canceled
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    Navigator.of(context)
                                        .pop(true); // User confirmed
                                  }
                                },
                                child: const Text("Confirm"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmExport == true) {
                        String fileName = fileNameController.text.trim();

                        if (fileName.isEmpty) {
                          fileName = fileNameLabel;
                        }

                        if (!fileName.endsWith(".json")) {
                          fileName += ".json";
                        }

                        final exportFilePath = "$selectedDirectory/$fileName";
                        await exportJSON(exportFilePath);
                      }
                    }
                  },
                  splashColor: Colors.transparent,
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Text(
                      "Guide",
                      style: TextStyle(fontSize: 18, color: textColor),
                    ),
                  ),
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    await Navigator.pushNamed(context, "/guide");
                  },
                  splashColor: Colors.transparent,
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Text("About",
                        style: TextStyle(fontSize: 18, color: textColor)),
                  ),
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    await Navigator.pushNamed(context, "/about");
                  },
                  splashColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _isSelecting = false;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCounterPage()),
            );
          },
          tooltip: "Add Counter",
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
