import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/prize_manager.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetScheduler {
  final DataBaseRepository repository;
  final PrizeManager prizeManager;
  final OverlayPortalController? controller;
  final List<Prizes> awardedPrizesHolder;

  ResetScheduler(
    this.repository, {
    required this.controller,
    required this.awardedPrizesHolder,
  }) : prizeManager = PrizeManager(repository);

  Future<void> performResetsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // === DAILY RESET ===
    final lastDailyReset = DateTime.tryParse(prefs.getString('lastDailyReset') ?? '');
    if (lastDailyReset == null || !_isSameDay(lastDailyReset, now)) {
      debugPrint('🔄 Performing daily reset...');
      await _resetDailyTasks();
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

      final isSameWeek = lastWeeklyReset != null &&
          _isSameIsoWeek(lastWeeklyReset, now, startOfWeek);

      final shouldReset = nowWeekday == targetWeekday && !isSameWeek;
      final isFirstWeek = lastWeeklyResetRaw == null && !(prefs.getBool('firstWeekRewardGiven') ?? false);

      if (shouldReset || isFirstWeek) {
        debugPrint('🔁 Performing weekly reset...');
        final prizes = await prizeManager.awardWeeklyPrizes();
        awardedPrizesHolder.clear();
        awardedPrizesHolder.addAll(prizes);

        await _resetWeeklyTasks();
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

    final startOfLastWeek = DateTime(lastReset.year, lastReset.month, lastReset.day - lastOffset);
    final startOfCurrentWeek = DateTime(now.year, now.month, now.day - nowOffset);

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