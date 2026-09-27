import 'package:drift/drift.dart';
import '../../domain/entities/streak_log.dart';
import '../../domain/repositories/streak_repository.dart';
import '../local/daos/streak_log_dao.dart';
import '../local/database.dart';

class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(this._streakLogDao);

  final StreakLogDao _streakLogDao;

  StreakLog _toDomain(StreakLogEntry entry) {
    return StreakLog(
      id: entry.id,
      habitId: entry.habitId,
      date: entry.date,
      wasCompletedOnTime: entry.wasCompletedOnTime,
    );
  }

  StreakLogsTableCompanion _toCompanion(StreakLog log) {
    return StreakLogsTableCompanion(
      id: Value(log.id),
      habitId: Value(log.habitId),
      date: Value(log.date),
      wasCompletedOnTime: Value(log.wasCompletedOnTime),
    );
  }

  @override
  Stream<List<StreakLog>> watchStreakLogs(String habitId) {
    return _streakLogDao
        .watchStreakLogs(habitId)
        .map((entries) => entries.map(_toDomain).toList());
  }

  @override
  Future<List<StreakLog>> getStreakLogs(String habitId) async {
    final entries = await _streakLogDao.getStreakLogs(habitId);
    return entries.map(_toDomain).toList();
  }

  @override
  Future<void> addStreakLog(StreakLog log) async {
    await _streakLogDao.insertStreakLog(_toCompanion(log));
  }

  @override
  Future<void> deleteLastStreakLog(String habitId, DateTime date) async {
    await _streakLogDao.deleteLastStreakLog(habitId, date);
  }

  @override
  Future<void> deleteStreakLogsForHabit(String habitId) async {
    await _streakLogDao.deleteStreakLogsForHabit(habitId);
  }
}
