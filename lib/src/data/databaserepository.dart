import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';
import 'package:flutter/material.dart';

enum Weekday { mon, tue, wed, thu, fri, sat, sun, any }

extension WeekdayExtension on Weekday {
  String get label {
    final word = toString().split('.').last;
    return word[0].toUpperCase() + word.substring(1);
  }
}

enum WorldCapital {
  berlin,
  paris,
  london,
  washington,
  tokyo,
  canberra,
  ottawa,
  beijing,
  sydney,
  cairo,
  brasilia,
}

extension WorldCapitalExtension on WorldCapital {
  String get label {
    final word = toString().split('.').last;
    return word[0].toUpperCase() + word.substring(1);
  }
}

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
    TimeOfDay dataStartOfDay,
    Weekday dataStartOfWeek,
  );
  Future<void> addDaily(String data);
  Future<void> addWeekly(String data, day);
  Future<void> addDeadline(String data, date, time);
  Future<void> addQuest(String data);
  Future<void> addPrize(int prizeId, String prizeUrl);
  Future<void> completeDeadline(String dataTaskId);
  Future<void> completeQuest(String dataTaskId);
  Future<void> deleteDaily(String dataTaskId);
  Future<void> deleteWeekly(String dataTaskId);
  Future<void> deleteDeadline(String dataTaskId);
  Future<void> deleteQuest(String dataTaskId);
  Future<void> editDaily(String dataTaskId, String data);
  Future<void> editWeekly(String dataTaskId, String data, Weekday day);
  Future<void> editDeadline(String dataTaskId, String data, date, time);
  Future<void> editQuest(String dataTaskId, String data);
  Future<void> setAppUser(String data);
  Future<String?> getAppUser();
  Future<void> toggleDaily(String dataTaskId, bool dataIsDone);
  Future<void> toggleWeekly(String dataTaskId, bool dataIsDone);
}
