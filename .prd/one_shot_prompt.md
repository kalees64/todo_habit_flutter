# One-Shot Build Prompt for Antigravity

Copy everything below into Antigravity as a single prompt.

---

You are building a complete, production-quality **Flutter Android application** called **TaskFlow** in one pass. Build the full project end-to-end: project scaffolding, all source files, local database, UI, notifications, and tests. Do not ask clarifying questions — every decision you need is specified below. Where something is genuinely ambiguous, make the most sensible professional choice and note it in a `DECISIONS.md` file at the project root.

## 1. What This App Does

TaskFlow is a **local-first, offline-only** Android app with three connected modules:

1. **To-Do Tasks** — create tasks with a title and optional due date/time. Mark tasks complete; store the exact completion date+time. Completed tasks move into a dedicated **Completed Tasks** history screen (grouped by completion date, most recent first).
2. **Habit Tracker** — a task can be marked recurring (Daily / Weekly / Custom interval) at creation time. A recurring task is a **Habit**.
3. **Streak Maintainer** — every time a Habit's task instance is completed on schedule, its streak counter increments. Missing a scheduled period resets the streak. Streaks are visualized and drive "keep your streak alive" reminder notifications.

There is **no backend, no cloud service, no remote database, and no network calls of any kind**. All data lives in an on-device SQLite database via Drift. The app must work fully in airplane mode, forever.

## 2. Tech Stack (use exactly these; do not substitute)

- Flutter (latest stable), Android target only for this build (ignore iOS-specific concerns).
- State management: `flutter_riverpod`
- Local database: `drift` (SQLite) with `sqlite3_flutter_libs`
- Routing: `go_router`
- Local notifications: `flutter_local_notifications` + `timezone` + `flutter_timezone`
- Date formatting: `intl`
- Streak/habit calendar visualization: `table_calendar` (for the heatmap/calendar view on Habit Detail)
- Fonts/Icons: `google_fonts` (Inter or Manrope), `lucide_icons` (or `phosphor_flutter`)
- IDs: `uuid`
- Testing: `flutter_test`, `mocktail`, Drift's in-memory `NativeDatabase.memory()` for repository tests
- App branding: `flutter_launcher_icons`, `flutter_native_splash`

Do not add Firebase, Supabase, Hive, Isar, get_it, http, dio, or any networking/cloud package. This is intentional.

## 3. Architecture — Feature-First Clean Architecture

Enforce this dependency rule strictly: **presentation → domain ← data**. The `domain/` layer must be pure Dart — zero imports of Flutter, Drift, or any UI/DB package — so its logic (especially streak calculation) is unit-testable with plain Dart date objects.

Use exactly this folder structure:

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
├── core/
│   ├── theme/            # colors.dart, typography.dart, spacing.dart, theme.dart
│   ├── constants/
│   ├── utils/            # date_utils.dart, streak_math.dart (pure helpers)
│   └── notifications/    # notification_service.dart
├── data/
│   ├── local/
│   │   ├── database.dart
│   │   ├── tables/
│   │   │   ├── tasks_table.dart
│   │   │   ├── habits_table.dart
│   │   │   └── streak_logs_table.dart
│   │   └── daos/
│   │       ├── task_dao.dart
│   │       ├── habit_dao.dart
│   │       └── streak_log_dao.dart
│   └── repositories/
│       ├── task_repository_impl.dart
│       ├── habit_repository_impl.dart
│       └── streak_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── task.dart
│   │   ├── habit.dart
│   │   └── streak_log.dart
│   ├── repositories/     # abstract interfaces: task_repository.dart, habit_repository.dart, streak_repository.dart
│   └── usecases/
│       ├── create_task.dart
│       ├── update_task.dart
│       ├── delete_task.dart
│       ├── complete_task.dart
│       ├── uncomplete_task.dart
│       ├── get_active_tasks.dart
│       ├── get_completed_tasks.dart
│       ├── promote_task_to_habit.dart
│       └── update_streak.dart
├── features/
│   ├── todo/
│   │   └── presentation/
│   │       ├── screens/home_screen.dart, task_detail_screen.dart
│   │       ├── widgets/task_tile.dart, add_edit_task_sheet.dart, section_header.dart
│   │       └── providers/task_providers.dart
│   ├── completed/
│   │   └── presentation/
│   │       ├── screens/completed_tasks_screen.dart
│   │       └── providers/completed_providers.dart
│   ├── habits/
│   │   └── presentation/
│   │       ├── screens/habits_screen.dart, habit_detail_screen.dart
│   │       ├── widgets/streak_badge.dart, streak_calendar.dart, habit_card.dart
│   │       └── providers/habit_providers.dart
│   └── settings/
│       └── presentation/screens/settings_screen.dart
└── shared/
    └── widgets/          # primary_button.dart, empty_state.dart, app_scaffold.dart, confirm_dialog.dart
