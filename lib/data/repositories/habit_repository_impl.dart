import 'package:drift/drift.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../local/daos/habit_dao.dart';
import '../local/database.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._habitDao);

  final HabitDao _habitDao;

  Habit _toDomain(HabitEntry entry) {
    return Habit(
      id: entry.id,
      title: entry.title,
      recurrenceRule: entry.recurrenceRule,
      customIntervalDays: entry.customIntervalDays,
      currentStreak: entry.currentStreak,
      longestStreak: entry.longestStreak,
      lastCompletedDate: entry.lastCompletedDate,
      reminderTime: entry.reminderTime,
      createdAt: entry.createdAt,
    );
  }

  HabitsTableCompanion _toCompanion(Habit habit) {
    return HabitsTableCompanion(
      id: Value(habit.id),
      title: Value(habit.title),
      recurrenceRule: Value(habit.recurrenceRule),
      customIntervalDays: Value(habit.customIntervalDays),
      currentStreak: Value(habit.currentStreak),
      longestStreak: Value(habit.longestStreak),
      lastCompletedDate: Value(habit.lastCompletedDate),
      reminderTime: Value(habit.reminderTime),
      createdAt: Value(habit.createdAt),
    );
  }

  @override
  Stream<List<Habit>> watchHabits() {
    return _habitDao
        .watchHabits()
        .map((entries) => entries.map(_toDomain).toList());
  }

  @override
  Future<List<Habit>> getHabits() async {
    final entries = await _habitDao.getHabits();
    return entries.map(_toDomain).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final entry = await _habitDao.getHabitById(id);
    return entry != null ? _toDomain(entry) : null;
  }

  @override
  Future<void> createHabit(Habit habit) async {
    await _habitDao.insertHabit(_toCompanion(habit));
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await _habitDao.updateHabit(_toCompanion(habit));
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _habitDao.deleteHabit(id);
  }
}
