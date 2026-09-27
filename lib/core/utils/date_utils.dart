import 'package:intl/intl.dart';

/// Pure date helpers for TaskFlow
class AppDateUtils {
  AppDateUtils._();

  /// Converts a UTC DateTime to local DateTime
  static DateTime toLocal(DateTime utc) => utc.toLocal();

  /// Formats date to 'MMM d, y' (e.g. Oct 24, 2024)
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, y').format(date.toLocal());
  }

  /// Formats time to 'h:mm a' (e.g. 6:42 PM)
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date.toLocal());
  }

  /// Formats DateTime for task due dates (e.g. 'Today, 8:30 PM' or 'Oct 24, 8:30 PM')
  static String formatDueDateTime(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();

    if (isSameDay(local, now)) {
      return 'Today, ${formatTime(local)}';
    } else if (isSameDay(local, now.add(const Duration(days: 1)))) {
      return 'Tomorrow, ${formatTime(local)}';
    } else if (isSameDay(local, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday, ${formatTime(local)}';
    }
    return DateFormat('MMM d, h:mm a').format(local);
  }

  /// Categorizes completion date into readable group headers: "Today", "Yesterday", or formatted date
  static String getCompletionGroupHeader(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();

    if (isSameDay(local, now)) {
      return 'Today';
    } else if (isSameDay(local, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('MMMM d, y').format(local);
  }

  /// Returns true if two DateTimes fall on the same calendar day in local time
  static bool isSameDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  /// Strips time components and returns Date only (at 00:00:00 UTC)
  static DateTime dateOnlyUtc(DateTime date) {
    final local = date.toLocal();
    return DateTime.utc(local.year, local.month, local.day);
  }

  /// Returns true if a due date is in the past relative to now
  static bool isOverdue(DateTime dueDate) {
    return dueDate.toUtc().isBefore(DateTime.now().toUtc());
  }
}
