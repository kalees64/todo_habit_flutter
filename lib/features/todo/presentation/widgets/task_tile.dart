import 'package:flutter/material.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onTap,
    this.onDelete,
    this.habitStreak,
  });

  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final int? habitStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final isDone = task.isCompleted;

    final dueDate = task.dueDate;
    final isOverdue = !isDone && dueDate != null && AppDateUtils.isOverdue(dueDate);

    return Dismissible(
      key: Key('task_dismissible_${task.id}'),
      direction: isDone ? DismissDirection.startToEnd : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe to complete/uncomplete
          onToggleComplete();
          return false; // Let reactive stream update the UI
        } else if (direction == DismissDirection.endToStart) {
          // Swipe to delete
          if (onDelete != null) {
            onDelete!();
          }
          return false;
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        child: Row(
          children: [
            Icon(
              isDone ? LucideIcons.undo : LucideIcons.check,
              color: theme.colorScheme.onPrimary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.p8),
            Text(
              isDone ? 'Restore' : 'Done',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onError,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.p8),
            Icon(
              LucideIcons.trash2,
              color: theme.colorScheme.onError,
              size: 22,
            ),
          ],
        ),
      ),
      child: Material(
        color: customColors?.cardBackground ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color: isOverdue
                    ? (customColors?.overdue.withValues(alpha: 0.3) ?? theme.colorScheme.error.withValues(alpha: 0.3))
                    : (customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom 22x22 Checkbox
                Semantics(
                  checked: isDone,
                  label: 'Mark ${task.title} as ${isDone ? "incomplete" : "complete"}',
                  child: InkWell(
                    onTap: onToggleComplete,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    child: Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 2, right: AppSpacing.p12),
                      decoration: BoxDecoration(
                        color: isDone
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        border: Border.all(
                          color: isDone
                              ? theme.colorScheme.primary
                              : (customColors?.hairlineBorder ?? theme.colorScheme.outline),
                          width: 1.5,
                        ),
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                // Task Content & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDone
                              ? (customColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant)
                              : theme.colorScheme.onSurface,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (dueDate != null ||
                          task.recurrenceRule != null ||
                          task.completedAt != null) ...[
                        const SizedBox(height: AppSpacing.p8),
                        Wrap(
                          spacing: AppSpacing.p8,
                          runSpacing: AppSpacing.p4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Due Date / Completed Date Pill
                            if (isDone && task.completedAt != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.p8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.checkCircle2,
                                      size: 13,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: AppSpacing.p4),
                                    Text(
                                      'Completed at ${AppDateUtils.formatTime(task.completedAt!)}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: customColors?.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (dueDate != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.p8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? (customColors?.overdueContainer ?? theme.colorScheme.errorContainer)
                                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.alarmClock,
                                      size: 13,
                                      color: isOverdue
                                          ? (customColors?.overdue ?? theme.colorScheme.error)
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: AppSpacing.p4),
                                    Text(
                                      AppDateUtils.formatDueDateTime(dueDate),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isOverdue
                                            ? (customColors?.overdue ?? theme.colorScheme.error)
                                            : customColors?.textSecondary,
                                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Recurrence / Habit Streak Pill
                            if (task.recurrenceRule != null &&
                                task.recurrenceRule!.toLowerCase() != 'none') ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.p8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: customColors?.streakContainer ??
                                      theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.flame,
                                      size: 13,
                                      color: customColors?.streak ?? theme.colorScheme.secondary,
                                    ),
                                    const SizedBox(width: AppSpacing.p4),
                                    Text(
                                      habitStreak != null && habitStreak! > 0
                                          ? '$habitStreak days'
                                          : task.recurrenceRule!.toUpperCase(),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: customColors?.onStreakContainer ??
                                            theme.colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
