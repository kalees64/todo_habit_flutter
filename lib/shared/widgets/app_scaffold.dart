import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../features/todo/presentation/providers/task_providers.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();
    ref.watch(dailyPinnedNotificationSyncProvider);
    final currentIndex = navigationShell.currentIndex;
    final enableHabits = AppConstants.enableHabits;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  isSelected: currentIndex == 0,
                  icon: LucideIcons.checkSquare,
                  label: 'Tasks',
                ),
                if (enableHabits)
                  _buildNavItem(
                    context,
                    index: 1,
                    isSelected: currentIndex == 1,
                    icon: LucideIcons.flame,
                    label: 'Habits',
                  ),
                _buildNavItem(
                  context,
                  index: enableHabits ? 2 : 1,
                  isSelected: currentIndex == (enableHabits ? 2 : 1),
                  icon: LucideIcons.history,
                  label: 'Completed',
                ),
                _buildNavItem(
                  context,
                  index: enableHabits ? 3 : 2,
                  isSelected: currentIndex == (enableHabits ? 3 : 2),
                  icon: LucideIcons.sliders,
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required bool isSelected,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? primary : inactiveColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primary : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
