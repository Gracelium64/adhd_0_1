import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/prize_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manual scenario for verifying weekly prize awarding and summary overlay.
///
/// Usage: call from a screen (e.g., Settings) and pass the app repository,
/// the weekly summary overlay controller, and the prizes holder list used by
/// WeeklySummaryOverlay. This will seed SharedPreferences, compute prizes,
/// update the prizes list, and show the overlay.
class ManualWeeklyPrizeScenario {
  /// Seeds this scenario and opens the weekly summary overlay using the
  /// new weekly-averaged daily completion logic.
  /// Expected prizes (with matching task data):
  /// 1 (dailyAvg >=75%) + 1 (weekly >=75%) + quest + deadline
  /// Ensure the repository already contains weekly tasks with the
  /// desired completion ratio before running this helper, as the
  /// prize logic now reads live task data instead of seeded counters.
  static Future<void> run({
    required DataBaseRepository repository,
    required OverlayPortalController controller,
    required List<Prizes> awardedPrizesHolder,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Reset reward flag so prizes can be awarded
    await prefs.setBool('weeklyRewardGiven', false);

    // Seed weekly average: 90% average daily completion over 5 days
    await prefs.setDouble('dailyWeekSum', 0.9 * 5);
    await prefs.setInt('dailyWeekCount', 5);

    // Seed weekly completion: 80%
    await prefs.setInt('weeklyTotal', 100);
    await prefs.setInt('weeklyCompleted', 80);

    // Seed quest/deadline counts
    await prefs.setInt('questCompleted', 3);
    await prefs.setInt('deadlineCompleted', 2);

    final prizeManager = PrizeManager(repository);
    final prizes = await prizeManager.awardWeeklyPrizes();

    awardedPrizesHolder
      ..clear()
      ..addAll(prizes);

    // Show overlay for visual verification
    controller.show();
  }
}
