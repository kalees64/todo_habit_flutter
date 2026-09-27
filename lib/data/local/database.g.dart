// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTableTable extends TasksTable
    with TableInfo<$TasksTableTable, TaskEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customIntervalDaysMeta =
      const VerificationMeta('customIntervalDays');
  @override
  late final GeneratedColumn<int> customIntervalDays = GeneratedColumn<int>(
    'custom_interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    dueDate,
    isCompleted,
    completedAt,
    recurrenceRule,
    customIntervalDays,
    habitId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('custom_interval_days')) {
      context.handle(
        _customIntervalDaysMeta,
        customIntervalDays.isAcceptableOrUnknown(
          data['custom_interval_days']!,
          _customIntervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      customIntervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_interval_days'],
      ),
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTableTable createAlias(String alias) {
    return $TasksTableTable(attachedDatabase, alias);
  }
}

class TaskEntry extends DataClass implements Insertable<TaskEntry> {
  final String id;
  final String title;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? recurrenceRule;
  final int? customIntervalDays;
  final String? habitId;
  final DateTime createdAt;
  const TaskEntry({
    required this.id,
    required this.title,
    this.dueDate,
    required this.isCompleted,
    this.completedAt,
    this.recurrenceRule,
    this.customIntervalDays,
    this.habitId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    if (!nullToAbsent || customIntervalDays != null) {
      map['custom_interval_days'] = Variable<int>(customIntervalDays);
    }
    if (!nullToAbsent || habitId != null) {
      map['habit_id'] = Variable<String>(habitId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksTableCompanion toCompanion(bool nullToAbsent) {
    return TasksTableCompanion(
      id: Value(id),
      title: Value(title),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      customIntervalDays: customIntervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(customIntervalDays),
      habitId: habitId == null && nullToAbsent
          ? const Value.absent()
          : Value(habitId),
      createdAt: Value(createdAt),
    );
  }

  factory TaskEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      customIntervalDays: serializer.fromJson<int?>(json['customIntervalDays']),
      habitId: serializer.fromJson<String?>(json['habitId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'customIntervalDays': serializer.toJson<int?>(customIntervalDays),
      'habitId': serializer.toJson<String?>(habitId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaskEntry copyWith({
    String? id,
    String? title,
    Value<DateTime?> dueDate = const Value.absent(),
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> recurrenceRule = const Value.absent(),
    Value<int?> customIntervalDays = const Value.absent(),
    Value<String?> habitId = const Value.absent(),
    DateTime? createdAt,
  }) => TaskEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    customIntervalDays: customIntervalDays.present
        ? customIntervalDays.value
        : this.customIntervalDays,
    habitId: habitId.present ? habitId.value : this.habitId,
    createdAt: createdAt ?? this.createdAt,
  );
  TaskEntry copyWithCompanion(TasksTableCompanion data) {
    return TaskEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      customIntervalDays: data.customIntervalDays.present
          ? data.customIntervalDays.value
          : this.customIntervalDays,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('dueDate: $dueDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('customIntervalDays: $customIntervalDays, ')
          ..write('habitId: $habitId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    dueDate,
    isCompleted,
    completedAt,
    recurrenceRule,
    customIntervalDays,
    habitId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.dueDate == this.dueDate &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.recurrenceRule == this.recurrenceRule &&
          other.customIntervalDays == this.customIntervalDays &&
          other.habitId == this.habitId &&
          other.createdAt == this.createdAt);
}

class TasksTableCompanion extends UpdateCompanion<TaskEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime?> dueDate;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<String?> recurrenceRule;
  final Value<int?> customIntervalDays;
  final Value<String?> habitId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TasksTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.customIntervalDays = const Value.absent(),
    this.habitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksTableCompanion.insert({
    required String id,
    required String title,
    this.dueDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.customIntervalDays = const Value.absent(),
    this.habitId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<TaskEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? dueDate,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<String>? recurrenceRule,
    Expression<int>? customIntervalDays,
    Expression<String>? habitId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (dueDate != null) 'due_date': dueDate,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (customIntervalDays != null)
        'custom_interval_days': customIntervalDays,
      if (habitId != null) 'habit_id': habitId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime?>? dueDate,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<String?>? recurrenceRule,
    Value<int?>? customIntervalDays,
    Value<String?>? habitId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TasksTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      habitId: habitId ?? this.habitId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (customIntervalDays.present) {
      map['custom_interval_days'] = Variable<int>(customIntervalDays.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('dueDate: $dueDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('customIntervalDays: $customIntervalDays, ')
          ..write('habitId: $habitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitsTableTable extends HabitsTable
    with TableInfo<$HabitsTableTable, HabitEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customIntervalDaysMeta =
      const VerificationMeta('customIntervalDays');
  @override
  late final GeneratedColumn<int> customIntervalDays = GeneratedColumn<int>(
    'custom_interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCompletedDateMeta = const VerificationMeta(
    'lastCompletedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastCompletedDate =
      GeneratedColumn<DateTime>(
        'last_completed_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    recurrenceRule,
    customIntervalDays,
    currentStreak,
    longestStreak,
    lastCompletedDate,
    reminderTime,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurrenceRuleMeta);
    }
    if (data.containsKey('custom_interval_days')) {
      context.handle(
        _customIntervalDaysMeta,
        customIntervalDays.isAcceptableOrUnknown(
          data['custom_interval_days']!,
          _customIntervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('last_completed_date')) {
      context.handle(
        _lastCompletedDateMeta,
        lastCompletedDate.isAcceptableOrUnknown(
          data['last_completed_date']!,
          _lastCompletedDateMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      )!,
      customIntervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_interval_days'],
      ),
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      lastCompletedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_completed_date'],
      ),
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitsTableTable createAlias(String alias) {
    return $HabitsTableTable(attachedDatabase, alias);
  }
}

class HabitEntry extends DataClass implements Insertable<HabitEntry> {
  final String id;
  final String title;
  final String recurrenceRule;
  final int? customIntervalDays;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final String? reminderTime;
  final DateTime createdAt;
  const HabitEntry({
    required this.id,
    required this.title,
    required this.recurrenceRule,
    this.customIntervalDays,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
    this.reminderTime,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['recurrence_rule'] = Variable<String>(recurrenceRule);
    if (!nullToAbsent || customIntervalDays != null) {
      map['custom_interval_days'] = Variable<int>(customIntervalDays);
    }
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    if (!nullToAbsent || lastCompletedDate != null) {
      map['last_completed_date'] = Variable<DateTime>(lastCompletedDate);
    }
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<String>(reminderTime);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitsTableCompanion toCompanion(bool nullToAbsent) {
    return HabitsTableCompanion(
      id: Value(id),
      title: Value(title),
      recurrenceRule: Value(recurrenceRule),
      customIntervalDays: customIntervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(customIntervalDays),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      lastCompletedDate: lastCompletedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedDate),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      createdAt: Value(createdAt),
    );
  }

  factory HabitEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      recurrenceRule: serializer.fromJson<String>(json['recurrenceRule']),
      customIntervalDays: serializer.fromJson<int?>(json['customIntervalDays']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      lastCompletedDate: serializer.fromJson<DateTime?>(
        json['lastCompletedDate'],
      ),
      reminderTime: serializer.fromJson<String?>(json['reminderTime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'recurrenceRule': serializer.toJson<String>(recurrenceRule),
      'customIntervalDays': serializer.toJson<int?>(customIntervalDays),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'lastCompletedDate': serializer.toJson<DateTime?>(lastCompletedDate),
      'reminderTime': serializer.toJson<String?>(reminderTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HabitEntry copyWith({
    String? id,
    String? title,
    String? recurrenceRule,
    Value<int?> customIntervalDays = const Value.absent(),
    int? currentStreak,
    int? longestStreak,
    Value<DateTime?> lastCompletedDate = const Value.absent(),
    Value<String?> reminderTime = const Value.absent(),
    DateTime? createdAt,
  }) => HabitEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    customIntervalDays: customIntervalDays.present
        ? customIntervalDays.value
        : this.customIntervalDays,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastCompletedDate: lastCompletedDate.present
        ? lastCompletedDate.value
        : this.lastCompletedDate,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    createdAt: createdAt ?? this.createdAt,
  );
  HabitEntry copyWithCompanion(HabitsTableCompanion data) {
    return HabitEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      customIntervalDays: data.customIntervalDays.present
          ? data.customIntervalDays.value
          : this.customIntervalDays,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      lastCompletedDate: data.lastCompletedDate.present
          ? data.lastCompletedDate.value
          : this.lastCompletedDate,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('customIntervalDays: $customIntervalDays, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastCompletedDate: $lastCompletedDate, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    recurrenceRule,
    customIntervalDays,
    currentStreak,
    longestStreak,
    lastCompletedDate,
    reminderTime,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.recurrenceRule == this.recurrenceRule &&
          other.customIntervalDays == this.customIntervalDays &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.lastCompletedDate == this.lastCompletedDate &&
          other.reminderTime == this.reminderTime &&
          other.createdAt == this.createdAt);
}

class HabitsTableCompanion extends UpdateCompanion<HabitEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> recurrenceRule;
  final Value<int?> customIntervalDays;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<DateTime?> lastCompletedDate;
  final Value<String?> reminderTime;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HabitsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.customIntervalDays = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastCompletedDate = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsTableCompanion.insert({
    required String id,
    required String title,
    required String recurrenceRule,
    this.customIntervalDays = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastCompletedDate = const Value.absent(),
    this.reminderTime = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       recurrenceRule = Value(recurrenceRule),
       createdAt = Value(createdAt);
  static Insertable<HabitEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? recurrenceRule,
    Expression<int>? customIntervalDays,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<DateTime>? lastCompletedDate,
    Expression<String>? reminderTime,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (customIntervalDays != null)
        'custom_interval_days': customIntervalDays,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (lastCompletedDate != null) 'last_completed_date': lastCompletedDate,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? recurrenceRule,
    Value<int?>? customIntervalDays,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<DateTime?>? lastCompletedDate,
    Value<String?>? reminderTime,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HabitsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (customIntervalDays.present) {
      map['custom_interval_days'] = Variable<int>(customIntervalDays.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (lastCompletedDate.present) {
      map['last_completed_date'] = Variable<DateTime>(lastCompletedDate.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('customIntervalDays: $customIntervalDays, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastCompletedDate: $lastCompletedDate, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreakLogsTableTable extends StreakLogsTable
    with TableInfo<$StreakLogsTableTable, StreakLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wasCompletedOnTimeMeta =
      const VerificationMeta('wasCompletedOnTime');
  @override
  late final GeneratedColumn<bool> wasCompletedOnTime = GeneratedColumn<bool>(
    'was_completed_on_time',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_completed_on_time" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, habitId, date, wasCompletedOnTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_logs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('was_completed_on_time')) {
      context.handle(
        _wasCompletedOnTimeMeta,
        wasCompletedOnTime.isAcceptableOrUnknown(
          data['was_completed_on_time']!,
          _wasCompletedOnTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wasCompletedOnTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StreakLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      wasCompletedOnTime: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_completed_on_time'],
      )!,
    );
  }

  @override
  $StreakLogsTableTable createAlias(String alias) {
    return $StreakLogsTableTable(attachedDatabase, alias);
  }
}

class StreakLogEntry extends DataClass implements Insertable<StreakLogEntry> {
  final String id;
  final String habitId;
  final DateTime date;
  final bool wasCompletedOnTime;
  const StreakLogEntry({
    required this.id,
    required this.habitId,
    required this.date,
    required this.wasCompletedOnTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['date'] = Variable<DateTime>(date);
    map['was_completed_on_time'] = Variable<bool>(wasCompletedOnTime);
    return map;
  }

  StreakLogsTableCompanion toCompanion(bool nullToAbsent) {
    return StreakLogsTableCompanion(
      id: Value(id),
      habitId: Value(habitId),
      date: Value(date),
      wasCompletedOnTime: Value(wasCompletedOnTime),
    );
  }

  factory StreakLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakLogEntry(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      date: serializer.fromJson<DateTime>(json['date']),
      wasCompletedOnTime: serializer.fromJson<bool>(json['wasCompletedOnTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'date': serializer.toJson<DateTime>(date),
      'wasCompletedOnTime': serializer.toJson<bool>(wasCompletedOnTime),
    };
  }

  StreakLogEntry copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? wasCompletedOnTime,
  }) => StreakLogEntry(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    date: date ?? this.date,
    wasCompletedOnTime: wasCompletedOnTime ?? this.wasCompletedOnTime,
  );
  StreakLogEntry copyWithCompanion(StreakLogsTableCompanion data) {
    return StreakLogEntry(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
      wasCompletedOnTime: data.wasCompletedOnTime.present
          ? data.wasCompletedOnTime.value
          : this.wasCompletedOnTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakLogEntry(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('wasCompletedOnTime: $wasCompletedOnTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, date, wasCompletedOnTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakLogEntry &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.date == this.date &&
          other.wasCompletedOnTime == this.wasCompletedOnTime);
}

class StreakLogsTableCompanion extends UpdateCompanion<StreakLogEntry> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<DateTime> date;
  final Value<bool> wasCompletedOnTime;
  final Value<int> rowid;
  const StreakLogsTableCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.wasCompletedOnTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StreakLogsTableCompanion.insert({
    required String id,
    required String habitId,
    required DateTime date,
    required bool wasCompletedOnTime,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       date = Value(date),
       wasCompletedOnTime = Value(wasCompletedOnTime);
  static Insertable<StreakLogEntry> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<DateTime>? date,
    Expression<bool>? wasCompletedOnTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (wasCompletedOnTime != null)
        'was_completed_on_time': wasCompletedOnTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StreakLogsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<DateTime>? date,
    Value<bool>? wasCompletedOnTime,
    Value<int>? rowid,
  }) {
    return StreakLogsTableCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      wasCompletedOnTime: wasCompletedOnTime ?? this.wasCompletedOnTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (wasCompletedOnTime.present) {
      map['was_completed_on_time'] = Variable<bool>(wasCompletedOnTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('wasCompletedOnTime: $wasCompletedOnTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTableTable tasksTable = $TasksTableTable(this);
  late final $HabitsTableTable habitsTable = $HabitsTableTable(this);
  late final $StreakLogsTableTable streakLogsTable = $StreakLogsTableTable(
    this,
  );
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final HabitDao habitDao = HabitDao(this as AppDatabase);
  late final StreakLogDao streakLogDao = StreakLogDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasksTable,
    habitsTable,
    streakLogsTable,
  ];
}

typedef $$TasksTableTableCreateCompanionBuilder = TasksTableCompanion Function({
  required String id,
  required String title,
  Value<DateTime?> dueDate,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<String?> recurrenceRule,
  Value<int?> customIntervalDays,
  Value<String?> habitId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TasksTableTableUpdateCompanionBuilder = TasksTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime?> dueDate,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<String?> recurrenceRule,
  Value<int?> customIntervalDays,
  Value<String?> habitId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$TasksTableTableFilterComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customIntervalDays => $composableBuilder(
    column: $table.customIntervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customIntervalDays => $composableBuilder(
    column: $table.customIntervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customIntervalDays => $composableBuilder(
    column: $table.customIntervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TasksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTableTable,
          TaskEntry,
          $$TasksTableTableFilterComposer,
          $$TasksTableTableOrderingComposer,
          $$TasksTableTableAnnotationComposer,
          $$TasksTableTableCreateCompanionBuilder,
          $$TasksTableTableUpdateCompanionBuilder,
          (
            TaskEntry,
            BaseReferences<_$AppDatabase, $TasksTableTable, TaskEntry>,
          ),
          TaskEntry,
          PrefetchHooks Function()
        > {
  $$TasksTableTableTableManager(_$AppDatabase db, $TasksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<int?> customIntervalDays = const Value.absent(),
                Value<String?> habitId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksTableCompanion(
                id: id,
                title: title,
                dueDate: dueDate,
                isCompleted: isCompleted,
                completedAt: completedAt,
                recurrenceRule: recurrenceRule,
                customIntervalDays: customIntervalDays,
                habitId: habitId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<int?> customIntervalDays = const Value.absent(),
                Value<String?> habitId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TasksTableCompanion.insert(
                id: id,
                title: title,
                dueDate: dueDate,
                isCompleted: isCompleted,
                completedAt: completedAt,
                recurrenceRule: recurrenceRule,
                customIntervalDays: customIntervalDays,
                habitId: habitId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTableTable, TaskEntry>(table),
                  BaseReferences<_$AppDatabase, $TasksTableTable, TaskEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTableTable,
      TaskEntry,
      $$TasksTableTableFilterComposer,
      $$TasksTableTableOrderingComposer,
      $$TasksTableTableAnnotationComposer,
      $$TasksTableTableCreateCompanionBuilder,
      $$TasksTableTableUpdateCompanionBuilder,
      (TaskEntry, BaseReferences<_$AppDatabase, $TasksTableTable, TaskEntry>),
      TaskEntry,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableTableCreateCompanionBuilder =
    HabitsTableCompanion Function({
      required String id,
      required String title,
      required String recurrenceRule,
      Value<int?> customIntervalDays,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<DateTime?> lastCompletedDate,
      Value<String?> reminderTime,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$HabitsTableTableUpdateCompanionBuilder =
    HabitsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> recurrenceRule,
      Value<int?> customIntervalDays,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<DateTime?> lastCompletedDate,
      Value<String?> reminderTime,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$HabitsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTableTable> {
  $$HabitsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customIntervalDays => $composableBuilder(
    column: $table.customIntervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTableTable> {
  $$HabitsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customIntervalDays => $composableBuilder(
    column: $table.customIntervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTableTable> {
  $$HabitsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customIntervalDays => $composableBuilder(
    column: $table.customIntervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCompletedDate => $composableBuilder(
    column: $table.lastCompletedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HabitsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTableTable,
          HabitEntry,
          $$HabitsTableTableFilterComposer,
          $$HabitsTableTableOrderingComposer,
          $$HabitsTableTableAnnotationComposer,
          $$HabitsTableTableCreateCompanionBuilder,
          $$HabitsTableTableUpdateCompanionBuilder,
          (
            HabitEntry,
            BaseReferences<_$AppDatabase, $HabitsTableTable, HabitEntry>,
          ),
          HabitEntry,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableTableManager(_$AppDatabase db, $HabitsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> recurrenceRule = const Value.absent(),
                Value<int?> customIntervalDays = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<DateTime?> lastCompletedDate = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsTableCompanion(
                id: id,
                title: title,
                recurrenceRule: recurrenceRule,
                customIntervalDays: customIntervalDays,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastCompletedDate: lastCompletedDate,
                reminderTime: reminderTime,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String recurrenceRule,
                Value<int?> customIntervalDays = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<DateTime?> lastCompletedDate = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => HabitsTableCompanion.insert(
                id: id,
                title: title,
                recurrenceRule: recurrenceRule,
                customIntervalDays: customIntervalDays,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastCompletedDate: lastCompletedDate,
                reminderTime: reminderTime,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTableTable, HabitEntry>(table),
                  BaseReferences<_$AppDatabase, $HabitsTableTable, HabitEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTableTable,
      HabitEntry,
      $$HabitsTableTableFilterComposer,
      $$HabitsTableTableOrderingComposer,
      $$HabitsTableTableAnnotationComposer,
      $$HabitsTableTableCreateCompanionBuilder,
      $$HabitsTableTableUpdateCompanionBuilder,
      (
        HabitEntry,
        BaseReferences<_$AppDatabase, $HabitsTableTable, HabitEntry>,
      ),
      HabitEntry,
      PrefetchHooks Function()
    >;
typedef $$StreakLogsTableTableCreateCompanionBuilder =
    StreakLogsTableCompanion Function({
      required String id,
      required String habitId,
      required DateTime date,
      required bool wasCompletedOnTime,
      Value<int> rowid,
    });
typedef $$StreakLogsTableTableUpdateCompanionBuilder =
    StreakLogsTableCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<DateTime> date,
      Value<bool> wasCompletedOnTime,
      Value<int> rowid,
    });

class $$StreakLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $StreakLogsTableTable> {
  $$StreakLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasCompletedOnTime => $composableBuilder(
    column: $table.wasCompletedOnTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreakLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakLogsTableTable> {
  $$StreakLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasCompletedOnTime => $composableBuilder(
    column: $table.wasCompletedOnTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreakLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakLogsTableTable> {
  $$StreakLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get wasCompletedOnTime => $composableBuilder(
    column: $table.wasCompletedOnTime,
    builder: (column) => column,
  );
}

class $$StreakLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakLogsTableTable,
          StreakLogEntry,
          $$StreakLogsTableTableFilterComposer,
          $$StreakLogsTableTableOrderingComposer,
          $$StreakLogsTableTableAnnotationComposer,
          $$StreakLogsTableTableCreateCompanionBuilder,
          $$StreakLogsTableTableUpdateCompanionBuilder,
          (
            StreakLogEntry,
            BaseReferences<
              _$AppDatabase,
              $StreakLogsTableTable,
              StreakLogEntry
            >,
          ),
          StreakLogEntry,
          PrefetchHooks Function()
        > {
  $$StreakLogsTableTableTableManager(
    _$AppDatabase db,
    $StreakLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> wasCompletedOnTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StreakLogsTableCompanion(
                id: id,
                habitId: habitId,
                date: date,
                wasCompletedOnTime: wasCompletedOnTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required DateTime date,
                required bool wasCompletedOnTime,
                Value<int> rowid = const Value.absent(),
              }) => StreakLogsTableCompanion.insert(
                id: id,
                habitId: habitId,
                date: date,
                wasCompletedOnTime: wasCompletedOnTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StreakLogsTableTable, StreakLogEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StreakLogsTableTable,
                    StreakLogEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreakLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakLogsTableTable,
      StreakLogEntry,
      $$StreakLogsTableTableFilterComposer,
      $$StreakLogsTableTableOrderingComposer,
      $$StreakLogsTableTableAnnotationComposer,
      $$StreakLogsTableTableCreateCompanionBuilder,
      $$StreakLogsTableTableUpdateCompanionBuilder,
      (
        StreakLogEntry,
        BaseReferences<_$AppDatabase, $StreakLogsTableTable, StreakLogEntry>,
      ),
      StreakLogEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableTableManager get tasksTable =>
      $$TasksTableTableTableManager(_db, _db.tasksTable);
  $$HabitsTableTableTableManager get habitsTable =>
      $$HabitsTableTableTableManager(_db, _db.habitsTable);
  $$StreakLogsTableTableTableManager get streakLogsTable =>
      $$StreakLogsTableTableTableManager(_db, _db.streakLogsTable);
}
