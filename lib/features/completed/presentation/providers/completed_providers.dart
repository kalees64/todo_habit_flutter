import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../domain/entities/task.dart';
import '../../../todo/presentation/providers/task_providers.dart';

/// Grouped completed tasks: header string -> list of tasks
final groupedCompletedTasksProvider =
    Provider<AsyncValue<Map<String, List<Task>>>>((ref) {
  final completedAsync = ref.watch(completedTasksStreamProvider);

  return completedAsync.whenData((tasks) {
    final groups = <String, List<Task>>{};

    for (final task in tasks) {
      if (task.completedAt == null) continue;
      final header = AppDateUtils.getCompletionGroupHeader(task.completedAt!);
      groups.putIfAbsent(header, () => []).add(task);
    }

    return groups;
  });
});
