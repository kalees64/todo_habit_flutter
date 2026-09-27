import 'package:drift/drift.dart';

@DataClassName('TaskEntry')
class TasksTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get recurrenceRule => text().nullable()();
  IntColumn get customIntervalDays => integer().nullable()();
  TextColumn get habitId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
