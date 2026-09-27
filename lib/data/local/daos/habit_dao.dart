import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/habits_table.dart';

part 'habit_dao.g.dart';

@DriftAccessor(tables: [HabitsTable])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  Stream<List<HabitEntry>> watchHabits() {
    return (select(habitsTable)
          ..orderBy([
            (h) => OrderingTerm(expression: h.createdAt, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<List<HabitEntry>> getHabits() {
    return (select(habitsTable)
          ..orderBy([
            (h) => OrderingTerm(expression: h.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<HabitEntry?> getHabitById(String id) {
    return (select(habitsTable)..where((h) => h.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertHabit(HabitsTableCompanion habit) {
    return into(habitsTable).insert(habit, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateHabit(HabitsTableCompanion habit) {
    return update(habitsTable).replace(habit);
  }

  Future<int> deleteHabit(String id) {
    return (delete(habitsTable)..where((h) => h.id.equals(id))).go();
  }
}
