import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/task.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/task_providers.dart';
import '../widgets/add_edit_task_sheet.dart';
import '../widgets/section_header.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isOverdueExpanded = true;
  bool _isTodayExpanded = true;
  bool _isUpcomingExpanded = true;
  bool _isNoDueDateExpanded = true;
  bool _isCompletedExpanded = true;

  DateTime? _selectedDate;
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _weekStart = today.subtract(Duration(days: today.weekday - 1));

    // Request notification permissions gracefully on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.requestPermissions();
    });
  }

  void _prevWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  Future<void> _pickManualDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        final pickedDay = DateTime(picked.year, picked.month, picked.day);
        _weekStart = pickedDay.subtract(Duration(days: pickedDay.weekday - 1));
      });
    }
  }

  void _selectDay(DateTime day) {
    setState(() {
      if (_selectedDate != null && AppDateUtils.isSameDay(_selectedDate!, day)) {
        _selectedDate = null;
      } else {
        _selectedDate = day;
      }
    });
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
  }

  Future<void> _toggleTaskComplete(Task task) async {
    if (task.isCompleted) {
      final uncompleteTask = ref.read(uncompleteTaskProvider);
      await uncompleteTask.execute(task);
    } else {
      final completeTask = ref.read(completeTaskProvider);
      await completeTask.execute(task);
      // Cancel notification if any
      await NotificationService.instance.cancelTaskNotification(task.id);
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete "${task.title}"?',
      confirmLabel: 'Delete',
    );
    if (confirmed) {
      final deleteTask = ref.read(deleteTaskProvider);
      await deleteTask.execute(task.id);
      await NotificationService.instance.cancelTaskNotification(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final categorizedAsync = ref.watch(categorizedTasksProvider);
    final rhythmStats = ref.watch(todayRhythmStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Tasks & Rhythm',
              style: theme.textTheme.bodySmall?.copyWith(
                color: customColors?.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(LucideIcons.sliders, size: 20),
            tooltip: 'Settings',
          ),
          const SizedBox(width: AppSpacing.p8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditTaskSheet.show(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: Text(
          'New Task',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: categorizedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (categorized) {
          final completedTasksList = ref.watch(completedTasksStreamProvider).asData?.value ?? [];
          final targetDate = _selectedDate ?? DateTime.now();
          final isSelectedToday = AppDateUtils.isSameDay(targetDate, DateTime.now());

          // Filter completed tasks for the target day (today or selected date)
          final dayCompletedTasks = completedTasksList
              .where((t) => t.completedAt != null && AppDateUtils.isSameDay(t.completedAt!, targetDate))
              .toList();

          final allActiveTasks = ref.watch(activeTasksStreamProvider).asData?.value ?? [];

          // When a specific date is selected:
          final List<Task> filteredDueTasks = _selectedDate == null
              ? []
              : allActiveTasks
                  .where((t) => t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!, _selectedDate!))
                  .toList();

          final isEmpty = _selectedDate == null
              ? (categorized.totalCount == 0 && rhythmStats.done == 0 && dayCompletedTasks.isEmpty)
              : (filteredDueTasks.isEmpty && dayCompletedTasks.isEmpty && (!isSelectedToday || categorized.overdue.isEmpty));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activeTasksStreamProvider);
              ref.invalidate(completedTasksStreamProvider);
            },
            child: ListView(
              padding: const EdgeInsets.only(
                left: AppSpacing.screenMargin,
                right: AppSpacing.screenMargin,
                top: AppSpacing.p8,
                bottom: 88,
              ),
              children: [
                // Today's Rhythm Progress Card
                _buildTodayRhythmCard(context, rhythmStats),
                const SizedBox(height: AppSpacing.p16),

                // Interactive Horizontal Weekly Calendar Bar
                _buildWeeklyCalendarBar(context),
                const SizedBox(height: AppSpacing.p16),

                if (isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.p32),
                    child: _selectedDate != null
                        ? Center(
                            child: Column(
                              children: [
                                Icon(
                                  LucideIcons.calendar,
                                  size: 44,
                                  color: theme.colorScheme.outlineVariant,
                                ),
                                const SizedBox(height: AppSpacing.p8),
                                Text(
                                  'No tasks for ${DateFormat('MMMM d, y').format(_selectedDate!)}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: customColors?.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.p4),
                                Text(
                                  'No pending or completed tasks on this date.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: customColors?.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.p12),
                                TextButton(
                                  onPressed: _clearDateFilter,
                                  child: const Text('Show All Tasks'),
                                ),
                              ],
                            ),
                          )
                        : EmptyState(
                            icon: LucideIcons.checkCheck,
                            title: 'All clear!',
                            subtitle: 'No tasks pending. Tap "New Task" to create one.',
                            action: FilledButton.icon(
                              onPressed: () => AddEditTaskSheet.show(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                              ),
                              icon: const Icon(LucideIcons.plus, size: 18),
                              label: const Text('Add Task'),
                            ),
                          ),
                  )
                else if (_selectedDate != null && !isSelectedToday) ...[
                  // SPECIFIC DATE SELECTED (Not today)
                  if (filteredDueTasks.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Tasks Due (${filteredDueTasks.length})',
                      count: filteredDueTasks.length,
                      isExpanded: _isTodayExpanded,
                      onToggle: () => setState(() {
                        _isTodayExpanded = !_isTodayExpanded;
                      }),
                      badgeColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                      badgeTextColor: theme.colorScheme.primary,
                    ),
                    if (_isTodayExpanded)
                      ...filteredDueTasks.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.p8),
                            child: TaskTile(
                              task: task,
                              onToggleComplete: () => _toggleTaskComplete(task),
                              onTap: () => context.push('/task/${task.id}'),
                              onDelete: () => _deleteTask(task),
                            ),
                          )),
                    const SizedBox(height: AppSpacing.p12),
                  ],

                  // COMPLETED ON THIS SELECTED DATE
                  if (dayCompletedTasks.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Completed on ${DateFormat('MMM d').format(_selectedDate!)}',
                      count: dayCompletedTasks.length,
                      isExpanded: _isCompletedExpanded,
                      onToggle: () => setState(() {
                        _isCompletedExpanded = !_isCompletedExpanded;
                      }),
                      titleColor: theme.colorScheme.primary,
                      badgeColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                      badgeTextColor: theme.colorScheme.primary,
                      leadingIcon: Icon(
                        LucideIcons.checkCheck,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (_isCompletedExpanded)
                      ...dayCompletedTasks.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.p8),
                            child: TaskTile(
                              task: task,
                              onToggleComplete: () => _toggleTaskComplete(task),
                              onTap: () => context.push('/task/${task.id}'),
                              onDelete: () => _deleteTask(task),
                            ),
                          )),
                    const SizedBox(height: AppSpacing.p12),
                  ],
                ] else ...[
                  // ALL TASKS OR TODAY VIEW
                  // 1. OVERDUE SECTION
                  if (categorized.overdue.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Overdue',
                      count: categorized.overdue.length,
                      isExpanded: _isOverdueExpanded,
                      onToggle: () => setState(() {
                        _isOverdueExpanded = !_isOverdueExpanded;
                      }),
                      titleColor: customColors?.overdue ?? theme.colorScheme.error,
                      badgeColor: customColors?.overdueContainer ??
                          theme.colorScheme.errorContainer,
                      badgeTextColor: customColors?.onOverdueContainer ??
                          theme.colorScheme.onErrorContainer,
                      leadingIcon: Icon(
                        LucideIcons.alertCircle,
                        size: 18,
                        color: customColors?.overdue ?? theme.colorScheme.error,
                      ),
                    ),
                    if (_isOverdueExpanded)
                      ...categorized.overdue.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.p8),
                            child: TaskTile(
                              task: task,
                              onToggleComplete: () => _toggleTaskComplete(task),
                              onTap: () => context.push('/task/${task.id}'),
                              onDelete: () => _deleteTask(task),
                            ),
                          )),
                    const SizedBox(height: AppSpacing.p12),
                  ],

                  // 2. TODAY SECTION
                  if (categorized.today.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Today',
                      count: categorized.today.length,
                      isExpanded: _isTodayExpanded,
                      onToggle: () => setState(() {
                        _isTodayExpanded = !_isTodayExpanded;
                      }),
                      badgeColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                      badgeTextColor: theme.colorScheme.primary,
                    ),
                    if (_isTodayExpanded)
                      ...categorized.today.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.p8),
                            child: TaskTile(
                              task: task,
                              onToggleComplete: () => _toggleTaskComplete(task),
                              onTap: () => context.push('/task/${task.id}'),
                              onDelete: () => _deleteTask(task),
                            ),
                          )),
                    const SizedBox(height: AppSpacing.p12),
                  ],

                  // 3. COMPLETED TODAY SECTION (when today or all is viewed)
                  if (dayCompletedTasks.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Completed Today',
                      count: dayCompletedTasks.length,
                      isExpanded: _isCompletedExpanded,
                      onToggle: () => setState(() {
                        _isCompletedExpanded = !_isCompletedExpanded;
                      }),
                      titleColor: theme.colorScheme.primary,
                      badgeColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                      badgeTextColor: theme.colorScheme.primary,
                      leadingIcon: Icon(
                        LucideIcons.checkCheck,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (_isCompletedExpanded)
                      ...dayCompletedTasks.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.p8),
                            child: TaskTile(
                              task: task,
                              onToggleComplete: () => _toggleTaskComplete(task),
                              onTap: () => context.push('/task/${task.id}'),
                              onDelete: () => _deleteTask(task),
                            ),
                          )),
                    const SizedBox(height: AppSpacing.p12),
                  ],

                  // 4. UPCOMING SECTION (only if viewing All Tasks)
                  if (_selectedDate == null && categorized.upcoming.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Upcoming',
                      count: categorized.upcoming.length,
                      isExpanded: _isUpcomingExpanded,
                      onToggle: () => setState(() {
                        _isUpcomingExpanded = !_isUpcomingExpanded;
                      }),
                    ),
                    if (_isUpcomingExpanded)
                      ...categorized.upcoming.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.p8),
                            child: TaskTile(
                              task: task,
                              onToggleComplete: () => _toggleTaskComplete(task),
                              onTap: () => context.push('/task/${task.id}'),
                              onDelete: () => _deleteTask(task),
                            ),
                          )),
                    const SizedBox(height: AppSpacing.p12),
                  ],

                  // 5. NO DUE DATE SECTION (only if viewing All Tasks)
                  if (_selectedDate == null && categorized.noDueDate.isNotEmpty) ...[
                    SectionHeader(
                      title: 'No Due Date',
                      count: categorized.noDueDate.length,
                      isExpanded: _isNoDueDateExpanded,
                      onToggle: () => setState(() {
                        _isNoDueDateExpanded = !_isNoDueDateExpanded;
                      }),
                    ),
                    if (_isNoDueDateExpanded)
                      ...categorized.noDueDate.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.p8),
                            child: TaskTile(
                              task: task,
                              onToggleComplete: () => _toggleTaskComplete(task),
                              onTap: () => context.push('/task/${task.id}'),
                              onDelete: () => _deleteTask(task),
                            ),
                          )),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayRhythmCard(
    BuildContext context,
    ({int done, int total, double progress}) rhythm,
  ) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final percent = (rhythm.progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: customColors?.cardBackground ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TODAY\'S RHYTHM',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.p4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${rhythm.done} of ${rhythm.total}',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.p8),
                      Text(
                        'done ($percent%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: customColors?.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rhythm.total == 0
                        ? 'Set daily goals to find your rhythm.'
                        : rhythm.done == rhythm.total
                            ? 'All done today! Outstanding focus.'
                            : 'Momentum is strong. Keep steady.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: customColors?.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              // Circular progress ring
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: rhythm.progress,
                      strokeWidth: 5,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                    Icon(
                      LucideIcons.sprout,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),
          // Ambient linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: rhythm.progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendarBar(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final now = DateTime.now();

    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final weekEnd = _weekStart.add(const Duration(days: 6));
    final weekRangeLabel = _weekStart.month == weekEnd.month
        ? '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('d, y').format(weekEnd)}'
        : '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('MMM d, y').format(weekEnd)}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: customColors?.cardBackground ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation & manual picker header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.p8),
                  Text(
                    weekRangeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _prevWeek,
                    icon: const Icon(LucideIcons.chevronLeft, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Previous week',
                  ),
                  IconButton(
                    onPressed: _nextWeek,
                    icon: const Icon(LucideIcons.chevronRight, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Next week',
                  ),
                  IconButton(
                    onPressed: _pickManualDate,
                    icon: const Icon(LucideIcons.calendar, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Pick date',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p8),

          // 7-day strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = days[index];
              final isToday = AppDateUtils.isSameDay(date, now);
              final isSelected = _selectedDate != null && AppDateUtils.isSameDay(date, _selectedDate!);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : isToday
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : isToday
                                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                                : customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant,
                        width: isSelected || isToday ? 1.5 : 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _selectDay(date),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dayLetters[index],
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : isToday
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${date.day}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : isToday
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : isToday
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.p8),

          // Quick filter pills row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  selected: _selectedDate == null,
                  label: const Text('All Tasks'),
                  onSelected: (_) => _clearDateFilter(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: AppSpacing.p8),
                FilterChip(
                  selected: _selectedDate != null && AppDateUtils.isSameDay(_selectedDate!, now),
                  label: const Text('Today'),
                  onSelected: (_) {
                    setState(() {
                      _selectedDate = now;
                      final today = DateTime(now.year, now.month, now.day);
                      _weekStart = today.subtract(Duration(days: today.weekday - 1));
                    });
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                if (_selectedDate != null && !AppDateUtils.isSameDay(_selectedDate!, now)) ...[
                  const SizedBox(width: AppSpacing.p8),
                  FilterChip(
                    selected: true,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(DateFormat('EEE, MMM d').format(_selectedDate!)),
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.x, size: 14),
                      ],
                    ),
                    onSelected: (_) => _clearDateFilter(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
