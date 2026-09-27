import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/streak_logs_table.dart';

part 'streak_log_dao.g.dart';

@DriftAccessor(tables: [StreakLogsTable])
class StreakLogDao extends DatabaseAccessor<AppDatabase>
    with _$StreakLogDaoMixin {
  StreakLogDao(super.db);

  Stream<List<StreakLogEntry>> watchStreakLogs(String habitId) {
    return (select(streakLogsTable)
          ..where((s) => s.habitId.equals(habitId))
          ..orderBy([(s) => OrderingTerm(expression: s.date, mode: OrderingMode.asc)]))
        .watch();
  }

  Future<List<StreakLogEntry>> getStreakLogs(String habitId) {
    return (select(streakLogsTable)
          ..where((s) => s.habitId.equals(habitId))
          ..orderBy([(s) => OrderingTerm(expression: s.date, mode: OrderingMode.asc)]))
        .get();
  }

  Future<int> insertStreakLog(StreakLogsTableCompanion log) {
    return into(streakLogsTable).insert(log, mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteLastStreakLog(String habitId, DateTime date) {
    return (delete(streakLogsTable)
          ..where((s) => s.habitId.equals(habitId) & s.date.equals(date)))
        .go();
  }

  Future<int> deleteStreakLogsForHabit(String habitId) {
    return (delete(streakLogsTable)..where((s) => s.habitId.equals(habitId)))
        .go();
  }
}
