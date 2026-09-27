import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/tasks_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [TasksTable])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Stream<List<TaskEntry>> watchActiveTasks() {
    return (select(tasksTable)
          ..where((t) => t.isCompleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Stream<List<TaskEntry>> watchCompletedTasks() {
    return (select(tasksTable)
          ..where((t) => t.isCompleted.equals(true))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<List<TaskEntry>> getActiveTasks() {
    return (select(tasksTable)
          ..where((t) => t.isCompleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<List<TaskEntry>> getCompletedTasks() {
    return (select(tasksTable)
          ..where((t) => t.isCompleted.equals(true))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<TaskEntry?> getTaskById(String id) {
    return (select(tasksTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertTask(TasksTableCompanion task) {
    return into(tasksTable).insert(task, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateTask(TasksTableCompanion task) {
    return update(tasksTable).replace(task);
  }

  Future<int> deleteTask(String id) {
    return (delete(tasksTable)..where((t) => t.id.equals(id))).go();
  }
}
