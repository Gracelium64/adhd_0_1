import 'package:adhd_0_1/src/common/domain/app_user.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prize_manager.dart';
import 'package:flutter/material.dart';

class SyncRepository implements DataBaseRepository {
  final DataBaseRepository mainRepo;
  final DataBaseRepository localRepo;
  final PrizeManager prizeManager;
  bool isSyncing = false;

  SyncRepository({
    required this.mainRepo,
    required this.localRepo,
    required this.prizeManager,
  });

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

  @override
  Future<void> completeDeadline(String dataTaskId) async {
    await localRepo.completeDeadline(dataTaskId);
    //////////////
    await prizeManager.incrementDeadlineCounter();
    //////////////
    triggerSync();
  }

  @override
  Future<void> completeQuest(String dataTaskId) async {
    await localRepo.completeQuest(dataTaskId);
    //////////////
    await prizeManager.incrementQuestCounter();
    //////////////
    triggerSync();
  }

  @override
  Future<void> deleteDaily(String dataTaskId) async {
    await localRepo.deleteDaily(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> deleteDeadline(String dataTaskId) async {
    await localRepo.deleteDeadline(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> deleteQuest(String dataTaskId) async {
    await localRepo.deleteQuest(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> deleteWeekly(String dataTaskId) async {
    await localRepo.deleteWeekly(dataTaskId);
    triggerSync();
  }

  @override
  Future<void> editDaily(String dataTaskId, String data) async {
    await localRepo.editDaily(dataTaskId, data);
    triggerSync();
  }

  @override
  Future<void> editDeadline(String dataTaskId, String data, date, time) async {
    await localRepo.editDeadline(dataTaskId, data, date, time);
    triggerSync();
  }

  @override
  Future<void> editQuest(String dataTaskId, String data) async {
    await localRepo.editQuest(dataTaskId, data);
    triggerSync();
  }

  @override
  Future<void> editWeekly(String dataTaskId, String data, day) async {
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
  Future<void> setAppUser(
    String userId,
    userName,
    email,
    password,
    isPowerUser,
  ) async {
    await localRepo.setAppUser(userId, userName, email, password, isPowerUser);
    triggerSync();
  }

  @override
  Future<AppUser?> getAppUser() async {
    return await localRepo.getAppUser();
  }

  @override
  Future<void> toggleDaily(String taskId, bool isDone) async {
    await localRepo.toggleDaily(taskId, isDone);
    //////////////
    if (isDone) {
      await prizeManager.trackDailyCompletion(isDone);
    }
    //////////////
    triggerSync();
  }

  @override
  Future<void> toggleWeekly(String dataTaskId, bool dataIsDone) async {
    await localRepo.toggleWeekly(dataTaskId, dataIsDone);
    //////////////
    if (dataIsDone) {
      await prizeManager.trackWeeklyCompletion(true);
    }
    //////////////
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
        final localDailies = await localRepo.getDailyTasks();
        final remoteDailies = await mainRepo.getDailyTasks();
        final remoteDailyMap = {for (var t in remoteDailies) t.taskId: t};

        for (final task in localDailies) {
          final remote = remoteDailyMap[task.taskId];
          if (remote == null) {
            await mainRepo.addDaily(task.taskDesctiption);
          } else {
            if (task.taskDesctiption != remote.taskDesctiption) {
              await mainRepo.editDaily(task.taskId, task.taskDesctiption);
            }
            if (task.isDone != remote.isDone) {
              await mainRepo.toggleDaily(task.taskId, task.isDone);
            }
          }
        }

        final localWeeklies = await localRepo.getWeeklyTasks();
        final remoteWeeklies = await mainRepo.getWeeklyTasks();
        final remoteWeeklyMap = {for (var t in remoteWeeklies) t.taskId: t};

        for (final task in localWeeklies) {
          final remote = remoteWeeklyMap[task.taskId];
          if (remote == null) {
            await mainRepo.addWeekly(task.taskDesctiption, task.dayOfWeek);
          } else {
            if (task.taskDesctiption != remote.taskDesctiption ||
                task.dayOfWeek != remote.dayOfWeek) {
              await mainRepo.editWeekly(
                task.taskId,
                task.taskDesctiption,
                Weekday.values.firstWhere((w) => w.name == task.dayOfWeek),
              );
            }
            if (task.isDone != remote.isDone) {
              await mainRepo.toggleWeekly(task.taskId, task.isDone);
            }
          }
        }

        final localDeadlines = await localRepo.getDeadlineTasks();
        final remoteDeadlines = await mainRepo.getDeadlineTasks();
        final remoteDeadlineMap = {for (var t in remoteDeadlines) t.taskId: t};

        for (final task in localDeadlines) {
          final remote = remoteDeadlineMap[task.taskId];
          if (remote == null) {
            await mainRepo.addDeadline(
              task.taskDesctiption,
              task.deadlineDate,
              task.deadlineTime,
            );
          } else {
            if (task.taskDesctiption != remote.taskDesctiption ||
                task.deadlineDate != remote.deadlineDate ||
                task.deadlineTime != remote.deadlineTime) {
              await mainRepo.editDeadline(
                task.taskId,
                task.taskDesctiption,
                task.deadlineDate,
                task.deadlineTime,
              );
            }
          }
        }

        final localQuests = await localRepo.getQuestTasks();
        final remoteQuests = await mainRepo.getQuestTasks();
        final remoteQuestMap = {for (var t in remoteQuests) t.taskId: t};

        for (final task in localQuests) {
          final remote = remoteQuestMap[task.taskId];
          if (remote == null) {
            await mainRepo.addQuest(task.taskDesctiption);
          } else {
            if (task.taskDesctiption != remote.taskDesctiption) {
              await mainRepo.editQuest(task.taskId, task.taskDesctiption);
            }
          }
        }

        final prizes = await localRepo.getPrizes();
        final remotePrizes = await mainRepo.getPrizes();
        final remotePrizeIds = remotePrizes.map((p) => p.prizeId).toSet();

        for (final prize in prizes) {
          if (!remotePrizeIds.contains(prize.prizeId)) {
            await mainRepo.addPrize(prize.prizeId, prize.prizeUrl);
          }
        }

        final settings = await localRepo.getSettings();
        if (settings != null) {
          await mainRepo.setSettings(
            settings.appSkinColor,
            settings.language,
            settings.location,
            settings.startOfDay,
            settings.startOfWeek,
          );
        }

        debugPrint("✅ Sync finished.");
      } catch (e, stack) {
        debugPrint("❌ Sync error: $e\n$stack");
      }
    } finally {
      isSyncing = false;
    }
  }

  void triggerSync() {
    syncAll();
  }
}
