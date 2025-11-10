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
import 'dart:convert';

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
    // Set ownerUid and keep ownerPassword for migration, but never save raw password
    final savedPassword = await storage.read(key: 'password');
    final Map<String, dynamic> payload = {
      'ownerUid': uid,
      if (savedPassword != null && savedPassword.isNotEmpty)
        'ownerPassword': savedPassword,
    };
    await userDoc.set(payload, SetOptions(merge: true));
  }

  // Public: ensure the parent user document exists and is owned by the current auth user.
  // Throws on permission issues so callers can bail out early.
  Future<void> ensureUserOwnershipPreflight() async {
    final String? userId = await storage.read(key: 'userId');
    if (userId == null || userId.isEmpty) return;
    await _ensureUserDoc(userId);
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
      orderIndex: taskIdCounter,
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
      orderIndex: (dayName == 'any') ? taskIdCounter : null,
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

    // Use concatenated taskId + secure userId as the public taskId field
    final String taskId = taskIdCounter.toString() + userId;
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
      orderIndex: taskIdCounter,
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
    await _ensureUserDoc(userId);
    final docRef =
        fs.collection('users').doc(userId).collection('prizesWon').doc();

    final Prizes prize = Prizes(prizeId: prizeId, prizeUrl: prizeUrl);
    await docRef.set(prize.toMap());
  }

  @override
  Future<void> completeDeadline(String dataTaskId) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('deadlineTasks')
        .doc(docId);
    var completed = false;
    await fs.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final raw = snap.data();
      if (raw != null) {
        final task = Task.fromMap(Map<String, dynamic>.from(raw));
        final hasIncomplete =
            task.subTasks.isNotEmpty && task.subTasks.any((s) => !s.isDone);
        if (hasIncomplete) {
          throw StateError('Cannot complete task with incomplete subtasks');
        }
      }
      tx.delete(docRef);
      completed = true;
    });

    if (completed) {
      await PrizeManager(this).incrementDeadlineCounter();
    }
  }

  @override
  Future<void> completeQuest(String dataTaskId) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('questTasks')
        .doc(docId);
    var completed = false;
    await fs.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final raw = snap.data();
      if (raw != null) {
        final task = Task.fromMap(Map<String, dynamic>.from(raw));
        final hasIncomplete =
            task.subTasks.isNotEmpty && task.subTasks.any((s) => !s.isDone);
        if (hasIncomplete) {
          throw StateError('Cannot complete task with incomplete subtasks');
        }
      }
      tx.delete(docRef);
      completed = true;
    });

    if (completed) {
      await PrizeManager(this).incrementQuestCounter();
    }
  }

  @override
  Future<void> deleteDaily(String dataTaskId) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    await fs
        .collection('users')
        .doc(userId)
        .collection('dailyTasks')
        .doc(docId)
        .delete();
  }

  @override
  Future<void> deleteWeekly(String dataTaskId) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    await fs
        .collection('users')
        .doc(userId)
        .collection('weeklyTasks')
        .doc(docId)
        .delete();
  }

  @override
  Future<void> deleteDeadline(String dataTaskId) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    await fs
        .collection('users')
        .doc(userId)
        .collection('deadlineTasks')
        .doc(docId)
        .delete();
  }

  @override
  Future<void> deleteQuest(String dataTaskId) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    await fs
        .collection('users')
        .doc(userId)
        .collection('questTasks')
        .doc(docId)
        .delete();
  }

  @override
  Future<void> editDaily(String dataTaskId, String data) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('dailyTasks')
        .doc(docId);
    await docRef.update({'taskDesctiption': data});
  }

  @override
  Future<void> editWeekly(String dataTaskId, String data, day) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    final String dayName = day.name; // Weekday enum
    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('weeklyTasks')
        .doc(docId);
    await docRef.update({'taskDesctiption': data, 'dayOfWeek': dayName});
  }

  @override
  Future<void> editDeadline(String dataTaskId, String data, date, time) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('deadlineTasks')
        .doc(docId);
    await docRef.update({
      'taskDesctiption': data,
      'deadlineDate': date,
      'deadlineTime': time,
    });
  }

  @override
  Future<void> editQuest(String dataTaskId, String data) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('questTasks')
        .doc(docId);
    await docRef.update({'taskDesctiption': data});
  }

  @override
  Future<List<Task>> getDailyTasks() async {
    final String? userId = await loadUserId();

    final query =
        await fs.collection('users').doc(userId).collection('dailyTasks').get();

    final list =
        query.docs
            .where((d) => (d.data()['isDuplicate'] != true))
            .map((e) => Task.fromMap(e.data()))
            .toList();
    if (list.any((t) => t.orderIndex != null)) {
      list.sort((a, b) {
        final ai = a.orderIndex ?? 1 << 30;
        final bi = b.orderIndex ?? 1 << 30;
        return ai.compareTo(bi);
      });
    }
    return list;
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

    final list =
        query.docs
            .where((d) => (d.data()['isDuplicate'] != true))
            .map((e) => Task.fromMap(e.data()))
            .toList();
    // For weekly, only 'any' should be ordered by orderIndex; others sorted by weekday rank
    int rank(String? day) {
      switch ((day ?? 'any').toLowerCase()) {
        case 'mon':
          return 1;
        case 'tue':
          return 2;
        case 'wed':
          return 3;
        case 'thu':
          return 4;
        case 'fri':
          return 5;
        case 'sat':
          return 6;
        case 'sun':
          return 7;
        default:
          return 8; // any
      }
    }

    list.sort((a, b) {
      final ra = rank(a.dayOfWeek);
      final rb = rank(b.dayOfWeek);
      if (ra != rb) return ra.compareTo(rb);
      // same bucket; if 'any', sort by orderIndex, else stable by taskId
      if (ra == 8) {
        if (list.any(
              (t) => t.dayOfWeek == null || t.dayOfWeek!.toLowerCase() == 'any',
            ) &&
            list.any((t) => t.orderIndex != null)) {
          final ai = a.orderIndex ?? 1 << 30;
          final bi = b.orderIndex ?? 1 << 30;
          return ai.compareTo(bi);
        }
        return a.taskId.compareTo(b.taskId);
      }
      return a.taskId.compareTo(b.taskId);
    });
    return list;
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

    return query.docs
        .where((d) => (d.data()['isDuplicate'] != true))
        .map((e) => Task.fromMap(e.data()))
        .toList();
  }

  @override
  Future<List<Task>> getQuestTasks() async {
    final String? userId = await loadUserId();

    final query =
        await fs.collection('users').doc(userId).collection('questTasks').get();

    final list =
        query.docs
            .where((d) => (d.data()['isDuplicate'] != true))
            .map((e) => Task.fromMap(e.data()))
            .toList();
    if (list.any((t) => t.orderIndex != null)) {
      list.sort((a, b) {
        final ai = a.orderIndex ?? 1 << 30;
        final bi = b.orderIndex ?? 1 << 30;
        return ai.compareTo(bi);
      });
    }
    return list;
  }

  @override
  Future<void> saveDailyOrder(List<String> orderedTaskIds) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final batch = fs.batch();
    for (int i = 0; i < orderedTaskIds.length; i++) {
      final id = orderedTaskIds[i];
      final docId = _extractCounterPrefix(id);
      final docRef = fs
          .collection('users')
          .doc(userId)
          .collection('dailyTasks')
          .doc(docId);
      batch.update(docRef, {'orderIndex': i});
    }
    await batch.commit();
  }

  @override
  Future<void> saveQuestOrder(List<String> orderedTaskIds) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final batch = fs.batch();
    for (int i = 0; i < orderedTaskIds.length; i++) {
      final id = orderedTaskIds[i];
      final docId = _extractCounterPrefix(id);
      final docRef = fs
          .collection('users')
          .doc(userId)
          .collection('questTasks')
          .doc(docId);
      batch.update(docRef, {'orderIndex': i});
    }
    await batch.commit();
  }

  @override
  Future<void> saveWeeklyAnyOrder(List<String> orderedTaskIds) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final batch = fs.batch();
    for (int i = 0; i < orderedTaskIds.length; i++) {
      final id = orderedTaskIds[i];
      final docId = _extractCounterPrefix(id);
      final docRef = fs
          .collection('users')
          .doc(userId)
          .collection('weeklyTasks')
          .doc(docId);
      batch.update(docRef, {'orderIndex': i});
    }
    await batch.commit();
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

    try {
      return Settings.fromMap(data);
    } catch (e, stack) {
      debugPrint('⚠️ Firestore settings invalid, using defaults: $e');
      debugPrint(stack.toString());
      final bool? skin =
          data['appSkinColor'] is bool ? data['appSkinColor'] as bool : null;
      final String language =
          data['language'] is String ? data['language'] as String : 'English';
      final String location =
          data['location'] is String ? data['location'] as String : 'Berlin';
      final String? startOfWeekRaw = data['startOfWeek'] as String?;
      final Weekday startOfWeek =
          startOfWeekRaw != null
              ? Weekday.values.firstWhere(
                (w) => w.name == startOfWeekRaw,
                orElse: () => Weekday.mon,
              )
              : Weekday.mon;
      final Settings fallback = Settings(
        appSkinColor: skin,
        language: language,
        location: location,
        startOfDay: const TimeOfDay(hour: 7, minute: 15),
        startOfWeek: startOfWeek,
      );
      return fallback;
    }
  }

  @override
  Future<void> setAppUser(
    String userId,
    String userName,
    String email,
    String password,
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

    // Avoid a pre-read which is blocked by rules before ownerUid exists.
    // Merge-write ensures:
    // - create with ownerUid when missing (allowed by create rule)
    // - backfill ownerUid if absent (allowed by update rule special case)
    // - normal update when ownerUid matches current user (allowed)
    final userDoc = fs.collection('users').doc(userId);
    // Build Firestore-safe payload (exclude raw password, keep ownerPassword, include email)
    final savedPassword = await storage.read(key: 'password');
    final payload = <String, dynamic>{
      'userId': user.userId,
      'userName': user.userName,
      'email': user.email,
      'isPowerUser': user.isPowerUser,
      'ownerUid': uid,
      if (savedPassword != null && savedPassword.isNotEmpty)
        'ownerPassword': savedPassword,
    };
    await userDoc.set(payload, SetOptions(merge: true));
  }

  @override
  Future<AppUser?> getAppUser() async {
    final String? userId = await storage.read(key: 'userId');
    if (userId == null) return null;

    final snapshot = await fs.collection('users').doc(userId).get();
    if (!snapshot.exists) return null;

    final data = snapshot.data() ?? {};
    // Combine Firestore profile with local secret fields (prefer Firestore email if present)
    final email =
        (data['email'] as String?) ?? (await storage.read(key: 'email') ?? '');
    final password = await storage.read(key: 'password') ?? '';
    final userName =
        (data['userName'] as String?) ??
        (await storage.read(key: 'name') ?? userId);
    final isPowerUser = (data['isPowerUser'] as bool?) ?? false;
    return AppUser(
      userId: userId,
      userName: userName,
      email: email,
      password: password,
      isPowerUser: isPowerUser,
    );
  }

  // One-time cleanup: remove any legacy 'password' field from the user doc, keeping ownerPassword.
  Future<void> cleanupUserDocLegacyFields() async {
    final String? userId = await storage.read(key: 'userId');
    if (userId == null) return;
    await _ensureUserDoc(userId);
    final userDoc = fs.collection('users').doc(userId);
    await userDoc.set({
      'password': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  String _collectionForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'daily':
        return 'dailyTasks';
      case 'weekly':
        return 'weeklyTasks';
      case 'deadline':
        return 'deadlineTasks';
      case 'quest':
        return 'questTasks';
    }
    throw UnsupportedError('Unsupported task category $category');
  }

  @override
  Future<Task> addSubTask(Task parentTask, String description) {
    throw UnsupportedError(
      'Direct subtask mutations should go through SyncRepository/local store first.',
    );
  }

  @override
  Future<Task> editSubTask(
    Task parentTask,
    String subTaskId,
    String description,
  ) {
    throw UnsupportedError(
      'Direct subtask mutations should go through SyncRepository/local store first.',
    );
  }

  @override
  Future<Task> toggleSubTask(
    Task parentTask,
    String subTaskId,
    bool isDone,
  ) {
    throw UnsupportedError(
      'Direct subtask mutations should go through SyncRepository/local store first.',
    );
  }

  @override
  Future<Task> deleteSubTask(Task parentTask, String subTaskId) {
    throw UnsupportedError(
      'Direct subtask mutations should go through SyncRepository/local store first.',
    );
  }

  @override
  Future<Task> replaceTask(Task originalTask, Task replacement) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');

    await _ensureUserDoc(userId);

    final sourceCollection = _collectionForCategory(originalTask.taskCatagory);
    final targetCollection = _collectionForCategory(replacement.taskCatagory);
    final docId = _extractCounterPrefix(originalTask.taskId);
    final userRef = fs.collection('users').doc(userId);

    if (sourceCollection == targetCollection) {
      final docRef = userRef.collection(sourceCollection).doc(docId);
      await docRef.set(replacement.toMap());
      return replacement;
    }

    final sourceRef = userRef.collection(sourceCollection).doc(docId);
    await sourceRef.delete();

    final targetRef = userRef.collection(targetCollection).doc(docId);
    await targetRef.set(replacement.toMap());
    return replacement;
  }

  @override
  Future<void> toggleDaily(String dataTaskId, bool dataIsDone) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('dailyTasks')
        .doc(docId);
    var updated = false;
    await fs.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        tx.set(docRef, {
          'isDone': dataIsDone,
          'subTasks': const <Map<String, dynamic>>[],
        });
        updated = true;
        return;
      }
      final raw = snap.data();
      if (raw == null) {
        tx.update(docRef, {'isDone': dataIsDone});
        updated = true;
        return;
      }
      final task = Task.fromMap(Map<String, dynamic>.from(raw));
      if (dataIsDone) {
        final hasIncomplete =
            task.subTasks.isNotEmpty && task.subTasks.any((s) => !s.isDone);
        if (hasIncomplete) {
          throw StateError('Cannot complete task with incomplete subtasks');
        }
        task.isDone = true;
      } else {
        task.isDone = false;
        for (final subTask in task.subTasks) {
          subTask.isDone = false;
        }
      }
      tx.update(docRef, {
        'isDone': task.isDone,
        'subTasks': task.subTasks.map((s) => s.toJson()).toList(),
      });
      updated = true;
    });

    if (updated) {
      await PrizeManager(this).trackDailyCompletion(dataIsDone);
    }
  }

  @override
  Future<void> toggleWeekly(String dataTaskId, bool dataIsDone) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final docId = _extractCounterPrefix(dataTaskId);
    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('weeklyTasks')
        .doc(docId);
    var updated = false;
    await fs.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        tx.set(docRef, {
          'isDone': dataIsDone,
          'subTasks': const <Map<String, dynamic>>[],
        });
        updated = true;
        return;
      }
      final raw = snap.data();
      if (raw == null) {
        tx.update(docRef, {'isDone': dataIsDone});
        updated = true;
        return;
      }
      final task = Task.fromMap(Map<String, dynamic>.from(raw));
      if (dataIsDone) {
        final hasIncomplete =
            task.subTasks.isNotEmpty && task.subTasks.any((s) => !s.isDone);
        if (hasIncomplete) {
          throw StateError('Cannot complete task with incomplete subtasks');
        }
        task.isDone = true;
      } else {
        task.isDone = false;
        for (final subTask in task.subTasks) {
          subTask.isDone = false;
        }
      }
      tx.update(docRef, {
        'isDone': task.isDone,
        'subTasks': task.subTasks.map((s) => s.toJson()).toList(),
      });
      updated = true;
    });

    if (updated) {
      await PrizeManager(this).trackWeeklyCompletion(dataIsDone);
    }
  }
}

