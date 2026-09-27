import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/data/local/database.dart';
import 'package:taskflow/data/repositories/task_repository_impl.dart';
import 'package:taskflow/domain/entities/task.dart';

void main() {
  late AppDatabase db;
  late TaskRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TaskRepositoryImpl(db.taskDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('TaskRepository In-Memory CRUD Tests', () {
    test('Create, retrieve, update, and delete task', () async {
      final task = Task(
        id: 'test-1',
        title: 'Learn Drift and Riverpod',
        dueDate: DateTime.utc(2024, 10, 25, 14, 0),
        recurrenceRule: 'daily',
        createdAt: DateTime.utc(2024, 10, 20),
      );

      // 1. Create
      await repository.createTask(task);
      final fetched = await repository.getTaskById('test-1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Learn Drift and Riverpod');
      expect(fetched.isCompleted, false);

      // 2. Active tasks stream
      final activeTasks = await repository.getActiveTasks();
      expect(activeTasks.length, 1);
      expect(activeTasks.first.id, 'test-1');

      // 3. Mark completed
      final completedTask = task.copyWith(
        isCompleted: true,
        completedAt: DateTime.utc(2024, 10, 21, 10, 0),
      );
      await repository.updateTask(completedTask);

      final activeAfterComplete = await repository.getActiveTasks();
      expect(activeAfterComplete.isEmpty, true);

      final completedTasks = await repository.getCompletedTasks();
      expect(completedTasks.length, 1);
      expect(completedTasks.first.id, 'test-1');
      expect(completedTasks.first.isCompleted, true);

      // 4. Delete
      await repository.deleteTask('test-1');
      final afterDelete = await repository.getTaskById('test-1');
      expect(afterDelete, isNull);
    });
  });
}
