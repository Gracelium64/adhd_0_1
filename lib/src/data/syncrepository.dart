import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prizes.dart';
import 'package:adhd_0_1/src/features/settings/domain/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SyncRepository implements DataBaseRepository {
  final DataBaseRepository mainRepo;
  final DataBaseRepository localRepo;
  bool isSyncing = false;

  SyncRepository({required this.mainRepo, required this.localRepo});

  @override
  Future<void> addDaily(String data) async {
    await localRepo.addDaily(data);
    triggerSync();
  }

  @override
  Future<void> addDeadline(String data, date, time) async {
    await localRepo.addDeadline(data, date, time);
    triggerSync();
  }

  @override
  Future<void> addPrize(int prizeId, String prizeUrl) async {
    await localRepo.addPrize(prizeId, prizeUrl);
    triggerSync();
  }

  @override
  Future<void> addQuest(String data) async {
    await localRepo.addQuest(data);
    triggerSync();
  }

  @override
  Future<void> addWeekly(String data, day) async {
    await localRepo.addWeekly(data, day);
    triggerSync();
  }

  // @override
  // Future<void> completeDaily(int dataTaskId) async {
  //   await localRepo.completeDaily(dataTaskId);
  //   triggerSync();
  // }

  @override
  Future<void> completeDeadline(int dataTaskId) async {
    await localRepo.completeDeadline(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> completeQuest(int dataTaskId) async {
    await localRepo.completeQuest(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> completeWeekly(int dataTaskId) async {
    await localRepo.completeWeekly(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> deleteDaily(int dataTaskId) async {
    await localRepo.deleteDaily(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> deleteDeadline(int dataTaskId) async {
    await localRepo.deleteDeadline(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> deleteQuest(int dataTaskId) async {
    await localRepo.deleteQuest(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> deleteWeekly(int dataTaskId) async {
    await localRepo.deleteWeekly(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> editDaily(int dataTaskId, String data) async {
    await localRepo.editDaily(dataTaskId, data);
    triggerSync();
  }

  @override
  Future<void> editDeadline(int dataTaskId, String data, date, time) async {
    await localRepo.editDeadline(dataTaskId, data, date, time);
    triggerSync();
  }

  @override
  Future<void> editQuest(int dataTaskId, String data) async {
    await localRepo.editQuest(dataTaskId, data);
    triggerSync();
  }

  @override
  Future<void> editWeekly(int dataTaskId, String data, day) async {
    await localRepo.editWeekly(dataTaskId, data, day);
    triggerSync();
  }

  @override
  Future<List<Task>> getDailyTasks() async {
    return await localRepo.getDailyTasks();
  }

  @override
  Future<List<Task>> getDeadlineTasks() async {
    return await localRepo.getDeadlineTasks();
  }

  @override
  Future<List<Prizes>> getPrizes() async {
    return await localRepo.getPrizes();
  }

  @override
  Future<List<Task>> getQuestTasks() async {
    return await localRepo.getQuestTasks();
  }

  @override
  Future<Settings?> getSettings() async {
    return await localRepo.getSettings();
  }

  @override
  Future<List<Task>> getWeeklyTasks() async {
    return await localRepo.getWeeklyTasks();
  }

  @override
  Future<Settings> setSettings(
    bool? dataAppSkinColor,
    String dataLanguage,
    String dataLocation,
    TimeOfDay dataStartOfDay,
    Weekday dataStartOfWeek,
  ) async {
    Settings settings = await localRepo.setSettings(
      dataAppSkinColor,
      dataLanguage,
      dataLocation,
      TimeOfDay(hour: dataStartOfDay.hour, minute: dataStartOfDay.minute),
      Weekday.values[dataStartOfWeek.index],
    );
    triggerSync();

    return settings;
  }

  @override
  Future<void> setAppUser(String data) async {
    await localRepo.setAppUser(data);
    triggerSync();
  }

  @override
  Future<String?> getAppUser() async {
    return await localRepo.getAppUser();
  }

  @override
  Future<void> toggleDaily(int taskId, bool isDone) async {
    await localRepo.toggleDaily(taskId, isDone);
    triggerSync();
  }

  Future<void> syncAll() async {
    if (isSyncing) {
      return;
    }
    isSyncing = true;
    try {
      debugPrint("Sync started...");

      try {
        final dailyTasks = await localRepo.getDailyTasks();
        for (final task in dailyTasks) {
          try {
            await mainRepo.addDaily(task.taskDesctiption);
          } catch (e) {
            debugPrint("Failed to sync daily task ${task.taskId}: $e");
          }
        }

        final weeklyTasks = await localRepo.getWeeklyTasks();
        for (final task in weeklyTasks) {
          try {
            await mainRepo.addWeekly(task.taskDesctiption, task.dayOfWeek);
          } catch (e) {
            debugPrint("Failed to sync weekly task ${task.taskId}: $e");
          }
        }

        final deadlineTasks = await localRepo.getDeadlineTasks();
        for (final task in deadlineTasks) {
          try {
            await mainRepo.addDeadline(
              task.taskDesctiption,
              task.deadlineDate,
              task.deadlineTime,
            );
          } catch (e) {
            debugPrint("Failed to sync deadline task ${task.taskId}: $e");
          }
        }

        final questTasks = await localRepo.getQuestTasks();
        for (final task in questTasks) {
          try {
            await mainRepo.addQuest(task.taskDesctiption);
          } catch (e) {
            debugPrint("Failed to sync quest task ${task.taskId}: $e");
          }
        }

        final prizes = await localRepo.getPrizes();
        for (final prize in prizes) {
          try {
            await mainRepo.addPrize(prize.prizeId, prize.prizeUrl);
          } catch (e) {
            debugPrint("Failed to sync prize ${prize.prizeId}: $e");
          }
        }

        final settings = await localRepo.getSettings();
        if (settings != null) {
          try {
            await mainRepo.setSettings(
              settings.appSkinColor,
              settings.language,
              settings.location,
              settings.startOfDay,
              settings.startOfWeek,
            );
          } catch (e) {
            debugPrint("Failed to sync settings: $e");
          }
        }

        debugPrint("Sync finished.");
      } catch (e) {
        debugPrint("General sync error: $e");
      }
    } finally {
      isSyncing = false;
    }
  }

  void triggerSync() {
    syncAll();
  }
}
