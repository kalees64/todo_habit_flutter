# TaskFlow 🌿

> **A thoughtful, distraction-free task and habit manager for Android.**
> Built with Flutter, Drift SQLite, and Flutter Riverpod. 100% offline with zero network tracking.

---

## 📖 Table of Contents
- [Overview](#overview)
- [Architecture & Tech Stack](#architecture--tech-stack)
- [Design System: Calm Kinetic](#design-system-calm-kinetic)
- [Project Directory Structure](#project-directory-structure)
- [Getting Started](#getting-started)
- [Running Code Generation](#running-code-generation)
- [Testing](#testing)
- [Core Features](#core-features)

---

## Overview

TaskFlow is designed to make productivity calm and purposeful. Combining flexible to-do management with seamless habit tracking:
- **Zero Networking**: 100% offline. No analytics, tracking, or network calls (`http`/`dio` are completely absent).
- **Reactive Persistence**: Powered by SQLite via **Drift**; UI updates instantly via reactive streams (`.watch()`).
- **Automatic Habit Promotion**: Recurring tasks automatically promote to tracked habits with streak calculations.
- **Grace-Period Streaks**: Missed by a day? A 1-day grace period keeps your momentum alive before resetting.
- **Calm Kinetic Design**: Soft sage greens, warm charcoal dark mode, crisp typography (Inter & Manrope), and strict 4pt baseline grid.

---

## Architecture & Tech Stack

TaskFlow follows **Feature-First Clean Architecture**:

```
lib/
├── app/                  # Application initialization, root widget, GoRouter configuration
├── core/                 # Shared foundations
│   ├── constants/        # Constants & native icon semantics
│   ├── notifications/    # Local notification service (exact alarms & habit nudges)
│   ├── providers/        # Global Drift database and repository providers
│   ├── theme/            # Calm Kinetic palette, typography tokens, spacing constants
│   └── utils/            # Pure streak calculation math and date utilities
├── data/                 # Data layer (Drift SQLite schema, DAOs, repository implementations)
│   ├── local/            # Database class, tables (Tasks, Habits, StreakLogs), DAOs
│   └── repositories/     # Concrete implementations of domain repository contracts
├── domain/               # Domain layer (pure Dart, zero Flutter dependencies)
│   ├── entities/         # Immutable models (Task, Habit, StreakLog)
│   ├── repositories/     # Repository interface contracts
│   └── usecases/         # Pure business logic (CreateTask, UpdateStreak, CompleteTask, etc.)
├── features/             # Feature-first presentation & state management
│   ├── completed/        # Completed tasks history screen & undo actions
│   ├── habits/           # Habit list, habit detail, heatmap calendar, streak badges
│   ├── settings/         # Theme toggling (System/Light/Dark) & notification diagnostics
│   └── todo/             # Home screen, task grouping, bottom sheets, task tiles
└── shared/               # Reusable UI widgets (AppScaffold, PrimaryButton, EmptyState, ConfirmDialog)
```

### Key Libraries
- **Flutter SDK**: 3.47+ (Dart 3.13+)
- **State Management**: `flutter_riverpod` (using modern `Notifier` and `NotifierProvider`)
- **Database & Reactive Querying**: `drift` & `sqlite3_flutter_libs`
- **Routing**: `go_router` (declarative shell navigation)
- **Notifications**: `flutter_local_notifications`, `timezone`, `flutter_timezone`
- **Typography & Calendar**: `google_fonts`, `table_calendar`, `intl`

---

## Design System: Calm Kinetic

- **Light Mode**:
  - Background: `#FAFAF9`
  - Surface: `#FFFFFF`
  - Primary Accent: `#2F6F4E` (Calm Forest Green)
  - Text Primary: `#1A1A1A`
  - Danger / Overdue: `#C0392B`
- **Dark Mode**:
  - Background: `#121212`
  - Surface: `#1E1E1E`
  - Primary Accent: `#5FBE8E` (Luminescent Mint)
  - Text Primary: `#EDEDED`
  - Danger / Overdue: `#E57373`
- **Spacing**: Strict 4pt grid (`4`, `8`, `12`, `16`, `24`, `32`).
- **Shapes & Elevation**: Flat cards with 12–16px radii, 1px subtle borders, no muddy drop shadows or neon gradients.

---

## Getting Started

### Prerequisites
- Flutter SDK (3.24+ recommended, tested on Flutter 3.47.2 / Dart 3.13.2)
- Android SDK / Emulator or Device (API 26+)

### Installation
```bash
# Clone or navigate to the project directory
cd "d:/Code/My Projects/todo"

# Install dependencies
flutter pub get
```

### Running the App
```bash
# Run on connected device or emulator
flutter run
```

---

## Running Code Generation

Drift SQLite tables and DAOs generate boilerplate via `build_runner`. To regenerate all `.g.dart` files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Testing

TaskFlow includes comprehensive unit and widget tests:

```bash
# Run the complete test suite
flutter test

# Run static analysis
flutter analyze
```

### Test Coverage Highlights
1. **Streak Calculation Engine (`test/unit/streak_calculation_test.dart`)**:
   - First completion initialization (`currentStreak = 1`, `longestStreak = 1`).
   - Consecutive on-time completion next day increments streak.
   - Grace period handling (1-day gap for daily habits keeps streak alive).
   - Late completion exceeding grace period resets streak to 1.
   - Same-day back-to-back completion idempotency (does not double-count).
   - Weekly recurrence intervals and validation.
2. **Repository CRUD (`test/unit/task_repository_test.dart`, `test/unit/habit_repository_test.dart`)**:
   - In-memory Drift SQLite test database testing full reactive lifecycle.
3. **Widget & Flow Tests (`test/widget/app_flows_test.dart`, `test/widget_test.dart`)**:
   - Creating tasks and verifying reactive appearance in grouped list.
   - Completing tasks and observing immediate transition to Completed screen with undo.
   - Two consecutive daily completions verifying habit streak increments.

---

## Core Features

1. **Intelligent Task Grouping**:
   - Automatically segments active tasks into **Overdue**, **Today**, **Upcoming**, and **No Due Date**.
   - Collapsible section headers with count badges.
2. **Seamless Habit Integration**:
   - Assigning a recurrence rule (`daily`, `weekdays`, `weekly`) automatically creates an associated Habit entity with streak tracking.
3. **Visual Streak Tracking**:
   - Habit detail view includes an interactive consistency heatmap powered by `table_calendar`.
   - Current streak and longest streak records with flame indicators.
4. **Offline Notifications**:
   - Task due date alarms and daily habit preservation nudges scheduled via Android's exact alarm permissions.
5. **Theme Switching**:
   - Persistent theme mode selection (System, Light, Dark) in Settings.
