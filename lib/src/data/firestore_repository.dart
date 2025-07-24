import 'package:adhd_0_1/src/common/domain/app_user.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/data/domain/functions.dart';
import 'package:adhd_0_1/src/features/prizes/domain/prize_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirestoreRepository implements DataBaseRepository {
  final fs = FirebaseFirestore.instance;
  final storage = FlutterSecureStorage();

  // Future<String?> loadUserId() async {
  //   String? storedValue = await storage.read(key: 'userId');
  //   return storedValue;
  // }

  @override
  Future<void> addDaily(String data) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final counterDocRef = fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter');

    final counterSnapshot = await counterDocRef.get();

    int currentCounter = counterSnapshot.get('taskIdCounter') ?? 0;
    int taskIdCounter = currentCounter + 1;

    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('dailyTasks')
        .doc(taskIdCounter.toString());
    final Task task = Task(
      taskIdCounter.toString() + userId,
      'Daily',
      data,
      null,
      null,
      null,
      false,
    );
    await docRef.set(task.toMap());

    await fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter')
        .update({'taskIdCounter': taskIdCounter});
  }

  @override
  Future<void> addWeekly(String data, day) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final counterDocRef = fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter');

    final counterSnapshot = await counterDocRef.get();

    int currentCounter = counterSnapshot.get('taskIdCounter') ?? 0;
    int taskIdCounter = currentCounter + 1;

    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('weeklyTasks')
        .doc(taskIdCounter.toString());
    final Task task = Task(
      taskIdCounter.toString() + userId,
      'Weekly',
      data,
      null,
      null,
      day.toString(),
      false,
    );
    await docRef.set(task.toMap());

    await fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter')
        .update({'taskIdCounter': taskIdCounter});
  }

  @override
  Future<void> addDeadline(String data, date, time) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final counterDocRef = fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter');

    final counterSnapshot = await counterDocRef.get();

    int currentCounter = counterSnapshot.get('taskIdCounter') ?? 0;
    int taskIdCounter = currentCounter + 1;

    ///
    final String taskId = '${taskIdCounter}_$userId';

    ///
    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('deadlineTasks')
        .doc(taskIdCounter.toString());
    final Task task = Task(taskId, 'Deadline', data, date, time, null, false);
    await docRef.set(task.toMap());

    await fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter')
        .update({'taskIdCounter': taskIdCounter});
  }

  @override
  Future<void> addQuest(String data) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final counterDocRef = fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter');

    final counterSnapshot = await counterDocRef.get();

    int currentCounter = counterSnapshot.get('taskIdCounter') ?? 0;
    int taskIdCounter = currentCounter + 1;

    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('questTasks')
        .doc(taskIdCounter.toString());
    final Task task = Task(
      taskIdCounter.toString() + userId,
      'Quest',
      data,
      null,
      null,
      null,
      false,
    );
    await docRef.set(task.toMap());

    await fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter')
        .update({'taskIdCounter': taskIdCounter});
  }

  @override
  Future<void> addPrize(int prizeId, String prizeUrl) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docRef =
        fs.collection('users').doc(userId).collection('prizesWon').doc();

    final Prizes prize = Prizes(prizeId: prizeId, prizeUrl: prizeUrl);
    await docRef.set(prize.toMap());
  }

  @override
  Future<void> completeDeadline(String dataTaskId) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('deadlineTasks')
            .where('taskId', isEqualTo: dataTaskId.toString())
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'isDone': true});
      await query.docs.first.reference.delete();
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }

    await PrizeManager(this).incrementDeadlineCounter();
  }

  @override
  Future<void> completeQuest(String dataTaskId) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('questTasks')
            .where('taskId', isEqualTo: dataTaskId.toString())
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'isDone': true});
      await query.docs.first.reference.delete();
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }

    await PrizeManager(this).incrementQuestCounter();
  }

  @override
  Future<void> deleteDaily(String dataTaskId) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('dailyTasks')
            .where('taskId', isEqualTo: dataTaskId.toString())
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }
  }

  @override
  Future<void> deleteWeekly(String dataTaskId) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('weeklyTasks')
            .where('taskId', isEqualTo: dataTaskId.toString())
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }
  }

  @override
  Future<void> deleteDeadline(String dataTaskId) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('deadlineTasks')
            .where('taskId', isEqualTo: dataTaskId.toString())
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }
  }

  @override
  Future<void> deleteQuest(String dataTaskId) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('questTasks')
            .where('taskId', isEqualTo: dataTaskId.toString())
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }
  }

  @override
  Future<void> editDaily(String dataTaskId, String data) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('dailyTasks')
            .where('taskId', isEqualTo: dataTaskId)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      final docRef = query.docs.first.reference;
      await docRef.update({'taskDesctiption': data});
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }
  }

  @override
  Future<void> editWeekly(String dataTaskId, String data, day) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('weeklyTasks')
            .where('taskId', isEqualTo: dataTaskId)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      final docRef = query.docs.first.reference;
      await docRef.update({'taskDesctiption': data, 'dayOfWeek': day.name});
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }
  }

  @override
  Future<void> editDeadline(String dataTaskId, String data, date, time) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('deadlineTasks')
            .where('taskId', isEqualTo: dataTaskId)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      final docRef = query.docs.first.reference;
      await docRef.update({
        'taskDesctiption': data,
        'dayOfWeek': date,
        'time': time,
      });
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }
  }

  @override
  Future<void> editQuest(String dataTaskId, String data) async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('questTasks')
            .where('taskId', isEqualTo: dataTaskId)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      final docRef = query.docs.first.reference;
      await docRef.update({'taskDesctiption': data});
    } else {
      throw Exception('Task with ID $dataTaskId not found');
    }
  }

  @override
  Future<List<Task>> getDailyTasks() async {
    final String? userId = await loadUserId();

    final query =
        await fs.collection('users').doc(userId).collection('dailyTasks').get();

    return query.docs.map((e) {
      return Task.fromMap(e.data());
    }).toList();
  }

  @override
  Future<List<Task>> getWeeklyTasks() async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('weeklyTasks')
            .get();

    return query.docs.map((e) {
      return Task.fromMap(e.data());
    }).toList();
  }

  @override
  Future<List<Task>> getDeadlineTasks() async {
    final String? userId = await loadUserId();

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('deadlineTasks')
            .get();

    return query.docs.map((e) {
      return Task.fromMap(e.data());
    }).toList();
  }

  @override
  Future<List<Task>> getQuestTasks() async {
    final String? userId = await loadUserId();

    final query =
        await fs.collection('users').doc(userId).collection('questTasks').get();

    return query.docs.map((e) {
      return Task.fromMap(e.data());
    }).toList();
  }

  @override
  Future<List<Prizes>> getPrizes() async {
    final String? userId = await loadUserId();

    final query =
        await fs.collection('users').doc(userId).collection('prizesWon').get();

    return query.docs.map((e) {
      return Prizes.fromMap(e.data());
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
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final settings = Settings(
      appSkinColor: dataAppSkinColor,
      language: dataLanguage,
      location: dataLocation,
      startOfDay: dataStartOfDay,
      startOfWeek: dataStartOfWeek,
    );

    final settingsRef = fs
        .collection('users')
        .doc(userId)
        .collection('userSettings')
        .doc('userSettings');

    final query = await settingsRef.get();

    if (query.exists) {
      await settingsRef.update(settings.toMap());
    } else {
      await settingsRef.set(settings.toMap());
    }

    return settings;
  }

  @override
  Future<Settings?> getSettings() async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('userSettings')
            .doc('userSettings')
            .get();

    if (!query.exists) {
      return Settings(
        appSkinColor: null,
        language: 'English',
        location: 'Berlin',
        startOfDay: TimeOfDay(hour: 07, minute: 15),
        startOfWeek: Weekday.mon,
      );
    }

    final data = query.data();
    if (data == null) return null;

    return Settings.fromMap(data);
  }

  @override
  Future<void> setAppUser(
    String userId,
    userName,
    email,
    password,
    bool isPowerUser,
  ) async {
    final AppUser user = AppUser(
      userId: userId,
      userName: userName,
      email: email,
      password: password,
      isPowerUser: isPowerUser,
    );

    await fs.collection('users').doc(userId).set(user.toMap());
  }

  @override
  Future<AppUser?> getAppUser() async {
    final String? userId = await storage.read(key: 'userId');
    if (userId == null) return null;

    final snapshot = await fs.collection('users').doc(userId).get();
    if (!snapshot.exists) return null;

    return AppUser.fromMap(snapshot.data()!);
  }

  @override
  Future<void> toggleDaily(String dataTaskId, bool dataIsDone) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('dailyTasks')
            .where('taskId', isEqualTo: dataTaskId)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'isDone': dataIsDone});
    } else {
      throw Exception('Daily task not found');
    }

    await PrizeManager(this).trackDailyCompletion(dataIsDone);
  }

  @override
  Future<void> toggleWeekly(String dataTaskId, bool dataIsDone) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    final query =
        await fs
            .collection('users')
            .doc(userId)
            .collection('weeklyTasks')
            .where('taskId', isEqualTo: dataTaskId)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'isDone': dataIsDone});
    } else {
      throw Exception('Weekly task not found');
    }

    await PrizeManager(this).trackWeeklyCompletion(dataIsDone);
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

