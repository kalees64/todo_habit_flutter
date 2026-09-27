import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/streak_log.dart';

class StreakCalendar extends StatelessWidget {
  const StreakCalendar({
    super.key,
    required this.streakLogs,
    this.focusedDay,
  });

  final List<StreakLog> streakLogs;
  final DateTime? focusedDay;

  bool _hasLogOnDay(DateTime day) {
    return streakLogs.any((log) => AppDateUtils.isSameDay(log.date, day));
  }

  bool _wasOnTimeOnDay(DateTime day) {
    final match = streakLogs.where((log) => AppDateUtils.isSameDay(log.date, day)).firstOrNull;
    return match?.wasCompletedOnTime ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final now = DateTime.now();
    final currentFocused = focusedDay ?? now;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consistency Grid',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Local Drift Ledger',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: customColors?.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${streakLogs.length} logged',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),

          TableCalendar<void>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: currentFocused,
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: theme.textTheme.labelSmall!.copyWith(
                color: customColors?.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: theme.textTheme.labelSmall!.copyWith(
                color: customColors?.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) =>
                  _buildCalendarCell(context, day, isToday: false),
              todayBuilder: (context, day, focusedDay) =>
                  _buildCalendarCell(context, day, isToday: true),
              outsideBuilder: (context, day, focusedDay) =>
                  _buildOutsideCell(context, day),
            ),
          ),
          const SizedBox(height: AppSpacing.p12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(
                context,
                color: theme.colorScheme.primary,
                label: 'Completed',
              ),
              const SizedBox(width: AppSpacing.p12),
              _buildLegendItem(
                context,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                label: 'Missed / Rest',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCell(BuildContext context, DateTime day, {required bool isToday}) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    final hasCompleted = _hasLogOnDay(day);
    final onTime = _wasOnTimeOnDay(day);

    Color bg;
    Color fg;
    Border? border;

    if (hasCompleted) {
      bg = onTime
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withValues(alpha: 0.65);
      fg = theme.colorScheme.onPrimary;
    } else if (isToday) {
      bg = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
      fg = theme.colorScheme.onSurface;
      border = Border.all(
        color: customColors?.streak ?? theme.colorScheme.secondary,
        width: 1.5,
      );
    } else {
      bg = Colors.transparent;
      fg = theme.colorScheme.onSurface;
    }

    return Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          border: border,
        ),
        child: Center(
          child: hasCompleted
              ? Icon(Icons.check, size: 16, color: fg)
              : Text(
                  '${day.day}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOutsideCell(BuildContext context, DateTime day) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    return Center(
      child: Text(
        '${day.day}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: customColors?.textSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, {required Color color, required String label}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AppSpacing.p4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
