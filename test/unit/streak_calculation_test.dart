import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/utils/streak_math.dart';
import 'package:taskflow/domain/entities/habit.dart';
import 'package:taskflow/domain/entities/streak_log.dart';
import 'package:taskflow/domain/entities/task.dart';
import 'package:taskflow/domain/repositories/habit_repository.dart';
import 'package:taskflow/domain/repositories/streak_repository.dart';
import 'package:taskflow/domain/usecases/update_streak.dart';

class FakeHabitRepository implements HabitRepository {
  final Map<String, Habit> habits = {};

  @override
  Future<void> createHabit(Habit habit) async => habits[habit.id] = habit;

  @override
  Future<void> deleteHabit(String id) async => habits.remove(id);

  @override
  Future<Habit?> getHabitById(String id) async => habits[id];

  @override
  Future<List<Habit>> getHabits() async => habits.values.toList();

  @override
  Future<void> updateHabit(Habit habit) async => habits[habit.id] = habit;

  @override
  Stream<List<Habit>> watchHabits() => Stream.value(habits.values.toList());
}

class FakeStreakRepository implements StreakRepository {
  final List<StreakLog> logs = [];

  @override
  Future<void> addStreakLog(StreakLog log) async => logs.add(log);

  @override
  Future<void> deleteLastStreakLog(String habitId, DateTime date) async {
    logs.removeWhere((l) => l.habitId == habitId && l.date == date);
  }

  @override
  Future<void> deleteStreakLogsForHabit(String habitId) async {
    logs.removeWhere((l) => l.habitId == habitId);
  }

  @override
  Future<List<StreakLog>> getStreakLogs(String habitId) async {
    return logs.where((l) => l.habitId == habitId).toList();
  }

  @override
  Stream<List<StreakLog>> watchStreakLogs(String habitId) {
    return Stream.value(logs.where((l) => l.habitId == habitId).toList());
  }
}

void main() {
  group('StreakMath Pure Unit Tests', () {
    test('First completion sets currentStreak = 1 and longestStreak = 1', () {
      final result = StreakMath.calculateStreakOnCompletion(
        currentStreak: 0,
        longestStreak: 0,
        lastCompletedDate: null,
        completionDate: DateTime.utc(2024, 10, 20, 10, 0),
        recurrenceRule: 'daily',
      );

      expect(result.newCurrentStreak, 1);
      expect(result.newLongestStreak, 1);
      expect(result.wasCompletedOnTime, true);
      expect(result.isDuplicateSameDay, false);
    });

    test('Consecutive on-time completion next day increments streak', () {
      final result = StreakMath.calculateStreakOnCompletion(
        currentStreak: 1,
        longestStreak: 1,
        lastCompletedDate: DateTime.utc(2024, 10, 20, 10, 0),
        completionDate: DateTime.utc(2024, 10, 21, 14, 0),
        recurrenceRule: 'daily',
      );

      expect(result.newCurrentStreak, 2);
      expect(result.newLongestStreak, 2);
      expect(result.wasCompletedOnTime, true);
      expect(result.isDuplicateSameDay, false);
    });

    test('Grace period completion (gap = 2 days for daily) keeps streak alive', () {
      final result = StreakMath.calculateStreakOnCompletion(
        currentStreak: 3,
        longestStreak: 3,
        lastCompletedDate: DateTime.utc(2024, 10, 20, 9, 0),
        completionDate: DateTime.utc(2024, 10, 22, 19, 0),
        recurrenceRule: 'daily',
      );

      expect(result.newCurrentStreak, 4);
      expect(result.newLongestStreak, 4);
      expect(result.wasCompletedOnTime, false); // gap > 1 day
      expect(result.isDuplicateSameDay, false);
    });

    test('Late completion exceeding grace period resets streak to 1', () {
      final result = StreakMath.calculateStreakOnCompletion(
        currentStreak: 5,
        longestStreak: 10,
        lastCompletedDate: DateTime.utc(2024, 10, 20, 9, 0),
        completionDate: DateTime.utc(2024, 10, 24, 11, 0), // 4 days gap
        recurrenceRule: 'daily',
      );

      expect(result.newCurrentStreak, 1);
      expect(result.newLongestStreak, 10); // longest streak preserved
      expect(result.wasCompletedOnTime, false);
      expect(result.isDuplicateSameDay, false);
    });

    test('Back-to-back completions on same day do NOT double-increment', () {
      final result = StreakMath.calculateStreakOnCompletion(
        currentStreak: 3,
        longestStreak: 5,
        lastCompletedDate: DateTime.utc(2024, 10, 20, 8, 0),
        completionDate: DateTime.utc(2024, 10, 20, 20, 0), // same day
        recurrenceRule: 'daily',
      );

      expect(result.newCurrentStreak, 3);
      expect(result.newLongestStreak, 5);
      expect(result.isDuplicateSameDay, true);
    });

    test('Weekly recurrence on-time completion (7 days later)', () {
      final result = StreakMath.calculateStreakOnCompletion(
        currentStreak: 2,
        longestStreak: 2,
        lastCompletedDate: DateTime.utc(2024, 10, 1),
        completionDate: DateTime.utc(2024, 10, 8),
        recurrenceRule: 'weekly',
      );

      expect(result.newCurrentStreak, 3);
      expect(result.newLongestStreak, 3);
      expect(result.wasCompletedOnTime, true);
    });
  });

  group('UpdateStreak Usecase Unit Tests', () {
    late FakeHabitRepository habitRepo;
    late FakeStreakRepository streakRepo;
    late UpdateStreak updateStreak;

    setUp(() {
      habitRepo = FakeHabitRepository();
      streakRepo = FakeStreakRepository();
      updateStreak = UpdateStreak(
        habitRepository: habitRepo,
        streakRepository: streakRepo,
      );
    });

    test('Ignores tasks with recurrence = none', () async {
      final task = Task(
        id: 'task-1',
        title: 'Plain task',
        recurrenceRule: 'none',
        createdAt: DateTime.utc(2024, 10, 1),
      );

      final habit = await updateStreak.execute(task);
      expect(habit, isNull);
      expect(habitRepo.habits.isEmpty, true);
      expect(streakRepo.logs.isEmpty, true);
    });

    test('Full lifecycle: 1st completion -> 2nd on-time completion -> logs written', () async {
      final t1 = Task(
        id: 't-1',
        title: 'Daily Meditation',
        recurrenceRule: 'daily',
        createdAt: DateTime.utc(2024, 10, 1),
      );

      // 1st completion on Day 1
      final h1 = await updateStreak.execute(
        t1,
        completedAtOverride: DateTime.utc(2024, 10, 1, 9, 0),
      );
      expect(h1, isNotNull);
      expect(h1!.currentStreak, 1);
      expect(h1.longestStreak, 1);
      expect(streakRepo.logs.length, 1);

      // 2nd completion on Day 2
      final t2 = t1.copyWith(habitId: h1.id);
      final h2 = await updateStreak.execute(
        t2,
        completedAtOverride: DateTime.utc(2024, 10, 2, 9, 0),
      );
      expect(h2, isNotNull);
      expect(h2!.currentStreak, 2);
      expect(h2.longestStreak, 2);
      expect(streakRepo.logs.length, 2);

      // Same day 2 completion again (does not increment)
      final h3 = await updateStreak.execute(
        t2,
        completedAtOverride: DateTime.utc(2024, 10, 2, 21, 0),
      );
      expect(h3!.currentStreak, 2);
      expect(streakRepo.logs.length, 2);
    });
  });
}
