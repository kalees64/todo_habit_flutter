import '../entities/streak_log.dart';

abstract class StreakRepository {
  Stream<List<StreakLog>> watchStreakLogs(String habitId);
  Future<List<StreakLog>> getStreakLogs(String habitId);
  Future<void> addStreakLog(StreakLog log);
  Future<void> deleteLastStreakLog(String habitId, DateTime date);
  Future<void> deleteStreakLogsForHabit(String habitId);
}
