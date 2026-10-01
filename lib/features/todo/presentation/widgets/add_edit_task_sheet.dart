import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/task.dart';

class AddEditTaskSheet extends ConsumerStatefulWidget {
  const AddEditTaskSheet({
    super.key,
    this.initialTask,
  });

  final Task? initialTask;

  static Future<void> show(BuildContext context, {Task? task}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditTaskSheet(initialTask: task),
    );
  }

  @override
  ConsumerState<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends ConsumerState<AddEditTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _customDaysController;

  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  String _selectedRecurrence = AppConstants.recurrenceNone;
  int? _customIntervalDays;
  bool _enableStreakNudge = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');

    if (task?.dueDate != null) {
      final local = task!.dueDate!.toLocal();
      _selectedDueDate = DateTime(local.year, local.month, local.day);
      _selectedDueTime = TimeOfDay(hour: local.hour, minute: local.minute);
    }

    _selectedRecurrence = task?.recurrenceRule ?? AppConstants.recurrenceNone;
    _customIntervalDays = task?.customIntervalDays;
    _customDaysController = TextEditingController(
      text: _customIntervalDays?.toString() ?? '3',
    );
  }

  @override
  void dispose() {
    _titleController.dispose;
    _customDaysController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _selectedDueTime ??= const TimeOfDay(hour: 18, minute: 0);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedDueTime = picked;
        _selectedDueDate ??= DateTime.now();
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  DateTime? _computeFullDueDateTime() {
    if (_selectedDueDate == null) return null;
    final time = _selectedDueTime ?? const TimeOfDay(hour: 23, minute: 59);
    return DateTime(
      _selectedDueDate!.year,
      _selectedDueDate!.month,
      _selectedDueDate!.day,
      time.hour,
      time.minute,
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _onSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Task title cannot be empty';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final dueDate = _computeFullDueDateTime();
      final isRecurring = _selectedRecurrence != AppConstants.recurrenceNone;
      final customDays = _selectedRecurrence == AppConstants.recurrenceCustom
          ? (int.tryParse(_customDaysController.text) ?? 3)
          : null;

      final reminderStr =
          isRecurring && _enableStreakNudge ? _formatTimeOfDay(_reminderTime) : null;

      if (widget.initialTask == null) {
        // Create new Task
        final createTask = ref.read(createTaskProvider);
        final created = await createTask.execute(
          title: title,
          dueDate: dueDate,
          recurrenceRule: _selectedRecurrence,
          customIntervalDays: customDays,
          reminderTime: reminderStr,
        );

        // Schedule notifications
        if (dueDate != null) {
          await NotificationService.instance.scheduleTaskDueNotification(
            taskId: created.id,
            taskTitle: created.title,
            dueDate: dueDate,
          );
        }
        if (created.habitId != null && reminderStr != null) {
          await NotificationService.instance.scheduleHabitStreakNudge(
            habitId: created.habitId!,
            habitTitle: created.title,
            reminderTime: reminderStr,
          );
        }
      } else {
        // Update existing Task
        final updateTask = ref.read(updateTaskProvider);
        final updated = await updateTask.execute(
          widget.initialTask!,
          title: title,
          dueDate: dueDate,
          clearDueDate: dueDate == null,
          recurrenceRule: _selectedRecurrence,
          customIntervalDays: customDays,
        );

        // Reschedule task notification
        await NotificationService.instance.cancelTaskNotification(updated.id);
        if (dueDate != null && !updated.isCompleted) {
          await NotificationService.instance.scheduleTaskDueNotification(
            taskId: updated.id,
            taskTitle: updated.title,
            dueDate: dueDate,
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final isEditing = widget.initialTask != null;
    final isCompletedTask = widget.initialTask?.isCompleted ?? false;
    final isRecurring = _selectedRecurrence != AppConstants.recurrenceNone;

    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
          border: Border.all(
            color: customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMargin,
              vertical: AppSpacing.p16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle pill
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.p16),

                // Sheet Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                      ),
                      child: const Text('Discard'),
                    ),
                    Text(
                      isEditing ? 'Edit Task' : 'New Task',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    FilledButton(
                      onPressed: _isSaving ? null : _onSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.p16,
                          vertical: AppSpacing.p8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isEditing ? 'Update' : 'Save Task'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.p16),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.p12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p12),
                ],

                // Task Title Input with Character Counter
                Container(
                  padding: const EdgeInsets.all(AppSpacing.p16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(
                      color: customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleController,
                        maxLength: 160,
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., Read 15 pages or Morning run',
                          hintStyle: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                        ),
                        onChanged: (text) => setState(() {}),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.p4),
                              Text(
                                'Intention matters most',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: customColors?.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_titleController.text.length}/160',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: customColors?.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.p16),

                if (!isCompletedTask) ...[
                  // Date & Time Scheduling Section
                  Text(
                    'WHEN & SCHEDULING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p8),
                  Row(
                    children: [
                      // Date Chip
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.p12,
                            vertical: AppSpacing.p8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            border: Border.all(
                              color: _selectedDueDate != null
                                  ? theme.colorScheme.primary
                                  : (customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 16,
                                color: _selectedDueDate != null
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.p8),
                              Text(
                                _selectedDueDate != null
                                    ? AppDateUtils.formatShortDate(_selectedDueDate!)
                                    : 'Pick Date',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.p8),

                      // Time Chip
                      if (_selectedDueDate != null) ...[
                        InkWell(
                          onTap: _pickTime,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.p12,
                              vertical: AppSpacing.p8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              border: Border.all(
                                color: _selectedDueTime != null
                                    ? theme.colorScheme.primary
                                    : (customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.bell,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: AppSpacing.p8),
                                Text(
                                  _selectedDueTime != null
                                      ? _selectedDueTime!.format(context)
                                      : 'Set Time',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.p4),

                        // Clear Date/Time Button
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedDueDate = null;
                              _selectedDueTime = null;
                            });
                          },
                          icon: const Icon(LucideIcons.x, size: 16),
                          tooltip: 'Clear Date',
                        ),
                      ],
                    ],
                  ),
                  if (AppConstants.enableHabits) ...[
                    const SizedBox(height: AppSpacing.p24),

                    // Recurrence & Habit Cadence
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CADENCE & HABIT ENGINE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isRecurring)
                          Row(
                            children: [
                              Icon(
                                LucideIcons.flame,
                                size: 14,
                                color: customColors?.streak ?? theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: AppSpacing.p4),
                              Text(
                                'Active Habit Loop',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: customColors?.streak ?? theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.p8),

                    // Recurrence Segmented Control
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.p4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      ),
                      child: Row(
                        children: [
                          _buildRecurrenceButton(AppConstants.recurrenceNone, 'None'),
                          _buildRecurrenceButton(AppConstants.recurrenceDaily, 'Daily'),
                          _buildRecurrenceButton(AppConstants.recurrenceWeekly, 'Weekly'),
                          _buildRecurrenceButton(AppConstants.recurrenceCustom, 'Custom'),
                        ],
                      ),
                    ),

                    // If Custom interval selected
                    if (_selectedRecurrence == AppConstants.recurrenceCustom) ...[
                      const SizedBox(height: AppSpacing.p12),
                      Row(
                        children: [
                          Text(
                            'Repeat every',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: AppSpacing.p12),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: _customDaysController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.p4,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.p12),
                          Text(
                            'days',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],

                    // Habit Auto-Promotion Banner
                    if (isRecurring) ...[
                      const SizedBox(height: AppSpacing.p16),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.p12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                              ),
                              child: const Icon(
                                LucideIcons.sparkles,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Auto-promoted to Habit Tracker!',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Completing this will build consecutive on-time streaks and keep your momentum chain unbroken.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: customColors?.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p12),

                      // Streak-at-risk Nudge Switch Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.p12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
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
                                color: customColors?.streakContainer ??
                                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                              ),
                              child: Icon(
                                LucideIcons.bellRing,
                                size: 18,
                                color: customColors?.streak ?? theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Streak-at-risk nudge',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _pickReminderTime,
                                    child: Text(
                                      'Daily reminder at ${_reminderTime.format(context)}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: customColors?.textSecondary,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _enableStreakNudge,
                              activeThumbColor: theme.colorScheme.primary,
                              onChanged: (val) {
                                setState(() {
                                  _enableStreakNudge = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],

                const SizedBox(height: AppSpacing.p16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecurrenceButton(String rule, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedRecurrence == rule;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRecurrence = rule;
          });
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
