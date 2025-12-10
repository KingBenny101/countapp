import "package:flutter/material.dart";

/// Abstract base class for all counter types
/// Each counter type implements its own update logic and UI presentation
abstract class BaseCounter {
  /// Constructor
  BaseCounter({
    required this.id,
    required this.name,
    required this.value,
    this.lastUpdated,
    List<DateTime>? updates,
  }) : updates = updates ?? [];

  /// Unique identifier for this counter instance
  final String id;

  /// Display name of the counter
  String name;

  /// Current count value
  num value;

  /// Timestamp of the last update
  DateTime? lastUpdated;

  /// History of all update timestamps
  List<DateTime> updates;

  /// Unique type identifier for this counter type (e.g., 'tap', 'long_press')
  String get counterType;

  /// Handle user interaction with the counter
  /// Returns true if the counter was updated, false otherwise
  Future<bool> onInteraction(BuildContext context);

  /// Build the icon widget to display in the counter list
  Widget buildIcon();

  /// Get the subtitle text to display (e.g., "Step: +5")
  String getSubtitle();

  /// Get the color for this counter type
  Color getColor();

  /// Serialize the counter to JSON
  Map<String, dynamic> toJson();

  /// Validate the counter's configuration
  bool validate() {
    return name.isNotEmpty;
  }

  /// Navigate to counter-specific statistics page
  /// Returns null if counter doesn't have a statistics page
  Widget? getStatisticsPage(int index) {
    return null; // Default: no statistics page
  }
}
