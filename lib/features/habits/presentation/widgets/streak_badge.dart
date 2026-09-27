import 'package:flutter/material.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({
    super.key,
    required this.streak,
    this.longestStreak,
    this.showFlameOnlyIfActive = false,
  });

  final int streak;
  final int? longestStreak;
  final bool showFlameOnlyIfActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();

    final isActive = streak > 0;
    final flameColor = isActive
        ? (customColors?.streak ?? theme.colorScheme.secondary)
        : theme.colorScheme.onSurfaceVariant;
    final bgColor = isActive
        ? (customColors?.streakContainer ?? theme.colorScheme.secondaryContainer.withValues(alpha: 0.3))
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final textColor = isActive
        ? (customColors?.onStreakContainer ?? theme.colorScheme.onSecondaryContainer)
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p8,
        vertical: AppSpacing.p4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.flame,
            size: 14,
            color: flameColor,
          ),
          const SizedBox(width: AppSpacing.p4),
          Text(
            '$streak ${streak == 1 ? 'Day' : 'Days'}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
