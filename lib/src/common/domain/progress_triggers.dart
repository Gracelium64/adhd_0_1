import 'package:flutter/foundation.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';

// Helper to compute progress (0..272) from completed/total
double _progressValue(int completed, int total) {
  if (total == 0) return 0.0;
  return 272.0 * (completed / total);
}

final ValueNotifier<Future<double>> dailyProgressFuture = ValueNotifier(
  Future.value(0),
);
final ValueNotifier<Future<double>> weeklyProgressFuture = ValueNotifier(
  Future.value(0),
);
final ValueNotifier<Future<double>> deadnlineProgressFuture = ValueNotifier(
  Future.value(0),
);
final ValueNotifier<Future<double>> questProgressFuture = ValueNotifier(
  Future.value(0),
);

// Recompute and publish daily progress to listeners
Future<void> refreshDailyProgress(DataBaseRepository repository) async {
  dailyProgressFuture.value = repository.getDailyTasks().then((tasks) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.isDone).length;
    return _progressValue(completed, total);
  });
}

// Recompute and publish weekly progress to listeners
Future<void> refreshWeeklyProgress(DataBaseRepository repository) async {
  weeklyProgressFuture.value = repository.getWeeklyTasks().then((tasks) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.isDone).length;
    return _progressValue(completed, total);
  });
}

// Optional: convenience to refresh both
Future<void> refreshAllProgress(DataBaseRepository repository) async {
  await Future.wait([
    refreshDailyProgress(repository),
    refreshWeeklyProgress(repository),
  ]);
}
