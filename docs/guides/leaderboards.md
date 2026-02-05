# Leaderboards Guide

Compete with friends, family, or colleagues using Count App's leaderboard feature! Create shared leaderboards to track who's leading in habits, fitness goals, or any counter-based competition.

<p align="center">
  <img src="../images/screenshots/leaderboards-list.png" width="250" />
</p>

---

## What are Leaderboards?

Leaderboards allow you to:

- **Compete** with others by sharing counter data
- **Compare** rankings in real-time
- **Motivate** each other to reach goals
- **Track** group progress on shared objectives

Each leaderboard is identified by a unique **6-character code** (letters and numbers) that you share with participants.

---

## Creating & Joining a Leaderboard

### Join or Create a Leaderboard

1. **Open the Leaderboards page**
   - Tap the menu icon (☰) or navigate to the Leaderboards section

2. **Tap the plus (+) button** to add a leaderboard

3. **Enter leaderboard details:**
   
   <p align="center">
     <img src="../images/screenshots/join-leaderboard.png" width="250" />
   </p>
   
   - **Code:** 6-character alphanumeric code (e.g., `ABC123`)
     - If the code exists, you'll join that leaderboard
     - If it's new, you'll create a new leaderboard
   - **Your Name:** Display name shown on the leaderboard
   - **Attach Counter:** Select which counter to share

4. **Tap Confirm** to join/create

!!! tip "Sharing Codes"
    Share your 6-character code with others via text, email, or messaging apps so they can join your leaderboard!

---

## Understanding Leaderboard Codes

### Code Format

- **Length:** Exactly 6 characters
- **Characters:** A-Z (uppercase letters) and 0-9 (numbers only)
- **Examples:** `FITNES`, `WATER1`, `STEP2K`, `ABC123`

### Code Behavior

**When you enter a code:**

- **Code exists:** You join the existing leaderboard with other participants
- **Code is new:** You create a new leaderboard and become the first participant

!!! note "Case Insensitive"
    Codes are automatically converted to uppercase. `abc123` and `ABC123` are the same leaderboard.

---

## Attaching Counters to Leaderboards

### What Gets Shared?

When you attach a counter to a leaderboard, the following data is shared:

- Counter name
- Current value
- Counter type (Tap Counter or Series Counter)
- Last update timestamp

### Selecting the Right Counter

You can attach any counter you've created:

- **Tap Counters:** Compare total counts (e.g., daily steps, water glasses)
- **Series Counters:** Compare latest values (e.g., current weight, daily revenue)

!!! warning "Privacy Note"
    Only the current value and counter name are shared. Historical data and detailed statistics remain private on your device.

---

## Viewing Leaderboard Rankings

### Accessing Your Leaderboards

1. **Open the Leaderboards page**
2. **Tap a leaderboard** to view details

<p align="center">
  <img src="../images/screenshots/leaderboard-detail.png" width="250" />
</p>

### Leaderboard View

The leaderboard shows:

- **Rankings:** Participants sorted by counter value (highest to lowest)
- **User Names:** Display names of all participants
- **Counter Values:** Current value for each participant
- **Counter Names:** Name of each participant's attached counter
- **Last Updated:** When each counter was last updated

### Real-Time Updates

Leaderboards automatically sync when you:

- Open the leaderboard detail page
- Pull to refresh (swipe down)
- Update your attached counter

---

## Managing Leaderboards

### Reordering Leaderboards

Organize your leaderboards list:

1. **Long-press the drag handle** (≡) on a leaderboard
2. **Drag up or down** to reorder
3. Release to set the new position

### Updating Your Counter

Your leaderboard ranking updates automatically when you update the attached counter:

1. Update your counter normally (from the home page)
2. The leaderboard will reflect your new value on next sync

### Leaving a Leaderboard

To remove a leaderboard from your list:

1. **Swipe left** on the leaderboard (or long-press)
2. **Tap Delete**
3. **Confirm deletion**

!!! note "Leaving vs Deleting"
    Deleting a leaderboard only removes it from your device. Other participants can still see the leaderboard, but your data will no longer be shared.

---

## Use Cases & Examples

### Fitness Challenges

**Daily Steps Competition**

1. Create a leaderboard with code `STEPS2024`
2. Attach your "Daily Steps" Tap Counter
3. Share the code with your fitness group
4. Compete to see who walks the most!

<p align="center">
  <img src="../images/screenshots/leaderboard-detail.png" width="250" />
</p>

### Habit Tracking

**Water Intake Challenge**

- Code: `WATER8`
- Counter: "Water Glasses" (Tap Counter with step size 1)
- Goal: Track who drinks the most water daily

### Weight Loss Group

**Team Weight Loss**

- Code: `WEIGHTLOSS`
- Counter: "Current Weight" (Series Counter)
- Goal: Support each other's progress (lowest value wins)

### Business Metrics

**Sales Team Challenge**

- Code: `SALES24`
- Counter: "Daily Sales" (Series Counter)
- Goal: Compare daily revenue across team members

---

## Troubleshooting

### Cannot Join Leaderboard

**Problem:** Error message when trying to join

**Possible Causes:**

- Invalid code format (must be exactly 6 alphanumeric characters)
- No internet connection
- Server temporarily unavailable

**Solutions:**

1. Verify the code is exactly 6 characters (A-Z, 0-9)
2. Check your internet connection
3. Try again in a few moments

### Leaderboard Not Updating

**Problem:** Rankings don't reflect latest counter values

**Solutions:**

1. **Pull to refresh** on the leaderboard detail page
2. Check your internet connection
3. Verify you updated the correct counter
4. Close and reopen the leaderboard page

### Duplicate Leaderboard Error

**Problem:** "A leaderboard with code XXX already exists"

**Cause:** You've already joined this leaderboard on your device

**Solution:** 

- Check your existing leaderboards list
- The leaderboard should already be there
- You cannot join the same leaderboard twice from one device

### Counter Not Showing in Dropdown

**Problem:** No counters available when joining a leaderboard

**Cause:** You haven't created any counters yet

**Solution:**

1. Exit the leaderboard dialog
2. Create a counter first from the home page
3. Return to join the leaderboard

---

## Best Practices

### Naming Your Leaderboards

When creating a new leaderboard code, choose memorable codes:

- **Descriptive:** `WATER8`, `STEPS`, `WEIGHT`
- **Time-based:** `JAN2024`, `WEEK01`
- **Group-based:** `TEAM01`, `FAM123`

### Counter Selection

Choose appropriate counters for fair competition:

- **Same type:** All participants should use similar counter types
- **Same units:** Agree on measurement units (kg vs lbs, etc.)
- **Clear rules:** Define what counts (e.g., "log weight once per day")

### Privacy Considerations

Remember:

- Anyone with the code can join your leaderboard
- Your counter value and name are visible to all participants
- Choose counter names that don't reveal sensitive information
- Use generic names like "Daily Goal" instead of specific details

---

## Technical Details

### Data Synchronization

- Leaderboards sync via HTTPS to a remote server
- Data is updated when you open the leaderboard detail page
- Background sync is not supported (manual refresh required)

### Data Stored Locally

On your device:

- Leaderboard codes you've joined
- Your display name for each leaderboard
- Reference to your attached counter
- Cached participant data from last sync

### Network Requirements

- Active internet connection required to join/create leaderboards
- Internet needed to view updated rankings
- Offline mode: View cached data only (rankings may be outdated)

---

## See Also

- **[Using the App](using-the-app.md)** - Learn the basics of Count App
- **[Counter Types](counters.md)** - Understand different counter types
- **[Installation](../getting-started/installation.md)** - Get started with Count App
