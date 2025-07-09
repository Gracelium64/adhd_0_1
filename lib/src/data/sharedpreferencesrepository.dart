import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/features/task_management/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prizes.dart';
import 'package:adhd_0_1/src/features/settings/domain/settings.dart';
import 'package:adhd_0_1/src/data/domain/prefs_keys.dart';


class SharedPreferencesRepository implements DataBaseRepository {
  int taskIdCounter = 0;

  Future<List<Task>> _loadTasks(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];
    return data.map((e) => Task.fromJson(jsonDecode(e))).toList();
  }

  Future<void> _saveTasks(String key, List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }

  @override
  Future<void> addDaily(String data) async {
    final list = await _loadTasks(PrefsKeys.dailyKey);
    list.add(Task(taskIdCounter++, 'Daily', data, null, null, null, false));
    await _saveTasks(PrefsKeys.dailyKey, list);
  }

  @override
  Future<void> addWeekly(String data, day) async {
    final list = await _loadTasks(PrefsKeys.weeklyKey);
    list.add(
      Task(taskIdCounter++, 'Weekly', data, null, null, day.label, false),
    );
    await _saveTasks(PrefsKeys.weeklyKey, list);
  }

  @override
  Future<void> addDeadline(String data, date, time) async {
    final list = await _loadTasks(PrefsKeys.deadlineKey);
    list.add(Task(taskIdCounter++, 'Deadline', data, date, time, null, false));
    await _saveTasks(PrefsKeys.deadlineKey, list);
  }

  @override
  Future<void> addQuest(String data) async {
    final list = await _loadTasks(PrefsKeys.questKey);
    list.add(Task(taskIdCounter++, 'Quest', data, null, null, null, false));
    await _saveTasks(PrefsKeys.questKey, list);
  }

  Future<void> _markComplete(
    String key,
    int taskId, {
    bool remove = false,
  }) async {
    final list = await _loadTasks(key);
    final index = list.indexWhere((t) => t.taskId == taskId);
    if (index != -1) {
      list[index].isDone = true;
      if (remove) list.removeAt(index);
      await _saveTasks(key, list);
    }
  }

  // @override
  // Future<void> completeDaily(int dataTaskId) async =>
  //     _markComplete(PrefsKeys.dailyKey, dataTaskId);

  // @override
  // Future<void> completeWeekly(int dataTaskId) async =>
  //     _markComplete(PrefsKeys.weeklyKey, dataTaskId);

  @override
  Future<void> completeDeadline(int dataTaskId) async =>
      _markComplete(PrefsKeys.deadlineKey, dataTaskId, remove: true);

  @override
  Future<void> completeQuest(int dataTaskId) async =>
      _markComplete(PrefsKeys.questKey, dataTaskId, remove: true);

  Future<void> _delete(String key, int taskId) async {
    final list = await _loadTasks(key);
    list.removeWhere((t) => t.taskId == taskId);
    await _saveTasks(key, list);
  }

  @override
  Future<void> deleteDaily(int dataTaskId) async =>
      _delete(PrefsKeys.dailyKey, dataTaskId);

  @override
  Future<void> deleteWeekly(int dataTaskId) async =>
      _delete(PrefsKeys.weeklyKey, dataTaskId);

  @override
  Future<void> deleteDeadline(int dataTaskId) async =>
      _delete(PrefsKeys.deadlineKey, dataTaskId);

  @override
  Future<void> deleteQuest(int dataTaskId) async =>
      _delete(PrefsKeys.questKey, dataTaskId);

  Future<void> _edit(String key, int taskId, void Function(Task) modify) async {
    final list = await _loadTasks(key);
    final index = list.indexWhere((t) => t.taskId == taskId);
    if (index != -1) {
      modify(list[index]);
      await _saveTasks(key, list);
    }
  }

  @override
  Future<void> editDaily(int taskId, String data) async =>
      _edit(PrefsKeys.dailyKey, taskId, (t) => t.taskDesctiption = data);

  @override
  Future<void> editWeekly(int taskId, String data, day) async =>
      _edit(PrefsKeys.weeklyKey, taskId, (t) {
        t.taskDesctiption = data;
        t.dayOfWeek = day.label;
      });

  @override
  Future<void> editDeadline(int taskId, String data, date, time) async =>
      _edit(PrefsKeys.deadlineKey, taskId, (t) {
        t.taskDesctiption = data;
        t.deadlineDate = date;
        t.deadlineTime = time;
      });

  @override
  Future<void> editQuest(int taskId, String data) async =>
      _edit(PrefsKeys.questKey, taskId, (t) => t.taskDesctiption = data);

  @override
  Future<List<Task>> getDailyTasks() => _loadTasks(PrefsKeys.dailyKey);

  @override
  Future<List<Task>> getWeeklyTasks() => _loadTasks(PrefsKeys.weeklyKey);

  @override
  Future<List<Task>> getDeadlineTasks() => _loadTasks(PrefsKeys.deadlineKey);

  @override
  Future<List<Task>> getQuestTasks() => _loadTasks(PrefsKeys.questKey);

  @override
  Future<void> addPrize(int prizeId, String prizeUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(PrefsKeys.prizesKey) ?? [];
    list.add(jsonEncode({'prizeId': prizeId, 'prizeUrl': prizeUrl}));
    await prefs.setStringList(PrefsKeys.prizesKey, list);
  }

  @override
  Future<List<Prizes>> getPrizes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(PrefsKeys.prizesKey) ?? [];
    return list.map((e) {
      final p = jsonDecode(e);
      return Prizes(prizeId: p['prizeId'], prizeUrl: p['prizeUrl']);
    }).toList();
  }

  @override
  Future<Settings> setSettings(
    bool? dataAppSkinColor,
    String dataLanguage,
    String dataLocation,
    TimeOfDay dataStartOfDay,
    Weekday dataStartOfWeek,
  ) async {
    final settings = Settings(
      appSkinColor: dataAppSkinColor,
      language: dataLanguage,
      location: dataLocation,
      startOfDay: dataStartOfDay,
      startOfWeek: dataStartOfWeek,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.settingsKey, jsonEncode(settings.toJson()));
    return settings;
  }

  @override
  Future<Settings?> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(PrefsKeys.settingsKey);
    if (str == null) return null;
    return Settings.fromJson(jsonDecode(str));
  }

  @override
  Future<void> setAppUser(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.appUserKey, data);
  }

  @override
  Future<String?> getAppUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefsKeys.appUserKey);
  }

  @override
  Future<void> toggleDaily(int dataTaskId, bool dataIsDone) async {
    final tasks = await _loadTasks(PrefsKeys.dailyKey);
    final index = tasks.indexWhere((t) {
      return t.taskId == dataTaskId;
    });
    if (index != -1) {
      tasks[index].isDone = dataIsDone;
      await _saveTasks(PrefsKeys.dailyKey, tasks);
    }
  }

  @override
  Future<void> toggleWeekly(int dataTaskId, bool dataIsDone) async {
    final tasks = await _loadTasks(PrefsKeys.weeklyKey);
    final index = tasks.indexWhere((t) {
      return t.taskId == dataTaskId;
    });
    if (index != -1) {
      tasks[index].isDone = dataIsDone;
      await _saveTasks(PrefsKeys.weeklyKey, tasks);
    }
  }
}



