import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/features/prizes/domain/available_prizes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';

class PrizeManager {
  final DataBaseRepository repository;

  PrizeManager(this.repository);

  Future<void> resetDailyCompletionCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyCompleted', 0);
    await prefs.setInt('dailyTotal', 0);
  }

  Future<void> resetWeeklyCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weeklyCompleted', 0);
    await prefs.setInt('weeklyTotal', 0);
    await prefs.setInt('questCompleted', 0);
    await prefs.setInt('deadlineCompleted', 0);
    await prefs.setBool('weeklyRewardGiven', false);
    // Reset weekly-averaged daily completion aggregates
    await prefs.setDouble('dailyWeekSum', 0.0);
    await prefs.setInt('dailyWeekCount', 0);
  }

  Future<void> trackDailyCompletion(bool isDone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyTotal', (prefs.getInt('dailyTotal') ?? 0) + 1);
    if (isDone) {
      await prefs.setInt(
        'dailyCompleted',
        (prefs.getInt('dailyCompleted') ?? 0) + 1,
      );
    }
  }

  Future<void> trackWeeklyCompletion(bool isDone) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final tasks = await repository.getWeeklyTasks();
      final total = tasks.length;
      final completed = tasks.where((task) => task.isDone).length;
      await prefs.setInt('weeklyTotal', total);
      await prefs.setInt('weeklyCompleted', completed);
    } catch (e) {
      // Preserve legacy behaviour as a fallback if repository access fails.
      await prefs.setInt(
        'weeklyTotal',
        (prefs.getInt('weeklyTotal') ?? 0) + 1,
      );
      if (isDone) {
        await prefs.setInt(
          'weeklyCompleted',
          (prefs.getInt('weeklyCompleted') ?? 0) + 1,
        );
      }
      debugPrint('trackWeeklyCompletion fallback path triggered: $e');
    }
  }

  Future<void> incrementQuestCounter() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('questCompleted') ?? 0;
    await prefs.setInt('questCompleted', current + 1);
  }

  Future<void> incrementDeadlineCounter() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('deadlineCompleted') ?? 0;
    await prefs.setInt('deadlineCompleted', current + 1);
  }

  /// Compute today's daily completion ratio from current tasks and
  /// add it as a weekly sample. We skip days with zero daily tasks
  /// to avoid penalizing the average when no dailies were configured.
  Future<void> recordTodayDailyRatioFromTasks() async {
    final tasks = await repository.getDailyTasks();
    final total = tasks.length;
    if (total == 0) return; // skip adding a sample for empty days
    final completed = tasks.where((t) => t.isDone).length;
    final ratio = total == 0 ? 0.0 : (completed / total);

    final prefs = await SharedPreferences.getInstance();
    final currentSum = prefs.getDouble('dailyWeekSum') ?? 0.0;
    final currentCount = prefs.getInt('dailyWeekCount') ?? 0;
    await prefs.setDouble('dailyWeekSum', currentSum + ratio);
    await prefs.setInt('dailyWeekCount', currentCount + 1);
  }

  Future<List<Prizes>> awardWeeklyPrizes() async {
    final prefs = await SharedPreferences.getInstance();
    bool alreadyGiven = prefs.getBool('weeklyRewardGiven') ?? false;
    if (alreadyGiven) return [];

    // Use weekly-averaged daily completion instead of last-day counters
    final dailyWeekSum = prefs.getDouble('dailyWeekSum') ?? 0.0;
    final dailyWeekCount = prefs.getInt('dailyWeekCount') ?? 0;
    final dailyAvg =
        dailyWeekCount == 0 ? 0.0 : (dailyWeekSum / dailyWeekCount);

    int weeklyTotal = 0;
    int weeklyCompleted = 0;
    try {
      final weeklyTasks = await repository.getWeeklyTasks();
      weeklyTotal = weeklyTasks.length;
      weeklyCompleted = weeklyTasks.where((task) => task.isDone).length;
      await prefs.setInt('weeklyTotal', weeklyTotal);
      await prefs.setInt('weeklyCompleted', weeklyCompleted);
    } catch (e) {
      weeklyTotal = prefs.getInt('weeklyTotal') ?? 0;
      weeklyCompleted = prefs.getInt('weeklyCompleted') ?? 0;
      debugPrint(
        'awardWeeklyPrizes using stored weekly counters due to error: $e',
      );
    }
    final questCount = prefs.getInt('questCompleted') ?? 0;
    final deadlineCount = prefs.getInt('deadlineCompleted') ?? 0;

    int prizesToGive = 0;
    final awarded = <Prizes>[];

    if (dailyAvg >= 0.75) prizesToGive++;
    if (weeklyTotal > 0 && (weeklyCompleted / weeklyTotal) >= 0.75) {
      prizesToGive++;
    }
    prizesToGive += questCount + deadlineCount;

    // Debug: log calculation (temporary)

    debugPrint(
      '[PrizeManager] dailyAvg: ${dailyAvg.toStringAsFixed(2)} (sum=$dailyWeekSum, n=$dailyWeekCount), weekly: '
      '$weeklyCompleted/$weeklyTotal, quest: $questCount, deadline: $deadlineCount, '
      'prizesToGive: $prizesToGive',
    );

    final random = Random();
    for (int i = 0; i < prizesToGive; i++) {
      final prize = availablePrizes[random.nextInt(availablePrizes.length)];
      await repository.addPrize(prize.prizeId, prize.prizeUrl);
      awarded.add(prize);
    }

    await prefs.setBool('weeklyRewardGiven', true);
    return awarded;
  }
}
