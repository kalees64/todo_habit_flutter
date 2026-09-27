import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/habit.dart';
import '../../../../domain/entities/streak_log.dart';

/// Stream of all Habits
final habitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final habitRepo = ref.watch(habitRepositoryProvider);
  return habitRepo.watchHabits();
});

/// Stream of a specific habit by ID
final habitDetailProvider = StreamProvider.family<Habit?, String>((ref, id) {
  final habitsAsync = ref.watch(habitsStreamProvider);
  return habitsAsync.when(
    data: (habits) {
      final habit = habits.where((h) => h.id == id).firstOrNull;
      return Stream.value(habit);
    },
    loading: () => const Stream.empty(),
    error: (e, st) => Stream.error(e, st),
  );
});

/// Stream of StreakLogs for a habit
final habitStreakLogsProvider =
    StreamProvider.family<List<StreakLog>, String>((ref, habitId) {
  final streakRepo = ref.watch(streakRepositoryProvider);
  return streakRepo.watchStreakLogs(habitId);
});

/// Habits summary: count of active streaks (>0), pending habits for today
final habitsSummaryProvider = Provider<({
  int activeStreakCount,
  int totalHabits,
  int pendingTodayCount,
})>((ref) {
  final habits = ref.watch(habitsStreamProvider).asData?.value ?? [];
  final now = DateTime.now();

  int activeStreaks = 0;
  int pendingToday = 0;

  for (final h in habits) {
    if (h.currentStreak > 0) {
      activeStreaks++;
    }
    // Check if completed today
    final isDoneToday =
        h.lastCompletedDate != null && AppDateUtils.isSameDay(h.lastCompletedDate!, now);
    if (!isDoneToday) {
      pendingToday++;
    }
  }

  return (
    activeStreakCount: activeStreaks,
    totalHabits: habits.length,
    pendingTodayCount: pendingToday,
  );
});
