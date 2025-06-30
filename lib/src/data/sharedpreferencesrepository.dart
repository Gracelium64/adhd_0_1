import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prizes.dart';
import 'package:adhd_0_1/src/features/settings/domain/settings.dart';

class SharedPreferencesRepository implements DataBaseRepository {
  final _dailyKey = 'dailyTasks';
  final _weeklyKey = 'weeklyTasks';
  final _deadlineKey = 'deadlineTasks';
  final _questKey = 'questTasks';
  final _settingsKey = 'userSettings';
  final _prizesKey = 'prizesWon';

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
    final list = await _loadTasks(_dailyKey);
    list.add(Task(taskIdCounter++, 'Daily', data, null, null, null, false));
    await _saveTasks(_dailyKey, list);
  }

  @override
  Future<void> addWeekly(String data, day) async {
    final list = await _loadTasks(_weeklyKey);
    list.add(Task(taskIdCounter++, 'Weekly', data, null, null, day, false));
    await _saveTasks(_weeklyKey, list);
  }

  @override
  Future<void> addDeadline(String data, date, time) async {
    final list = await _loadTasks(_deadlineKey);
    list.add(Task(taskIdCounter++, 'Deadline', data, date, time, null, false));
    await _saveTasks(_deadlineKey, list);
  }

  @override
  Future<void> addQuest(String data) async {
    final list = await _loadTasks(_questKey);
    list.add(Task(taskIdCounter++, 'Quest', data, null, null, null, false));
    await _saveTasks(_questKey, list);
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

  @override
  Future<void> completeDaily(int dataTaskId) async =>
      _markComplete(_dailyKey, dataTaskId);

  @override
  Future<void> completeWeekly(int dataTaskId) async =>
      _markComplete(_weeklyKey, dataTaskId);

  @override
  Future<void> completeDeadline(int dataTaskId) async =>
      _markComplete(_deadlineKey, dataTaskId, remove: true);

  @override
  Future<void> completeQuest(int dataTaskId) async =>
      _markComplete(_questKey, dataTaskId, remove: true);

  Future<void> _delete(String key, int taskId) async {
    final list = await _loadTasks(key);
    list.removeWhere((t) => t.taskId == taskId);
    await _saveTasks(key, list);
  }

  @override
  Future<void> deleteDaily(int dataTaskId) async =>
      _delete(_dailyKey, dataTaskId);

  @override
  Future<void> deleteWeekly(int dataTaskId) async =>
      _delete(_weeklyKey, dataTaskId);

  @override
  Future<void> deleteDeadline(int dataTaskId) async =>
      _delete(_deadlineKey, dataTaskId);

  @override
  Future<void> deleteQuest(int dataTaskId) async =>
      _delete(_questKey, dataTaskId);

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
      _edit(_dailyKey, taskId, (t) => t.taskDesctiption = data);

  @override
  Future<void> editWeekly(int taskId, String data, day) async =>
      _edit(_weeklyKey, taskId, (t) {
        t.taskDesctiption = data;
        t.dayOfWeek = day;
      });

  @override
  Future<void> editDeadline(int taskId, String data, date, time) async =>
      _edit(_deadlineKey, taskId, (t) {
        t.taskDesctiption = data;
        t.deadlineDate = date;
        t.deadlineTime = time;
      });

  @override
  Future<void> editQuest(int taskId, String data) async =>
      _edit(_questKey, taskId, (t) => t.taskDesctiption = data);

  @override
  Future<List<Task>> getDailyTasks() => _loadTasks(_dailyKey);

  @override
  Future<List<Task>> getWeeklyTasks() => _loadTasks(_weeklyKey);

  @override
  Future<List<Task>> getDeadlineTasks() => _loadTasks(_deadlineKey);

  @override
  Future<List<Task>> getQuestTasks() => _loadTasks(_questKey);

  @override
  Future<void> addPrize(int prizeId, String prizeUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prizesKey) ?? [];
    list.add(jsonEncode({'prizeId': prizeId, 'prizeUrl': prizeUrl}));
    await prefs.setStringList(_prizesKey, list);
  }

  @override
  Future<List<Prizes>> getPrizes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prizesKey) ?? [];
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
    int dataStartOfDay,
    int dataStartOfWeek,
  ) async {
    final settings = Settings(
      appSkinColor: dataAppSkinColor,
      language: dataLanguage,
      location: dataLocation,
      startOfDay: dataStartOfDay,
      startOfWeek: dataStartOfWeek,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    return settings;
  }

  @override
  Future<Settings?> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_settingsKey);
    if (str == null) return null;
    return Settings.fromJson(jsonDecode(str));
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
