import "package:intl/intl.dart";

List<dynamic> generateUpdateStatistics(List<DateTime> updatesData) {
  if (updatesData.isEmpty) {
    return [0.0, "No updates", 0, "No updates", 0.0, 0.0, "No updates window"];
  }

  // Group updates by date
  final Map<String, int> updatesPerDay = {};
  final Map<String, List<int>> updatesPerDayWithTimes =
      {}; // To track times of day

  for (final update in updatesData) {
    // Format the date to "yyyy-MM-dd" to group by day
    final String formattedDate = DateFormat("yyyy-MM-dd").format(update);

    // Increment the count of updates for that date
    updatesPerDay[formattedDate] = (updatesPerDay[formattedDate] ?? 0) + 1;

    // Track times of updates for time analysis
    updatesPerDayWithTimes[formattedDate] =
        updatesPerDayWithTimes[formattedDate] ?? [];
    updatesPerDayWithTimes[formattedDate]!
        .add(update.hour * 60 + update.minute); // Store time in minutes
  }

  final DateTime firstDate =
      updatesData.reduce((a, b) => a.isBefore(b) ? a : b);
  final DateTime lastDate = updatesData.reduce((a, b) => a.isAfter(b) ? a : b);
  final double totalDays =
      (lastDate.difference(firstDate).inHours / 24).roundToDouble() + 1;

  // Calculate the updates per day as a list
  final List<int> updatesList = updatesPerDay.values.toList();

  // Average Updates per Day
  final double avgUpdatesPerDay =
      updatesList.fold(0, (sum, updates) => sum + updates) / totalDays;

  // Most Updates Day and Count
  final mostUpdatesEntry =
      updatesPerDay.entries.reduce((a, b) => a.value > b.value ? a : b);
  final String mostUpdatesDay = mostUpdatesEntry.key;
  final int mostUpdatesCount = mostUpdatesEntry.value;

  // Time of Day with the Most Updates
  final Map<int, int> timeOfDayCounts =
      {}; // key: time in minutes, value: count of updates
  for (final times in updatesPerDayWithTimes.values) {
    for (final time in times) {
      timeOfDayCounts[time] = (timeOfDayCounts[time] ?? 0) + 1;
    }
  }

  // Find the time with the most updates (key is time in minutes)
  final mostUpdatesTime =
      timeOfDayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  final String mostUpdatesTimeFormatted =
      '${(mostUpdatesTime ~/ 60).toString().padLeft(2, '0')}:${(mostUpdatesTime % 60).toString().padLeft(2, '0')}';

  // Rolling average over the last 7 days
  final List<int> rollingUpdates = [];
  final List<double> rollingAverages = [];
  for (int i = 0; i < updatesList.length; i++) {
    rollingUpdates.add(updatesList[i]);
    if (rollingUpdates.length > 7) {
      rollingUpdates.removeAt(
        0,
      ); // Remove the first element to maintain the size of the last 7 days
    }
    final double rollingAverage =
        rollingUpdates.fold(0, (sum, updates) => sum + updates) /
            rollingUpdates.length;
    rollingAverages.add(rollingAverage);
  }

  final double rollingAvgLast7Days =
      rollingAverages.isEmpty ? 0.0 : rollingAverages.last;

  // Calculate percentage of days with no updates
  final double daysWithNoUpdates = totalDays - updatesPerDay.length;
  final double percentDaysWithNoUpdates = (daysWithNoUpdates / totalDays) * 100;

  // Find the highest update time window (e.g., 60-minute window)
  const int windowSize =
      180; // Define the window size (e.g., 60 minutes = 1 hour)
  final Map<int, int> updateWindows =
      {}; // key: start of window in minutes, value: number of updates in that window

  for (final time in updatesData) {
    final int windowStart =
        (time.hour * 60 + time.minute) ~/ windowSize * windowSize;
    updateWindows[windowStart] = (updateWindows[windowStart] ?? 0) + 1;
  }

  // Find the time window with the most updates
  final mostUpdatesWindow =
      updateWindows.entries.reduce((a, b) => a.value > b.value ? a : b);
  final String mostUpdatesWindowStartTime =
      '${(mostUpdatesWindow.key ~/ 60).toString().padLeft(2, '0')}:${(mostUpdatesWindow.key % 60).toString().padLeft(2, '0')}';
  final String mostUpdatesWindowEndTime =
      '${((mostUpdatesWindow.key + windowSize) ~/ 60).toString().padLeft(2, '0')}:${((mostUpdatesWindow.key + windowSize) % 60).toString().padLeft(2, '0')}';

  // Return the statistics including the highest update time window
  return [
    avgUpdatesPerDay, // Average Updates per Day
    mostUpdatesDay, // Most Updates Day
    mostUpdatesCount, // Most Updates Count
    mostUpdatesTimeFormatted, // Time of Day with the Most Updates
    rollingAvgLast7Days, // Rolling Average over the Last 7 Days
    percentDaysWithNoUpdates, // Percentage of Days with No Updates
    "$mostUpdatesWindowStartTime - $mostUpdatesWindowEndTime", // Time Window with the Most Updates
    updatesPerDay,
  ];
}