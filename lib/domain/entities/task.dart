/// Pure Dart Task entity
class Task {
  const Task({
    required this.id,
    required this.title,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.recurrenceRule,
    this.customIntervalDays,
    this.habitId,
    required this.createdAt,
  });

  final String id;
  final String title;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? recurrenceRule;
  final int? customIntervalDays;
  final String? habitId;
  final DateTime createdAt;

  Task copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? recurrenceRule,
    int? customIntervalDays,
    String? habitId,
    bool clearHabitId = false,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      habitId: clearHabitId ? null : (habitId ?? this.habitId),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          dueDate == other.dueDate &&
          isCompleted == other.isCompleted &&
          completedAt == other.completedAt &&
          recurrenceRule == other.recurrenceRule &&
          customIntervalDays == other.customIntervalDays &&
          habitId == other.habitId &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      dueDate.hashCode ^
      isCompleted.hashCode ^
      completedAt.hashCode ^
      recurrenceRule.hashCode ^
      customIntervalDays.hashCode ^
      habitId.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, dueDate: $dueDate, isCompleted: $isCompleted, completedAt: $completedAt, recurrenceRule: $recurrenceRule, customIntervalDays: $customIntervalDays, habitId: $habitId, createdAt: $createdAt)';
  }
}