//                                               ▒███████
//           ██                                 ████     ██▒
//         ▒█▒ ██▒                           ████   █████ ██▒
//         ██    ███▓                      ███   ████████  ██
//       ▓██   ▓  ███                   ███▓  ███████████ ██░
//       ███    ▓▓  ███                ███  ▓███      ███ ██
//       ▓█▒     ▓▓▓  ▒██            ███  ▒▒██     ░░  ██ ██
//       ██  ░    ▓▓▓▓  ███         ░██  ▓░██     ░    ██ ██░
//       ██  ░     ▒▒▒▓▓  ██       ███ ░▓░██    ▒░    ░█  ██ 
//       ░██  ░      ░▒▒▓▓  ██     ░██  ▓▒░█           ██ ▒█▒
//       ░██          ▓▒░▒▓  ██    ███ ▓▒░██    ░      ██ ██ 
//       ██  ░       ▒▓▓▓▓▓  ██  ▓██  ▓░░█           ██  █▓
//       ██  ░           ▒▓▓ ██████░ ▓▒░▒█          ▓██ ██░
//       ███ ░       ░            █  ▓▒░█          ░██ ▒█░
//       ▓██            ▒            ▒▒░█         ▓██  █░
//       ▒██  ▒▒    ▓▓▓▓▓         ░▓▓▒░▓█    ░   ███  █▓
//         ██  ▒   ▓▓▓▒▒       █▓  ▓▒▒▒░█       ████  █▒
//           ██   ▓▓▒▒▒▒▒ ▒   ███  ▓▒░░░░▒▓    ░███  ██
//           ███  ▒▓▒▒    ▓  █████ ▓▒░░░░░░▒▓ ▒▓██   ██
//           ▓██  ▒▓▓▓▓▓▓▓  ███████▓░▒▓▓▒░░░░▒▓▓▓  ░██
//           ███  ░       ▓▓█████████▒   ▒░░░░░▒▒ ███
//         ░██  ░▓▓█  █   ██████████▒▓▓▓▓▓▓▓▒▒░▓  █▓
//         ███  ▓▓▒░█       ██████████       ░▓░▒░ ██
//       ▓███  ▓▓▒░░▓       █████████    ██    ▒░▓ ░█▒
//   ▒██████     ░▓█████▓▓ ▓███████         █ ▓░░▓░ ██                              
// ░████████  ███▓▓   █████  ▓ ░███░     ██▓▒░░▒░▓  █▒                             
//       ██  ▓█████▒ ░ ███░    ▒██████▓▓▒░░░░▒▓▓▓▓  █                             
//     █████     ██████░ ███ █████    ░░░███▓▒       ██                            
//   ███░  ███▒  █▓█████        ░███▒   ██▓   █▓▒   ░█
//   █░ ██▒  ███    ▒█████████▓█████████   █████   ██░
//     ▒▒   ███           ██████████████████▓     █░██
//       ▓██▒      ░▒░                          ██░░
//       ███       ░   ░████████▓░       ░▒▓▓▒▒   ██
//     ██▒     ▓▓██████████████████████████████▓  ██
//     ██▓     ▒▓░ █████████████████████████████▒   ██░
//   ▒██ ░▓   ▒▓▒▓░ ░███████████████████████████▒    █▓
//   ▓█  ▓▓    ▓░░ ██████████████████████████▓▒░▓  ▓  █▒
//   ██ ▓▓██   ▓▒░░░░▒  █████████████████████▓░▒▓ ▒▓▒ ██
// ▒██ █████  ▓▓░░░░░▒▒█░ ████████████████░ ░░▓  ███  █▒
//   ██ ░▓▒██▒  ▓▒░░░▒  ░▒▒█▓ ██████▓██▓██░▒░░▒▓  ███  █▒
//   ▓█  ▓▒▓▒ ▒  ▓▒░░░▒░   ░░  ██  ▒░▓▒    ░░▒▓  ████  █▒
//   ▒██  █░  ▒█  ▓▒░░▒▒▒    ▒    ░▒     ▒▒▒▒▓  ▒░███ ░█▒
//   ▓██    ░     ▓▓▒▒░▒▒▒  █░   █   ▒▓▓▒▒▒▒   ▓ ▒█  ██
//     ██       ▒    ▓▓▓░░░▒▒  █████ ░▓▒▒▓▓▓▓         ██
//     ░██     ▓▓ ▓▓    ▓███▓         ░▓       ▓▓   ███
//       ████        ██  ██ ██▒ ███ ██▓ ██ ██      ██░
//         ░▓███████   ▒ ██▒    ███  █ ███    █████▒
//                 █████     ████░███     █████
//                 ░  ▒█████▓      