```

## 4. Data Model (Drift tables)

```
Task
- id: TEXT (uuid, primary key)
- title: TEXT NOT NULL
- dueDate: DATETIME NULL
- isCompleted: BOOLEAN NOT NULL DEFAULT false
- completedAt: DATETIME NULL
- recurrenceRule: TEXT NULL   -- enum: none | daily | weekly | custom
- customIntervalDays: INTEGER NULL  -- only used when recurrenceRule = custom
- habitId: TEXT NULL          -- FK -> Habit.id
- createdAt: DATETIME NOT NULL

Habit
- id: TEXT (uuid, primary key)
- title: TEXT NOT NULL
- recurrenceRule: TEXT NOT NULL
- customIntervalDays: INTEGER NULL
- currentStreak: INTEGER NOT NULL DEFAULT 0
- longestStreak: INTEGER NOT NULL DEFAULT 0
- lastCompletedDate: DATETIME NULL
- reminderTime: TEXT NULL     -- "HH:mm" local time for the daily nudge
- createdAt: DATETIME NOT NULL

StreakLog
- id: TEXT (uuid, primary key)
- habitId: TEXT NOT NULL      -- FK -> Habit.id
- date: DATETIME NOT NULL
- wasCompletedOnTime: BOOLEAN NOT NULL
```

Store all DATETIME values in UTC. Convert to device local time only inside the presentation layer.

## 5. Functional Requirements

### 5.1 To-Do Core

- Create task: title (required), due date + time (optional), recurrence (None by default).
- Edit task: same fields, editable anytime except after completion (allow editing title even if completed).
- Delete task with a confirmation dialog.
- Mark complete: stamp `completedAt = DateTime.now().toUtc()`, set `isCompleted = true`. If the task has a recurrence != none, run the habit promotion + streak update flow (5.3).
- Uncomplete (undo): available from both Home and Completed Tasks screens via a swipe or button; clears `completedAt`, sets `isCompleted = false`. If this was a habit completion, roll back the streak update for that log entry.
- Home screen groups active tasks into: **Overdue** (dueDate in the past, not completed), **Today**, **Upcoming**, **No due date** — in that order.

### 5.2 Completed Tasks Screen

- Query: `isCompleted == true`, ordered by `completedAt DESC`.
- Group by completion date (e.g., "Today", "Yesterday", then actual dates).
- Each row shows the task title and the completion time (e.g., "Completed at 6:42 PM").
- Support undo-complete from this screen.

### 5.3 Habit Promotion & Streak Logic

Implement as a pure, unit-testable usecase (`update_streak.dart` in `domain/usecases`), with this exact algorithm:

```
onTaskCompleted(task):
  if task.recurrenceRule == none:
    return  // plain to-do, nothing else happens

  habit = findHabitByTaskLineage(task) ?? createHabitFromTask(task)

  expectedPeriod = periodFor(habit.recurrenceRule, habit.customIntervalDays)
  if habit.lastCompletedDate == null:
    habit.currentStreak = 1
  else:
    gap = task.completedAt.date - habit.lastCompletedDate.date
    if gap <= expectedPeriod (with 1 grace day for daily/weekly):
      habit.currentStreak += 1
    else:
      habit.currentStreak = 1  // missed a period, restart

  habit.longestStreak = max(habit.longestStreak, habit.currentStreak)
  habit.lastCompletedDate = task.completedAt
  writeStreakLog(habit.id, task.completedAt, wasCompletedOnTime: gap <= expectedPeriod)
  persist(habit)
