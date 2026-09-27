import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/daos/habit_dao.dart';
import '../../data/local/daos/streak_log_dao.dart';
import '../../data/local/daos/task_dao.dart';
import '../../data/local/database.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../data/repositories/streak_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/streak_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/complete_task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_active_tasks.dart';
import '../../domain/usecases/get_completed_tasks.dart';
import '../../domain/usecases/promote_task_to_habit.dart';
import '../../domain/usecases/uncomplete_task.dart';
import '../../domain/usecases/update_streak.dart';
import '../../domain/usecases/update_task.dart';

/// AppDatabase singleton provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// DAOs
final taskDaoProvider = Provider<TaskDao>((ref) {
  return ref.watch(databaseProvider).taskDao;
});

final habitDaoProvider = Provider<HabitDao>((ref) {
  return ref.watch(databaseProvider).habitDao;
});

final streakLogDaoProvider = Provider<StreakLogDao>((ref) {
  return ref.watch(databaseProvider).streakLogDao;
});

// Repositories
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskDaoProvider));
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(ref.watch(habitDaoProvider));
});

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepositoryImpl(ref.watch(streakLogDaoProvider));
});

// Usecases
final promoteTaskToHabitProvider = Provider<PromoteTaskToHabit>((ref) {
  return PromoteTaskToHabit(
    habitRepository: ref.watch(habitRepositoryProvider),
  );
});

final updateStreakProvider = Provider<UpdateStreak>((ref) {
  return UpdateStreak(
    habitRepository: ref.watch(habitRepositoryProvider),
    streakRepository: ref.watch(streakRepositoryProvider),
  );
});

final createTaskProvider = Provider<CreateTask>((ref) {
  return CreateTask(
    taskRepository: ref.watch(taskRepositoryProvider),
    promoteTaskToHabit: ref.watch(promoteTaskToHabitProvider),
  );
});

final updateTaskProvider = Provider<UpdateTask>((ref) {
  return UpdateTask(
    taskRepository: ref.watch(taskRepositoryProvider),
    promoteTaskToHabit: ref.watch(promoteTaskToHabitProvider),
  );
});

final deleteTaskProvider = Provider<DeleteTask>((ref) {
  return DeleteTask(taskRepository: ref.watch(taskRepositoryProvider));
});

final completeTaskProvider = Provider<CompleteTask>((ref) {
  return CompleteTask(
    taskRepository: ref.watch(taskRepositoryProvider),
    updateStreak: ref.watch(updateStreakProvider),
  );
});

final uncompleteTaskProvider = Provider<UncompleteTask>((ref) {
  return UncompleteTask(
    taskRepository: ref.watch(taskRepositoryProvider),
    habitRepository: ref.watch(habitRepositoryProvider),
    streakRepository: ref.watch(streakRepositoryProvider),
  );
});

final getActiveTasksProvider = Provider<GetActiveTasks>((ref) {
  return GetActiveTasks(taskRepository: ref.watch(taskRepositoryProvider));
});

final getCompletedTasksProvider = Provider<GetCompletedTasks>((ref) {
  return GetCompletedTasks(taskRepository: ref.watch(taskRepositoryProvider));
});
