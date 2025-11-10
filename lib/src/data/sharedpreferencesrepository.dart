import 'dart:async';
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
  static const _subTaskCounterKey = 'local_sub_task_id_counter_v1';

  Future<int> _nextLocalCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_localCounterKey) ?? 0;
    final next = current + 1;
    await prefs.setInt(_localCounterKey, next);
    return next;
  }

  Future<int> _nextSubTaskCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_subTaskCounterKey) ?? 0;
    final next = current + 1;
    await prefs.setInt(_subTaskCounterKey, next);
    return next;
  }

  Future<String> _newLocalTaskId(String userId) async {
    final n = await _nextLocalCounter();
    return '$n$userId';
  }

  Future<String> _newLocalSubTaskId(String taskId) async {
    final n = await _nextSubTaskCounter();
    return 'st${n}_$taskId';
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

  Task _duplicateTask(Task task) => Task.fromJson(task.toJson());
  SubTask _duplicateSubTask(SubTask subTask) => SubTask(
    subTaskId: subTask.subTaskId,
    description: subTask.description,
    isDone: subTask.isDone,
    orderIndex: subTask.orderIndex,
  );

  String? _prefsKeyForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'daily':
        return PrefsKeys.dailyKey;
      case 'weekly':
        return PrefsKeys.weeklyKey;
      case 'deadline':
        return PrefsKeys.deadlineKey;
      case 'quest':
        return PrefsKeys.questKey;
    }
    return null;
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
    if (index == -1) return;
    final task = list[index];
    final hasIncomplete =
        task.subTasks.isNotEmpty && task.subTasks.any((s) => !s.isDone);
    if (hasIncomplete) {
      throw StateError('Cannot complete task with incomplete subtasks');
    }
    task.isDone = true;
    if (remove) list.removeAt(index);
    await _saveTasks(key, list);
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
    if (str == null || str.isEmpty) return null;
    try {
      return Settings.fromJson(jsonDecode(str));
    } catch (e, stack) {
      debugPrint('⚠️ Failed to decode local settings; resetting defaults: $e');
      debugPrint(stack.toString());
      Map<String, dynamic>? raw;
      try {
        final dynamic decoded = jsonDecode(str);
        if (decoded is Map<String, dynamic>) raw = decoded;
      } catch (_) {}

      bool? rawSkin;
      if (raw != null && raw['appSkinColor'] is bool) {
        rawSkin = raw['appSkinColor'] as bool;
      }

      String rawLanguage = 'English';
      if (raw != null && raw['language'] is String) {
        rawLanguage = raw['language'] as String;
      }

      String rawLocation = 'Berlin';
      if (raw != null && raw['location'] is String) {
        rawLocation = raw['location'] as String;
      }

      String? rawStartOfWeekName;
      if (raw != null && raw['startOfWeek'] is String) {
        rawStartOfWeekName = raw['startOfWeek'] as String;
      }
      final Weekday rawStartOfWeek =
          rawStartOfWeekName != null
              ? Weekday.values.firstWhere(
                (w) => w.name == rawStartOfWeekName,
                orElse: () => Weekday.mon,
              )
              : Weekday.mon;

      final fallback = Settings(
        appSkinColor: rawSkin,
        language: rawLanguage,
        location: rawLocation,
        startOfDay: const TimeOfDay(hour: 7, minute: 15),
        startOfWeek: rawStartOfWeek,
      );

      await prefs.setString(
        PrefsKeys.settingsKey,
        jsonEncode(fallback.toJson()),
      );
      return fallback;
    }
  }

  @override
  Future<void> setAppUser(
    String userId,
    String userName,
    String email,
    String password,
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

  Future<Task> _mutateTask(
    Task parentTask,
    Future<void> Function(Task task) mutate,
  ) async {
    final key = _prefsKeyForCategory(parentTask.taskCatagory);
    if (key == null) {
      throw UnsupportedError(
        'Unsupported task category ${parentTask.taskCatagory}',
      );
    }
    final tasks = await _loadTasks(key);
    final index = tasks.indexWhere((t) => t.taskId == parentTask.taskId);
    if (index == -1) {
      throw StateError('Task ${parentTask.taskId} not found locally');
    }
    final task = tasks[index];
    await mutate(task);
    await _saveTasks(key, tasks);
    return _duplicateTask(task);
  }

  @override
  Future<Task> addSubTask(Task parentTask, String description) async {
    return _mutateTask(parentTask, (task) async {
      final id = await _newLocalSubTaskId(task.taskId);
      final nextOrder = task.subTasks.length;
      task.subTasks.add(
        SubTask(
          subTaskId: id,
          description: description,
          isDone: false,
          orderIndex: nextOrder,
        ),
      );
      task.isDone = false;
    });
  }

  @override
  Future<Task> editSubTask(
    Task parentTask,
    String subTaskId,
    String description,
  ) async {
    return _mutateTask(parentTask, (task) async {
      final index = task.subTasks.indexWhere(
        (subTask) => subTask.subTaskId == subTaskId,
      );
      if (index == -1) {
        throw StateError(
          'Subtask $subTaskId not found for task ${task.taskId}',
        );
      }
      task.subTasks[index].description = description;
    });
  }

  @override
  Future<Task> toggleSubTask(
    Task parentTask,
    String subTaskId,
    bool isDone,
  ) async {
    return _mutateTask(parentTask, (task) async {
      final index = task.subTasks.indexWhere(
        (subTask) => subTask.subTaskId == subTaskId,
      );
      if (index == -1) {
        throw StateError(
          'Subtask $subTaskId not found for task ${task.taskId}',
        );
      }
      task.subTasks[index].isDone = isDone;
      if (!isDone) {
        task.isDone = false;
        return;
      }
      final allDone =
          task.subTasks.isNotEmpty && task.subTasks.every((s) => s.isDone);
      if (allDone) {
        task.isDone = true;
      }
    });
  }

  @override
  Future<Task> deleteSubTask(Task parentTask, String subTaskId) async {
    return _mutateTask(parentTask, (task) async {
      task.subTasks.removeWhere((subTask) => subTask.subTaskId == subTaskId);
      for (int i = 0; i < task.subTasks.length; i++) {
        task.subTasks[i].orderIndex = i;
      }
      if (task.subTasks.isEmpty) {
        return;
      }
      final allDone = task.subTasks.every((s) => s.isDone);
      task.isDone = allDone;
    });
  }

  int? _defaultOrderIndexForCategory(String category, List<Task> tasks) {
    switch (category.toLowerCase()) {
      case 'daily':
      case 'quest':
        return tasks.length;
      case 'weekly':
        final anyCount =
            tasks.where((task) {
              final day = task.dayOfWeek?.toLowerCase();
              return day == null || day == 'any';
            }).length;
        return anyCount;
      default:
        return null;
    }
  }

  @override
  Future<Task> replaceTask(Task originalTask, Task replacement) async {
    final sourceKey = _prefsKeyForCategory(originalTask.taskCatagory);
    final targetKey = _prefsKeyForCategory(replacement.taskCatagory);

    if (sourceKey == null) {
      throw UnsupportedError(
        'Unsupported task category ${originalTask.taskCatagory}',
      );
    }

    if (targetKey == null) {
      throw UnsupportedError(
        'Unsupported task category ${replacement.taskCatagory}',
      );
    }

    final sourceTasks = await _loadTasks(sourceKey);
    final index = sourceTasks.indexWhere(
      (task) => task.taskId == originalTask.taskId,
    );

    if (index == -1) {
      throw StateError(
        'Task ${originalTask.taskId} not found in ${originalTask.taskCatagory}',
      );
    }

    final existing = sourceTasks.removeAt(index);

    if (sourceKey == targetKey) {
      existing.taskDesctiption = replacement.taskDesctiption;
      existing.deadlineDate = replacement.deadlineDate;
      existing.deadlineTime = replacement.deadlineTime;
      existing.dayOfWeek = replacement.dayOfWeek;
      existing.isDone = replacement.isDone;
      existing.orderIndex = replacement.orderIndex;
      existing.subTasks
        ..clear()
        ..addAll(replacement.subTasks.map(_duplicateSubTask));
      sourceTasks.insert(index, existing);
      await _saveTasks(sourceKey, sourceTasks);
      return _duplicateTask(existing);
    }

    await _saveTasks(sourceKey, sourceTasks);

    final targetTasks = await _loadTasks(targetKey);
    int? orderIndex = replacement.orderIndex;
    final normalizedCat = replacement.taskCatagory.toLowerCase();

    if (normalizedCat == 'weekly') {
      final day = replacement.dayOfWeek?.toLowerCase();
      if (day == null || day == 'any') {
        orderIndex ??= _defaultOrderIndexForCategory(
          normalizedCat,
          targetTasks,
        );
      } else {
        orderIndex = null;
      }
    } else {
      orderIndex ??= _defaultOrderIndexForCategory(normalizedCat, targetTasks);
    }

    final inserted = Task(
      replacement.taskId,
      replacement.taskCatagory,
      replacement.taskDesctiption,
      replacement.deadlineDate,
      replacement.deadlineTime,
      replacement.dayOfWeek,
      replacement.isDone,
      orderIndex: orderIndex,
      subTasks: replacement.subTasks.map(_duplicateSubTask).toList(),
    );

    targetTasks.add(inserted);
    await _saveTasks(targetKey, targetTasks);
    return _duplicateTask(inserted);
  }

  @override
  Future<void> toggleDaily(String dataTaskId, bool dataIsDone) async {
    final tasks = await _loadTasks(PrefsKeys.dailyKey);
    final index = tasks.indexWhere((t) {
      return t.taskId == dataTaskId;
    });
    if (index != -1) {
      final task = tasks[index];
      if (dataIsDone) {
        final hasIncomplete =
            task.subTasks.isNotEmpty && task.subTasks.any((s) => !s.isDone);
        if (hasIncomplete) {
          throw StateError('Cannot complete task with incomplete subtasks');
        }
        task.isDone = true;
      } else {
        task.isDone = false;
        for (final subTask in task.subTasks) {
          subTask.isDone = false;
        }
      }
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
      final task = tasks[index];
      if (dataIsDone) {
        final hasIncomplete =
            task.subTasks.isNotEmpty && task.subTasks.any((s) => !s.isDone);
        if (hasIncomplete) {
          throw StateError('Cannot complete task with incomplete subtasks');
        }
        task.isDone = true;
      } else {
        task.isDone = false;
        for (final subTask in task.subTasks) {
          subTask.isDone = false;
        }
      }
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
