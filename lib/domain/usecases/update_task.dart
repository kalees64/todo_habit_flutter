import '../entities/task.dart';
import '../repositories/task_repository.dart';
import 'promote_task_to_habit.dart';

class UpdateTask {
  UpdateTask({
    required this.taskRepository,
    required this.promoteTaskToHabit,
  });

  final TaskRepository taskRepository;
  final PromoteTaskToHabit promoteTaskToHabit;

  Future<Task> execute(
    Task task, {
    required String title,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? recurrenceRule,
    int? customIntervalDays,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }

    // If task was already completed, allow title edit only per spec 5.1
    if (task.isCompleted) {
      final updated = task.copyWith(title: trimmedTitle);
      await taskRepository.updateTask(updated);
      return updated;
    }

    String? habitId = task.habitId;
    final isRecurring = recurrenceRule != null &&
        recurrenceRule.toLowerCase() != 'none';

    if (isRecurring && habitId == null) {
      final habit = await promoteTaskToHabit.execute(
        task: task,
        recurrenceRule: recurrenceRule,
        customIntervalDays: customIntervalDays,
      );
      habitId = habit.id;
    }

    final updated = task.copyWith(
      title: trimmedTitle,
      dueDate: dueDate?.toUtc(),
      clearDueDate: clearDueDate,
      recurrenceRule: recurrenceRule,
      customIntervalDays: customIntervalDays,
      habitId: habitId,
    );

    await taskRepository.updateTask(updated);
    return updated;
  }
}
