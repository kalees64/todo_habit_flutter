import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../features/completed/presentation/screens/completed_tasks_screen.dart';
import '../features/habits/presentation/screens/habit_detail_screen.dart';
import '../features/habits/presentation/screens/habits_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/todo/presentation/screens/home_screen.dart';
import '../features/todo/presentation/screens/task_detail_screen.dart';
import '../shared/widgets/app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Tasks
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'task/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return TaskDetailScreen(taskId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        if (AppConstants.enableHabits)
          // Branch 2: Habits
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) => const HabitsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return HabitDetailScreen(habitId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

        // Branch 3: History / Completed
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/completed',
              builder: (context, state) => const CompletedTasksScreen(),
            ),
          ],
        ),

        // Branch 4: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
