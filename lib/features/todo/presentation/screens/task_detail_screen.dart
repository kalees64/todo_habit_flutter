import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/task.dart';
import '../../../../shared/widgets/ad_banner_widget.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../widgets/add_edit_task_sheet.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final taskRepo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AdBannerWidget(
          margin: EdgeInsets.only(bottom: AppSpacing.p8, top: AppSpacing.p4),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Delete Task',
                message: 'Are you sure you want to delete this task?',
              );
              if (confirmed) {
                final deleteTask = ref.read(deleteTaskProvider);
                await deleteTask.execute(taskId);
                await NotificationService.instance.cancelTaskNotification(taskId);
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Task?>(
        future: taskRepo.getTaskById(taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final task = snapshot.data;
          if (task == null) {
            return const Center(child: Text('Task not found'));
          }

          final isDone = task.isCompleted;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            children: [
              // Task Title Card
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.p8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDone
                                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          ),
                          child: Text(
                            isDone ? 'COMPLETED' : 'PENDING',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDone
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(LucideIcons.edit2, size: 18),
                          onPressed: () async {
                            await AddEditTaskSheet.show(context, task: task);
                            // Refresh
                            (context as Element).markNeedsBuild();
                          },
                          tooltip: 'Edit Task',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    Text(
                      task.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),

              // Metadata card
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
                    _buildMetaRow(
                      context,
                      icon: LucideIcons.calendar,
                      label: 'Due Date',
                      value: task.dueDate != null
                          ? AppDateUtils.formatDueDateTime(task.dueDate!)
                          : 'None',
                    ),
                    if (task.completedAt != null) ...[
                      const Divider(height: AppSpacing.p24),
                      _buildMetaRow(
                        context,
                        icon: LucideIcons.checkCircle2,
                        label: 'Completed At',
                        value: '${AppDateUtils.formatShortDate(task.completedAt!)} at ${AppDateUtils.formatTime(task.completedAt!)}',
                      ),
                    ],
                    const Divider(height: AppSpacing.p24),
                    _buildMetaRow(
                      context,
                      icon: LucideIcons.repeat,
                      label: 'Recurrence',
                      value: task.recurrenceRule?.toUpperCase() ?? 'NONE',
                    ),
                    if (task.habitId != null) ...[
                      const Divider(height: AppSpacing.p24),
                      _buildMetaRow(
                        context,
                        icon: LucideIcons.flame,
                        label: 'Habit Linked',
                        value: 'Yes (Tracks Streaks)',
                        valueColor: customColors?.streak,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p24),

              // Action button: Toggle complete/uncomplete
              FilledButton.icon(
                onPressed: () async {
                  if (isDone) {
                    final uncompleteTask = ref.read(uncompleteTaskProvider);
                    await uncompleteTask.execute(task);
                  } else {
                    final completeTask = ref.read(completeTaskProvider);
                    await completeTask.execute(task);
                    await NotificationService.instance.cancelTaskNotification(task.id);
                  }
                  if (context.mounted) {
                    context.pop();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: isDone
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary,
                  foregroundColor: isDone
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
                icon: Icon(isDone ? LucideIcons.rotateCcw : LucideIcons.check),
                label: Text(isDone ? 'Mark as Incomplete' : 'Mark as Complete'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.p12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
