# TaskFlow — To-Do + Habit + Streak Tracker

### Flutter App Blueprint (Local-First, No Server)

---

## 1. Project Summary

A single local-first Android app (Flutter) with three connected modules:

1. **To-Do Tasks** — title, due date, completion tracking (date + time stamped on completion), and a separate "Completed Tasks" history page.
2. **Habit Tracker** — a task repeated daily or on a fixed period automatically gets promoted into a "habit."
3. **Streak Maintainer** — counts consecutive on-time completions of a habit and drives reminder notifications.

**"No server, no databases"** — interpreted as: no backend/cloud database. You still need an **on-device** database for reliable relational data (tasks ↔ habits ↔ streak logs). This is not a "server" — it's just a local file on the phone, fully offline, fully private.

---

## 2. Recommended Tech Stack

| Concern              | Package                                                       | Why                                                                                                                                                        |
| -------------------- | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| State management     | **flutter_riverpod**                                          | Compile-safe DI, testable, minimal boilerplate, scales well for a solo/small dev                                                                           |
| Local database       | **drift** (SQLite wrapper)                                    | Your data is relational (Task → Habit → StreakLog). Drift gives type-safe SQL, reactive streams, and migrations — best fit over key-value stores like Hive |
| Routing              | **go_router**                                                 | Declarative, deep-link ready, clean navigation between Home / Completed / Habits / Task Detail                                                             |
| Local notifications  | **flutter_local_notifications** + **timezone**                | Schedule due-date reminders and streak "don't break the chain" nudges, fully offline                                                                       |
| Date/time handling   | **intl**                                                      | Formatting due dates, completion timestamps                                                                                                                |
| Streak/habit visuals | **fl_chart** or **table_calendar**                            | Calendar-heatmap style streak view (GitHub-contribution style)                                                                                             |
| Fonts/icons          | **google_fonts**, **lucide_icons** or **phosphor_flutter**    | Clean, modern icon set for a minimal UI                                                                                                                    |
| Unique IDs           | **uuid**                                                      | Local primary keys not tied to autoincrement quirks                                                                                                        |
| Testing              | **flutter_test**, **mocktail**, **drift**'s in-memory test DB | Unit test streak-calculation logic (the trickiest part)                                                                                                    |
| App icon/splash      | **flutter_launcher_icons**, **flutter_native_splash**         | Professional first impression                                                                                                                              |

**Optional, later phases:**

- **workmanager** — if you want streak-break detection to run even when the app isn't open (Android background checks).
- **shared_preferences** — only for tiny app settings (theme, first-run flag), not core data.

> Skip Firebase/Supabase/Isar entirely for v1 — they add complexity you don't need for a local-first, single-user app with relational data.

---

## 3. Architecture

Use a **feature-first Clean Architecture**, kept lightweight (no need for heavy DI frameworks like get_it if Riverpod already handles injection).

### 3.1 Layers (per feature)

```
presentation  →  UI widgets + Riverpod state (Notifiers/Providers)
domain        →  Entities + UseCases (pure Dart, no Flutter/Drift imports)
data          →  Repository implementation + Drift DAOs (talks to local DB)
```

Rule of dependency: **presentation → domain ← data**. Domain never imports Drift or Flutter — this keeps streak-calculation logic 100% unit-testable.

### 3.2 Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                # MaterialApp, theme, router
│   └── router.dart             # go_router routes
├── core/
│   ├── theme/                  # colors, typography, spacing tokens
│   ├── constants/
│   ├── utils/                  # date helpers, streak math helpers
│   └── notifications/          # local notification service wrapper
├── data/
│   ├── local/
│   │   ├── database.dart       # Drift @DriftDatabase
│   │   ├── tables/
│   │   │   ├── tasks_table.dart
│   │   │   ├── habits_table.dart
│   │   │   └── streak_logs_table.dart
│   │   └── daos/
│   └── repositories/
│       ├── task_repository_impl.dart
│       ├── habit_repository_impl.dart
│       └── streak_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── task.dart
│   │   ├── habit.dart
│   │   └── streak_log.dart
│   ├── repositories/            # abstract interfaces
│   └── usecases/
│       ├── create_task.dart
│       ├── complete_task.dart
│       ├── detect_habit_from_task.dart
│       ├── update_streak.dart
│       └── get_completed_tasks.dart
├── features/
│   ├── todo/
│   │   ├── presentation/
│   │   │   ├── screens/ (home_screen.dart, task_detail_screen.dart)
│   │   │   ├── widgets/ (task_tile.dart, add_task_sheet.dart)
│   │   │   └── providers/ (task_list_provider.dart)
│   ├── completed/
│   │   └── presentation/screens/completed_tasks_screen.dart
│   └── habits/
│       ├── presentation/
│       │   ├── screens/habits_screen.dart, habit_detail_screen.dart
│       │   └── widgets/streak_calendar.dart, streak_badge.dart
└── shared/
    └── widgets/                 # buttons, empty states, app_bar, dialogs
