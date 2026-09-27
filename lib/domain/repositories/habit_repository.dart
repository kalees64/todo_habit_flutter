import '../entities/habit.dart';

abstract class HabitRepository {
  Stream<List<Habit>> watchHabits();
  Future<List<Habit>> getHabits();
  Future<Habit?> getHabitById(String id);
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
}
