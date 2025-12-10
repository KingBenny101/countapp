import "package:flutter/material.dart";
import "package:intl/intl.dart";

class SeriesCounterUpdatesPage extends StatefulWidget {
  const SeriesCounterUpdatesPage({
    super.key,
    required this.name,
    required this.updates,
    required this.values,
  });
  final String name;
  final List<DateTime> updates;
  final List<double> values;

  @override
  _SeriesCounterUpdatesPageState createState() =>
      _SeriesCounterUpdatesPageState();
}

class _SeriesCounterUpdatesPageState extends State<SeriesCounterUpdatesPage> {
  late List<int> filteredIndices;

  @override
  void initState() {
    super.initState();
    filteredIndices = List.generate(widget.updates.length, (index) => index);
  }

  void _searchDate(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredIndices =
            List.generate(widget.updates.length, (index) => index);
      } else {
        filteredIndices = [];
        for (int i = 0; i < widget.updates.length; i++) {
          final date = widget.updates[i];
          final value = widget.values[i];
          final formattedDate =
              DateFormat("MMM d, yyyy (EEEE) - h:mm a").format(date.toLocal());
          final formattedValue = value.toStringAsFixed(2);
          if (formattedDate.toLowerCase().contains(query.toLowerCase()) ||
              formattedValue.contains(query)) {
            filteredIndices.add(i);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Updates - ${widget.name}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SeriesSearchDelegate(
                  updates: widget.updates,
                  values: widget.values,
                  onSearch: _searchDate,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredIndices.length,
        itemBuilder: (context, index) {
          final dataIndex = filteredIndices[index];
          return _buildUpdateTile(
            widget.updates[dataIndex],
            widget.values[dataIndex],
          );
        },
      ),
    );
  }

  Widget _buildUpdateTile(DateTime date, double value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.show_chart, color: Colors.deepPurple),
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
        return _buildUpdateTile(updates[dataIndex], values[dataIndex]);
      },
    );
  }

  Widget _buildUpdateTile(DateTime date, double value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.show_chart, color: Colors.deepPurple),
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
    );
  }
}
