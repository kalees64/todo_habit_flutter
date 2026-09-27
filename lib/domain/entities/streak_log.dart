/// Pure Dart StreakLog entity
class StreakLog {
  const StreakLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.wasCompletedOnTime,
  });

  final String id;
  final String habitId;
  final DateTime date;
  final bool wasCompletedOnTime;

  StreakLog copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? wasCompletedOnTime,
  }) {
    return StreakLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      wasCompletedOnTime: wasCompletedOnTime ?? this.wasCompletedOnTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          date == other.date &&
          wasCompletedOnTime == other.wasCompletedOnTime;

  @override
  int get hashCode =>
      id.hashCode ^
      habitId.hashCode ^
      date.hashCode ^
      wasCompletedOnTime.hashCode;

  @override
  String toString() {
    return 'StreakLog(id: $id, habitId: $habitId, date: $date, wasCompletedOnTime: $wasCompletedOnTime)';
  }
}