extension FirestoreUpserts on FirestoreRepository {
  // Extract leading numeric counter from a taskId formatted as "<counter><userId>"
  String _extractCounterPrefix(String taskId) {
    final m = RegExp(r'^\d+').firstMatch(taskId);
    return m?.group(0) ?? taskId; // fallback: use full taskId
  }

  Future<void> _bumpTaskCounterIfNeeded(String userId, int counter) async {
    final counterDocRef = fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter');
    await fs.runTransaction((tx) async {
      final snap = await tx.get(counterDocRef);
      int current = 0;
      if (snap.exists) {
        final data = snap.data();
        current = (data?['taskIdCounter'] as int?) ?? 0;
      }
      if (!snap.exists) {
        tx.set(counterDocRef, {'taskIdCounter': counter});
      } else if (counter > current) {
        tx.update(counterDocRef, {'taskIdCounter': counter});
      }
    });
  }

  Future<void> upsertDailyTask(Task t) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    // Ensure parent user doc exists & is owned
    await _ensureUserDoc(userId);
    final col = fs.collection('users').doc(userId).collection('dailyTasks');
    final docId = _extractCounterPrefix(t.taskId);
    final doc = col.doc(docId);
    await doc.set(t.toMap(), SetOptions(merge: true));
    // Keep Firestore counter >= this task's counter
    final parsed = int.tryParse(docId);
    if (parsed != null) await _bumpTaskCounterIfNeeded(userId, parsed);
  }

  Future<void> upsertWeeklyTask(Task t) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    await _ensureUserDoc(userId);
    final col = fs.collection('users').doc(userId).collection('weeklyTasks');
    final docId = _extractCounterPrefix(t.taskId);
    final doc = col.doc(docId);
    await doc.set(t.toMap(), SetOptions(merge: true));
    final parsed = int.tryParse(docId);
    if (parsed != null) await _bumpTaskCounterIfNeeded(userId, parsed);
  }

  Future<void> upsertDeadlineTask(Task t) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    await _ensureUserDoc(userId);
    final col = fs.collection('users').doc(userId).collection('deadlineTasks');
    final docId = _extractCounterPrefix(t.taskId);
    final doc = col.doc(docId);
    await doc.set(t.toMap(), SetOptions(merge: true));
    final parsed = int.tryParse(docId);
    if (parsed != null) await _bumpTaskCounterIfNeeded(userId, parsed);
  }

  Future<void> upsertQuestTask(Task t) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    await _ensureUserDoc(userId);
    final col = fs.collection('users').doc(userId).collection('questTasks');
    final docId = _extractCounterPrefix(t.taskId);
    final doc = col.doc(docId);
    await doc.set(t.toMap(), SetOptions(merge: true));
    final parsed = int.tryParse(docId);
    if (parsed != null) await _bumpTaskCounterIfNeeded(userId, parsed);
  }

  // Mark all but one document per taskId as duplicates in a collection
  Future<void> markDuplicatesInCollection(String collectionName) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    final col = fs.collection('users').doc(userId).collection(collectionName);
    final snap = await col.get();
    final byTask =
        <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
    for (final d in snap.docs) {
      final tid = d.data()['taskId'];
      if (tid == null) continue;
      byTask.putIfAbsent(tid, () => []).add(d);
    }
    final batch = fs.batch();
    byTask.forEach((tid, docs) {
      if (docs.length <= 1) return;
      // Keep the first, mark the rest
      for (int i = 1; i < docs.length; i++) {
        batch.update(docs[i].reference, {'isDuplicate': true});
      }
    });
    await batch.commit();
  }

  // Batch upsert multiple tasks across categories using a single writeBatch.
  Future<void> batchUpsertTasks(List<Task> tasks) async {
    if (tasks.isEmpty) return;
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    await _ensureUserDoc(userId);

    // Get current counter to detect "new" tasks without per-doc reads
    final counterDocRef = fs
        .collection('users')
        .doc(userId)
        .collection('taskIdCounter')
        .doc('taskIdCounter');
    final counterSnap = await counterDocRef.get();
    int currentCounter = 0;
    if (counterSnap.exists) {
      currentCounter = (counterSnap.data()?['taskIdCounter'] as int?) ?? 0;
    }

    final batch = fs.batch();
    final Set<int> newPrefixes = <int>{};

    for (final t in tasks) {
      final docId = _extractCounterPrefix(t.taskId);
      final parsed = int.tryParse(docId);
      if (parsed != null && parsed > currentCounter) newPrefixes.add(parsed);
      late final CollectionReference<Map<String, dynamic>> col;
      switch (t.taskCatagory) {
        case 'Daily':
          col = fs.collection('users').doc(userId).collection('dailyTasks');
          break;
        case 'Weekly':
          col = fs.collection('users').doc(userId).collection('weeklyTasks');
          break;
        case 'Deadline':
          col = fs.collection('users').doc(userId).collection('deadlineTasks');
          break;
        case 'Quest':
          col = fs.collection('users').doc(userId).collection('questTasks');
          break;
        default:
          continue; // skip unknown categories
      }
      final doc = col.doc(docId);
      batch.set(doc, t.toMap(), SetOptions(merge: true));
    }

    await batch.commit();

    if (newPrefixes.isNotEmpty) {
      final sorted = newPrefixes.toList()..sort();
      // Single-transaction bump: advance by the number of contiguous
      // prefixes immediately following the current value.
      await fs.runTransaction((tx) async {
        final snap = await tx.get(counterDocRef);
        int curr = 0;
        if (snap.exists) {
          curr = (snap.data()?['taskIdCounter'] as int?) ?? 0;
        }
        int n = 0;
        int expected = curr + 1;
        for (final p in sorted) {
          if (p == expected) {
            n++;
            expected++;
          } else if (p > expected) {
            // gap encountered; stop contiguous count
            break;
          } else {
            // p < expected: older prefix, ignore and continue
            continue;
          }
        }
        if (n > 0) {
          if (!snap.exists) {
            tx.set(counterDocRef, {'taskIdCounter': curr + n});
          } else {
            tx.update(counterDocRef, {'taskIdCounter': curr + n});
          }
        }
      });
    }
  }

  // Upsert prize with a deterministic doc ID to avoid duplicates without a read.
  Future<void> upsertPrizeDeterministic(int prizeId, String prizeUrl) async {
    final String? userId = await loadUserId();
    if (userId == null) throw Exception('User ID not found');
    await _ensureUserDoc(userId);
    final safeUrl = base64Url.encode(utf8.encode(prizeUrl));
    final docId = 'p_${prizeId}_$safeUrl';
    final docRef = fs
        .collection('users')
        .doc(userId)
        .collection('prizesWon')
        .doc(docId);
    await docRef.set({
      'prizeId': prizeId,
      'prizeUrl': prizeUrl,
    }, SetOptions(merge: true));
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

