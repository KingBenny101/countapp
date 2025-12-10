# Quick Start

Get Count App up and running in minutes! This guide assumes you've already completed the [Installation](installation.md) steps.

## Running the App

### Development Mode

Run the app in debug mode on your connected device or emulator:

```bash
flutter run
```

Or specify a platform:

=== "Android"

    ```bash
    flutter run -d android
    ```

=== "Windows"

    ```bash
    flutter run -d windows
    ```

=== "Linux"

    ```bash
    flutter run -d linux
    ```

### Hot Reload

While the app is running, you can:

- **Hot Reload**: Press `r` in the terminal to reload code changes
- **Hot Restart**: Press `R` to restart the app
- **Quit**: Press `q` to stop the app

## First Time Setup

When you first launch Count App:

1. **Theme Selection**: The app automatically detects your system theme (light/dark)
2. **Empty State**: You'll see an empty counter list
3. **Ready to Use**: The app is ready to create your first counter!

## Creating Your First Counter

### Using the UI

1. **Tap the FAB**: Click the floating action button (➕) at the bottom right
2. **Select Counter Type**: Currently, "Tap Counter" is available
3. **Configure Counter**:
   - **Name**: Enter a descriptive name (e.g., "Water Intake")
   - **Step Size**: Set increment/decrement value (e.g., 1)
   - **Direction**: Toggle switch for increment (➕) or decrement (➖)
   - **Initial Count**: Starting value (default: 0)
4. **Create**: Tap the FAB to save

### Example Configuration

```
Counter Name: Daily Steps
Step Size: 100
Direction: Increment (ON)
Initial Count: 0
```

## Using Counters

### Update a Counter

1. **Tap the counter** in the list
2. **Confirmation Dialog** appears (if enabled)
3. **Confirm** to update the counter value
4. **Snackbar** shows success message

### View Counter Details

Each counter displays:

- **Icon**: Color-coded by type (blue for Tap Counter)
- **Name**: Counter display name
- **Current Value**: Large number showing count
- **Subtitle**: Shows step size and direction
- **Last Updated**: Timestamp of last update

### Counter Actions

Long-press or select counters to access:

- **Statistics**: View detailed analytics and charts
- **🗑️ Delete**: Remove selected counters
- **Cancel**: Clear selection

## Navigation

### Main Screen (Home)

The home screen shows all your counters:

```
┌─────────────────────────────┐
│  Count App          ⋮      │
├─────────────────────────────┤
│                             │
│  🔵 Water Intake            │
│     8 glasses               │
│     Step Size: +1           │
│                             │
│  🔵 Daily Steps             │
│     5,200 steps             │
│     Step Size: +100         │
│                             │
└─────────────────────────────┘
              ➕
```

- **App Bar**: Title, options menu, theme toggle
- **Counter List**: All your counters
- **FAB**: Add new counter

### Options Menu

Tap the menu icon (⋮) to access:

- **All Updates**: View all counter updates across all counters
- **Info**: App information and version
- **Options**: Settings and preferences
- **Theme Toggle**: Switch between light/dark mode

## Exploring Statistics

### Access Statistics

1. **Select a counter** (long-press to enter selection mode)
2. **Tap Statistics button** in the action bar
3. **View detailed analytics**:
   - Daily update frequency chart
   - Total updates count
   - Average updates per day
   - Most active day
   - Update history timeline

### Understanding Charts

The statistics page includes:

- **Bar Chart**: Updates by day of week
- **📈 Line Chart**: Update trends over time
- **📅 Calendar View**: Daily update counts
- **📜 Update History**: Chronological list of all updates

## Data Management

### Export Data

Export all counter data to JSON:

1. Go to **Options** menu (⋮)
2. Select **Export Data**
3. Choose save location
4. JSON file is created with all counters

### Import Data

Import previously exported data:

1. Go to **Options** menu (⋮)
2. Select **Import Data**
3. Choose JSON file
4. Confirm to import

!!! warning "Import Warning"
Importing will replace all existing counters. Export your current data first if needed!

## Keyboard Shortcuts

When running on desktop (Windows/Linux):

| Action          | Shortcut       |
| --------------- | -------------- |
| Add Counter     | `Ctrl+N`       |
| Delete Selected | `Delete`       |
| Select All      | `Ctrl+A`       |
| Deselect All    | `Escape`       |
| Toggle Theme    | `Ctrl+Shift+T` |

## Example Workflows

### Workflow 1: Daily Habit Tracking

```mermaid
graph LR
    A[Create Counter] --> B[Name: Water Intake]
    B --> C[Step: +1]
    C --> D[Tap 8 times daily]
    D --> E[View Statistics]
    E --> F[Track Progress]
```

1. Create "Water Intake" counter with step size +1
2. Tap once each time you drink a glass of water
3. View statistics to see daily patterns
4. Adjust habits based on data

### Workflow 2: Project Tracking

```mermaid
graph LR
    A[Create Counter] --> B[Name: Bug Fixes]
    B --> C[Step: +1]
    C --> D[Update on completion]
    D --> E[Export weekly]
    E --> F[Generate reports]
```

1. Create "Bug Fixes" counter with step size +1
2. Increment for each bug fixed
3. Export data weekly for reporting
4. Analyze productivity trends

### Workflow 3: Inventory Management

```mermaid
graph LR
    A[Create Counters] --> B[Name: Stock Items]
    B --> C[Step: ±10]
    C --> D[Increment on restock]
    D --> E[Decrement on use]
    E --> F[Monitor levels]
```

1. Create counter for each inventory item
2. Use increment direction for restocking
3. Use decrement direction for consumption
4. Monitor stock levels in real-time

## Tips & Tricks

!!! tip "Confirmation Dialogs"
Disable confirmation dialogs in counter settings for faster updates. Useful for high-frequency counting.

!!! tip "Step Size Strategy"
Use larger step sizes (10, 100) for counts that change in batches, like inventory or batch processing.

!!! tip "Naming Convention"
Use clear, descriptive names with categories: "Health: Water Intake", "Work: Tasks Completed"

!!! tip "Regular Exports"
Export your data regularly to prevent loss. Consider weekly or monthly backups.

## Common Tasks

### Task: Reset a Counter

Currently, to reset a counter:

1. Note the counter configuration
2. Delete the counter
3. Create a new counter with the same settings

### Task: Duplicate a Counter

To create a similar counter:

1. Export data
2. Open JSON file in text editor
3. Copy counter configuration
4. Modify as needed
5. Import modified JSON

### Task: Bulk Delete

To delete multiple counters:

1. Long-press to enter selection mode
2. Tap all counters to delete
3. Tap delete button (🗑️)
4. Confirm deletion

## Next Steps

Now that you're familiar with the basics:

- **[Building →](building.md)** - Create release builds for distribution
- **[Architecture →](../architecture/overview.md)** - Understand how the app works
- **[Adding Counter Types →](../guides/adding-counter-types.md)** - Extend the app with new counter types
- **[User Guide →](../user-guide/features.md)** - Explore all features in detail

## Troubleshooting

### App Won't Start

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Counters Not Saving

Check permissions:

- Android: Storage permissions
- Windows/Linux: Write permissions to app directory

### UI Not Updating

Try hot restart instead of hot reload:

- Press `R` in terminal
- Or restart the app completely

!!! success "You're Ready!"
You now know the basics of Count App. Start creating counters and tracking your data!
