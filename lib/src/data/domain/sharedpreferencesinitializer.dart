import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prizes.dart';
import 'package:adhd_0_1/src/features/settings/domain/settings.dart';

class SharedPreferencesInitializer {
  static Future<void> initializeDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('dailyTasks')) {
      final dailyTasks = List.generate(
        11,
        (i) => Task(i + 1, 'Daily', 'Daily ${i + 1}', null, null, null, false),
      );
      await prefs.setStringList(
        'dailyTasks',
        dailyTasks.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }

    if (!prefs.containsKey('weeklyTasks')) {
      final weeklyTasks = [
        Task(12, 'Weekly', 'Weekly 1', null, null, 'Mon', false),
        Task(13, 'Weekly', 'Weekly 2', null, null, 'Mon', true),
        Task(14, 'Weekly', 'Weekly 3', null, null, '', false),
        Task(15, 'Weekly', 'Weekly 4', null, null, '', false),
        Task(16, 'Weekly', 'Weekly 5', null, null, '', false),
        Task(17, 'Weekly', 'Weekly 6', null, null, 'Thu', false),
        Task(18, 'Weekly', 'Weekly 7', null, null, 'Fri', false),
        Task(19, 'Weekly', 'Weekly 8', null, null, '', false),
      ];
      await prefs.setStringList(
        'weeklyTasks',
        weeklyTasks.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }

    if (!prefs.containsKey('deadlineTasks')) {
      final deadlineTasks = [
        Task(20, 'Deadline', 'Overlays', '18/05/25', '16:15', null, false),
        Task(21, 'Deadline', 'Theming', '18/05/25', '16:15', null, false),
        Task(
          22,
          'Deadline',
          'ListView.builder',
          '18/05/25',
          '16:15',
          null,
          false,
        ),
        Task(
          23,
          'Deadline',
          'Add Task Button functionality',
          '18/05/25',
          '16:15',
          null,
          false,
        ),
        Task(
          24,
          'Deadline',
          'NavigationBar Highlight',
          '18/05/25',
          '16:15',
          null,
          false,
        ),
        Task(
          25,
          'Deadline',
          'setLimit of 36 characters for task',
          '18/05/25',
          '16:15',
          null,
          false,
        ),
      ];
      await prefs.setStringList(
        'deadlineTasks',
        deadlineTasks.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }

    if (!prefs.containsKey('questTasks')) {
      final questTasks = [
        Task(26, 'Quest', 'Quest 1', null, null, null, false),
        Task(27, 'Quest', 'Quest 2', null, null, null, false),
        Task(28, 'Quest', 'Quest 3', null, null, null, false),
        Task(29, 'Quest', 'Quest 4', null, null, null, false),
        Task(30, 'Quest', 'Quest 5', null, null, null, false),
      ];
      await prefs.setStringList(
        'questTasks',
        questTasks.map((t) => jsonEncode(t.toJson())).toList(),
      );
    }

    if (!prefs.containsKey('prizesWon')) {
      final prizes = List.generate(
        19,
        (i) => Prizes(
          prizeId: 15 + i,
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
        startOfDay: 715,
        startOfWeek: 2,
      );
      await prefs.setString('userSettings', jsonEncode(settings.toJson()));
    }
  }
}
