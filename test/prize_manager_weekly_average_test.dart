// Unit tests for PrizeManager weekly average logic.

import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';
import 'package:adhd_0_1/src/common/domain/app_user.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/prize_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo implements DataBaseRepository {
  List<Task> weeklyTasks = <Task>[];
  List<Task> dailyTasks = <Task>[];

  @override
  Future<void> addDaily(String data) async {}
  @override
  Future<void> addDeadline(String data, date, time) async {}
  @override
  Future<void> addPrize(int prizeId, String prizeUrl) async {}
  @override
  Future<void> addQuest(String data) async {}
  @override
  Future<void> addWeekly(String data, day) async {}
  @override
  Future<void> completeDeadline(String dataTaskId) async {}
  @override
  Future<void> completeQuest(String dataTaskId) async {}
  @override
  Future<void> deleteDaily(String dataTaskId) async {}
  @override
  Future<void> deleteDeadline(String dataTaskId) async {}
  @override
  Future<void> deleteQuest(String dataTaskId) async {}
  @override
  Future<void> deleteWeekly(String dataTaskId) async {}
  @override
  Future<void> editDaily(String dataTaskId, String data) async {}
  @override
  Future<void> editDeadline(String dataTaskId, String data, date, time) async {}
  @override
  Future<void> editQuest(String dataTaskId, String data) async {}
  @override
  Future<void> editWeekly(String dataTaskId, String data, day) async {}
  @override
  Future<List<Task>> getDailyTasks() async => dailyTasks;
  @override
  Future<List<Task>> getDeadlineTasks() async => <Task>[];
  @override
  Future<List<Prizes>> getPrizes() async => <Prizes>[];
  @override
  Future<List<Task>> getQuestTasks() async => <Task>[];
  @override
  Future<Settings?> getSettings() async => null;
  @override
  Future<Settings> setSettings(
    bool? dataAppSkinColor,
    String dataLanguage,
    String dataLocation,
    TimeOfDay dataStartOfDay,
    Weekday dataStartOfWeek,
  ) async => throw UnimplementedError();
  @override
  Future<void> setAppUser(
    String userId,
    String userName,
    String email,
    String password,
    bool isPowerUser,
  ) async {}
  @override
  Future<AppUser?> getAppUser() async => null;
  @override
  Future<List<Task>> getWeeklyTasks() async => weeklyTasks;
  @override
  Future<void> toggleDaily(String dataTaskId, bool dataIsDone) async {}
  @override
  Future<void> toggleWeekly(String dataTaskId, bool dataIsDone) async {}
  @override
  Future<void> saveDailyOrder(List<String> orderedTaskIds) async {}
  @override
  Future<void> saveQuestOrder(List<String> orderedTaskIds) async {}
  @override
  Future<void> saveWeeklyAnyOrder(List<String> orderedTaskIds) async {}
  @override
  Future<Task> addSubTask(Task parentTask, String description) async =>
      parentTask;
  @override
  Future<Task> editSubTask(
    Task parentTask,
    String subTaskId,
    String description,
  ) async => parentTask;
  @override
  Future<Task> toggleSubTask(
    Task parentTask,
    String subTaskId,
    bool isDone,
  ) async => parentTask;
  @override
  Future<Task> deleteSubTask(Task parentTask, String subTaskId) async =>
      parentTask;
  @override
  Future<Task> replaceTask(Task originalTask, Task replacement) async =>
      replacement;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrizeManager weekly average daily completion', () {
    setUp(() async {
      // Initialize mock storage for shared_preferences on the test platform
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test(
      'awards based on dailyAvg >= 0.75 using dailyWeekSum/dailyWeekCount',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('weeklyRewardGiven', false);

        await prefs.setDouble('dailyWeekSum', 0.8 * 5);
        await prefs.setInt('dailyWeekCount', 5);

        await prefs.setInt('weeklyTotal', 10);
        await prefs.setInt('weeklyCompleted', 7);

        await prefs.setInt('questCompleted', 2);
        await prefs.setInt('deadlineCompleted', 1);

        final repo = _FakeRepo();
        repo.weeklyTasks = List.generate(
          10,
          (index) => Task(
            'w$index',
            'weekly',
            'Task $index',
            null,
            null,
            null,
            index < 7,
          ),
        );
        final pm = PrizeManager(repo);
        final prizes = await pm.awardWeeklyPrizes();

        expect(prizes.length, 4);
        expect(prefs.getBool('weeklyRewardGiven'), true);
      },
    );

    test(
      'no sample days => dailyAvg = 0, only other sources contribute',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('weeklyRewardGiven', false);

        await prefs.setInt('weeklyTotal', 4);
        await prefs.setInt('weeklyCompleted', 3); // 0.75

        await prefs.setInt('questCompleted', 0);
        await prefs.setInt('deadlineCompleted', 0);

        final repo = _FakeRepo();
        repo.weeklyTasks = List.generate(
          4,
          (index) => Task(
            'w$index',
            'weekly',
            'Task $index',
            null,
            null,
            null,
            index < 3,
          ),
        );
        final pm = PrizeManager(repo);
        final prizes = await pm.awardWeeklyPrizes();

        expect(prizes.length, 1);
      },
    );

    test('resetWeeklyCounters clears aggregates and flag', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('dailyWeekSum', 4.2);
      await prefs.setInt('dailyWeekCount', 6);
      await prefs.setBool('weeklyRewardGiven', true);

      final repo = _FakeRepo();
      final pm = PrizeManager(repo);
      await pm.resetWeeklyCounters();

      expect(prefs.getDouble('dailyWeekSum') ?? 0.0, 0.0);
      expect(prefs.getInt('dailyWeekCount') ?? 0, 0);
      expect(prefs.getBool('weeklyRewardGiven') ?? false, false);
    });

    test(
      'trackWeeklyCompletion reflects current repo state when toggled off',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final repo = _FakeRepo();
        repo.weeklyTasks = [
          Task('w1', 'weekly', 'Done task', null, null, null, true),
          Task('w2', 'weekly', 'Pending task', null, null, null, false),
          Task('w3', 'weekly', 'Another pending task', null, null, null, false),
        ];
        final pm = PrizeManager(repo);

        await pm.trackWeeklyCompletion(false);

        expect(prefs.getInt('weeklyTotal'), 3);
        expect(prefs.getInt('weeklyCompleted'), 1);
      },
    );
  });
}
