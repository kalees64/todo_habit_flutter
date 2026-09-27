import '../entities/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchActiveTasks();
  Stream<List<Task>> watchCompletedTasks();
  Future<List<Task>> getActiveTasks();
  Future<List<Task>> getCompletedTasks();
  Future<Task?> getTaskById(String id);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
}
