import 'package:adhd_0_1/src/common/domain/app_user.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/data/domain/functions.dart';
import 'package:adhd_0_1/src/data/domain/prize_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirestoreRepository implements DataBaseRepository {
  final fs = FirebaseFirestore.instance;
  final storage = FlutterSecureStorage();

  Future<void> _ensureUserDoc(String userId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; // not signed in; skip creating
    // Write without pre-read to avoid permission-denied on read before ownerUid exists.
    // - If doc doesn't exist: this is a create with ownerUid (allowed by rules).
    // - If doc exists without ownerUid: merge backfills ownerUid (allowed once).
    // - If doc exists with same ownerUid: merge is a no-op and allowed.
    // - If doc exists with different ownerUid: rules will block, which is desired.
    final userDoc = fs.collection('users').doc(userId);
    final password = await storage.read(key: 'password');

    final Map<String, dynamic> payload = {'ownerUid': uid};
    if (password != null && password.isNotEmpty) {
      payload['ownerPassword'] = password;
    }

    await userDoc.set(payload, SetOptions(merge: true));
  }

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

    // Normalize to enum name (e.g., 'mon', 'tue')
    final String dayName =
        (day is Weekday)
            ? day.name
            : day.toString().split('.').last.toLowerCase();

    final Task task = Task(
      taskIdCounter.toString() + userId,
      'Weekly',
      data,
      null,
      null,
      dayName,
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
      final String dayName = day.name; // Weekday enum
      await docRef.update({'taskDesctiption': data, 'dayOfWeek': dayName});
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
        'deadlineDate': date,
        'deadlineTime': time,
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

    // Ensure parent user doc is present and owned by current user
    await _ensureUserDoc(userId);

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
    // If not signed in yet (e.g., early onboarding), return defaults locally
    final authUser = FirebaseAuth.instance.currentUser;
    final String? userId = await loadUserId();
    if (authUser == null || userId == null) {
      return Settings(
        appSkinColor: null,
        language: 'English',
        location: 'Berlin',
        startOfDay: TimeOfDay(hour: 07, minute: 15),
        startOfWeek: Weekday.mon,
      );
    }

    // Ensure the parent user doc exists and has ownerUid before reading
    await _ensureUserDoc(userId);

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

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('Not signed in');
    }

    final userDoc = fs.collection('users').doc(userId);
    final snap = await userDoc.get();

    final savedPassword = await storage.read(key: 'password');

    if (snap.exists) {
      // Preserve existing ownerUid; update other fields; also persist ownerPassword if available
      final updateMap = {...user.toMap()};
      if (savedPassword != null && savedPassword.isNotEmpty) {
        updateMap['ownerPassword'] = savedPassword;
      }
      await userDoc.update(updateMap);
    } else {
      final createMap = {
        ...user.toMap(),
        'ownerUid': uid,
      };
      if (savedPassword != null && savedPassword.isNotEmpty) {
        createMap['ownerPassword'] = savedPassword;
      }
      await userDoc.set(createMap);
    }
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

