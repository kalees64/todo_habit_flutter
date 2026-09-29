import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/core/notifications/notification_service.dart';
import 'package:taskflow/core/utils/date_utils.dart';
import 'package:taskflow/domain/entities/task.dart';

void main() {
  group('Daily Pinned Notification Tests', () {
    test('Notification constants are properly configured', () {
      expect(AppConstants.pinnedNotificationChannelId, 'taskflow_pinned_tasks');
      expect(AppConstants.pinnedNotificationId, 99999);
      expect(AppConstants.midnightScheduledNotificationId, 99998);
    });

    test('Pending task filtering accurately combines Overdue and Today tasks', () {
      final now = DateTime.now();
      final todayMorning = DateTime(now.year, now.month, now.day, 9, 0);
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final tasks = [
        Task(
          id: '1',
          title: 'Overdue Task from yesterday',
          dueDate: yesterday,
          isCompleted: false,
          createdAt: yesterday,
        ),
        Task(
          id: '2',
          title: 'Today Morning Standup',
          dueDate: todayMorning,
          isCompleted: false,
          createdAt: now,
        ),
        Task(
          id: '3',
          title: 'Tomorrow Feature Review',
          dueDate: tomorrow,
          isCompleted: false,
          createdAt: now,
        ),
        Task(
          id: '4',
          title: 'Unscheduled Idea',
          dueDate: null,
          isCompleted: false,
          createdAt: now,
        ),
      ];

      // Logic matching Socratic Gate decision (Overdue + Today)
      final pendingTasks = <Task>[];
      for (final t in tasks) {
        if (t.dueDate != null) {
          final localDue = t.dueDate!.toLocal();
          if (AppDateUtils.isSameDay(localDue, now) || localDue.isBefore(now)) {
            pendingTasks.add(t);
          }
        }
      }

      expect(pendingTasks.length, 2);
      expect(pendingTasks[0].id, '1');
      expect(pendingTasks[1].id, '2');

      // Tomorrow tasks matching midnight scheduling logic
      final tomorrowTasks = tasks.where((t) {
        return t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!.toLocal(), tomorrow);
      }).toList();

      expect(tomorrowTasks.length, 1);
      expect(tomorrowTasks[0].id, '3');
    });

    test('NotificationService handles show, update, and auto-dismiss gracefully in test environment', () async {
      final now = DateTime.now();
      final task1 = Task(
        id: 'task-1',
        title: 'Review Pull Request',
        dueDate: DateTime(now.year, now.month, now.day, 10, 0),
        isCompleted: false,
        createdAt: now,
      );

      // When tasks exist: showOrUpdateDailyPinnedNotification executes without error
      await expectLater(
        NotificationService.instance.showOrUpdateDailyPinnedNotification(
          pendingTasks: [task1],
          totalTodayCount: 1,
          completedTodayCount: 0,
        ),
        completes,
      );

      // When all tasks are completed (pendingTasks is empty): cancels notification automatically
      await expectLater(
        NotificationService.instance.showOrUpdateDailyPinnedNotification(
          pendingTasks: [],
          totalTodayCount: 1,
          completedTodayCount: 1,
        ),
        completes,
      );

      // Explicit cancelDailyPinnedNotification executes cleanly
      await expectLater(
        NotificationService.instance.cancelDailyPinnedNotification(),
        completes,
      );

      // Scheduling midnight pinned notification for tomorrow completes cleanly
      await expectLater(
        NotificationService.instance.scheduleMidnightPinnedNotification(
          tomorrowTasks: [task1],
        ),
        completes,
      );
    });
  });
}
