import "package:intl/intl.dart";

/// Result of time window analysis
class TimeWindowResult {
  const TimeWindowResult({
    required this.count,
    required this.windowStart,
    required this.windowEnd,
  });
  final int count;
  final DateTime windowStart;
  final DateTime windowEnd;

  String toFormattedString() {
    final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    final DateFormat timeFormat = DateFormat("HH:mm");
    return "$count|${dateFormat.format(windowStart)}|${timeFormat.format(windowStart)}-${timeFormat.format(windowEnd)}";
  }
}

/// Generic statistics utilities for date/time data analysis
class DateStatistics {
  DateStatistics._();

  /// Group DateTime list by date, returning a map of date strings to update counts
  static Map<String, int> groupUpdatesByDay(List<DateTime> updates) {
    final Map<String, int> updatesPerDay = {};
    final DateFormat formatter = DateFormat("yyyy-MM-dd");

    for (final update in updates) {
      final dateKey = formatter.format(update);
      updatesPerDay[dateKey] = (updatesPerDay[dateKey] ?? 0) + 1;
    }

    return updatesPerDay;
  }

  /// Count how many days had each specific number of updates
  /// Returns a map of update count to number of days with that count
  static Map<int, int> countDaysByUpdateFrequency(
      Map<String, int> updatesPerDay) {
    final Map<int, int> daysPerUpdateCount = {};

    for (final count in updatesPerDay.values) {
      daysPerUpdateCount[count] = (daysPerUpdateCount[count] ?? 0) + 1;
    }

    return daysPerUpdateCount;
  }

  /// Calculate average updates per day over all days
  static double calculateAverageUpdatesPerDay(
    List<DateTime> updates,
    int totalDays,
  ) {
    if (totalDays == 0) return 0.0;
    return updates.length / totalDays;
  }

  /// Find the date with the most updates
  /// Returns [date, count] or ["No updates", 0] if empty
  static List<dynamic> findMostUpdatesDay(Map<String, int> updatesPerDay) {
    if (updatesPerDay.isEmpty) return ["No updates", 0];

    String mostUpdatesDay = "";
    int mostUpdatesCount = 0;

    for (final entry in updatesPerDay.entries) {
      if (entry.value > mostUpdatesCount) {
        mostUpdatesDay = entry.key;
        mostUpdatesCount = entry.value;
      }
    }

    return [mostUpdatesDay, mostUpdatesCount];
  }

  /// Calculate average updates over the last N days
  static double calculateAverageLastNDays(
    Map<String, int> updatesPerDay,
    int days,
  ) {
    if (updatesPerDay.isEmpty) return 0.0;

    // Get the last N days from the map
    final sortedDates = updatesPerDay.keys.toList()..sort();
    final recentDates = sortedDates.length > days
        ? sortedDates.sublist(sortedDates.length - days)
        : sortedDates;

    final totalUpdates =
        recentDates.fold(0, (sum, date) => sum + (updatesPerDay[date] ?? 0));

    return totalUpdates / days;
  }

  /// Calculate percentage of days with no updates
  static double calculatePercentDaysWithNoUpdates(
    Map<String, int> updatesPerDay,
    int totalDays,
  ) {
    if (totalDays == 0) return 0.0;
    final daysWithNoUpdates = totalDays - updatesPerDay.length;
    return (daysWithNoUpdates / totalDays) * 100;
  }

  /// Find the most active time window of specified size (in minutes)
  /// Uses sliding window algorithm to find period with most updates
  static TimeWindowResult findMostActiveTimeWindow(
    List<DateTime> updates,
    int windowSizeMinutes,
  ) {
    if (updates.isEmpty) {
      final now = DateTime.now();
      return TimeWindowResult(
        count: 0,
        windowStart: now,
        windowEnd: now,
      );
    }

    // Sort times
    final sortedTimes = List<DateTime>.from(updates)..sort();

    int maxCount = 0;
    DateTime windowStart = sortedTimes[0];
    DateTime windowEnd =
        sortedTimes[0].add(Duration(minutes: windowSizeMinutes));

    // Sliding window approach
    int start = 0;
    for (int end = 0; end < sortedTimes.length; end++) {
      // Move start forward until within window size
      while (sortedTimes[end].difference(sortedTimes[start]) >
          Duration(minutes: windowSizeMinutes)) {
        start++;
      }

      // Update max window
      final currentCount = end - start + 1;
      if (currentCount > maxCount) {
        maxCount = currentCount;
        windowStart = sortedTimes[start];
        windowEnd =
            sortedTimes[start].add(Duration(minutes: windowSizeMinutes));
      }
    }

    return TimeWindowResult(
      count: maxCount,
      windowStart: windowStart,
      windowEnd: windowEnd,
    );
  }

  /// Calculate total days between first and last update
  static int calculateTotalDays(List<DateTime> updates) {
    if (updates.isEmpty) return 0;

    final sortedUpdates = List<DateTime>.from(updates)..sort();
    final firstUpdate = sortedUpdates.first;
    final lastUpdate = sortedUpdates.last;

    return lastUpdate.difference(firstUpdate).inDays + 1;
  }
}
