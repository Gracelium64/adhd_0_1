import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/prize_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test scenarios for in-app manual verification.
///
/// Usage: call from a screen (e.g., Settings) and pass the app repository,
/// the weekly summary overlay controller, and the prizes holder list used by
/// WeeklySummaryOverlay. This will seed SharedPreferences, compute prizes,
/// update the prizes list, and show the overlay.
class TestScenarios {
  /// Seeds this scenario and opens the weekly summary overlay:
  /// - 90% average daily completion across the week
  /// - 80% weekly tasks completion across the week
  /// - 2 deadline tasks completed
  /// - 3 quest tasks completed
  /// Expected prizes: 1 (daily >=75%) + 1 (weekly >=75%) + 2 + 3 = 7
  static Future<void> runWeeklyPrizeScenario({
    required DataBaseRepository repository,
    required OverlayPortalController controller,
    required List<Prizes> awardedPrizesHolder,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Reset reward flag so prizes can be awarded
    await prefs.setBool('weeklyRewardGiven', false);

    // Seed ratios: 90% daily, 80% weekly, 3 quests, 2 deadlines
    await prefs.setInt('dailyTotal', 100);
    await prefs.setInt('dailyCompleted', 90);
    await prefs.setInt('weeklyTotal', 100);
    await prefs.setInt('weeklyCompleted', 80);
    await prefs.setInt('questCompleted', 3);
    await prefs.setInt('deadlineCompleted', 2);

    // Optional: backdate lastWeeklyReset so ResetScheduler won't immediately block
    // But for this scenario we call awardWeeklyPrizes directly.

    final prizeManager = PrizeManager(repository);
    final prizes = await prizeManager.awardWeeklyPrizes();

    awardedPrizesHolder
      ..clear()
      ..addAll(prizes);

    // Show overlay if any prizes were awarded
    if (prizes.isNotEmpty) {
      controller.show();
    } else {
      // Ensure visibility for manual verification if nothing awarded
      controller.show();
    }
  }
}
