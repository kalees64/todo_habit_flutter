import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetCompletedTasks {
  GetCompletedTasks({required this.taskRepository});

  final TaskRepository taskRepository;

  Stream<List<Task>> watch() => taskRepository.watchCompletedTasks();
  Future<List<Task>> execute() => taskRepository.getCompletedTasks();
}
