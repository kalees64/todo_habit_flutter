
/// Pure calculation helpers for Habit Streaks
class StreakMath {
  StreakMath._();

  /// Calculates calendar day difference between two DateTimes (b - a in calendar days).
  /// Operates on UTC dates to maintain timezone independence.
  static int calendarDaysDifference(DateTime a, DateTime b) {
    final aUtc = a.toUtc();
    final bUtc = b.toUtc();
    final aDate = DateTime.utc(aUtc.year, aUtc.month, aUtc.day);
    final bDate = DateTime.utc(bUtc.year, bUtc.month, bUtc.day);
    return bDate.difference(aDate).inDays;
  }

  /// Calculates the expected period in days for a recurrence rule
  /// - daily: 1 day (grace window up to 2 days)
  /// - weekly: 7 days (grace window up to 8 days)
  /// - custom: [customIntervalDays] days (grace window = customIntervalDays + 1)
  static int expectedPeriodDays(String recurrenceRule, int? customIntervalDays) {
    switch (recurrenceRule.toLowerCase()) {
      case 'daily':
        return 1;
      case 'weekly':
        return 7;
      case 'custom':
        return (customIntervalDays != null && customIntervalDays > 0)
            ? customIntervalDays
            : 1;
      default:
        return 1;
    }
  }

  /// Maximum gap in calendar days allowed for a streak to continue uninterrupted.
  /// Standard 1 day grace period for daily/weekly/custom.
  static int maxAllowedGapDays(String recurrenceRule, int? customIntervalDays) {
    final period = expectedPeriodDays(recurrenceRule, customIntervalDays);
    return period + 1; // 1 grace day
  }

  /// Evaluates the streak transition on a task completion.
  /// Returns a record:
  /// - [newCurrentStreak]: updated current streak
  /// - [newLongestStreak]: updated longest streak
  /// - [wasCompletedOnTime]: whether this completion fell within expected period
  /// - [isDuplicateSameDay]: whether this was a back-to-back completion on the same calendar day
  static ({
    int newCurrentStreak,
    int newLongestStreak,
    bool wasCompletedOnTime,
    bool isDuplicateSameDay,
  }) calculateStreakOnCompletion({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastCompletedDate,
    required DateTime completionDate,
    required String recurrenceRule,
    int? customIntervalDays,
  }) {
    if (lastCompletedDate == null) {
      // First completion ever
      const streak = 1;
      final longest = longestStreak < 1 ? 1 : longestStreak;
      return (
        newCurrentStreak: streak,
        newLongestStreak: longest,
        wasCompletedOnTime: true,
        isDuplicateSameDay: false,
      );
    }

    final gap = calendarDaysDifference(lastCompletedDate, completionDate);

    // If completed on the very same calendar day (gap == 0), don't double-increment streak
    if (gap == 0) {
      return (
        newCurrentStreak: currentStreak,
        newLongestStreak: longestStreak,
        wasCompletedOnTime: true,
        isDuplicateSameDay: true,
      );
    }

    final allowedGap = maxAllowedGapDays(recurrenceRule, customIntervalDays);
    final period = expectedPeriodDays(recurrenceRule, customIntervalDays);
    final onTime = gap <= period;

    int nextStreak;
    if (gap <= allowedGap) {
      // Within expected window + grace period -> increment
      nextStreak = currentStreak + 1;
    } else {
      // Missed expected window -> reset streak to 1
      nextStreak = 1;
    }

    final nextLongest = nextStreak > longestStreak ? nextStreak : longestStreak;

    return (
      newCurrentStreak: nextStreak,
      newLongestStreak: nextLongest,
      wasCompletedOnTime: onTime,
      isDuplicateSameDay: false,
    );
  }
}
