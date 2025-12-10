import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/counters/tap_counter/tap_counter.dart";
import "package:flutter/material.dart";

/// Factory for creating counters from JSON with backward compatibility
class CounterFactory {
  /// Registry of counter type constructors
  static final Map<String, BaseCounter Function(Map<String, dynamic>)>
      _registry = {
    "tap": TapCounter.fromJson,
    // Future counter types will be registered here:
    // "long_press": LongPressCounter.fromJson,
    // "swipe": SwipeCounter.fromJson,
  };

  /// Create counter from JSON with backward compatibility for old format
  static BaseCounter fromJson(Map<String, dynamic> json) {
    String counterType;

    // Backward compatibility: old format uses "type" field instead of "counterType"
    if (json.containsKey("type") && !json.containsKey("counterType")) {
      // Old format detected - it's a tap counter
      counterType = "tap";
    } else {
      counterType = json["counterType"] as String;
    }

    final factory = _registry[counterType];
    if (factory == null) {
      throw UnsupportedError("Unknown counter type: $counterType");
    }

    return factory(json);
  }

  /// Get all available counter types for UI selection
  static List<CounterTypeInfo> getAvailableTypes() {
    return [
      CounterTypeInfo(
        type: "tap",
        name: "Tap Counter",
        description: "Update count with a single tap",
        icon: Icons.touch_app,
      ),
      // Future counter types will be added here
    ];
  }
}

/// Information about a counter type for display in UI
class CounterTypeInfo {

  CounterTypeInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
  });
  final String type;
  final String name;
  final String description;
  final IconData icon;
}
