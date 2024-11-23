import 'package:countapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_ce/hive.dart';
import 'package:provider/provider.dart';
import 'add_counter_page.dart';
import '../models/counter_model.dart';
import 'how_to_use_page.dart';
import '../theme/theme_notifier.dart';
import 'about_page.dart';
import '../providers/counter_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<bool> selectedCounters = [];
  bool isSelecting = false;

  @override
  void initState() {
    super.initState();
    final counterProvider =
        Provider.of<CounterProvider>(context, listen: false);
    counterProvider
        .loadCounters(); 
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final counterProvider = Provider.of<CounterProvider>(context);

    bool isUpdating = false;

    if (selectedCounters.length != counterProvider.counters.length) {
      selectedCounters =
          List<bool>.filled(counterProvider.counters.length, false);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Count App'),
        actions: isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      isSelecting = false;
                      selectedCounters = List<bool>.filled(
                          counterProvider.counters.length, false);
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
                    if (isSelecting) {
                      setState(() {
                        selectedCounters[index] = !selectedCounters[index];
                      });
                    } else if (!isUpdating) {
                      setState(() {
                        isUpdating = true;
                      });

                      await Provider.of<CounterProvider>(context, listen: false)
                          .updateCounter(context, index);

                      setState(() {
                        isUpdating = false;
                      });
                    }
                  },
                  onLongPress: () {
                    selectedCounters[index] = true;
                    setState(() {
                      isSelecting = true;
                    });
                  },
                  child: Card(
                    elevation: 4,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isSelecting
                              ? Checkbox(
                                  value: selectedCounters[index],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCounters[index] = value!;
                                    });
                                  },
                                )
                              : const SizedBox(width: 8),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              counter.type == 'increment' ? '+' : '-',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      title: Text(
                        counter.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        counter.type == 'increment'
                            ? 'Step Size: +${counter.stepSize}'
                            : 'Step Size: -${counter.stepSize}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${counter.value}',
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
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
          if (isSelecting && selectedCounters.any((selected) => selected))
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog before deleting
                  bool? confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                          'Delete the selected Counters?',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // Cancel delete
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(true); // Proceed with delete
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true) {
                    final selectedCount =
                        selectedCounters.where((selected) => selected).length;

                    if (selectedCount > 0) {
                      // Get the Hive box
                      var box = Hive.box<Counter>('countersBox');

                      // Remove selected counters from the Hive box and in-memory list
                      for (int index = counterProvider.counters.length - 1;
                          index >= 0;
                          index--) {
                        if (selectedCounters[index]) {
                          // Remove from Hive
                          box.deleteAt(index);
                          // Remove from the in-memory list
                          counterProvider.counters.removeAt(index);
                        }
                      }

                      setState(() {
                        selectedCounters = List<bool>.filled(
                            counterProvider.counters.length, false);
                        isSelecting = false;
                      });

                      // Show a toast message for successful delete
                      Fluttertoast.showToast(
                        msg: '$selectedCount Counters Deleted Successfully!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
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
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/icon/android/icon.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Count App',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child:
                          const Text('Options', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  ListTile(
                    title: const Text('Toggle Theme'),
                    trailing: Switch(
                      value: themeNotifier.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeNotifier.toggleTheme();
                      },
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text('Import', style: TextStyle(fontSize: 18)),
              ),
              onTap: () {
                importJSON(counterProvider,'D:/Code/countapp/export.json');
              },
              splashColor: Colors.transparent,
            ),ListTile(
              leading: const Icon(Icons.file_upload),
              title: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text('Export', style: TextStyle(fontSize: 18)),
              ),
              onTap: () {
                exportJSON('D:/Code/countapp/export.json');
              },
              splashColor: Colors.transparent,
            ),ListTile(
              leading: const Icon(Icons.help_outline),
              title: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text('How to Use', style: TextStyle(fontSize: 18)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HowToUsePage()),
                );
              },
              splashColor: Colors.transparent,
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: const Text('About', style: TextStyle(fontSize: 18)),
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
               splashColor: Colors.transparent,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          isSelecting = false;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCounterPage()),
          );
        },
        tooltip: 'Add Counter',
        child: const Icon(Icons.add),
      ),
    );
  }
}
