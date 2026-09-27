import '../entities/habit.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import 'update_streak.dart';

class CompleteTask {
  CompleteTask({
    required this.taskRepository,
    required this.updateStreak,
  });

  final TaskRepository taskRepository;
  final UpdateStreak updateStreak;

  Future<({Task task, Habit? habit})> execute(
    Task task, {
    DateTime? completedAtOverride,
  }) async {
    final completionDate = completedAtOverride ?? DateTime.now().toUtc();
    final updatedTask = task.copyWith(
      isCompleted: true,
      completedAt: completionDate,
    );

    await taskRepository.updateTask(updatedTask);

    Habit? updatedHabit;
    if (updatedTask.recurrenceRule != null &&
        updatedTask.recurrenceRule!.toLowerCase() != 'none') {
      updatedHabit = await updateStreak.execute(
        updatedTask,
        completedAtOverride: completionDate,
      );
    }

    return (task: updatedTask, habit: updatedHabit);
  }
}
