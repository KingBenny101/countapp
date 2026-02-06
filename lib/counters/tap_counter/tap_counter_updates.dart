import "package:countapp/providers/counter_provider.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";

class TapCounterUpdatesPage extends StatefulWidget {
  const TapCounterUpdatesPage({
    super.key,
    required this.name,
    required this.counterIndex,
  });
  final String name;
  final int counterIndex;

  @override
  _TapCounterUpdatesPageState createState() => _TapCounterUpdatesPageState();
}

class _TapCounterUpdatesPageState extends State<TapCounterUpdatesPage> {
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
            "Are you sure you want to delete ${_selectedIndices.length} update(s)? This will adjust the counter value."),
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
    final counter = provider.counters[widget.counterIndex];
    final selectedDate = counter.updates[index];

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
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        await provider.editCounterUpdate(widget.counterIndex, index,
            newDate: newDateTime);
        if (mounted) {
          setState(() {
            _selectedIndices.clear();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
      builder: (context, provider, child) {
        final counter = provider.counters[widget.counterIndex];
        final updates = counter.updates;
        final filteredUpdates = _searchQuery.isEmpty
            ? updates
            : updates
                .where((date) => DateFormat("MMM d, yyyy (EEEE) - h:mm a")
                    .format(date.toLocal())
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();

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
                      delegate: DateSearchDelegate(
                        data: updates,
                        onSearch: _searchDate,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          body: ListView.builder(
            itemCount: filteredUpdates.length,
            itemBuilder: (context, index) {
              final date = filteredUpdates[index];
              final originalIndex = updates.indexOf(date);
              final isSelected = _selectedIndices.contains(originalIndex);

              return _buildUpdateTile(date, isSelected, originalIndex);
            },
          ),
        );
      },
    );
  }

  Widget _buildUpdateTile(DateTime date, bool isSelected, int originalIndex) {
    final formattedDate =
        DateFormat("MMM d, yyyy (EEEE) - h:mm a").format(date.toLocal());

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
              : CircleAvatar(
                  backgroundColor: Colors.blueAccent.withAlpha(25),
                  child: const Icon(Icons.history, color: Colors.blueAccent),
                ),
          title: Text(
            formattedDate,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
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

class DateSearchDelegate extends SearchDelegate {
  DateSearchDelegate({required this.data, required this.onSearch});
  final List<DateTime> data;
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
          onSearch(query); // Reset to all data
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
    // Returning an empty container as we're updating search live
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? data
        : data.where((date) {
            final formattedDate = DateFormat("MMM d, yyyy (EEEE) - h:mm a")
                .format(date.toLocal());
            return formattedDate.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return _buildUpdateTile(context, suggestions[index]);
      },
    );
  }

  Widget _buildUpdateTile(BuildContext context, DateTime date) {
    final formattedDate =
        DateFormat("MMM d, yyyy (EEEE) - h:mm a").format(date.toLocal());

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
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent.withAlpha(25),
            child: const Icon(Icons.history, color: Colors.blueAccent),
          ),
          title: Text(
            formattedDate,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