```

### 3.3 Data Model (Drift tables, simplified)

```
Task
- id (uuid, pk)
- title
- dueDate (nullable DateTime)
- isCompleted (bool)
- completedAt (nullable DateTime)   -- exact completion date+time
- recurrenceRule (nullable enum: none/daily/weekly/custom)
- habitId (nullable FK → Habit)

Habit
- id (uuid, pk)
- title
- recurrenceRule
- createdFromTaskId
- currentStreak (int)
- longestStreak (int)
- lastCompletedDate

StreakLog
- id (uuid, pk)
- habitId (FK)
- date
- wasCompletedOnTime (bool)
```

### 3.4 How the three modules connect

1. User creates a **Task**. If it has no recurrence → it's a plain to-do.
2. On completion, `completedAt` is stamped and the task moves to the **Completed Tasks** page (a filtered query: `isCompleted == true`, sorted by `completedAt DESC`).
3. **Habit detection use case**: when the same task title/recurrence pattern is completed for N consecutive periods (e.g., same task repeated daily for 3+ days), it's auto-promoted to a **Habit** — or the user can explicitly mark a task as recurring at creation time (simpler for v1 — do this first, add auto-detection later).
4. Each time a Habit's linked task instance is completed, a **StreakLog** entry is written and `currentStreak` is recalculated (see logic below).
5. **Notifications** read from both Task (due date) and Habit (time-of-day + streak-at-risk warning, e.g., "Complete 'Read 10 pages' today to keep your 7-day streak!").

### 3.5 Streak Calculation Logic (core algorithm)

```
On task completion:
1. Find linked Habit (or none).
2. If none and recurrenceRule != none → create Habit, streak = 1.
3. If Habit exists:
   a. Compare completedAt date to lastCompletedDate + expected period.
   b. If completed within the expected window → currentStreak += 1.
   c. If a period was missed → currentStreak resets to 1 (or 0, then 1 on this completion).
   d. longestStreak = max(longestStreak, currentStreak).
   e. Write StreakLog row for the day/period.
4. Persist updated Habit.
```

Keep this in a pure `UpdateStreak` usecase in `domain/` — no Flutter/DB imports — so it can be unit tested with plain date fixtures.

---

## 4. Minimal, Professional Design Direction

### 4.1 Principles

- **Material 3**, but restrained — no default purple. Custom `ColorScheme.fromSeed()` with a calm, focused accent.
- Generous white space, **4/8pt spacing grid** (4, 8, 12, 16, 24, 32).
- One accent color for action + streak highlights; everything else neutral gray/ink.
- No unnecessary shadows/gradients — flat cards with subtle elevation (1–2dp) or a hairline border.

### 4.2 Suggested Palette

| Token            | Light                                               | Dark      |
| ---------------- | --------------------------------------------------- | --------- |
| Background       | `#FAFAF9`                                           | `#121212` |
| Surface/Card     | `#FFFFFF`                                           | `#1E1E1E` |
| Primary (accent) | `#2F6F4E` (calm green — reinforces "growth/streak") | `#5FBE8E` |
| Text primary     | `#1A1A1A`                                           | `#EDEDED` |
| Text secondary   | `#6B6B6B`                                           | `#A0A0A0` |
| Success/Streak   | `#2F6F4E`                                           | `#5FBE8E` |
| Overdue/Danger   | `#C0392B`                                           | `#E57373` |

### 4.3 Typography

- **Inter** or **Manrope** via `google_fonts` — modern, highly legible on Android.
- Scale: Title 22/600, Section 16/600, Body 14/400, Caption 12/400.

