# LeaderboardService API Reference

`LeaderboardService` handles all interactions with the backend leaderboard system, including creation, joining, fetching, and updating.

## Class Definition

```dart
class LeaderboardService {
  // Static methods only
}
```

**Location**: `lib/services/leaderboard_service.dart`

## Methods

### addLeaderboard

```dart
static Future<Map<String, dynamic>> addLeaderboard({
  required String code,
  required String userName,
  required BaseCounter counter,
  String? attachedCounterId,
})
```

Creates or joins a leaderboard with the specified code.

**Parameters**:

- `code` (`String`): Unique 6-character leaderboard code
- `userName` (`String`): User's display name
- `counter` (`BaseCounter`): Counter instance to map (for type validation)
- `attachedCounterId` (`String?`): Optional ID of existing counter to link

**Returns**: `Map<String, dynamic>`
- `success` (`bool`): Operation status
- `leaderboard` (`Leaderboard?`): The resulting leaderboard object
- `message` (`String?`): Error or status message

### fetchLeaderboard

```dart
static Future<Leaderboard?> fetchLeaderboard(String code)
```

Retrieves the latest state of a leaderboard from the server.

**Parameters**:

- `code` (`String`): 6-character code

**Returns**: `Leaderboard?` (null if not found or error)

### postUpdate

```dart
static Future<bool> postUpdate({
  required Leaderboard lb,
  required BaseCounter counter,
})
```

Posts a counter update to the leaderboard.

**Parameters**:

- `lb` (`Leaderboard`): Target leaderboard
- `counter` (`BaseCounter`): Updated counter with current value

**Returns**: `bool` (success/failure)

**Behavior**:
- Used for auto-posting updates when a local counter changes.
- Validates that the counter matches the leaderboard type.

### deleteLeaderboard

```dart
static Future<void> deleteLeaderboard(String code)
```

Removes a leaderboard from local storage.

**Parameters**:

- `code` (`String`): Leaderboard code to delete

## Connectivity Handling

The service handles network conditions:
- **Offline**: Some operations may fail or return cached data.
- **Redirects**: Follows 307/308 redirects automatically for robust server communication.

## Usage Example

```dart
// Join a leaderboard
final result = await LeaderboardService.addLeaderboard(
  code: "ABC123",
  userName: "Benny",
  counter: myTapCounter,
);

if (result["success"]) {
  print("Joined leaderboard: ${result["leaderboard"].code}");
} else {
  print("Error: ${result["message"]}");
}
```
