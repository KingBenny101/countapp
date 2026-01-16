import "package:countapp/utils/constants.dart";
import "package:hive_ce/hive.dart";

class LeaderboardEntry {
  LeaderboardEntry({
    required this.userName,
    required this.counterValue,
    required this.timestamp,
  });

  String userName;
  int counterValue;
  DateTime timestamp;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userName: json["user_name"] as String,
      counterValue: (json["counter_value"] as num).toInt(),
      timestamp: DateTime.parse(json["timestamp"] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        "user_name": userName,
        "counter_value": counterValue,
        "timestamp": timestamp.toIso8601String(),
      };
}

class Leaderboard {
  Leaderboard({
    required this.code,
    required this.leaderboardName,
    required this.counterType,
    required this.leaderboard,
    this.attachedCounterId,
    this.joinedUserName,
  });

  String code;
  String leaderboardName;
  String counterType;
  List<LeaderboardEntry> leaderboard;

  /// Local counter id that this leaderboard is attached to
  String? attachedCounterId;

  /// The user name that this local device joined the leaderboard with
  String? joinedUserName;

  factory Leaderboard.fromApiJson(Map<String, dynamic> json) {
    final data = json;
    return Leaderboard(
      code: data["code"] as String,
      leaderboardName:
          data["leaderboard_name"] as String? ?? data["code"] as String,
      counterType: data["counter_type"] as String? ?? "",
      leaderboard: (data["leaderboard"] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "leaderboard_name": leaderboardName,
        "counter_type": counterType,
        "leaderboard": leaderboard.map((e) => e.toJson()).toList(),
        "attachedCounterId": attachedCounterId,
        "joinedUserName": joinedUserName,
      };
}

/// Manual adapters for Hive storage
class LeaderboardEntryAdapter extends TypeAdapter<LeaderboardEntry> {
  @override
  final int typeId = AppConstants.leaderboardEntryTypeId;

  @override
  LeaderboardEntry read(BinaryReader reader) {
    final userName = reader.readString();
    final counterValue = reader.readInt();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return LeaderboardEntry(
      userName: userName,
      counterValue: counterValue,
      timestamp: timestamp,
    );
  }

  @override
  void write(BinaryWriter writer, LeaderboardEntry obj) {
    writer.writeString(obj.userName);
    writer.writeInt(obj.counterValue);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}

class LeaderboardAdapter extends TypeAdapter<Leaderboard> {
  @override
  final int typeId = AppConstants.leaderboardTypeId;

  @override
  Leaderboard read(BinaryReader reader) {
    final code = reader.readString();
    final name = reader.readString();
    final counterType = reader.readString();
    final hasAttached = reader.readBool();
    final attached = hasAttached ? reader.readString() : null;
    final hasJoined = reader.readBool();
    final joined = hasJoined ? reader.readString() : null;
    final length = reader.readInt();
    final entries = <LeaderboardEntry>[];
    for (int i = 0; i < length; i++) {
      final entry = LeaderboardEntryAdapter().read(reader);
      entries.add(entry);
    }
    return Leaderboard(
      code: code,
      leaderboardName: name,
      counterType: counterType,
      leaderboard: entries,
      attachedCounterId: attached,
      joinedUserName: joined,
    );
  }

  @override
  void write(BinaryWriter writer, Leaderboard obj) {
    writer.writeString(obj.code);
    writer.writeString(obj.leaderboardName);
    writer.writeString(obj.counterType);
    writer.writeBool(obj.attachedCounterId != null);
    if (obj.attachedCounterId != null)
      writer.writeString(obj.attachedCounterId!);
    writer.writeBool(obj.joinedUserName != null);
    if (obj.joinedUserName != null) writer.writeString(obj.joinedUserName!);
    writer.writeInt(obj.leaderboard.length);
    final entryAdapter = LeaderboardEntryAdapter();
    for (final e in obj.leaderboard) {
      entryAdapter.write(writer, e);
    }
  }
}
