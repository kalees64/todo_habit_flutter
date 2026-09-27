import 'package:uuid/uuid.dart';
import '../entities/habit.dart';
import '../entities/task.dart';
import '../repositories/habit_repository.dart';

class PromoteTaskToHabit {
  PromoteTaskToHabit({
    required this.habitRepository,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final HabitRepository habitRepository;
  final Uuid _uuid;

  Future<Habit> execute({
    required Task task,
    required String recurrenceRule,
    int? customIntervalDays,
    String? reminderTime,
  }) async {
    final habitId = task.habitId ?? _uuid.v4();

    // Check if habit already exists
    final existing = await habitRepository.getHabitById(habitId);
    if (existing != null) {
      final updated = existing.copyWith(
        title: task.title,
        recurrenceRule: recurrenceRule,
        customIntervalDays: customIntervalDays,
        reminderTime: reminderTime,
      );
      await habitRepository.updateHabit(updated);
      return updated;
    }

    final newHabit = Habit(
      id: habitId,
      title: task.title,
      recurrenceRule: recurrenceRule,
      customIntervalDays: customIntervalDays,
      reminderTime: reminderTime,
      currentStreak: 0,
      longestStreak: 0,
      createdAt: DateTime.now().toUtc(),
    );

    await habitRepository.createHabit(newHabit);
    return newHabit;
  }
}
