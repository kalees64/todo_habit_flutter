import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/providers/database_providers.dart';
import 'package:taskflow/data/local/database.dart';
import 'package:taskflow/data/repositories/habit_repository_impl.dart';
import 'package:taskflow/data/repositories/streak_repository_impl.dart';
import 'package:taskflow/data/repositories/task_repository_impl.dart';
import 'package:taskflow/domain/usecases/complete_task.dart';
import 'package:taskflow/domain/usecases/create_task.dart';
import 'package:taskflow/domain/usecases/promote_task_to_habit.dart';
import 'package:taskflow/domain/usecases/update_streak.dart';
import 'package:taskflow/features/completed/presentation/screens/completed_tasks_screen.dart';
import 'package:taskflow/features/todo/presentation/screens/home_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableApp({required Widget child}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('Widget and User Flow Tests', () {
    testWidgets('Adding a task and displaying it in the active list', (tester) async {
      final taskRepo = TaskRepositoryImpl(db.taskDao);
      final habitRepo = HabitRepositoryImpl(db.habitDao);
      final promote = PromoteTaskToHabit(habitRepository: habitRepo);
      final createTask = CreateTask(taskRepository: taskRepo, promoteTaskToHabit: promote);

      await tester.pumpWidget(buildTestableApp(child: const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially empty
      expect(find.text('All clear!'), findsOneWidget);

      // Create a task
      await createTask.execute(
        title: 'Complete Drift Setup',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify task tile appears
      expect(find.text('Complete Drift Setup'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
    });

    testWidgets('Completing a task moves it from Active to Completed', (tester) async {
      final taskRepo = TaskRepositoryImpl(db.taskDao);
      final habitRepo = HabitRepositoryImpl(db.habitDao);
      final streakRepo = StreakRepositoryImpl(db.streakLogDao);
      final promote = PromoteTaskToHabit(habitRepository: habitRepo);
      final createTask = CreateTask(taskRepository: taskRepo, promoteTaskToHabit: promote);

      // Create task
      final task = await createTask.execute(
        title: 'Review PR Code',
        dueDate: DateTime.now(),
      );

      // Render Home
      await tester.pumpWidget(buildTestableApp(child: const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Review PR Code'), findsOneWidget);

      // Tap checkbox to complete
      final completeTask = CompleteTask(
        taskRepository: taskRepo,
        updateStreak: UpdateStreak(
          habitRepository: habitRepo,
          streakRepository: streakRepo,
        ),
      );
      await completeTask.execute(task);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // When completed today, it is displayed in the Completed Today section on HomeScreen
      expect(find.text('Completed Today'), findsOneWidget);
      expect(find.text('Review PR Code'), findsOneWidget);

      // Now view CompletedTasksScreen
      await tester.pumpWidget(buildTestableApp(child: const CompletedTasksScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should be in Completed list
      expect(find.text('Review PR Code'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
    });

    testWidgets('Habit streak increments to 2 after two consecutive completions', (tester) async {
      final taskRepo = TaskRepositoryImpl(db.taskDao);
      final habitRepo = HabitRepositoryImpl(db.habitDao);
      final streakRepo = StreakRepositoryImpl(db.streakLogDao);
      final promote = PromoteTaskToHabit(habitRepository: habitRepo);
      final createTask = CreateTask(taskRepository: taskRepo, promoteTaskToHabit: promote);
      final updateStreak = UpdateStreak(habitRepository: habitRepo, streakRepository: streakRepo);

      // Create recurring task
      final task = await createTask.execute(
        title: 'Read 10 Pages',
        recurrenceRule: 'daily',
      );

      expect(task.habitId, isNotNull);

      // Day 1 Completion
      final day1 = DateTime.utc(2024, 10, 1, 9, 0);
      final h1 = await updateStreak.execute(task, completedAtOverride: day1);
      expect(h1!.currentStreak, 1);

      // Day 2 Completion (next consecutive day)
      final day2 = DateTime.utc(2024, 10, 2, 9, 0);
      final h2 = await updateStreak.execute(task, completedAtOverride: day2);
      expect(h2!.currentStreak, 2);
      expect(h2.longestStreak, 2);
    });
  });
}
