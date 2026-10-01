/// Global App Constants for TaskFlow
class AppConstants {
  AppConstants._();

  static const String appName = 'TaskFlow';
  static const String appTagline = 'Focus • Habits • Momentum';

  // Feature Flags
  static const bool enableHabits = false;
  static const bool enableAds = false; // Disabled for now, will enable in later releases

  // Recurrence Rules
  static const String recurrenceNone = 'none';
  static const String recurrenceDaily = 'daily';
  static const String recurrenceWeekly = 'weekly';
  static const String recurrenceCustom = 'custom';

  // Notification Channels
  static const String notificationChannelId = 'taskflow_reminders';
  static const String notificationChannelName = 'Task & Habit Reminders';
  static const String notificationChannelDescription =
      'Notifications for task due dates and habit streak preservation';

  static const String pinnedNotificationChannelId = 'taskflow_pinned_tasks';
  static const String pinnedNotificationChannelName = 'Today\'s Planned Tasks';
  static const String pinnedNotificationChannelDescription =
      'Persistent pinned notification of today\'s planned tasks';

  static const int pinnedNotificationId = 99999;
  static const int midnightScheduledNotificationId = 99998;
}
