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
      final query =
          await fs
              .collection('users')
              .doc(userId)
              .collection('dailyTasks')
              .where('taskId', isEqualTo: id)
              .limit(1)
              .get();
      if (query.docs.isNotEmpty) {
        batch.update(query.docs.first.reference, {'orderIndex': i});
      }
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
      final query =
          await fs
              .collection('users')
              .doc(userId)
              .collection('questTasks')
              .where('taskId', isEqualTo: id)
              .limit(1)
              .get();
      if (query.docs.isNotEmpty) {
        batch.update(query.docs.first.reference, {'orderIndex': i});
      }
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
      final query =
          await fs
              .collection('users')
              .doc(userId)
              .collection('weeklyTasks')
              .where('taskId', isEqualTo: id)
              .limit(1)
              .get();
      if (query.docs.isNotEmpty) {
        batch.update(query.docs.first.reference, {'orderIndex': i});
      }
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

