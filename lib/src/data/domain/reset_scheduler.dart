import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/prize_manager.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/domain/progress_triggers.dart';
import 'package:adhd_0_1/src/common/domain/app_clock.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetScheduler {
  final DataBaseRepository repository;
  final PrizeManager prizeManager;
  final OverlayPortalController? controller;
  final List<Prizes> awardedPrizesHolder;
  final DateTime Function() _now;

  ResetScheduler(
    this.repository, {
    required this.controller,
    required this.awardedPrizesHolder,
    DateTime Function()? now,
  }) : prizeManager = PrizeManager(repository),
       _now = now ?? AppClock.instance.now;

  DateTime getNow() => _now();

  Future<void> performResetsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final now = getNow();

    // === DAILY RESET ===
    final lastDailyReset = DateTime.tryParse(
      prefs.getString('lastDailyReset') ?? '',
    );
    if (lastDailyReset == null || !_isSameDay(lastDailyReset, now)) {
      debugPrint('🔄 Performing daily reset...');
      // Before clearing daily counters, record today's daily completion sample
      try {
        await prizeManager.recordTodayDailyRatioFromTasks();
      } catch (e) {
        debugPrint('Failed to record daily ratio sample: $e');
      }
      await _resetDailyTasks();
      // Refresh progress after reset
      await refreshDailyProgress(repository);
      await prizeManager.resetDailyCompletionCounters();
      await prefs.setString('lastDailyReset', now.toIso8601String());
    }

    // === WEEKLY RESET ===
    final lastWeeklyResetRaw = prefs.getString('lastWeeklyReset');
    final lastWeeklyReset = DateTime.tryParse(lastWeeklyResetRaw ?? '');
    final settings = await repository.getSettings();

    if (settings != null) {
      final startOfWeek = settings.startOfWeek;
      final nowWeekday = now.weekday;
      final targetWeekday = _weekdayToInt(startOfWeek);

      final isSameWeek =
          lastWeeklyReset != null &&
          _isSameIsoWeek(lastWeeklyReset, now, startOfWeek);

      final shouldReset = nowWeekday == targetWeekday && !isSameWeek;
      final isFirstWeek =
          lastWeeklyResetRaw == null &&
          !(prefs.getBool('firstWeekRewardGiven') ?? false);

      if (shouldReset || isFirstWeek) {
        debugPrint('🔁 Performing weekly reset...');
        final prizes = await prizeManager.awardWeeklyPrizes();
        awardedPrizesHolder.clear();
        awardedPrizesHolder.addAll(prizes);

        // Snapshot current week aggregates for the overlay before clearing
        try {
          final snapPrefs = await SharedPreferences.getInstance();
          final lastDailyWeekSum = snapPrefs.getDouble('dailyWeekSum') ?? 0.0;
          final lastDailyWeekCount = snapPrefs.getInt('dailyWeekCount') ?? 0;
          int lastWeeklyCompleted;
          int lastWeeklyTotal;
          try {
            final weeklyTasks = await repository.getWeeklyTasks();
            lastWeeklyTotal = weeklyTasks.length;
            lastWeeklyCompleted =
                weeklyTasks.where((task) => task.isDone).length;
          } catch (e) {
            lastWeeklyCompleted = snapPrefs.getInt('weeklyCompleted') ?? 0;
            lastWeeklyTotal = snapPrefs.getInt('weeklyTotal') ?? 0;
            debugPrint('Weekly snapshot fallback to stored counters: $e');
          }
          final lastQuestCompleted = snapPrefs.getInt('questCompleted') ?? 0;
          final lastDeadlineCompleted =
              snapPrefs.getInt('deadlineCompleted') ?? 0;

          await snapPrefs.setDouble('lastDailyWeekSum', lastDailyWeekSum);
          await snapPrefs.setInt('lastDailyWeekCount', lastDailyWeekCount);
          await snapPrefs.setInt('lastWeeklyCompleted', lastWeeklyCompleted);
          await snapPrefs.setInt('lastWeeklyTotal', lastWeeklyTotal);
          await snapPrefs.setInt('lastQuestCompleted', lastQuestCompleted);
          await snapPrefs.setInt(
            'lastDeadlineCompleted',
            lastDeadlineCompleted,
          );
        } catch (e) {
          debugPrint('Failed to snapshot weekly aggregates: $e');
        }

        await _resetWeeklyTasks();
        // Refresh progress after reset
        await refreshWeeklyProgress(repository);
        await prizeManager.resetWeeklyCounters();
        await prefs.setString('lastWeeklyReset', now.toIso8601String());

        if (isFirstWeek) {
          await prefs.setBool('firstWeekRewardGiven', true);
        }

        if (controller != null && prizes.isNotEmpty) {
          controller!.show();
        }
      }
    }
  }

  /// Debug-only: run the reset logic immediately using the injected clock
  /// and current preferences/settings.
  Future<void> performDebugResetsNow() async {
    await performResetsIfNeeded();
  }

  Future<void> _resetDailyTasks() async {
    final tasks = await repository.getDailyTasks();
    for (final task in tasks) {
      if (task.isDone) await repository.toggleDaily(task.taskId, false);
    }
  }

  Future<void> _resetWeeklyTasks() async {
    final tasks = await repository.getWeeklyTasks();
    for (final task in tasks) {
      if (task.isDone) await repository.toggleWeekly(task.taskId, false);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameIsoWeek(DateTime lastReset, DateTime now, Weekday startOfWeek) {
    final int lastOffset = (lastReset.weekday - _weekdayToInt(startOfWeek)) % 7;
    final int nowOffset = (now.weekday - _weekdayToInt(startOfWeek)) % 7;

    final startOfLastWeek = DateTime(
      lastReset.year,
      lastReset.month,
      lastReset.day - lastOffset,
    );
    final startOfCurrentWeek = DateTime(
      now.year,
      now.month,
      now.day - nowOffset,
    );

    return startOfLastWeek == startOfCurrentWeek;
  }

  int _weekdayToInt(Weekday day) {
    switch (day) {
      case Weekday.mon:
        return DateTime.monday;
      case Weekday.tue:
        return DateTime.tuesday;
      case Weekday.wed:
        return DateTime.wednesday;
      case Weekday.thu:
        return DateTime.thursday;
      case Weekday.fri:
        return DateTime.friday;
      case Weekday.sat:
        return DateTime.saturday;
      case Weekday.sun:
        return DateTime.sunday;
      case Weekday.any:
        return DateTime.monday; // fallback
    }
  }
}
