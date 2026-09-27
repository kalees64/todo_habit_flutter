import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetActiveTasks {
  GetActiveTasks({required this.taskRepository});

  final TaskRepository taskRepository;

  Stream<List<Task>> watch() => taskRepository.watchActiveTasks();
  Future<List<Task>> execute() => taskRepository.getActiveTasks();
}
