import 'dart:convert';
import 'package:adhd_0_1/src/common/domain/app_user.dart';
import 'package:adhd_0_1/src/data/domain/functions.dart';
// Prize side-effects are handled by higher-level coordinator (SyncRepository).
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';
import 'package:adhd_0_1/src/data/domain/prefs_keys.dart';

class SharedPreferencesRepository implements DataBaseRepository {
  int taskIdCounter = 1;

  // Persisted local counter to generate IDs like "<counter><userId>"
  static const _localCounterKey = 'local_task_id_counter_v1';

  Future<int> _nextLocalCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_localCounterKey) ?? 0;
    final next = current + 1;
    await prefs.setInt(_localCounterKey, next);
    return next;
  }

  Future<String> _newLocalTaskId(String userId) async {
    final n = await _nextLocalCounter();
    return '$n$userId';
  }

  Future<List<Task>> _loadTasks(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];
    final list = data.map((e) => Task.fromJson(jsonDecode(e))).toList();
    // Sort by orderIndex when present to respect saved custom order
    final hasAnyOrder = list.any((t) => t.orderIndex != null);
    if (hasAnyOrder) {
      list.sort((a, b) {
        final ai = a.orderIndex ?? 1 << 30;
        final bi = b.orderIndex ?? 1 << 30;
        return ai.compareTo(bi);
      });
    }
    return list;
  }

  Future<void> _saveTasks(String key, List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }

  // ——— Hydration helpers (used by SyncRepository on user switch) ———
  Future<void> setDailyTasks(List<Task> tasks) async =>
      _saveTasks(PrefsKeys.dailyKey, tasks);

  Future<void> setWeeklyTasks(List<Task> tasks) async =>
      _saveTasks(PrefsKeys.weeklyKey, tasks);

  Future<void> setDeadlineTasks(List<Task> tasks) async =>
      _saveTasks(PrefsKeys.deadlineKey, tasks);

  Future<void> setQuestTasks(List<Task> tasks) async =>
      _saveTasks(PrefsKeys.questKey, tasks);

  Future<void> replacePrizes(List<Prizes> prizes) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prizes.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(PrefsKeys.prizesKey, list);
  }

  Future<void> setSettingsLocal(Settings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      PrefsKeys.settingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  Future<void> setLocalTaskCounterAbsolute(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_localCounterKey, value);
  }

  Future<void> _saveOrder(
    String key,
    List<String> orderedTaskIds, {
    bool weeklyAnyOnly = false,
  }) async {
    final list = await _loadTasks(key);
    // Build map of indices
    final idToIndex = <String, int>{};
    for (int i = 0; i < orderedTaskIds.length; i++) {
      idToIndex[orderedTaskIds[i]] = i;
    }
    for (final t in list) {
      if (weeklyAnyOnly) {
        final isAny =
            (t.dayOfWeek == null) || (t.dayOfWeek!.toLowerCase() == 'any');
        if (!isAny) continue;
      }
      t.orderIndex = idToIndex[t.taskId];
    }
    await _saveTasks(key, list);
  }

  @override
  Future<void> addDaily(String data) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final list = await _loadTasks(PrefsKeys.dailyKey);
    final newId = await _newLocalTaskId(userId);
    list.add(
      Task(
        newId,
        'Daily',
        data,
        null,
        null,
        null,
        false,
        orderIndex: list.length,
      ),
    );
    await _saveTasks(PrefsKeys.dailyKey, list);
  }

  @override
  Future<void> addWeekly(String data, day) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final list = await _loadTasks(PrefsKeys.weeklyKey);

    // Normalize to enum name (e.g., 'mon', 'tue')
    final String dayName =
        (day is Weekday)
            ? day.name
            : day.toString().split('.').last.toLowerCase();

    final newId = await _newLocalTaskId(userId);
    list.add(
      Task(
        newId,
        'Weekly',
        data,
        null,
        null,
        dayName,
        false,
        // only 'any' will be reorderable, but keep a stable default
        orderIndex:
            (dayName == 'any')
                ? list
                    .where(
                      (t) =>
                          (t.dayOfWeek == null) ||
                          (t.dayOfWeek!.toLowerCase() == 'any'),
                    )
                    .length
                : null,
      ),
    );
    await _saveTasks(PrefsKeys.weeklyKey, list);
  }

  @override
  Future<void> addDeadline(String data, date, time) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final list = await _loadTasks(PrefsKeys.deadlineKey);
    final newId = await _newLocalTaskId(userId);
    list.add(
      Task(
        newId,
        'Deadline',
        data,
        date,
        time,
        null,
        false,
      ),
    );
    await _saveTasks(PrefsKeys.deadlineKey, list);
  }

  @override
  Future<void> addQuest(String data) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final list = await _loadTasks(PrefsKeys.questKey);
    final newId = await _newLocalTaskId(userId);
    list.add(
      Task(
        newId,
        'Quest',
        data,
        null,
        null,
        null,
        false,
        orderIndex: list.length,
      ),
    );
    await _saveTasks(PrefsKeys.questKey, list);
  }

  Future<void> _markComplete(
    String key,
    String taskId, {
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
  // Future<void> completeDaily(String dataTaskId) async =>
  //     _markComplete(PrefsKeys.dailyKey, dataTaskId);

  // @override
  // Future<void> completeWeekly(String dataTaskId) async =>
  //     _markComplete(PrefsKeys.weeklyKey, dataTaskId);

  @override
  Future<void> completeDeadline(String dataTaskId) async =>
      _markComplete(PrefsKeys.deadlineKey, dataTaskId, remove: true);

  @override
  Future<void> completeQuest(String dataTaskId) async =>
      _markComplete(PrefsKeys.questKey, dataTaskId, remove: true);

  Future<void> _delete(String key, String taskId) async {
    final list = await _loadTasks(key);
    list.removeWhere((t) => t.taskId == taskId);
    await _saveTasks(key, list);
  }

  @override
  Future<void> deleteDaily(String dataTaskId) async =>
      _delete(PrefsKeys.dailyKey, dataTaskId);

  @override
  Future<void> deleteWeekly(String dataTaskId) async =>
      _delete(PrefsKeys.weeklyKey, dataTaskId);

  @override
  Future<void> deleteDeadline(String dataTaskId) async =>
      _delete(PrefsKeys.deadlineKey, dataTaskId);

  @override
  Future<void> deleteQuest(String dataTaskId) async =>
      _delete(PrefsKeys.questKey, dataTaskId);

  Future<void> _edit(
    String key,
    String taskId,
    void Function(Task) modify,
  ) async {
    final list = await _loadTasks(key);
    final index = list.indexWhere((t) => t.taskId == taskId);
    if (index != -1) {
      modify(list[index]);
      await _saveTasks(key, list);
    }
  }

  @override
  Future<void> editDaily(String taskId, String data) async {
    return _edit(PrefsKeys.dailyKey, taskId, (t) => t.taskDesctiption = data);
  }

  @override
  Future<void> editWeekly(String taskId, String data, day) async =>
      _edit(PrefsKeys.weeklyKey, taskId, (t) {
        t.taskDesctiption = data;
        t.dayOfWeek = day.name; // normalize to enum name
      });

  @override
  Future<void> editDeadline(String taskId, String data, date, time) async =>
      _edit(PrefsKeys.deadlineKey, taskId, (t) {
        t.taskDesctiption = data;
        t.deadlineDate = date;
        t.deadlineTime = time;
      });

  @override
  Future<void> editQuest(String taskId, String data) async =>
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
  Future<void> saveDailyOrder(List<String> orderedTaskIds) async {
    await _saveOrder(PrefsKeys.dailyKey, orderedTaskIds);
  }

  @override
  Future<void> saveQuestOrder(List<String> orderedTaskIds) async {
    await _saveOrder(PrefsKeys.questKey, orderedTaskIds);
  }

  @override
  Future<void> saveWeeklyAnyOrder(List<String> orderedTaskIds) async {
    await _saveOrder(PrefsKeys.weeklyKey, orderedTaskIds, weeklyAnyOnly: true);
  }

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
  Future<void> setAppUser(
    String userId,
    userName,
    email,
    password,
    bool isPowerUser,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      PrefsKeys.appUserKey,
      jsonEncode(
        AppUser(
          userId: userId,
          userName: userName,
          email: email,
          password: password,
          isPowerUser: isPowerUser,
        ).toJson(),
      ),
    );
  }

  @override
  Future<AppUser?> getAppUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(PrefsKeys.appUserKey);
    if (str == null) return null;
    return AppUser.fromJson(jsonDecode(str));
  }

  @override
  Future<void> toggleDaily(String dataTaskId, bool dataIsDone) async {
    final tasks = await _loadTasks(PrefsKeys.dailyKey);
    final index = tasks.indexWhere((t) {
      return t.taskId == dataTaskId;
    });
    if (index != -1) {
      tasks[index].isDone = dataIsDone;
      await _saveTasks(PrefsKeys.dailyKey, tasks);
    }

    // Side-effects handled by SyncRepository
  }

  @override
  Future<void> toggleWeekly(String dataTaskId, bool dataIsDone) async {
    final tasks = await _loadTasks(PrefsKeys.weeklyKey);
    final index = tasks.indexWhere((t) {
      return t.taskId == dataTaskId;
    });
    if (index != -1) {
      tasks[index].isDone = dataIsDone;
      await _saveTasks(PrefsKeys.weeklyKey, tasks);
    }

    // Side-effects handled by SyncRepository
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
