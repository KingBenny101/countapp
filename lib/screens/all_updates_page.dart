import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class AllUpdatesPage extends StatefulWidget {
  const AllUpdatesPage({super.key, required this.name, required this.data});
  final String name;
  final List<DateTime> data;

  @override
  _AllUpdatesPageState createState() => _AllUpdatesPageState();
}

class _AllUpdatesPageState extends State<AllUpdatesPage> {
  late List<DateTime> filteredData;

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
  }

  void _searchDate(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredData = widget.data;
      } else {
        filteredData = widget.data
            .where((date) => date.toString().contains(query))
            .toList();
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
                delegate: DateSearchDelegate(
                  data: widget.data,
                  onSearch: _searchDate,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          return buildCustomListTile(filteredData[index]);
        },
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
          final formattedDate = DateFormat("EEEE, MMM d, yyyy - h:mm a")
              .format(date.toLocal());
          return formattedDate.toLowerCase().contains(query.toLowerCase());
        }).toList();

  return ListView.builder(
    itemCount: suggestions.length,
    itemBuilder: (context, index) {
      return buildCustomListTile(suggestions[index]);
    },
  );
}
}
