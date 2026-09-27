import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/habit.dart';
import '../providers/habit_providers.dart';
import 'streak_badge.dart';

class HabitCard extends ConsumerWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
  });

  final Habit habit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final streakLogsAsync = ref.watch(habitStreakLogsProvider(habit.id));

    final now = DateTime.now();
    final isDoneToday = habit.lastCompletedDate != null &&
        AppDateUtils.isSameDay(habit.lastCompletedDate!, now);

    return Container(
      decoration: BoxDecoration(
        color: customColors?.cardBackground ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Habit icon container
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDoneToday
                            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                      child: Icon(
                        isDoneToday ? LucideIcons.checkCheck : LucideIcons.flame,
                        size: 20,
                        color: isDoneToday
                            ? theme.colorScheme.primary
                            : (customColors?.streak ?? theme.colorScheme.secondary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.p12),

                    // Title and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                habit.recurrenceRule.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: customColors?.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                              if (isDoneToday) ...[
                                const SizedBox(width: AppSpacing.p8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.p4),
                                Text(
                                  'Completed today',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(width: AppSpacing.p8),
                                Text(
                                  '• Pending today',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: customColors?.streak ?? theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Streak Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StreakBadge(streak: habit.currentStreak),
                        const SizedBox(height: 2),
                        Text(
                          'Best: ${habit.longestStreak}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: customColors?.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p16),

                // 7-day Mini Tracker Strip
                streakLogsAsync.when(
                  loading: () => const SizedBox(height: 32),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (logs) => _buildSevenDayStrip(context, logs),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSevenDayStrip(BuildContext context, List logs) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final now = DateTime.now();

    // Past 7 days ending today
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = days[index];
        final isToday = index == 6;
        final letter = dayLetters[day.weekday - 1];

        final hasCompleted = logs.any((log) => AppDateUtils.isSameDay(log.date, day));

        return Column(
          children: [
            Text(
              letter,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isToday ? theme.colorScheme.primary : customColors?.textSecondary,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: AppSpacing.p4),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: hasCompleted
                    ? theme.colorScheme.primary
                    : isToday
                        ? (customColors?.streakContainer ?? theme.colorScheme.secondaryContainer.withValues(alpha: 0.3))
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                border: isToday && !hasCompleted
                    ? Border.all(
                        color: customColors?.streak ?? theme.colorScheme.secondary,
                        width: 1.5,
                      )
                    : null,
              ),
              child: Center(
                child: hasCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : isToday
                        ? Icon(
                            LucideIcons.flame,
                            size: 14,
                            color: customColors?.streak ?? theme.colorScheme.secondary,
                          )
                        : null,
              ),
            ),
          ],
        );
      }),
    );
  }
}
