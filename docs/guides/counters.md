# Counters — available types and options

This documents the counter types shipped with Count App and the main options available.

## Tap Counter

- Purpose: Simple increment/decrement counter for frequent quick updates.
- Key options:
  - **Step size**: amount to add or subtract per interaction.
  - **Direction**: increment (default) or decrement.
  - **Require confirmation**: whether to show a confirmation dialog before updating.

## Series Counter

- Purpose: Track a series of numeric values over time, useful for measurements or scored events.
- Key options:
  - **Description**: text to help identify the series.
  - **Values**: a chronological list of recorded values; new values are added with their timestamps.
  - **Statistics**: weekly/monthly averages, highs and lows, and charts.

## Extending counters

See the [Adding New Counter Types](adding-counter-types.md) guide for a developer-oriented tutorial on creating custom counters and registering them in the app.
