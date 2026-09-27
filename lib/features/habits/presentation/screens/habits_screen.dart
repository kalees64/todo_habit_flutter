import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../todo/presentation/widgets/add_edit_task_sheet.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_card.dart';

enum HabitFilter { all, pending, completed }

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  HabitFilter _currentFilter = HabitFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final habitsAsync = ref.watch(habitsStreamProvider);
    final summary = ref.watch(habitsSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Tracker',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Streaks & Consistency Loops',
              style: theme.textTheme.bodySmall?.copyWith(
                color: customColors?.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditTaskSheet.show(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: Text(
          'New Habit',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (habits) {
          if (habits.isEmpty) {
            return EmptyState(
              icon: LucideIcons.flame,
              title: 'No habits tracked yet',
              subtitle:
                  'Create a recurring task (Daily or Weekly) to auto-promote it into your habit momentum engine.',
              action: FilledButton.icon(
                onPressed: () => AddEditTaskSheet.show(context),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                ),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Add Recurring Task'),
              ),
            );
          }

          final now = DateTime.now();

          // Apply filters
          final filtered = habits.where((h) {
            final isDoneToday = h.lastCompletedDate != null &&
                AppDateUtils.isSameDay(h.lastCompletedDate!, now);
            switch (_currentFilter) {
              case HabitFilter.all:
                return true;
              case HabitFilter.pending:
                return !isDoneToday;
              case HabitFilter.completed:
                return isDoneToday;
            }
          }).toList();

          return ListView(
            padding: const EdgeInsets.only(
              left: AppSpacing.screenMargin,
              right: AppSpacing.screenMargin,
              top: AppSpacing.p8,
              bottom: 88,
            ),
            children: [
              // Top Stats Banner
              _buildStatsBanner(context, summary),
              const SizedBox(height: AppSpacing.p16),

              // Filter Tabs
              Row(
                children: [
                  _buildFilterTab(HabitFilter.all, 'All (${habits.length})'),
                  const SizedBox(width: AppSpacing.p8),
                  _buildFilterTab(
                    HabitFilter.pending,
                    'Pending (${summary.pendingTodayCount})',
                  ),
                  const SizedBox(width: AppSpacing.p8),
                  _buildFilterTab(
                    HabitFilter.completed,
                    'Completed (${habits.length - summary.pendingTodayCount})',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.p16),

              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.p32),
                  child: Center(
                    child: Text('No habits match this filter.'),
                  ),
                )
              else
                ...filtered.map((habit) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.p12),
                      child: HabitCard(
                        habit: habit,
                        onTap: () => context.push('/habits/${habit.id}'),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsBanner(
    BuildContext context,
    ({int activeStreakCount, int totalHabits, int pendingTodayCount}) summary,
  ) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: customColors?.streakContainer ??
                      theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Icon(
                  LucideIcons.flame,
                  size: 22,
                  color: customColors?.streak ?? theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.p12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${summary.activeStreakCount} Active Streaks',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${summary.totalHabits} total habits registered',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: customColors?.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                LucideIcons.trophy,
                size: 24,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          if (summary.pendingTodayCount > 0) ...[
            const SizedBox(height: AppSpacing.p12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p12,
                vertical: AppSpacing.p8,
              ),
              decoration: BoxDecoration(
                color: customColors?.streakContainer ??
                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.hourglass,
                    size: 14,
                    color: customColors?.streak ?? theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: AppSpacing.p8),
                  Expanded(
                    child: Text(
                      'Don\'t break the chain: ${summary.pendingTodayCount} habit${summary.pendingTodayCount > 1 ? 's' : ''} pending today',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customColors?.onStreakContainer ??
                            theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterTab(HabitFilter filter, String label) {
    final theme = Theme.of(context);
    final isSelected = _currentFilter == filter;

    return InkWell(
      onTap: () => setState(() => _currentFilter = filter),
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p12,
          vertical: AppSpacing.p8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
