import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../domain/entities/habit.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../providers/habit_providers.dart';
import '../widgets/streak_calendar.dart';

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({
    super.key,
    required this.habitId,
  });

  final String habitId;

  Future<void> _editReminderTime(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final currentParts = (habit.reminderTime ?? '20:00').split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(currentParts[0]) ?? 20,
      minute: int.tryParse(currentParts[1]) ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      final newTime = '$hourStr:$minStr';

      final updated = habit.copyWith(reminderTime: newTime);
      final habitRepo = ref.read(habitRepositoryProvider);
      await habitRepo.updateHabit(updated);

      // Reschedule nudge
      await NotificationService.instance.scheduleHabitStreakNudge(
        habitId: habit.id,
        habitTitle: habit.title,
        reminderTime: newTime,
      );
    }
  }

  Future<void> _deleteHabit(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Habit',
      message:
          'Are you sure you want to delete "${habit.title}"? All streak logs will also be removed.',
    );
    if (confirmed) {
      final habitRepo = ref.read(habitRepositoryProvider);
      final streakRepo = ref.read(streakRepositoryProvider);

      await streakRepo.deleteStreakLogsForHabit(habit.id);
      await habitRepo.deleteHabit(habit.id);
      await NotificationService.instance.cancelHabitNotification(habit.id);

      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final habitAsync = ref.watch(habitDetailProvider(habitId));
    final streakLogsAsync = ref.watch(habitStreakLogsProvider(habitId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Habit Analytics'),
        actions: [
          habitAsync.when(
            data: (habit) => habit != null
                ? IconButton(
                    icon: const Icon(LucideIcons.trash2),
                    onPressed: () => _deleteHabit(context, ref, habit),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: habitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (habit) {
          if (habit == null) {
            return const Center(child: Text('Habit not found'));
          }

          return streakLogsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (logs) {
              // Calculate On-time percentage
              final onTimeCount = logs.where((l) => l.wasCompletedOnTime).length;
              final onTimePercentage = logs.isEmpty
                  ? 100
                  : ((onTimeCount / logs.length) * 100).toInt();

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                children: [
                  // Title & Recurrence Header
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.recurrenceRule.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: customColors?.streak ?? theme.colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              habit.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p16),

                  // Hero Streak Metric Card
                  Container(
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
                                    Icon(
                                      LucideIcons.flame,
                                      size: 16,
                                      color: customColors?.streak ?? theme.colorScheme.secondary,
                                    ),
                                    const SizedBox(width: AppSpacing.p4),
                                    Text(
                                      'ACTIVE MOMENTUM',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: customColors?.streak ?? theme.colorScheme.secondary,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.p4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${habit.currentStreak}',
                                      style: theme.textTheme.displayLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.p8),
                                    Text(
                                      habit.currentStreak == 1 ? 'Day Streak' : 'Days Streak',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: customColors?.streak ?? theme.colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: customColors?.streakContainer ??
                                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.sparkles,
                                size: 24,
                                color: customColors?.streak ?? theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.p16),

                        // 3 Quick Metrics Pills
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                context,
                                label: 'Best Streak',
                                value: '${habit.longestStreak} D',
                                subtitle: 'All-time record',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.p8),
                            Expanded(
                              child: _buildMetricTile(
                                context,
                                label: 'On-Time',
                                value: '$onTimePercentage%',
                                subtitle: '$onTimeCount/${logs.length} on time',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.p8),
                            Expanded(
                              child: _buildMetricTile(
                                context,
                                label: 'Total Logged',
                                value: '${logs.length}',
                                subtitle: 'Sessions',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p16),

                  // Heatmap Calendar Grid via table_calendar
                  StreakCalendar(streakLogs: logs),
                  const SizedBox(height: AppSpacing.p16),

                  // Streak Reminder Nudge Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: customColors?.cardBackground ?? theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      border: Border.all(
                        color: customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          ),
                          child: Icon(
                            LucideIcons.bellRing,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Streak Reminder',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                habit.reminderTime != null
                                    ? 'Scheduled at ${habit.reminderTime}'
                                    : 'No reminder configured',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: customColors?.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _editReminderTime(context, ref, habit),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p8,
        vertical: AppSpacing.p8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: customColors?.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: customColors?.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
