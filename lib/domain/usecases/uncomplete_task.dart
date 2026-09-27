import '../entities/task.dart';
import '../repositories/habit_repository.dart';
import '../repositories/streak_repository.dart';
import '../repositories/task_repository.dart';

class UncompleteTask {
  UncompleteTask({
    required this.taskRepository,
    required this.habitRepository,
    required this.streakRepository,
  });

  final TaskRepository taskRepository;
  final HabitRepository habitRepository;
  final StreakRepository streakRepository;

  Future<Task> execute(Task task) async {
    final oldCompletedAt = task.completedAt;

    final uncompleted = task.copyWith(
      isCompleted: false,
      clearCompletedAt: true,
    );

    await taskRepository.updateTask(uncompleted);

    // Rollback streak log if linked to a habit
    if (task.habitId != null && oldCompletedAt != null) {
      await streakRepository.deleteLastStreakLog(task.habitId!, oldCompletedAt);

      // Recalculate habit's current streak from remaining logs
      final habit = await habitRepository.getHabitById(task.habitId!);
      if (habit != null) {
        final logs = await streakRepository.getStreakLogs(habit.id);
        if (logs.isEmpty) {
          final resetHabit = habit.copyWith(
            currentStreak: 0,
            clearLastCompletedDate: true,
          );
          await habitRepository.updateHabit(resetHabit);
        } else {
          // Sort logs ascending
          logs.sort((a, b) => a.date.compareTo(b.date));
          final latestDate = logs.last.date;
          // Decrement current streak if > 0
          final newStreak = habit.currentStreak > 0 ? habit.currentStreak - 1 : 0;
          final updatedHabit = habit.copyWith(
            currentStreak: newStreak,
            lastCompletedDate: latestDate,
          );
          await habitRepository.updateHabit(updatedHabit);
        }
      }
    }

    return uncompleted;
  }
}
