import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prizes.dart';
import 'package:adhd_0_1/src/features/settings/domain/settings.dart';

class SyncRepository implements DataBaseRepository {
  final DataBaseRepository mainRepo;
  final DataBaseRepository localRepo;

  SyncRepository({required this.mainRepo, required this.localRepo});

  @override
  Future<void> addDaily(String data) async {
    await localRepo.addDaily(data);
    try {
      await mainRepo.addDaily(data);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> addDeadline(String data, date, time) async {
    await localRepo.addDeadline(data, date, time);
    try {
      await mainRepo.addDeadline(data, date, time);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> addPrize(int prizeId, String prizeUrl) async {
    await localRepo.addPrize(prizeId, prizeUrl);
    try {
      await mainRepo.addPrize(prizeId, prizeUrl);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> addQuest(String data) async {
    await localRepo.addQuest(data);
    try {
      await mainRepo.addQuest(data);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> addWeekly(String data, day) async {
    await localRepo.addWeekly(data, day);
    try {
      await mainRepo.addWeekly(data, day);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> completeDaily(int dataTaskId) async {
    await localRepo.completeDaily(dataTaskId);
    try {
      await mainRepo.completeDaily(dataTaskId);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> completeDeadline(int dataTaskId) async {
    await localRepo.completeDeadline(dataTaskId);
    try {
      await mainRepo.completeDeadline(dataTaskId);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> completeQuest(int dataTaskId) async {
    await localRepo.completeQuest(dataTaskId);
    try {
      await mainRepo.completeQuest(dataTaskId);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> completeWeekly(int dataTaskId) async {
    await localRepo.completeWeekly(dataTaskId);
    try {
      await mainRepo.completeWeekly(dataTaskId);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> deleteDaily(int dataTaskId) async {
    await localRepo.deleteDaily(dataTaskId);
    try {
      await mainRepo.deleteDaily(dataTaskId);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> deleteDeadline(int dataTaskId) async {
    await localRepo.deleteDeadline(dataTaskId);
    try {
      await mainRepo.deleteDeadline(dataTaskId);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> deleteQuest(int dataTaskId) async {
    await localRepo.deleteQuest(dataTaskId);
    try {
      await mainRepo.deleteQuest(dataTaskId);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> deleteWeekly(int dataTaskId) async {
    await localRepo.deleteWeekly(dataTaskId);
    try {
      await mainRepo.deleteWeekly(dataTaskId);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> editDaily(int dataTaskId, String data) async {
    await localRepo.editDaily(dataTaskId, data);
    try {
      await mainRepo.editDaily(dataTaskId, data);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> editDeadline(int dataTaskId, String data, date, time) async {
    await localRepo.editDeadline(dataTaskId, data, date, time);
    try {
      await mainRepo.editDeadline(dataTaskId, data, date, time);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> editQuest(int dataTaskId, String data) async {
    await localRepo.editQuest(dataTaskId, data);
    try {
      await mainRepo.editQuest(dataTaskId, data);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Future<void> editWeekly(int dataTaskId, String data, day) async {
    await localRepo.editWeekly(dataTaskId, data, day);
    try {
      await mainRepo.editWeekly(dataTaskId, data, day);
    } catch (e) {
      print('Sync error: $e');
    }
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
    int dataStartOfDay,
    int dataStartOfWeek,
  ) async {
    Settings settings = await localRepo.setSettings(
      dataAppSkinColor,
      dataLanguage,
      dataLocation,
      dataStartOfDay,
      dataStartOfWeek,
    );
    try {
      await mainRepo.setSettings(
        dataAppSkinColor,
        dataLanguage,
        dataLocation,
        dataStartOfDay,
        dataStartOfWeek,
      );
    } catch (e) {
      print('Sync error: $e');
    }
    return settings;
  }

  Future<void> syncAll() async {
    print("Sync started...");

    try {
      // Sync daily tasks
      final dailyTasks = await localRepo.getDailyTasks();
      for (final task in dailyTasks) {
        try {
          await mainRepo.addDaily(task.taskDesctiption);
        } catch (e) {
          print("Failed to sync daily task ${task.taskId}: $e");
        }
      }

      // Sync weekly tasks
      final weeklyTasks = await localRepo.getWeeklyTasks();
      for (final task in weeklyTasks) {
        try {
          await mainRepo.addWeekly(
            task.taskDesctiption,
            task.dayOfWeek,
          ); // adapt if needed
        } catch (e) {
          print("Failed to sync weekly task ${task.taskId}: $e");
        }
      }

      // Sync deadline tasks
      final deadlineTasks = await localRepo.getDeadlineTasks();
      for (final task in deadlineTasks) {
        try {
          await mainRepo.addDeadline(
            task.taskDesctiption,
            task.deadlineDate,
            task.deadlineTime,
          );
        } catch (e) {
          print("Failed to sync deadline task ${task.taskId}: $e");
        }
      }

      // Sync quests
      final questTasks = await localRepo.getQuestTasks();
      for (final task in questTasks) {
        try {
          await mainRepo.addQuest(task.taskDesctiption);
        } catch (e) {
          print("Failed to sync quest task ${task.taskId}: $e");
        }
      }

      // Sync prizes
      final prizes = await localRepo.getPrizes();
      for (final prize in prizes) {
        try {
          await mainRepo.addPrize(prize.prizeId, prize.prizeUrl);
        } catch (e) {
          print("Failed to sync prize ${prize.prizeId}: $e");
        }
      }

      // Sync settings
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
          print("Failed to sync settings: $e");
        }
      }

      print("Sync finished.");
    } catch (e) {
      print("General sync error: $e");
    }
  }
}
