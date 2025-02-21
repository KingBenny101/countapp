import "package:countapp/utils/widgets.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class StatisticsGenerator {
  StatisticsGenerator(this.updatesData) {
    _processUpdates();
  }
  final List<DateTime> updatesData;
  late Map<String, int> updatesPerDay;
  late Map<String, List<int>> updatesPerDayWithTimes;
  late Map<int, int> daysPerUpdateCount;
  late DateTime _firstDate;
  late DateTime _lastDate;
  late double _totalDays;
  late List<int> _updatesList;
  late double _avgUpdatesPerDay;
  late String _mostUpdatesDay;
  late int _mostUpdatesCount;
  late double _avgUpdatesLast7Days;
  late double _avgUpdatesLast30Days;
  late double _percentDaysWithNoUpdates;
  late String _mostActive180TimeWindow;
  late String _mostActive60TimeWindow;
  late String _mostActive360TimeWindow;
  late String _mostActive720TimeWindow;
  late String _mostActive1080TimeWindow;
  late String _mostActive1440TimeWindow;

  void _processUpdates() {
    updatesPerDay = {};
    updatesPerDayWithTimes = {};
    daysPerUpdateCount = {};

    for (final update in updatesData) {
      final String formattedDate = DateFormat("yyyy-MM-dd").format(update);
      updatesPerDay[formattedDate] = (updatesPerDay[formattedDate] ?? 0) + 1;
      updatesPerDayWithTimes[formattedDate] =
          updatesPerDayWithTimes[formattedDate] ?? [];
      updatesPerDayWithTimes[formattedDate]!
          .add(update.hour * 60 + update.minute);
    }

    for (final updateCount in updatesPerDay.values) {
      daysPerUpdateCount[updateCount] =
          (daysPerUpdateCount[updateCount] ?? 0) + 1;
    }

    _firstDate = updatesData.reduce((a, b) => a.isBefore(b) ? a : b);
    _lastDate = updatesData.reduce((a, b) => a.isAfter(b) ? a : b);
    _totalDays =
        (_lastDate.difference(_firstDate).inHours / 24).roundToDouble() + 1;
    _updatesList = updatesPerDay.values.toList();

    _calcAvgUpdatesPerDay();
    _calcMostUpdatesDayAndCount();
    _calcAvgUpdatesLastNDays();
    _calcPercentDaysWithNoUpdates();
    _mostActive180TimeWindow = _calcMostActiveTimeWindow(180);
    _mostActive60TimeWindow = _calcMostActiveTimeWindow(60);
    _mostActive360TimeWindow = _calcMostActiveTimeWindow(360);
    _mostActive720TimeWindow = _calcMostActiveTimeWindow(720);
    _mostActive1080TimeWindow = _calcMostActiveTimeWindow(1080);
    _mostActive1440TimeWindow = _calcMostActiveTimeWindow(1440);
  }

  // Average Updates per Day
  void _calcAvgUpdatesPerDay() {
    _avgUpdatesPerDay =
        _updatesList.fold(0, (sum, updates) => sum + updates) / _totalDays;
  }

  // Most Updates Day and Count
  void _calcMostUpdatesDayAndCount() {
    final mostUpdatesEntry =
        updatesPerDay.entries.reduce((a, b) => a.value > b.value ? a : b);
    _mostUpdatesDay = mostUpdatesEntry.key;
    _mostUpdatesCount = mostUpdatesEntry.value;
  }

  // Average of last 7 days and 30 days
  void _calcAvgUpdatesLastNDays() {
    final today = DateTime.now();
    final last7Days = today.subtract(const Duration(days: 7));
    final last30Days = today.subtract(const Duration(days: 30));

    final List<int> updatesLast7Days = [];
    final List<int> updatesLast30Days = [];
    for (final date in updatesPerDay.keys) {
      final DateTime dateObj = DateFormat("yyyy-MM-dd").parse(date);
      if (dateObj.isAfter(last7Days) && dateObj.isBefore(today)) {
        updatesLast7Days.add(updatesPerDay[date]!);
      }
      if (dateObj.isAfter(last30Days) && dateObj.isBefore(today)) {
        updatesLast30Days.add(updatesPerDay[date]!);
      }
    }

    final totalUpdatesLast7Days =
        updatesLast7Days.fold(0, (sum, updates) => sum + updates);
    final totalUpdatesLast30Days =
        updatesLast30Days.fold(0, (sum, updates) => sum + updates);

    _avgUpdatesLast7Days =
        updatesLast7Days.isEmpty ? 0.0 : totalUpdatesLast7Days / 7;

    _avgUpdatesLast30Days =
        updatesLast30Days.isEmpty ? 0.0 : totalUpdatesLast30Days / 30;
  }

  // Calculate percentage of days with no updates'
  void _calcPercentDaysWithNoUpdates() {
    final double daysWithNoUpdates = _totalDays - updatesPerDay.length;
    _percentDaysWithNoUpdates = (daysWithNoUpdates / _totalDays) * 100;
  }

  String _calcMostActiveTimeWindow(int windowSize) {
    if (updatesData.isEmpty) return "No updates";

    // Convert all times to DateTime and sort them
    final sortedTimes = List<DateTime>.from(updatesData)..sort();

    int maxCount = 0;
    DateTime? windowStart;
    DateTime? windowEnd;

    // Sliding window approach
    int start = 0;
    for (int end = 0; end < sortedTimes.length; end++) {
      // Move start forward until within window size
      while (sortedTimes[end].difference(sortedTimes[start]) >
          Duration(minutes: windowSize)) {
        start++;
      }

      // Update max window
      final currentCount = end - start + 1;
      if (currentCount > maxCount) {
        maxCount = currentCount;
        windowStart = sortedTimes[start];
        windowEnd = sortedTimes[end].add(Duration(minutes: windowSize));
      }
    }

    final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    final DateFormat timeFormat = DateFormat("HH:mm");

    return "$maxCount|"
        "${dateFormat.format(windowStart!)}|"
        "${timeFormat.format(windowStart)}-"
        "${timeFormat.format(windowEnd!)}";
  }

  List<Widget> generateStatsWidgets() {
    return [
      buildInfoCard(
        "Average Updates per Day",
        _avgUpdatesPerDay.toStringAsFixed(2),
      ),
      buildInfoCard("Most Updates Day", _mostUpdatesDay),
      buildInfoCard("Most Updates Count", _mostUpdatesCount.toString()),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildSummaryCard(
            title: "1h Max",
            count: _mostActive60TimeWindow.split("|")[0],
            date: _mostActive60TimeWindow.split("|")[1],
            timeRange: _mostActive60TimeWindow.split("|")[2],
          ),
          buildSummaryCard(
            title: "3h Max",
            count: _mostActive180TimeWindow.split("|")[0],
            date: _mostActive180TimeWindow.split("|")[1],
            timeRange: _mostActive180TimeWindow.split("|")[2],
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildSummaryCard(
            title: "6h Max",
            count: _mostActive360TimeWindow.split("|")[0],
            date: _mostActive360TimeWindow.split("|")[1],
            timeRange: _mostActive360TimeWindow.split("|")[2],
          ),
          buildSummaryCard(
            title: "12h Max",
            count: _mostActive720TimeWindow.split("|")[0],
            date: _mostActive720TimeWindow.split("|")[1],
            timeRange: _mostActive720TimeWindow.split("|")[2],
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [buildSummaryCard(
            title: "18h Max",
            count: _mostActive1080TimeWindow.split("|")[0],
            date: _mostActive1080TimeWindow.split("|")[1],
            timeRange: _mostActive1080TimeWindow.split("|")[2],
          ),
          buildSummaryCard(
            title: "24h Max",
            count: _mostActive1440TimeWindow.split("|")[0],
            date: _mostActive1440TimeWindow.split("|")[1],
            timeRange: _mostActive1440TimeWindow.split("|")[2],
          ),
        ],
      ),
      buildInfoCard(
        "Average over the Last 7 Days",
        _avgUpdatesLast7Days.toStringAsFixed(2),
      ),
      buildInfoCard(
        "Average over the Last 30 Days",
        _avgUpdatesLast30Days.toStringAsFixed(2),
      ),
      buildInfoCard(
        "Days with No Updates",
        "${_percentDaysWithNoUpdates.toStringAsFixed(2)}%",
      ),
    ];
  }
}
