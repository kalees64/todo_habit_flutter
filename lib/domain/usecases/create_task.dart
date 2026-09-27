import 'package:uuid/uuid.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import 'promote_task_to_habit.dart';

class CreateTask {
  CreateTask({
    required this.taskRepository,
    required this.promoteTaskToHabit,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final TaskRepository taskRepository;
  final PromoteTaskToHabit promoteTaskToHabit;
  final Uuid _uuid;

  Future<Task> execute({
    required String title,
    DateTime? dueDate,
    String? recurrenceRule,
    int? customIntervalDays,
    String? reminderTime,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }

    final taskId = _uuid.v4();
    final isRecurring = recurrenceRule != null &&
        recurrenceRule.toLowerCase() != 'none';

    String? habitId;
    if (isRecurring) {
      final dummyTask = Task(
        id: taskId,
        title: trimmedTitle,
        dueDate: dueDate,
        recurrenceRule: recurrenceRule,
        customIntervalDays: customIntervalDays,
        createdAt: DateTime.now().toUtc(),
      );
      final habit = await promoteTaskToHabit.execute(
        task: dummyTask,
        recurrenceRule: recurrenceRule,
        customIntervalDays: customIntervalDays,
        reminderTime: reminderTime,
      );
      habitId = habit.id;
    }

    final task = Task(
      id: taskId,
      title: trimmedTitle,
      dueDate: dueDate?.toUtc(),
      isCompleted: false,
      completedAt: null,
      recurrenceRule: recurrenceRule,
      customIntervalDays: customIntervalDays,
      habitId: habitId,
      createdAt: DateTime.now().toUtc(),
    );

    await taskRepository.createTask(task);
    return task;
  }
}
