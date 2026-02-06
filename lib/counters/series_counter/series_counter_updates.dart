import "package:countapp/counters/series_counter/series_counter.dart";
import "package:countapp/providers/counter_provider.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";

class SeriesCounterUpdatesPage extends StatefulWidget {
  const SeriesCounterUpdatesPage({
    super.key,
    required this.name,
    required this.counterIndex,
  });
  final String name;
  final int counterIndex;

  @override
  _SeriesCounterUpdatesPageState createState() =>
      _SeriesCounterUpdatesPageState();
}

class _SeriesCounterUpdatesPageState extends State<SeriesCounterUpdatesPage> {
  String _searchQuery = "";
  final Set<int> _selectedIndices = {};

  void _searchDate(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, CounterProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Updates?"),
        content: Text(
            "Are you sure you want to delete ${_selectedIndices.length} update(s)? This will adjust the counter value and history."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteCounterUpdates(
          widget.counterIndex, _selectedIndices.toList());
      if (mounted) {
        setState(() {
          _selectedIndices.clear();
        });
      }
    }
  }

  Future<void> _showEditDialog(
      BuildContext context, CounterProvider provider, int index) async {
    final counter = provider.counters[widget.counterIndex] as SeriesCounter;
    final originalDate = counter.updates[index];
    DateTime selectedDate = originalDate;
    final originalValue = counter.seriesValues[index];

    final cautionConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Caution"),
        content: const Text(
            "Editing updates can cause change in the metric. Proceed with caution."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Proceed"),
          ),
        ],
      ),
    );

    if (cautionConfirmed != true) return;

    if (!context.mounted) return;

    final valueController =
        TextEditingController(text: originalValue.toString());
    final formKey = GlobalKey<FormState>();

    final confirmedEdit = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Update"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("Date & Time"),
                  subtitle: Text(DateFormat("MMM d, yyyy - h:mm a")
                      .format(selectedDate.toLocal())),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      if (!context.mounted) return;
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (pickedTime != null) {
                        setDialogState(() {
                          selectedDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                TextFormField(
                  controller: valueController,
                  decoration: const InputDecoration(labelText: "Value"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Required";
                    if (double.tryParse(value) == null) return "Invalid number";
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );

    if (confirmedEdit == true) {
      final newValue = double.parse(valueController.text);
      await provider.editCounterUpdate(widget.counterIndex, index,
          newDate: selectedDate, newValue: newValue);
      if (mounted) {
        setState(() {
          _selectedIndices.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
      builder: (context, provider, child) {
        final counter = provider.counters[widget.counterIndex] as SeriesCounter;
        final updates = counter.updates;
        final values = counter.seriesValues;

        final List<int> filteredIndices = [];
        for (int i = 0; i < updates.length; i++) {
          final dateStr = DateFormat("MMM d, yyyy (EEEE) - h:mm a")
              .format(updates[i].toLocal());
          final valStr = values[i].toString();
          if (_searchQuery.isEmpty ||
              dateStr.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              valStr.contains(_searchQuery)) {
            filteredIndices.add(i);
          }
        }

        final isSelectionMode = _selectedIndices.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: isSelectionMode
                ? Text("${_selectedIndices.length} Selected")
                : Text("All Updates - ${widget.name}"),
            actions: [
              if (isSelectionMode) ...[
                if (_selectedIndices.length == 1)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(
                        context, provider, _selectedIndices.first),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(context, provider),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedIndices.clear();
                    });
                  },
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: SeriesSearchDelegate(
                        updates: updates,
                        values: values,
                        onSearch: _searchDate,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          body: ListView.builder(
            itemCount: filteredIndices.length,
            itemBuilder: (context, index) {
              final dataIndex = filteredIndices[index];
              final isSelected = _selectedIndices.contains(dataIndex);
              return _buildUpdateTile(
                  updates[dataIndex], values[dataIndex], isSelected, dataIndex);
            },
          ),
        );
      },
    );
  }

  Widget _buildUpdateTile(
      DateTime date, double value, bool isSelected, int originalIndex) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ListTile(
          leading: isSelected
              ? CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.check, color: Colors.white),
                )
              : const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.show_chart, color: Colors.white),
                ),
          title: Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.bold,
            ),
          ),
          subtitle: Text(
            DateFormat("MMM d, yyyy (EEEE) - h:mm a").format(date.toLocal()),
            style: const TextStyle(fontSize: 14),
          ),
          onTap: () {
            if (_selectedIndices.isNotEmpty) {
              _toggleSelection(originalIndex);
            }
          },
          onLongPress: () {
            _toggleSelection(originalIndex);
          },
        ),
      ),
    );
  }
}

class SeriesSearchDelegate extends SearchDelegate {
  SeriesSearchDelegate({
    required this.updates,
    required this.values,
    required this.onSearch,
  });
  final List<DateTime> updates;
  final List<double> values;
  final Function(String) onSearch;

  @override
  String get searchFieldLabel => "Search";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = <int>[];
    for (int i = 0; i < updates.length; i++) {
      final formattedDate = DateFormat("MMM d, yyyy (EEEE) - h:mm a")
          .format(updates[i].toLocal());
      final formattedValue = values[i].toStringAsFixed(2);
      if (query.isEmpty ||
          formattedDate.toLowerCase().contains(query.toLowerCase()) ||
          formattedValue.contains(query)) {
        suggestions.add(i);
      }
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final dataIndex = suggestions[index];
        return _buildUpdateTile(context, updates[dataIndex], values[dataIndex]);
      },
    );
  }

  Widget _buildUpdateTile(BuildContext context, DateTime date, double value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.show_chart, color: Colors.white),
          ),
          title: Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            DateFormat("MMM d, yyyy (EEEE) - h:mm a").format(date.toLocal()),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
