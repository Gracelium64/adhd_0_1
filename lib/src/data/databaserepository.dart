import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prizes.dart';
import 'package:adhd_0_1/src/features/settings/domain/settings.dart';

abstract class DataBaseRepository {
  List<Task> getDailyTasks();
  List<Task> getWeeklyTasks();
  List<Task> getDeadlineTasks();
  List<Task> getQuestTasks();
  List<Prizes> getPrizes();
  // int getTaskIdCounter();
  // int getCompletedDailyTasks();
  // int getCompletedWeeklyTasks();
  // int getCompletedDeadlineTasks();
  // int getCompletedQuestTasks();
  Settings? getSettings();
  Settings setSettings(
    bool? dataAppSkinColor,
    String dataLanguage,
    String dataLocation,
    int dataStartOfDay,
    int dataStartOfWeek,
  );
  void addDaily(String data);
  void addWeekly(String data, day);
  void addDeadline(String data, date, time);
  void addQuest(String data);
  void addPrize(int prizeId, String prizeUrl);
  void completeDaily(int dataTaskId);
  void completeWeekly(int dataTaskId);
  void completeDeadline(int dataTaskId);
  void completeQuest(int dataTaskId);
  void deleteDaily(int dataTaskId);
  void deleteWeekly(int dataTaskId);
  void deleteDeadline(int dataTaskId);
  void deleteQuest(int dataTaskId);
  void editDaily(int dataTaskId, String data);
  void editWeekly(int dataTaskId, String data, day);
  void editDeadline(int dataTaskId, String data, date, time);
  void editQuest(int dataTaskId, String data);
}
