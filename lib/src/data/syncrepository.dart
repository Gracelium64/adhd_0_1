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
    await mainRepo.addDaily(data);
    await localRepo.addDaily(data);
  }

  @override
  Future<void> addDeadline(String data, date, time) async {
    await mainRepo.addDeadline(data, date, time);
    await localRepo.addDeadline(data, date, time);
  }

  @override
  Future<void> addPrize(int prizeId, String prizeUrl) async {
    await mainRepo.addPrize(prizeId, prizeUrl);
    await localRepo.addPrize(prizeId, prizeUrl);
  }

  @override
  Future<void> addQuest(String data) async {
    await mainRepo.addQuest(data);
    await localRepo.addQuest(data);
  }

  @override
  Future<void> addWeekly(String data, day) async {
    await mainRepo.addWeekly(data, day);
    await localRepo.addWeekly(data, day);
  }

  @override
  Future<void> completeDaily(int dataTaskId) async {
    await mainRepo.completeDaily(dataTaskId);
    await localRepo.completeDaily(dataTaskId);
  }

  @override
  Future<void> completeDeadline(int dataTaskId) async {
    await mainRepo.completeDeadline(dataTaskId);
    await localRepo.completeDeadline(dataTaskId);
  }

  @override
  Future<void> completeQuest(int dataTaskId) async {
    await mainRepo.completeQuest(dataTaskId);
    await localRepo.completeQuest(dataTaskId);
  }

  @override
  Future<void> completeWeekly(int dataTaskId) async {
    await mainRepo.completeWeekly(dataTaskId);
    await localRepo.completeWeekly(dataTaskId);
  }

  @override
  Future<void> deleteDaily(int dataTaskId) async {
    await mainRepo.deleteDaily(dataTaskId);
    await localRepo.deleteDaily(dataTaskId);
  }

  @override
  Future<void> deleteDeadline(int dataTaskId) async {
    await mainRepo.deleteDeadline(dataTaskId);
    await localRepo.deleteDeadline(dataTaskId);
  }

  @override
  Future<void> deleteQuest(int dataTaskId) async {
    await mainRepo.deleteQuest(dataTaskId);
    await localRepo.deleteQuest(dataTaskId);
  }

  @override
  Future<void> deleteWeekly(int dataTaskId) async {
    await mainRepo.deleteWeekly(dataTaskId);
    await localRepo.deleteWeekly(dataTaskId);
  }

  @override
  Future<void> editDaily(int dataTaskId, String data) async {
    await mainRepo.editDaily(dataTaskId, data);
    await localRepo.editDaily(dataTaskId, data);
  }

  @override
  Future<void> editDeadline(int dataTaskId, String data, date, time) async {
    await mainRepo.editDeadline(dataTaskId, data, date, time);
    await localRepo.editDeadline(dataTaskId, data, date, time);
  }

  @override
  Future<void> editQuest(int dataTaskId, String data) async {
    await mainRepo.editQuest(dataTaskId, data);
    await localRepo.editQuest(dataTaskId, data);
  }

  @override
  Future<void> editWeekly(int dataTaskId, String data, day) async {
    await mainRepo.editWeekly(dataTaskId, data, day);
    await localRepo.editWeekly(dataTaskId, data, day);
  }

  @override
  Future<List<Task>> getDailyTasks() async {
    await mainRepo.getDailyTasks();
    await localRepo.getDailyTasks();
  }

  @override
  Future<List<Task>> getDeadlineTasks() async {
    await mainRepo.getDeadlineTasks();
    await localRepo.getDeadlineTasks();
  }

  @override
  Future<List<Prizes>> getPrizes() async {
    await mainRepo.getPrizes();
    await localRepo.getPrizes();
  }

  @override
  Future<List<Task>> getQuestTasks() async {
    await mainRepo.getQuestTasks();
    await localRepo.getQuestTasks();
  }

  @override
  Future<Settings?> getSettings() async {
    await mainRepo.getSettings();
    await localRepo.getSettings();
  }

  @override
  Future<List<Task>> getWeeklyTasks() async {
    await mainRepo.getWeeklyTasks();
    await localRepo.getWeeklyTasks();
  }

  @override
  Future<Settings> setSettings(
    bool? dataAppSkinColor,
    String dataLanguage,
    String dataLocation,
    int dataStartOfDay,
    int dataStartOfWeek,
  ) async {
    await mainRepo.setSettings(
      dataAppSkinColor,
      dataLanguage,
      dataLocation,
      dataStartOfDay,
      dataStartOfWeek,
    );
    await localRepo.setSettings(
      dataAppSkinColor,
      dataLanguage,
      dataLocation,
      dataStartOfDay,
      dataStartOfWeek,
    );
  }
}
