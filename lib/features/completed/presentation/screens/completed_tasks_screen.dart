import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/task.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../todo/presentation/providers/task_providers.dart';

enum CompletedFilter { all, today, thisWeek, thisMonth, customDate }

class CompletedTasksScreen extends ConsumerStatefulWidget {
  const CompletedTasksScreen({super.key});

  @override
  ConsumerState<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends ConsumerState<CompletedTasksScreen> {
  CompletedFilter _filter = CompletedFilter.all;
  DateTime? _selectedCustomDate;

  Future<void> _undoComplete(Task task) async {
    final uncompleteTask = ref.read(uncompleteTaskProvider);
    await uncompleteTask.execute(task);
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedCustomDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedCustomDate = picked;
        _filter = CompletedFilter.customDate;
      });
    }
  }

  bool _matchesFilter(Task task) {
    final completed = task.completedAt;
    if (completed == null) return false;
    final localComp = completed.toLocal();
    final now = DateTime.now();

    switch (_filter) {
      case CompletedFilter.all:
        return true;
      case CompletedFilter.today:
        return AppDateUtils.isSameDay(localComp, now);
      case CompletedFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = start.add(const Duration(days: 7));
        return localComp.isAfter(start.subtract(const Duration(seconds: 1))) &&
            localComp.isBefore(end);
      case CompletedFilter.thisMonth:
        return localComp.year == now.year && localComp.month == now.month;
      case CompletedFilter.customDate:
        if (_selectedCustomDate == null) return true;
        return AppDateUtils.isSameDay(localComp, _selectedCustomDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final completedStreamAsync = ref.watch(completedTasksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed Tasks',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Accomplishments & History Ledger',
              style: theme.textTheme.bodySmall?.copyWith(
                color: customColors?.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: completedStreamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allCompletedTasks) {
          final filteredTasks = allCompletedTasks.where(_matchesFilter).toList();

          // Group by completion date
          final groups = <String, List<Task>>{};
          for (final task in filteredTasks) {
            if (task.completedAt == null) continue;
            final header = AppDateUtils.getCompletionGroupHeader(task.completedAt!);
            groups.putIfAbsent(header, () => []).add(task);
          }

          return Column(
            children: [
              // Filter Chips Bar
              Container(
                height: 48,
                margin: const EdgeInsets.only(top: AppSpacing.p8, bottom: AppSpacing.p4),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
                  children: [
                    _buildFilterChip('All Time', CompletedFilter.all),
                    const SizedBox(width: AppSpacing.p8),
                    _buildFilterChip('Today', CompletedFilter.today),
                    const SizedBox(width: AppSpacing.p8),
                    _buildFilterChip('This Week', CompletedFilter.thisWeek),
                    const SizedBox(width: AppSpacing.p8),
                    _buildFilterChip('This Month', CompletedFilter.thisMonth),
                    const SizedBox(width: AppSpacing.p8),
                    _buildCustomDateChip(),
                  ],
                ),
              ),

              // Summary Info Strip
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenMargin,
                  vertical: AppSpacing.p4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredTasks.length} task${filteredTasks.length == 1 ? '' : 's'} completed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customColors?.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_filter != CompletedFilter.all)
                      GestureDetector(
                        onTap: () => setState(() => _filter = CompletedFilter.all),
                        child: Text(
                          'Reset Filter',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: AppSpacing.p12),

              // Task List or Empty State
              Expanded(
                child: groups.isEmpty
                    ? EmptyState(
                        icon: LucideIcons.history,
                        title: _filter == CompletedFilter.all
                            ? 'No completed tasks yet'
                            : 'No tasks for selected period',
                        subtitle: _filter == CompletedFilter.all
                            ? 'Check off tasks on the Tasks tab to build your momentum.'
                            : 'Try selecting a different date range or reset filter.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.screenMargin,
                          right: AppSpacing.screenMargin,
                          top: AppSpacing.p4,
                          bottom: AppSpacing.p32,
                        ),
                        itemCount: groups.keys.length,
                        itemBuilder: (context, groupIndex) {
                          final header = groups.keys.elementAt(groupIndex);
                          final tasks = groups[header]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group Header (e.g. "Today", "Yesterday")
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.p12,
                                  horizontal: AppSpacing.p4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      header,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.p8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.p8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                                      ),
                                      child: Text(
                                        '${tasks.length}',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Tasks in this group
                              ...tasks.map((task) => Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.p8),
                                    child: Dismissible(
                                      key: Key('completed_dismissible_${task.id}'),
                                      direction: DismissDirection.startToEnd,
                                      confirmDismiss: (direction) async {
                                        await _undoComplete(task);
                                        return false;
                                      },
                                      background: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.p24,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusLarge,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.undo,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: AppSpacing.p8),
                                            Text(
                                              'Restore Task',
                                              style: theme.textTheme.labelLarge?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () => context.push('/task/${task.id}'),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusLarge,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                                          decoration: BoxDecoration(
                                            color: customColors?.cardBackground ??
                                                theme.colorScheme.surface,
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusLarge,
                                            ),
                                            border: Border.all(
                                              color: customColors?.hairlineBorder ??
                                                  theme.colorScheme.outlineVariant,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // Checked Indicator with Undo Tap
                                              Semantics(
                                                button: true,
                                                label: 'Restore ${task.title} to active',
                                                child: InkWell(
                                                  onTap: () => _undoComplete(task),
                                                  borderRadius: BorderRadius.circular(
                                                    AppSpacing.radiusSmall,
                                                  ),
                                                  child: Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: theme.colorScheme.primary,
                                                      borderRadius: BorderRadius.circular(
                                                        AppSpacing.radiusSmall,
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: AppSpacing.p12),

                                              // Title and timestamp
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      task.title,
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        decoration: TextDecoration.lineThrough,
                                                        color: customColors?.textSecondary ??
                                                            theme.colorScheme.onSurfaceVariant,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    if (task.completedAt != null) ...[
                                                      const SizedBox(height: AppSpacing.p4),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            LucideIcons.clock,
                                                            size: 12,
                                                            color: customColors?.textSecondary,
                                                          ),
                                                          const SizedBox(width: AppSpacing.p4),
                                                          Text(
                                                            'Completed at ${AppDateUtils.formatTime(task.completedAt!)}',
                                                            style: theme.textTheme.bodySmall
                                                                ?.copyWith(
                                                              color: customColors?.textSecondary,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),

                                              // Quick Undo Button
                                              IconButton(
                                                onPressed: () => _undoComplete(task),
                                                tooltip: 'Undo completion',
                                                icon: const Icon(LucideIcons.rotateCcw, size: 16),
                                                color: theme.colorScheme.primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, CompletedFilter filter) {
    final theme = Theme.of(context);
    final isSelected = _filter == filter;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _filter = filter;
        });
      },
      selectedColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
    );
  }

  Widget _buildCustomDateChip() {
    final theme = Theme.of(context);
    final isSelected = _filter == CompletedFilter.customDate;
    final label = _selectedCustomDate != null
        ? DateFormat('MMM d').format(_selectedCustomDate!)
        : 'Pick Date';

    return ActionChip(
      avatar: Icon(
        LucideIcons.calendar,
        size: 14,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(label),
      onPressed: _pickCustomDate,
      backgroundColor: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : Colors.transparent,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
    );
  }
}
