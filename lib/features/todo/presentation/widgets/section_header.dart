import 'package:flutter/material.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/spacing.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.isExpanded,
    required this.onToggle,
    this.titleColor,
    this.badgeColor,
    this.badgeTextColor,
    this.leadingIcon,
  });

  final String title;
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Color? titleColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textCol = titleColor ?? theme.colorScheme.onSurface;
    final bgBadge = badgeColor ?? theme.colorScheme.surfaceContainerHighest;
    final fgBadge = badgeTextColor ?? theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8, horizontal: AppSpacing.p4),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: AppSpacing.p8),
            ],
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: textCol,
              ),
            ),
            const SizedBox(width: AppSpacing.p8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: 2),
              decoration: BoxDecoration(
                color: bgBadge,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: fgBadge,
                ),
              ),
            ),
            const Spacer(),
            Icon(
              isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
