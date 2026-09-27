# Architecture & Technical Decisions (DECISIONS.md)

This document records the key architectural choices, trade-offs, and technical solutions adopted during the development of **TaskFlow**.

---

### 1. Native Iconography Bridge (`AppIcons`)
- **Context**: The Calm Kinetic design tokens reference Lucide-style iconography. However, `lucide_icons 0.257.0` defines subclasses of `IconData`, which was made `final` in Dart 3.13 / Flutter 3.47+. This caused hard compilation failures.
- **Decision**: Implemented `AppIcons` in `lib/core/constants/app_icons.dart`. It provides a clean semantic abstraction layer mapping all required glyphs (checkmarks, flames, calendar, repeat, clock, undo, delete, tags, etc.) directly to Flutter's native, tree-shakeable Material icon font.
- **Benefits**: Zero external font asset overhead, zero compilation incompatibility with current and future Flutter versions.

---

### 2. UTC Normalization for Calendar Math (`calendarDaysDifference`)
- **Context**: Calculating calendar-day differences using local `DateTime.difference(other).inDays` is susceptible to off-by-one errors during Daylight Saving Time (DST) switches (where a day may have 23 or 25 hours) or across midnight transitions.
- **Decision**: In `lib/core/utils/streak_math.dart`, the `calendarDaysDifference(a, b)` function strips all time components and normalizes both dates to UTC:
  ```dart
  final utcA = DateTime.utc(a.year, a.month, a.day);
  final utcB = DateTime.utc(b.year, b.month, b.day);
  return utcB.difference(utcA).inDays;
  ```
- **Benefits**: Guarantees deterministic streak calculations in unit tests and production regardless of the device's local timezone or daylight saving regime.

---

### 3. Automatic Task-to-Habit Promotion
- **Context**: The PRD requires that any recurring task automatically becomes a tracked habit, while still behaving as an actionable to-do item on the home screen.
- **Decision**: In `lib/domain/usecases/create_task.dart`, if `recurrenceRule != 'none'`, the use case invokes `PromoteTaskToHabit`. This creates a corresponding record in the `HabitsTable` (with default streak values and daily reminders) and stamps the task with the resulting `habitId`.
- **Completion Flow**: When the task is completed via `CompleteTask`, the `UpdateStreak` use case is invoked with the task's `completedAt` timestamp, logging a streak event into `StreakLogsTable` and recalculating `currentStreak` and `longestStreak`.

---

### 4. Modern Riverpod Notifier Architecture
- **Context**: In `flutter_riverpod` 3.x, `StateNotifier` and `StateNotifierProvider` are in maintenance mode in favor of the newer `Notifier` / `AsyncNotifier` API.
- **Decision**: State management for user-configurable state (such as `ThemeModeNotifier` in `lib/features/settings/presentation/providers/theme_provider.dart`) is built using `Notifier<ThemeMode>` and `NotifierProvider`. List views and query streams use Riverpod's `StreamProvider.autoDispose` reading Drift's reactive `.watch()` queries.

---

### 5. Headless Test Isolation for Platform Channels
- **Context**: Calling `NotificationService.instance.requestPermissions()` or scheduling notifications during headless widget tests invokes Android platform channels (`AndroidFlutterLocalNotificationsPlugin`). Without native Android channel mocks, these calls can time out or leave pending async timers.
- **Decision**: Added a lightweight test-environment check in `NotificationService`:
  ```dart
  bool get _isTest => Platform.environment.containsKey('FLUTTER_TEST');
  ```
  All platform channel interactions are cleanly short-circuited when running under `flutter test`, while remaining fully operational in production on real devices and emulators.

---

### 6. Drift Stream Cancellation Timer Cleanup in Widget Tests
- **Context**: Drift's `StreamQueryStore` schedules a micro-delay `Timer(Duration.zero)` when closing or cancelling active query streams. When unmounting test widgets, Flutter's test runner enforces `!timersPending`.
- **Decision**: Widget tests explicitly pump a blank widget and drain microtasks before test teardown:
  ```dart
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
  ```
  This guarantees all reactive streams unregister and all timers resolve cleanly before test assertion checks.

---

### 7. Material 3 Theme Configuration (Flutter 3.47+ Alignment)
- **Context**: In Flutter 3.47, `CardTheme` and `DialogTheme` have migrated to `CardThemeData` and `DialogThemeData`. Furthermore, `.withOpacity()` is deprecated in favor of `.withValues(alpha: ...)`, and `ColorScheme.surfaceVariant` has been replaced with `ColorScheme.surfaceContainerHighest`.
- **Decision**: All theme and component definitions adhere to the latest Material 3 styling tokens with zero deprecated member warnings under `flutter analyze`.
