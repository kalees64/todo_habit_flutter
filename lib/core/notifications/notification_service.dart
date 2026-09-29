import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../domain/entities/task.dart';
import '../constants/app_constants.dart';
import '../utils/date_utils.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get _isTest => Platform.environment.containsKey('FLUTTER_TEST');

  Future<void> initialize() async {
    if (_isInitialized || _isTest) return;

    try {
      tz.initializeTimeZones();
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      } catch (e) {
        debugPrint('Could not get local timezone: $e, defaulting to UTC');
        tz.setLocalLocation(tz.UTC);
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (_isTest || !Platform.isAndroid) return true;

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  Future<bool> areNotificationsEnabled() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      return enabled ?? false;
    }
    return false;
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  /// Hashes a String ID into a unique 31-bit positive integer for Android notification IDs
  int _hashId(String id, {int prefix = 0}) {
    return (id.hashCode.abs() + prefix) % 2147483647;
  }

  /// Schedules a notification for a task at its due date
  Future<void> scheduleTaskDueNotification({
    required String taskId,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    if (_isTest) return;
    await initialize();

    final scheduledDate = tz.TZDateTime.from(dueDate.toLocal(), tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      // Due date is already in the past, do not schedule
      return;
    }

    final id = _hashId(taskId, prefix: 10000);
    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Task Due: $taskTitle',
        body: 'It\'s time to complete this task.',
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: taskId,
      );
    } catch (e) {
      debugPrint('Error scheduling task notification: $e');
    }
  }

  /// Cancels any scheduled notification for a task
  Future<void> cancelTaskNotification(String taskId) async {
    if (_isTest) return;
    await initialize();
    final id = _hashId(taskId, prefix: 10000);
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Error canceling task notification: $e');
    }
  }

  /// Schedules a daily streak preservation notification for a habit
  /// [reminderTime] is formatted as "HH:mm" (24h local time)
  Future<void> scheduleHabitStreakNudge({
    required String habitId,
    required String habitTitle,
    required String reminderTime,
  }) async {
    if (_isTest) return;
    await initialize();

    final parts = reminderTime.split(':');
    if (parts.length != 2) return;
    final hour = int.tryParse(parts[0]) ?? 20;
    final minute = int.tryParse(parts[1]) ?? 0;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final id = _hashId(habitId, prefix: 50000);
    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Don\'t break your streak!',
        body: 'Complete \'$habitTitle\' today to keep your streak alive.',
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: habitId,
      );
    } catch (e) {
      debugPrint('Error scheduling habit nudge: $e');
    }
  }

  /// Cancels habit notification
  Future<void> cancelHabitNotification(String habitId) async {
    if (_isTest) return;
    await initialize();
    final id = _hashId(habitId, prefix: 50000);
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Error canceling habit notification: $e');
    }
  }

  /// Displays or updates the persistent, un-dismissible pinned notification
  /// of today's planned tasks.
  ///
  /// Criteria:
  /// - Only shown when user has planned tasks for today that are pending.
  /// - User is unable to clear/swipe away this notification (ongoing: true).
  /// - Automatically cancels/dismisses when all tasks for today are completed
  ///   or when no tasks are scheduled.
  Future<void> showOrUpdateDailyPinnedNotification({
    required List<Task> pendingTasks,
    required int totalTodayCount,
    required int completedTodayCount,
  }) async {
    if (_isTest) return;
    await initialize();

    // If no tasks scheduled or all planned tasks are completed, cancel notification
    if (pendingTasks.isEmpty || totalTodayCount == 0) {
      await cancelDailyPinnedNotification();
      return;
    }

    final remaining = pendingTasks.length;
    final title =
        "Today's Tasks • $remaining remaining ($completedTodayCount/$totalTodayCount done)";
    final summaryText = '$remaining task${remaining == 1 ? '' : 's'} remaining';

    final lines = pendingTasks.map((t) {
      final timeStr =
          t.dueDate != null ? '${AppDateUtils.formatTime(t.dueDate!)} - ' : '';
      return '• $timeStr${t.title}';
    }).toList();

    final inboxStyle = InboxStyleInformation(
      lines,
      contentTitle: title,
      summaryText: summaryText,
    );

    final androidDetails = AndroidNotificationDetails(
      AppConstants.pinnedNotificationChannelId,
      AppConstants.pinnedNotificationChannelName,
      channelDescription: AppConstants.pinnedNotificationChannelDescription,
      importance: Importance.low, // Silent lock-screen pinning at midnight
      priority: Priority.low,
      ongoing: true, // User cannot swipe or clear away
      autoCancel: false,
      onlyAlertOnce: true, // Silent live updates when tasks are checked off
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: inboxStyle,
    );

    try {
      await _notificationsPlugin.show(
        id: AppConstants.pinnedNotificationId,
        title: title,
        body: summaryText,
        notificationDetails: NotificationDetails(android: androidDetails),
        payload: 'daily_pinned_tasks',
      );
    } catch (e) {
      debugPrint('Error showing daily pinned notification: $e');
    }
  }

  /// Cancels the daily pinned notification
  Future<void> cancelDailyPinnedNotification() async {
    if (_isTest) return;
    await initialize();
    try {
      await _notificationsPlugin.cancel(id: AppConstants.pinnedNotificationId);
    } catch (e) {
      debugPrint('Error canceling daily pinned notification: $e');
    }
  }

  /// Schedules the midnight (00:00:00) exact alarm to pin tomorrow's planned tasks
  /// right as the new day begins.
  Future<void> scheduleMidnightPinnedNotification({
    required List<Task> tomorrowTasks,
  }) async {
    if (_isTest) return;
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = now.add(const Duration(days: 1));
    final midnight = tz.TZDateTime(
      tz.local,
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      0,
      0,
      0,
    );

    if (tomorrowTasks.isEmpty) {
      try {
        await _notificationsPlugin.cancel(
            id: AppConstants.midnightScheduledNotificationId);
      } catch (e) {
        debugPrint('Error canceling midnight notification: $e');
      }
      return;
    }

    final count = tomorrowTasks.length;
    final title = "Today's Tasks • $count planned for today";
    final summaryText = '$count task${count == 1 ? '' : 's'} scheduled';

    final lines = tomorrowTasks.map((t) {
      final timeStr =
          t.dueDate != null ? '${AppDateUtils.formatTime(t.dueDate!)} - ' : '';
      return '• $timeStr${t.title}';
    }).toList();

    final inboxStyle = InboxStyleInformation(
      lines,
      contentTitle: title,
      summaryText: summaryText,
    );

    final androidDetails = AndroidNotificationDetails(
      AppConstants.pinnedNotificationChannelId,
      AppConstants.pinnedNotificationChannelName,
      channelDescription: AppConstants.pinnedNotificationChannelDescription,
      importance: Importance.low, // Silent lock-screen pin
      priority: Priority.low,
      ongoing: true, // Pinned, user cannot clear
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: inboxStyle,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: AppConstants.midnightScheduledNotificationId,
        title: title,
        body: summaryText,
        scheduledDate: midnight,
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'daily_pinned_tasks',
      );
    } catch (e) {
      debugPrint('Error scheduling midnight pinned notification: $e');
    }
  }
}
