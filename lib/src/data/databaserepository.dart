import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prizes.dart';
import 'package:adhd_0_1/src/features/settings/domain/settings.dart';

abstract class DataBaseRepository {
  Future<List<Task>> getDailyTasks();
  Future<List<Task>> getWeeklyTasks();
  Future<List<Task>> getDeadlineTasks();
  Future<List<Task>> getQuestTasks();
  Future<List<Prizes>> getPrizes();
  // int getTaskIdCounter();
  // int getCompletedDailyTasks();
  // int getCompletedWeeklyTasks();
  // int getCompletedDeadlineTasks();
  // int getCompletedQuestTasks();
  Future<Settings?> getSettings();
  Future<Settings> setSettings(
    bool? dataAppSkinColor,
    String dataLanguage,
    String dataLocation,
    int dataStartOfDay,
    int dataStartOfWeek,
  );
  Future<void> addDaily(String data);
  Future<void> addWeekly(String data, day);
  Future<void> addDeadline(String data, date, time);
  Future<void> addQuest(String data);
  Future<void> addPrize(int prizeId, String prizeUrl);
  // Future<void> completeDaily(int dataTaskId);
  Future<void> completeWeekly(int dataTaskId);
  Future<void> completeDeadline(int dataTaskId);
  Future<void> completeQuest(int dataTaskId);
  Future<void> deleteDaily(int dataTaskId);
  Future<void> deleteWeekly(int dataTaskId);
  Future<void> deleteDeadline(int dataTaskId);
  Future<void> deleteQuest(int dataTaskId);
  Future<void> editDaily(int dataTaskId, String data);
  Future<void> editWeekly(int dataTaskId, String data, day);
  Future<void> editDeadline(int dataTaskId, String data, date, time);
  Future<void> editQuest(int dataTaskId, String data);
  Future<void> setAppUser(String data);
  Future<String?> getAppUser();
  Future<void> toggleDaily(int dataTaskId, bool dataIsDone);
}