### 4.4 Key Screens

1. **Home (To-Do list)** — grouped by "Today / Upcoming / Overdue," floating action button to add task, swipe-to-complete.
2. **Add/Edit Task sheet** — bottom sheet: title, due date/time picker, recurrence toggle (None / Daily / Weekly / Custom).
3. **Completed Tasks** — reverse-chronological list, grouped by date, shows completion time as a small trailing chip.
4. **Habits** — card grid/list, each showing current streak (flame icon + number) and a mini calendar-heatmap.
5. **Habit Detail** — full streak calendar, longest streak, completion history, edit reminder time.
6. **Settings** — theme toggle, notification preferences.

### 4.5 Micro-details that make it feel "professional"

- Subtle check-mark animation on completion (`AnimatedSwitcher` or `flutter_animate`, optional).
- Streak flame icon changes color intensity with streak length.
- Empty states with a simple line-icon illustration, not a wall of text.
- Consistent 12–16px corner radius across cards/sheets/buttons.

---

## 5. Phase-Wise Development Plan

### Phase 0 — Setup (0.5–1 day)

- Init Flutter project, folder structure above.
- Add core packages, set up theme tokens, `go_router` skeleton.
- Set up Drift database with empty tables + migrations scaffold.

### Phase 1 — Core To-Do (2–4 days)

- Task entity + Drift table + repository + usecases (create/read/update/delete).
- Home screen: list tasks, add task bottom sheet (title + due date only, no recurrence yet).
- Mark task complete → stamp `completedAt`.
- Basic Riverpod providers wired to Drift's reactive streams (`watch()` queries auto-update UI).

**Milestone:** Fully working offline to-do list with due dates and completion timestamps.

### Phase 2 — Completed Tasks Page (1–2 days)

- Separate screen querying `isCompleted == true`, grouped by completion date.
- Undo-complete action (swipe back to active).
- Empty state design.

### Phase 3 — Reminders/Notifications for Tasks (2–3 days)

- Integrate `flutter_local_notifications` + timezone setup.
- Schedule a local notification at due date/time.
- Handle notification permission (Android 13+ runtime permission).
- Cancel/reschedule notification on task edit/delete/complete.

### Phase 4 — Recurrence & Habit Engine (3–5 days)

- Add recurrence field to task creation (Daily/Weekly/Custom).
- Implement `Habit` table + repository.
- Implement the habit-promotion + `UpdateStreak` usecase (write unit tests here first — this is the logic that must be bulletproof).
- Wire task completion to also update linked Habit + write `StreakLog`.

### Phase 5 — Habit & Streak UI (3–4 days)

- Habits list screen with streak badges.
- Habit detail screen with calendar-heatmap (`table_calendar` custom builder or `fl_chart`).
- Streak-at-risk notification ("Don't break your 5-day streak — complete today!") scheduled based on habit's time window.

### Phase 6 — Polish, Testing, Release Prep (2–4 days)

- Full theming pass (light/dark), app icon, splash screen.
- Unit tests for streak logic + repository tests with in-memory Drift DB.
- Widget tests for critical flows (add task, complete task, streak increments).
- Performance pass (avoid rebuild storms, index Drift queries by date).
- Play Store listing assets, release build signing.

**Total estimate for a focused solo dev: ~3–4 weeks** for a polished v1.

---

## 6. Build Order Priority (if time-boxed further)

If you need an even leaner MVP first:

1. Phase 1 (To-do CRUD + completion) →
2. Phase 2 (Completed page) →
3. Phase 3 (Notifications) →
   **ship this as v1**, then add Habit/Streak (Phases 4–5) as v1.1 — since you said "start with to-do task" first, this order matches your own stated priority.

---

## 7. Key Implementation Notes

- Use Drift's `.watch()` streams everywhere instead of manual refresh calls — this keeps UI reactive with almost no boilerplate.
- Keep the streak math in pure Dart (`domain/usecases/update_streak.dart`) with no Flutter or Drift imports so it's trivially unit-testable with fake dates.
- Store all dates in UTC in the DB, convert to local time only in the presentation layer, to avoid streak-calculation bugs around timezones/DST.
- Android 13+ requires the `POST_NOTIFICATIONS` runtime permission — request it on first app launch or right before scheduling the first reminder.
