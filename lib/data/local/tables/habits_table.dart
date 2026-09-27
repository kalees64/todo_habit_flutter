import 'package:drift/drift.dart';

@DataClassName('HabitEntry')
class HabitsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get recurrenceRule => text()();
  IntColumn get customIntervalDays => integer().nullable()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCompletedDate => dateTime().nullable()();
  TextColumn get reminderTime => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
