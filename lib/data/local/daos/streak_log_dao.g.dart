// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_log_dao.dart';

// ignore_for_file: type=lint
mixin _$StreakLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $StreakLogsTableTable get streakLogsTable => attachedDatabase.streakLogsTable;
  StreakLogDaoManager get managers => StreakLogDaoManager(this);
}

class StreakLogDaoManager {
  final _$StreakLogDaoMixin _db;
  StreakLogDaoManager(this._db);
  $$StreakLogsTableTableTableManager get streakLogsTable =>
      $$StreakLogsTableTableTableManager(
        _db.attachedDatabase,
        _db.streakLogsTable,
      );
}