```

Write this with clear, named functions and full unit test coverage using fixed fake `DateTime` values (on-time completion, late completion that breaks the streak, and back-to-back completions on the same day which should NOT double-increment).

### 5.4 Notifications (all local, no network)

- Schedule a notification at a task's `dueDate` if set (only for incomplete tasks).
- Cancel/reschedule the notification whenever the task is edited, completed, or deleted.
- For each Habit with a `reminderTime` set, schedule a daily (or per-recurrence) local notification: "Don't break your streak — complete '{habit.title}' today!" only if today's instance isn't completed yet.
- Handle the Android 13+ `POST_NOTIFICATIONS` runtime permission request on first launch, before the first scheduled notification.

## 6. Design System

Implement Material 3 with a custom seed color — do not use the default purple.

**Colors** (define as `ColorScheme` extensions / theme tokens, with light + dark variants):

- Background: light `#FAFAF9`, dark `#121212`
- Surface/Card: light `#FFFFFF`, dark `#1E1E1E`
- Primary/accent (calm green): light `#2F6F4E`, dark `#5FBE8E`
- Text primary: light `#1A1A1A`, dark `#EDEDED`
- Text secondary: light `#6B6B6B`, dark `#A0A0A0`
- Danger/overdue: light `#C0392B`, dark `#E57373`

**Typography**: Google Fonts "Inter" (fallback "Manrope"). Scale: Title 22/600, Section header 16/600, Body 14/400, Caption 12/400.

**Spacing**: strict 4pt grid — use only 4, 8, 12, 16, 24, 32 for padding/margins/gaps.

**Components**: flat cards, 12–16px corner radius everywhere (cards, sheets, buttons, chips), elevation 1–2dp max or a 1px hairline border instead of shadow. No gradients.

**Screens to build:**

1. Home (grouped to-do list, FAB to add task, swipe-to-complete)
2. Add/Edit Task bottom sheet (title, due date+time picker, recurrence selector)
3. Completed Tasks (grouped by date, undo action)
4. Habits list (cards with streak flame + number, tap to open detail)
5. Habit Detail (calendar heatmap via `table_calendar`, current/longest streak stats, reminder time editor)
6. Settings (theme toggle: light/dark/system, notification permission status)
7. Empty states for Home, Completed, and Habits when their lists are empty (simple line-icon + short message, no walls of text)

Support both light and dark mode fully, following system setting by default with a manual override in Settings.

## 7. Non-Functional Requirements

- 100% offline. No `http`/`dio` packages, no analytics SDKs, no permissions beyond notifications.
- Use Drift's `.watch()` reactive streams for all list queries — no manual pull-to-refresh needed for data changes.
- Unit tests for: streak calculation (all branch cases in 5.3), task repository CRUD, habit repository CRUD — using in-memory Drift DB.
- Widget tests for: adding a task, completing a task (and seeing it move to Completed), and a habit's streak incrementing after two on-time completions.
- App must build and run with `flutter run` with zero manual setup steps beyond `flutter pub get`.
- Add `flutter_launcher_icons` and `flutter_native_splash` config with a simple, on-brand icon (a checkmark or flame motif in the primary green) and matching splash background.

## 8. Deliverables

- Complete Flutter project source tree matching the structure in Section 3.
- All Drift generated code produced (`build_runner` run, `.g.dart` files committed or a note on how to regenerate).
- `README.md` explaining how to run the app, run tests, and the architecture at a glance.
- `DECISIONS.md` documenting any ambiguous calls you made while building.
- All unit and widget tests passing.

## 9. Build Order (internal sequencing — still deliver everything in this one pass)

1. Scaffold project + dependencies + theme tokens + router skeleton.
2. Drift schema (tables, DAOs, database class) + domain entities/repository interfaces.
3. To-Do core: create/edit/delete/complete/uncomplete + Home screen + Add/Edit sheet.
4. Completed Tasks screen wired to the same repository.
5. Notification service + due-date scheduling, with permission handling.
6. Habit + StreakLog tables/DAOs, `update_streak` usecase with unit tests.
7. Habits list + Habit Detail screens, streak-at-risk notifications.
8. Settings screen, theming polish, launcher icon/splash.
9. Full test pass, README, DECISIONS.md.

Build the entire app now, following every specification above exactly.
