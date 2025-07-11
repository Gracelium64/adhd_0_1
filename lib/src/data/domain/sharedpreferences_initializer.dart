import 'dart:convert';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';

class SharedPreferencesInitializer {
  static Future<void> initializeDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('dailyTasks')) {
      final dailyTasks = List.generate(2, (i) {
        return Task(
          {i + 1}.toString(),
          'Daily',
          'Daily ${i + 1}',
          null,
          null,
          null,
          false,
        );
      });
      await prefs.setStringList(
        'dailyTasks',
        dailyTasks.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }

    if (!prefs.containsKey('weeklyTasks')) {
      final weeklyTasks = List.generate(2, (i) {
        return Task(
          {i + 1}.toString(),
          'Weekly',
          'Weekly ${i + 1}',
          null,
          null,
          '',
          false,
        );
      });
      await prefs.setStringList(
        'weeklyTasks',
        weeklyTasks.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }

    if (!prefs.containsKey('deadlineTasks')) {
      final deadlineTasks = List.generate(2, (i) {
        return Task(
          {i + 1}.toString(),
          'Deadline',
          'Deadline ${i + 1}',
          '30/8/25',
          '16:45',
          null,
          false,
        );
      });
      await prefs.setStringList(
        'deadlineTasks',
        deadlineTasks.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }

    if (!prefs.containsKey('questTasks')) {
      final questTasks = List.generate(2, (i) {
        return Task(
          {i + 1}.toString(),
          'Quest',
          'Weekly ${i + 1}',
          null,
          null,
          '',
          false,
        );
      });
      await prefs.setStringList(
        'questTasks',
        questTasks.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }

    if (!prefs.containsKey('prizesWon')) {
      final prizes = List.generate(
        2,
        (i) => Prizes(
          prizeId: 17 + i,
          prizeUrl: 'assets/img/prizes/Sticker${15 + i}.png',
        ),
      );
      await prefs.setStringList(
        'prizesWon',
        prizes.map((p) => jsonEncode(p.toJson())).toList(),
      );
    }

    if (!prefs.containsKey('userSettings')) {
      final settings = Settings(
        appSkinColor: true,
        language: 'English',
        location: 'Berlin',
        startOfDay: TimeOfDay(hour: 8, minute: 0),
        startOfWeek: Weekday.mon,
      );
      await prefs.setString('userSettings', jsonEncode(settings.toJson()));
    }
  }
}
