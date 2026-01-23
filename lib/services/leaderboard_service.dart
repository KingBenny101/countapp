import "dart:convert";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:countapp/counters/base/base_counter.dart";
import "package:countapp/models/leaderboard.dart";
import "package:countapp/utils/constants.dart";
import "package:flutter/foundation.dart";
import "package:hive_ce/hive.dart";
import "package:http/http.dart" as http;

class LeaderboardService {
  LeaderboardService._();
  static const String _apiUrl =
      "https://script.google.com/macros/s/AKfycbwJiFChM3iXsQjiUDFst874lrGkg3Vqss7MIAnvd9ILeGAMiLyoMeWPI1h7ju9acc25/exec";

  static Box _box() => Hive.box(AppConstants.leaderboardsBox);

  static String _mapCounterType(String counterType) {
    // API now accepts internal counter types directly
    return counterType;
  }

  /// Adds (creates/joins) a leaderboard. Returns a map with keys:
  /// - success: bool
  /// - leaderboard: Leaderboard? (when success)
  /// - message: String? (server message when available)
  static Future<Map<String, dynamic>> addLeaderboard({
    required String code,
    required String userName,
    required BaseCounter counter,
    String? attachedCounterId,
  }) async {
    // Check internet connectivity before attempting network call
    final conn = await Connectivity().checkConnectivity();
    // conn can be a single ConnectivityResult or a list; ignore type warning
    // ignore: unrelated_type_equality_checks
    final bool offline = conn == ConnectivityResult.none;
    if (offline) {
      debugPrint("addLeaderboard aborted: no internet");
      return {
        "success": false,
        "leaderboard": null,
        "message": "No internet connection"
      };
    }

    final payload = {
      "code": code,
      "user_name": userName,
      "counter_type": _mapCounterType(counter.counterType),
      "counter_value": counter.value.toInt(),
    };

    final resp = await _postFollow(Uri.parse(_apiUrl),
        {"Content-Type": "application/json"}, jsonEncode(payload));

    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      final bool ok = map["success"] == true;
      final String? message = map["message"] as String?;

      if (ok && map["data"] != null) {
        final lb = Leaderboard.fromApiJson(
            Map<String, dynamic>.from(map["data"] as Map));
        if (attachedCounterId != null) lb.attachedCounterId = attachedCounterId;
        lb.joinedUserName = userName;
        await _save(lb);
        return {"success": true, "leaderboard": lb, "message": message};
      }

      // Debug print server failure
      debugPrint(
          "addLeaderboard failed for code $code: ${message ?? 'Server returned failure'}");
      return {
        "success": false,
        "leaderboard": null,
        "message": message ?? "Server returned failure"
      };
    }

