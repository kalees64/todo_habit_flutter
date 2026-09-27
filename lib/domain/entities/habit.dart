/// Pure Dart Habit entity
class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.recurrenceRule,
    this.customIntervalDays,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.reminderTime,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String recurrenceRule;
  final int? customIntervalDays;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final String? reminderTime; // "HH:mm" in local time
  final DateTime createdAt;

  Habit copyWith({
    String? id,
    String? title,
    String? recurrenceRule,
    int? customIntervalDays,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    bool clearLastCompletedDate = false,
    String? reminderTime,
    bool clearReminderTime = false,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: clearLastCompletedDate
          ? null
          : (lastCompletedDate ?? this.lastCompletedDate),
      reminderTime:
          clearReminderTime ? null : (reminderTime ?? this.reminderTime),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          recurrenceRule == other.recurrenceRule &&
          customIntervalDays == other.customIntervalDays &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          lastCompletedDate == other.lastCompletedDate &&
          reminderTime == other.reminderTime &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      recurrenceRule.hashCode ^
      customIntervalDays.hashCode ^
      currentStreak.hashCode ^
      longestStreak.hashCode ^
      lastCompletedDate.hashCode ^
      reminderTime.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'Habit(id: $id, title: $title, recurrenceRule: $recurrenceRule, customIntervalDays: $customIntervalDays, currentStreak: $currentStreak, longestStreak: $longestStreak, lastCompletedDate: $lastCompletedDate, reminderTime: $reminderTime, createdAt: $createdAt)';
  }
}
