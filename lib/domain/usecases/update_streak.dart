import 'package:uuid/uuid.dart';
import '../../core/utils/streak_math.dart';
import '../entities/habit.dart';
import '../entities/streak_log.dart';
import '../entities/task.dart';
import '../repositories/habit_repository.dart';
import '../repositories/streak_repository.dart';

/// Pure, testable usecase for updating habit streaks when a task is completed.
class UpdateStreak {
  UpdateStreak({
    required this.habitRepository,
    required this.streakRepository,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final HabitRepository habitRepository;
  final StreakRepository streakRepository;
  final Uuid _uuid;

  Future<Habit?> execute(Task task, {DateTime? completedAtOverride}) async {
    final recurrence = task.recurrenceRule;
    if (recurrence == null || recurrence.toLowerCase() == 'none') {
      return null;
    }

    final completionDate = completedAtOverride ?? task.completedAt ?? DateTime.now().toUtc();

    // 1. Find existing Habit or create one from Task
    Habit? habit;
    if (task.habitId != null) {
      habit = await habitRepository.getHabitById(task.habitId!);
    }

    habit ??= Habit(
      id: task.habitId ?? _uuid.v4(),
      title: task.title,
      recurrenceRule: recurrence,
      customIntervalDays: task.customIntervalDays,
      currentStreak: 0,
      longestStreak: 0,
      createdAt: DateTime.now().toUtc(),
    );

    // 2. Calculate next streak state using StreakMath
    final result = StreakMath.calculateStreakOnCompletion(
      currentStreak: habit.currentStreak,
      longestStreak: habit.longestStreak,
      lastCompletedDate: habit.lastCompletedDate,
      completionDate: completionDate,
      recurrenceRule: habit.recurrenceRule,
      customIntervalDays: habit.customIntervalDays,
    );

    // If back-to-back same-day completion, do not duplicate streak increment or logs
    if (result.isDuplicateSameDay) {
      return habit;
    }

    final updatedHabit = habit.copyWith(
      currentStreak: result.newCurrentStreak,
      longestStreak: result.newLongestStreak,
      lastCompletedDate: completionDate,
    );

    // 3. Write StreakLog entry
    final log = StreakLog(
      id: _uuid.v4(),
      habitId: updatedHabit.id,
      date: completionDate,
      wasCompletedOnTime: result.wasCompletedOnTime,
    );

    await streakRepository.addStreakLog(log);
    await habitRepository.updateHabit(updatedHabit);

    return updatedHabit;
  }
}
