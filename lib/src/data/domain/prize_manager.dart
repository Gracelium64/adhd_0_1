import 'dart:math';
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
  }

  Future<void> trackDailyCompletion(bool isDone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyTotal', (prefs.getInt('dailyTotal') ?? 0) + 1);
    if (isDone) {
      await prefs.setInt(
        'dailyCompleted',
        prefs.getInt('dailyCompleted') ?? 0 + 1,
      );
    }
  }

  Future<void> trackWeeklyCompletion(bool isDone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weeklyTotal', prefs.getInt('weeklyTotal') ?? 0 + 1);
    if (isDone) {
      await prefs.setInt(
        'weeklyCompleted',
        prefs.getInt('weeklyCompleted') ?? 0 + 1,
      );
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

  Future<List<Prizes>> awardWeeklyPrizes() async {
    final prefs = await SharedPreferences.getInstance();
    bool alreadyGiven = prefs.getBool('weeklyRewardGiven') ?? false;
    if (alreadyGiven) return [];

    final dailyTotal = prefs.getInt('dailyTotal') ?? 1;
    final dailyCompleted = prefs.getInt('dailyCompleted') ?? 0;
    final weeklyTotal = prefs.getInt('weeklyTotal') ?? 1;
    final weeklyCompleted = prefs.getInt('weeklyCompleted') ?? 0;
    final questCount = prefs.getInt('questCompleted') ?? 0;
    final deadlineCount = prefs.getInt('deadlineCompleted') ?? 0;

    int prizesToGive = 0;
    final awarded = <Prizes>[];

    if ((dailyCompleted / dailyTotal) >= 0.75) prizesToGive++;
    if ((weeklyCompleted / weeklyTotal) >= 0.75) prizesToGive++;
    prizesToGive += questCount + deadlineCount;

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
