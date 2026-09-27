import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/data/local/database.dart';
import 'package:taskflow/data/repositories/habit_repository_impl.dart';
import 'package:taskflow/data/repositories/streak_repository_impl.dart';
import 'package:taskflow/domain/entities/habit.dart';
import 'package:taskflow/domain/entities/streak_log.dart';

void main() {
  late AppDatabase db;
  late HabitRepositoryImpl habitRepo;
  late StreakRepositoryImpl streakRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    habitRepo = HabitRepositoryImpl(db.habitDao);
    streakRepo = StreakRepositoryImpl(db.streakLogDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('Habit and Streak Repository In-Memory Tests', () {
    test('Create habit, update streaks, and add/delete streak logs', () async {
      final habit = Habit(
        id: 'habit-1',
        title: 'Morning Yoga',
        recurrenceRule: 'daily',
        currentStreak: 0,
        longestStreak: 0,
        createdAt: DateTime.utc(2024, 10, 1),
      );

      // 1. Create habit
      await habitRepo.createHabit(habit);
      final fetched = await habitRepo.getHabitById('habit-1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Morning Yoga');

      // 2. Add streak logs
      final log1 = StreakLog(
        id: 'log-1',
        habitId: 'habit-1',
        date: DateTime.utc(2024, 10, 1, 8, 0),
        wasCompletedOnTime: true,
      );
      await streakRepo.addStreakLog(log1);

      final log2 = StreakLog(
        id: 'log-2',
        habitId: 'habit-1',
        date: DateTime.utc(2024, 10, 2, 8, 0),
        wasCompletedOnTime: true,
      );
      await streakRepo.addStreakLog(log2);

      final logs = await streakRepo.getStreakLogs('habit-1');
      expect(logs.length, 2);

      // 3. Update habit streak
      final updatedHabit = habit.copyWith(
        currentStreak: 2,
        longestStreak: 2,
        lastCompletedDate: DateTime.utc(2024, 10, 2, 8, 0),
      );
      await habitRepo.updateHabit(updatedHabit);

      final afterUpdate = await habitRepo.getHabitById('habit-1');
      expect(afterUpdate!.currentStreak, 2);

      // 4. Delete streak log
      await streakRepo.deleteLastStreakLog('habit-1', DateTime.utc(2024, 10, 2, 8, 0));
      final logsAfterDelete = await streakRepo.getStreakLogs('habit-1');
      expect(logsAfterDelete.length, 1);

      // 5. Delete habit
      await habitRepo.deleteHabit('habit-1');
      final habitAfterDelete = await habitRepo.getHabitById('habit-1');
      expect(habitAfterDelete, isNull);
    });
  });
}
