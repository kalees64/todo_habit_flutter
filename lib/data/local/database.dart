import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/habit_dao.dart';
import 'daos/streak_log_dao.dart';
import 'daos/task_dao.dart';
import 'tables/habits_table.dart';
import 'tables/streak_logs_table.dart';
import 'tables/tasks_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [TasksTable, HabitsTable, StreakLogsTable],
  daos: [TaskDao, HabitDao, StreakLogDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'taskflow.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
