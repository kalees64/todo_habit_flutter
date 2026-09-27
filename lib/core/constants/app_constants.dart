/// Global App Constants for TaskFlow
class AppConstants {
  AppConstants._();

  static const String appName = 'TaskFlow';
  static const String appTagline = 'Focus • Habits • Momentum';

  // Feature Flags
  static const bool enableHabits = false;

  // Recurrence Rules
  static const String recurrenceNone = 'none';
  static const String recurrenceDaily = 'daily';
  static const String recurrenceWeekly = 'weekly';
  static const String recurrenceCustom = 'custom';

  // Notification Channel
  static const String notificationChannelId = 'taskflow_reminders';
  static const String notificationChannelName = 'Task & Habit Reminders';
  static const String notificationChannelDescription =
      'Notifications for task due dates and habit streak preservation';
}