    debugPrint(
        "addLeaderboard HTTP error for code $code: ${resp.statusCode} - ${resp.body}");
    return {
      "success": false,
      "leaderboard": null,
      "message": "HTTP ${resp.statusCode}"
    };
  }

  static Future<void> _save(Leaderboard lb) async {
    final box = _box();
    await box.put(lb.code, lb);

    // Ensure order list contains this code (append if new)
    final order =
        (box.get("__order__") as List<dynamic>?)?.cast<String>() ?? [];
    if (!order.contains(lb.code)) {
      order.add(lb.code);
      await box.put("__order__", order);
    }
  }

  static Future<void> deleteLeaderboard(String code) async {
    final box = _box();
    await box.delete(code);
    final order =
        (box.get("__order__") as List<dynamic>?)?.cast<String>() ?? [];
    if (order.contains(code)) {
      order.remove(code);
      await box.put("__order__", order);
    }
  }

  static List<Leaderboard> getAll() {
    final box = _box();
    final order = (box.get("__order__") as List<dynamic>?)?.cast<String>();

    // If no explicit order saved, return natural values order (filtering non-leaderboard entries)
    if (order == null) return box.values.whereType<Leaderboard>().toList();

    final List<Leaderboard> items = [];
    for (final code in order) {
      final lb = box.get(code) as Leaderboard?;
      if (lb != null) items.add(lb);
    }

    // Append any leaderboards not present in order list (skip non-Leaderboard values like __order__)
    for (final value in box.values) {
      if (value is! Leaderboard) continue;
      if (!items.any((e) => e.code == value.code)) items.add(value);
    }

    return items;
  }

  static Leaderboard? getByCode(String code) {
    return _box().get(code) as Leaderboard?;
  }

  /// Update leaderboard metadata only (used for detaching counters)
  static Future<void> updateLeaderboardMetadata(Leaderboard lb) async {
    await _save(lb);
  }

  /// Reorder leaderboards and persist the new order to Hive
  static Future<void> reorderLeaderboards(int oldIndex, int newIndex) async {
    // Adjust newIndex when moving down the list (as per ReorderableListView behaviour)
    final int targetIndex = (newIndex > oldIndex) ? newIndex - 1 : newIndex;

    final items = getAll();
    final item = items.removeAt(oldIndex);
    items.insert(targetIndex, item);

    final box = _box();
    final newOrder = items.map((e) => e.code).toList();
    await box.put("__order__", newOrder);
  }

  /// Internal helper to follow redirects for POST requests.
  /// Follows up to 5 redirects. For 307/308, repeats the POST; otherwise follows with GET.
  static Future<http.Response> _postFollow(
      Uri uri, Map<String, String> headers, String body) async {
    http.Response resp = await http.post(uri, headers: headers, body: body);
    int redirects = 0;
    Uri current = uri;

    while (resp.statusCode >= 300 && resp.statusCode < 400 && redirects < 5) {
      final loc = resp.headers["location"];
      if (loc == null) break;
      final next = current.resolve(loc);
      debugPrint("Following redirect ${resp.statusCode} -> $next");

      if (resp.statusCode == 307 || resp.statusCode == 308) {
        // Repeat POST to new location
        resp = await http.post(next, headers: headers, body: body);
      } else {
        // For 301/302/303, follow with GET
        resp = await http.get(next, headers: headers);
      }

      current = next;
      redirects++;
    }

    return resp;
  }

  static Future<Leaderboard?> fetchLeaderboard(String code) async {
    // Preserve any locally stored attachment or user metadata when refreshing
    final existing = getByCode(code);
    final payload = {"code": code};

    final resp = await _postFollow(Uri.parse(_apiUrl),
        {"Content-Type": "application/json"}, jsonEncode(payload));

    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      if (map["success"] == true && map["data"] != null) {
        final lb = Leaderboard.fromApiJson(
            Map<String, dynamic>.from(map["data"] as Map));

        // Merge back any local metadata so we do not lose attachment info on refresh
        if (existing != null) {
          lb.attachedCounterId = existing.attachedCounterId;
          lb.joinedUserName = existing.joinedUserName;
        }

        await _save(lb);
        return lb;
      }
    }

    return existing;
  }

  /// Post an update for an existing leaderboard (used when a local counter updates)
  static Future<bool> postUpdate({
    required Leaderboard lb,
    required BaseCounter counter,
  }) async {
    if (lb.joinedUserName == null) return false;

    // Check internet connectivity
    final conn = await Connectivity().checkConnectivity();
    // conn can be a single ConnectivityResult or a list; ignore type warning
    // ignore: unrelated_type_equality_checks
    final bool offline = conn == ConnectivityResult.none;
    if (offline) {
      debugPrint("postUpdate aborted: no internet for leaderboard ${lb.code}");
      return false;
    }

    final payload = {
      "code": lb.code,
      "user_name": lb.joinedUserName!,
      "counter_type": _mapCounterType(counter.counterType),
      "counter_value": counter.value.toInt(),
    };

    final resp = await _postFollow(Uri.parse(_apiUrl),
        {"Content-Type": "application/json"}, jsonEncode(payload));

    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      final String? message = map["message"] as String?;
      if (map["success"] == true && map["data"] != null) {
        final updated = Leaderboard.fromApiJson(
            Map<String, dynamic>.from(map["data"] as Map));
        // Merge leaderboard entries and all metadata (preserve attachedCounterId)
        lb.leaderboardName = updated.leaderboardName;
        lb.counterType = updated.counterType;
        lb.leaderboard = updated.leaderboard;
        // Ensure attachedCounterId and joinedUserName are preserved
        lb.attachedCounterId = lb.attachedCounterId ?? lb.attachedCounterId;
        lb.joinedUserName = lb.joinedUserName ?? lb.joinedUserName;
        await _save(lb);
        debugPrint("postUpdate succeeded for leaderboard ${lb.code}");
        return true;
      }

      debugPrint(
          "postUpdate failed for leaderboard ${lb.code}: ${message ?? 'Server returned failure'}");
      return false;
    }

    debugPrint(
        "postUpdate HTTP error for leaderboard ${lb.code}: ${resp.statusCode} - ${resp.body}");
    return false;
  }
}
