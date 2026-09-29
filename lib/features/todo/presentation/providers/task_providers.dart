import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/task.dart';

/// Stream of all active (incomplete) tasks
final activeTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final getActiveTasks = ref.watch(getActiveTasksProvider);
  return getActiveTasks.watch();
});

/// Categorized active tasks container
class CategorizedTasks {
  const CategorizedTasks({
    required this.overdue,
    required this.today,
    required this.upcoming,
    required this.noDueDate,
  });

  final List<Task> overdue;
  final List<Task> today;
  final List<Task> upcoming;
  final List<Task> noDueDate;

  int get totalCount =>
      overdue.length + today.length + upcoming.length + noDueDate.length;
}

/// Active tasks categorized into Overdue, Today, Upcoming, and No due date
final categorizedTasksProvider = Provider<AsyncValue<CategorizedTasks>>((ref) {
  final activeTasksAsync = ref.watch(activeTasksStreamProvider);

  return activeTasksAsync.whenData((tasks) {
    final now = DateTime.now();
    final overdue = <Task>[];
    final today = <Task>[];
    final upcoming = <Task>[];
    final noDueDate = <Task>[];

    for (final task in tasks) {
      final dueDate = task.dueDate;
      if (dueDate == null) {
        noDueDate.add(task);
      } else {
        final localDue = dueDate.toLocal();
        if (AppDateUtils.isSameDay(localDue, now)) {
          today.add(task);
        } else if (localDue.isBefore(now)) {
          overdue.add(task);
        } else {
          upcoming.add(task);
        }
      }
    }

    return CategorizedTasks(
      overdue: overdue,
      today: today,
      upcoming: upcoming,
      noDueDate: noDueDate,
    );
  });
});

/// Rhythm Stats: total today tasks vs completed today
final todayRhythmStatsProvider = Provider<({int done, int total, double progress})>((ref) {
  final activeTasks = ref.watch(activeTasksStreamProvider).asData?.value ?? [];

  // Completed today
  final now = DateTime.now();
  int completedTodayCount = 0;
  final completedTasksList = ref.watch(completedTasksStreamProvider).asData?.value ?? [];
  for (final t in completedTasksList) {
    if (t.completedAt != null && AppDateUtils.isSameDay(t.completedAt!, now)) {
      completedTodayCount++;
    }
  }

  int activeTodayCount = 0;
  for (final t in activeTasks) {
    if (t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!, now)) {
      activeTodayCount++;
    }
  }

  final total = activeTodayCount + completedTodayCount;
  final progress = total == 0 ? 0.0 : (completedTodayCount / total).clamp(0.0, 1.0);

  return (
    done: completedTodayCount,
    total: total,
    progress: progress,
  );
});

/// Stream of completed tasks for use in providers and history screen
final completedTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final getCompletedTasks = ref.watch(getCompletedTasksProvider);
  return getCompletedTasks.watch();
});

/// Provider that keeps the un-dismissible pinned daily tasks notification in sync
/// with active and completed tasks in real-time.
///
/// Behavior:
/// - Evaluates overdue and today's tasks.
/// - If all tasks are completed or no tasks are planned today: cancels the pinned notification.
/// - If tasks remain: shows/updates the notification with live counts & bullet list.
/// - Pre-schedules tomorrow's 00:00 midnight alarm with tomorrow's planned tasks.
final dailyPinnedNotificationSyncProvider = Provider<void>((ref) {
  final activeTasksAsync = ref.watch(activeTasksStreamProvider);
  final completedTasksAsync = ref.watch(completedTasksStreamProvider);

  activeTasksAsync.whenData((activeTasks) {
    completedTasksAsync.whenData((completedTasks) {
      final now = DateTime.now();

      // Overdue + Today's pending tasks (per Socratic Gate approval)
      final pendingTasks = <Task>[];
      for (final t in activeTasks) {
        if (t.dueDate != null) {
          final localDue = t.dueDate!.toLocal();
          if (AppDateUtils.isSameDay(localDue, now) || localDue.isBefore(now)) {
            pendingTasks.add(t);
          }
        }
      }

      int completedTodayCount = 0;
      for (final t in completedTasks) {
        if (t.completedAt != null && AppDateUtils.isSameDay(t.completedAt!, now)) {
          completedTodayCount++;
        }
      }

      final totalTodayCount = pendingTasks.length + completedTodayCount;

      // Update or clear the pinned notification based on remaining tasks
      NotificationService.instance.showOrUpdateDailyPinnedNotification(
        pendingTasks: pendingTasks,
        totalTodayCount: totalTodayCount,
        completedTodayCount: completedTodayCount,
      );

      // Pre-schedule midnight (00:00:00) exact alarm for tomorrow's tasks
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowTasks = activeTasks
          .where((t) => t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!.toLocal(), tomorrow))
          .toList();

      NotificationService.instance.scheduleMidnightPinnedNotification(
        tomorrowTasks: tomorrowTasks,
      );
    });
  });
});
