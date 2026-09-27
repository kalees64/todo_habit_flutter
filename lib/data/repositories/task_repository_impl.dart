import 'package:drift/drift.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../local/daos/task_dao.dart';
import '../local/database.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._taskDao);

  final TaskDao _taskDao;

  Task _toDomain(TaskEntry entry) {
    return Task(
      id: entry.id,
      title: entry.title,
      dueDate: entry.dueDate,
      isCompleted: entry.isCompleted,
      completedAt: entry.completedAt,
      recurrenceRule: entry.recurrenceRule,
      customIntervalDays: entry.customIntervalDays,
      habitId: entry.habitId,
      createdAt: entry.createdAt,
    );
  }

  TasksTableCompanion _toCompanion(Task task) {
    return TasksTableCompanion(
      id: Value(task.id),
      title: Value(task.title),
      dueDate: Value(task.dueDate),
      isCompleted: Value(task.isCompleted),
      completedAt: Value(task.completedAt),
      recurrenceRule: Value(task.recurrenceRule),
      customIntervalDays: Value(task.customIntervalDays),
      habitId: Value(task.habitId),
      createdAt: Value(task.createdAt),
    );
  }

  @override
  Stream<List<Task>> watchActiveTasks() {
    return _taskDao
        .watchActiveTasks()
        .map((entries) => entries.map(_toDomain).toList());
  }

  @override
  Stream<List<Task>> watchCompletedTasks() {
    return _taskDao
        .watchCompletedTasks()
        .map((entries) => entries.map(_toDomain).toList());
  }

  @override
  Future<List<Task>> getActiveTasks() async {
    final entries = await _taskDao.getActiveTasks();
    return entries.map(_toDomain).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final entries = await _taskDao.getCompletedTasks();
    return entries.map(_toDomain).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final entry = await _taskDao.getTaskById(id);
    return entry != null ? _toDomain(entry) : null;
  }

  @override
  Future<void> createTask(Task task) async {
    await _taskDao.insertTask(_toCompanion(task));
  }

  @override
  Future<void> updateTask(Task task) async {
    await _taskDao.updateTask(_toCompanion(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    await _taskDao.deleteTask(id);
  }
}
