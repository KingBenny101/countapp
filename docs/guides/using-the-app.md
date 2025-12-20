# Using Count App

A comprehensive user guide for everyday use of Count App.

---

## Getting Started

After installing Count App, you'll see the home screen with your counter list. Initially, this will be empty. Let's walk through the basic operations.

---

## Creating Counters

### Add a New Counter

1. **Tap the floating action button** (+) in the bottom-right corner of the home screen
2. **Select a counter type:**
   - **Tap Counter** - For quick counting (steps, water intake, habits)
   - **Series Counter** - For tracking measurements (weight, revenue, temperature)
3. **Fill in the configuration form** (see below for details)
4. **Tap the save button** to create your counter

### Tap Counter Configuration

When creating a Tap Counter, you'll configure:

**Counter Name** (required)
- Choose a descriptive name
- Example: "Daily Water (8oz glasses)"

**Step Size** (required)
- How much to add/subtract per tap
- Default: 1
- Example: Use 5 for counting by fives

**Direction**
- **Increment (+):** Count up (most common)
- **Decrement (-):** Count down

**Initial Count**
- Starting value for your counter
- Default: 0

**Require Confirmation**
- **Enabled:** Shows dialog before each update (prevents accidents)
- **Disabled:** Updates immediately (faster for frequent updates)

!!! tip
    For counters you'll update many times per day, disable confirmation for a faster workflow.

### Series Counter Configuration

When creating a Series Counter, you'll configure:

**Counter Name** (required)
- Choose a descriptive name
- Example: "Morning Weight (kg)"

**Description** (optional)
- Add context about what you're tracking
- Include units and timing
- Example: "Daily weight measurement before breakfast"

**Initial Value** (required)
- Your first measurement
- Supports decimals (e.g., 75.5)

---

## Updating Counters

### Update a Tap Counter

1. **Tap the counter** in your list
2. If confirmation is enabled, **confirm the update** in the dialog
3. The counter value updates immediately
4. A success message appears briefly

**What happens:**
- Value changes by the step size
- Increment counters add the step size
- Decrement counters subtract the step size
- Update timestamp is recorded

### Update a Series Counter

1. **Tap the counter** in your list
2. **Enter the new value** in the dialog
   - Supports decimal numbers (e.g., 75.5, 98.6)
   - Previous value and last update time are shown for reference
3. **Tap OK** to save the value
4. The counter updates with your new measurement

**What happens:**
- New value is recorded with current timestamp
- Value is added to the series history
- Statistics are automatically recalculated

!!! note
    Series counters store every value you enter, allowing you to track trends over time.

---

## Viewing Statistics

### Access Statistics

1. **Long-press a counter** to open the context menu
2. **Select "View Statistics"** (or tap the info icon if available)
3. View detailed analytics and charts

### Tap Counter Statistics

**Available data:**
- Total update count
- Daily update frequency
- Most active days
- Update history timeline
- Frequency charts

### Series Counter Statistics

**Available data:**
- **Averages:** Weekly and monthly
- **Extremes:** Weekly high/low, all-time high/low
- **Interactive charts** with time-range filters:
  - 1W (last 7 days)
  - 1M (last 30 days) - default
  - 3M (last 90 days)
  - 1Y (last 365 days)
  - All (complete history)

**Using the chart:**
- Tap the time range buttons to filter data
- View trends and patterns
- Identify highs and lows visually

---

## Managing Counters

### Edit a Counter

1. **Long-press the counter** in your list
2. **Select "Edit"** from the menu
3. **Modify the settings** (name, step size, etc.)
4. **Save your changes**

!!! note
    You cannot change the counter type after creation. To switch types, create a new counter and export/delete the old one.

### Delete Counters

**Delete a single counter:**
1. **Long-press the counter** you want to remove
2. **Select "Delete"** from the menu
3. **Confirm the deletion**

**Delete multiple counters:**
1. **Long-press any counter** to enter selection mode
2. **Tap additional counters** to select them
3. **Tap the delete icon** in the toolbar
4. **Confirm the deletion**

!!! warning
    Deleted counters cannot be recovered unless you have a backup export. Always export important data before deleting.

---

## Backup & Restore

### Export Counters

Create a backup of all your counters:

1. **Open the app menu** (three dots or hamburger icon)
2. **Select "Export Counters"**
3. **Choose a save location** on your device
4. **Save the JSON file**

The export file contains:
- All counter configurations
- Complete value history
- Update timestamps
- All statistics data

**File format:** JSON (human-readable text)

!!! tip
    Export your counters regularly, especially before app updates or when switching devices.

### Import Counters

Restore counters from a previous export:

1. **Open the app menu**
2. **Select "Import Counters"**
3. **Navigate to your backup file** (JSON format)
4. **Select the file** to import
5. **Choose import mode:**
   - **Merge:** Add imported counters to existing ones
   - **Replace:** Delete existing counters and import

!!! warning
    "Replace" mode will delete all current counters. Make sure you have a backup before using this option.

---

## Tips & Best Practices

### Naming Conventions

**Good names include:**
- What you're tracking
- Units of measurement
- Timing context

**Examples:**
- "Daily Water (8oz glasses)"
- "Morning Weight (kg)"
- "Work Tasks Completed"
- "Push-ups (per session)"

### Organization

**Keep your counter list organized:**
- Use consistent naming patterns
- Delete counters you no longer use
- Group related counters with prefixes (e.g., "Health: Weight", "Health: Steps")

### Data Management

**Protect your data:**
- Export counters monthly
- Keep backups in cloud storage
- Test imports periodically to ensure backups work

**Review your data:**
- Check statistics weekly
- Look for patterns and trends
- Adjust tracking methods if needed

### Performance Tips

**For faster updates:**
- Disable confirmation on frequently-used Tap Counters
- Use appropriate step sizes (avoid step size 1 if counting by 10s)
- Keep counter names concise

---

## Themes

### Switch Between Light and Dark Mode

1. **Open the app menu**
2. **Select "Settings"** or "Theme"
3. **Choose your preferred theme:**
   - Light mode
   - Dark mode
   - System default (matches device setting)

The theme applies immediately to all screens.

---

## Troubleshooting

### Counter Not Updating

**Possible causes:**
- Confirmation dialog was cancelled
- Invalid value entered (Series Counter)
- App needs restart

**Solutions:**
- Try updating again
- Check for error messages
- Restart the app

### Statistics Not Showing

**Possible causes:**
- No data recorded yet
- Time range filter excludes all data
- Counter was just created

**Solutions:**
- Add some data points first
- Adjust time range filter to "All"
- Wait for data to accumulate

### Import Failed

**Possible causes:**
- Invalid JSON file
- File from incompatible version
- Corrupted backup

**Solutions:**
- Verify the file is a valid Count App export
- Check file wasn't modified
- Try a different backup file

### Data Disappeared

**Prevention:**
- Regular exports (weekly or monthly)
- Multiple backup locations
- Test restores periodically

**Recovery:**
- Import from most recent backup
- Check device storage for auto-backups (if enabled)

---

## Keyboard Shortcuts

(If applicable to desktop versions)

| Action | Shortcut |
|--------|----------|
| Add counter | Ctrl/Cmd + N |
| Export | Ctrl/Cmd + E |
| Search | Ctrl/Cmd + F |

---

## See Also

- **[Counter Types Guide](counters.md)** - Detailed information about Tap and Series counters
- **[Installation](../getting-started/installation.md)** - Download and install the app
- **[Development](../getting-started/development.md)** - Build from source
