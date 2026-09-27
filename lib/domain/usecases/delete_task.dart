import '../repositories/task_repository.dart';

class DeleteTask {
  DeleteTask({required this.taskRepository});

  final TaskRepository taskRepository;

  Future<void> execute(String taskId) async {
    await taskRepository.deleteTask(taskId);
  }
}
