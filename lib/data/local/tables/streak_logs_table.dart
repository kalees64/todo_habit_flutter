import 'package:drift/drift.dart';

@DataClassName('StreakLogEntry')
class StreakLogsTable extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get wasCompletedOnTime => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
