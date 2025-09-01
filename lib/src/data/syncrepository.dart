import 'dart:async';
import 'dart:convert';
import 'package:adhd_0_1/src/common/domain/app_user.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';
import 'package:adhd_0_1/src/data/domain/prize_manager.dart';
import 'package:flutter/material.dart';
import 'package:adhd_0_1/src/data/firestore_repository.dart';
import 'package:adhd_0_1/src/data/sharedpreferencesrepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncRepository implements DataBaseRepository {
  final DataBaseRepository mainRepo;
  final DataBaseRepository localRepo;
  final PrizeManager prizeManager;
  bool isSyncing = false;
  bool _pending = false;
  DateTime? _lastSync;
  final Duration _debounce = const Duration(milliseconds: 1200);
  String? _lastSignature; // prevent redundant sync loops
  bool _forceNextSync = false; // allow bypassing signature check when needed
  Timer? _debounceTimer; // throttle frequent sync requests
  // Public notifier for UI to show a tiny sync indicator
  final ValueNotifier<bool> isSyncingNotifier = ValueNotifier<bool>(false);
  // Tombstones: locally record deletions to ensure remote is purged and prevent resurrection
  static const _tombstonesKey = 'sync_tombstones_v1';

  SyncRepository({
    required this.mainRepo,
    required this.localRepo,
    required this.prizeManager,
  });

  @override
  Future<void> addDaily(String data) async {
    await localRepo.addDaily(data);
    triggerSync();
  }

  @override
  Future<void> addDeadline(String data, date, time) async {
    await localRepo.addDeadline(data, date, time);
    triggerSync();
  }

  @override
  Future<void> addPrize(int prizeId, String prizeUrl) async {
    await localRepo.addPrize(prizeId, prizeUrl);
    triggerSync();
  }

  @override
  Future<void> addQuest(String data) async {
    await localRepo.addQuest(data);
    triggerSync();
  }

  @override
  Future<void> addWeekly(String data, day) async {
    await localRepo.addWeekly(data, day);
    triggerSync();
  }

  @override
  Future<void> completeDeadline(String dataTaskId) async {
    await localRepo.completeDeadline(dataTaskId);
    // Record tombstone so remote will be deleted on next sync
    await _addTombstone(dataTaskId, 'Deadline');
    //////////////
    await prizeManager.incrementDeadlineCounter();
    //////////////
    triggerSync();
  }

  @override
  Future<void> completeQuest(String dataTaskId) async {
    await localRepo.completeQuest(dataTaskId);
    // Record tombstone so remote will be deleted on next sync
    await _addTombstone(dataTaskId, 'Quest');
    await prizeManager.incrementQuestCounter();
    triggerSync();
  }

  @override
  Future<void> deleteDaily(String dataTaskId) async {
    await localRepo.deleteDaily(dataTaskId);
    await _addTombstone(dataTaskId, 'Daily');
    triggerSync();
  }

  @override
  Future<void> deleteDeadline(String dataTaskId) async {
    await localRepo.deleteDeadline(dataTaskId);
    await _addTombstone(dataTaskId, 'Deadline');
    triggerSync();
  }

  @override
  Future<void> deleteQuest(String dataTaskId) async {
    await localRepo.deleteQuest(dataTaskId);
    await _addTombstone(dataTaskId, 'Quest');
    triggerSync();
  }

  @override
  Future<void> deleteWeekly(String dataTaskId) async {
    await localRepo.deleteWeekly(dataTaskId);
    await _addTombstone(dataTaskId, 'Weekly');
    triggerSync();
  }

  @override
  Future<void> editDaily(String dataTaskId, String data) async {
    await localRepo.editDaily(dataTaskId, data);
    triggerSync();
  }

  @override
  Future<void> editDeadline(String dataTaskId, String data, date, time) async {
    await localRepo.editDeadline(dataTaskId, data, date, time);
    triggerSync();
  }

  @override
  Future<void> editQuest(String dataTaskId, String data) async {
    await localRepo.editQuest(dataTaskId, data);
    triggerSync();
  }

  @override
  Future<void> editWeekly(String dataTaskId, String data, day) async {
    await localRepo.editWeekly(dataTaskId, data, day);
    triggerSync();
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
    TimeOfDay dataStartOfDay,
    Weekday dataStartOfWeek,
  ) async {
    Settings settings = await localRepo.setSettings(
      dataAppSkinColor,
      dataLanguage,
      dataLocation,
      TimeOfDay(hour: dataStartOfDay.hour, minute: dataStartOfDay.minute),
      Weekday.values[dataStartOfWeek.index],
    );
    triggerSync();

    return settings;
  }

  @override
  Future<void> setAppUser(
    String userId,
    userName,
    email,
    password,
    isPowerUser,
  ) async {
    await localRepo.setAppUser(userId, userName, email, password, isPowerUser);
    triggerSync();
  }

  @override
  Future<AppUser?> getAppUser() async {
    return await localRepo.getAppUser();
  }

  @override
  Future<void> toggleDaily(String taskId, bool isDone) async {
    await localRepo.toggleDaily(taskId, isDone);
    //////////////
    if (isDone) {
      await prizeManager.trackDailyCompletion(isDone);
    }
    //////////////
    triggerSync();
  }

  @override
  Future<void> toggleWeekly(String dataTaskId, bool dataIsDone) async {
    await localRepo.toggleWeekly(dataTaskId, dataIsDone);
    //////////////
    if (dataIsDone) {
      await prizeManager.trackWeeklyCompletion(true);
    }
    //////////////
    triggerSync();
  }

  @override
  Future<void> saveDailyOrder(List<String> orderedTaskIds) async {
    await localRepo.saveDailyOrder(orderedTaskIds);
    await mainRepo.saveDailyOrder(orderedTaskIds);
    // Avoid redundant sync: order was written to remote already.
  }

  @override
  Future<void> saveQuestOrder(List<String> orderedTaskIds) async {
    await localRepo.saveQuestOrder(orderedTaskIds);
    await mainRepo.saveQuestOrder(orderedTaskIds);
    // Avoid redundant sync: order was written to remote already.
  }

  @override
  Future<void> saveWeeklyAnyOrder(List<String> orderedTaskIds) async {
    await localRepo.saveWeeklyAnyOrder(orderedTaskIds);
    await mainRepo.saveWeeklyAnyOrder(orderedTaskIds);
    // Avoid redundant sync: order was written to remote already.
  }

  Future<void> syncAll() async {
    if (isSyncing) {
      _pending = true;
      return;
    }
    // Debounce
    final now = DateTime.now();
    if (_lastSync != null) {
      final since = now.difference(_lastSync!);
      if (since < _debounce) {
        final remaining = _debounce - since;
        if (_debounceTimer?.isActive ?? false) {
          debugPrint('⏳ Debounce active; skip scheduling');
        } else {
          debugPrint('⏳ Debouncing next sync by ${remaining.inMilliseconds}ms');
          _debounceTimer = Timer(remaining, () {
            if (!isSyncing) {
              Future.microtask(syncAll);
            } else {
              _pending = true;
            }
          });
        }
        return;
      }
    }

    isSyncing = true;
    isSyncingNotifier.value = true;
    try {
      debugPrint(
        "🔁 Sync started (force=$_forceNextSync, hadPending=$_pending, lastSync=${_lastSync?.toIso8601String()})",
      );

      // Ensure ownership once before any push to avoid cascading permission-denied
      if (mainRepo is FirestoreRepository) {
        try {
          await (mainRepo as FirestoreRepository)
              .ensureUserOwnershipPreflight();
        } catch (e) {
          debugPrint('⛔ Sync preflight failed (ownership not stamped): $e');
          return; // bail out; will retry on next trigger
        }
      }

      // First, flush any pending tombstones to remote to avoid resurrection
      await _flushTombstones();

      // Calculate local snapshot signature; bail if unchanged since last sync
      final dailies = await localRepo.getDailyTasks();
      final weeklies = await localRepo.getWeeklyTasks();
      final deadlines = await localRepo.getDeadlineTasks();
      final quests = await localRepo.getQuestTasks();
      final prizes = await localRepo.getPrizes();
      final settings = await localRepo.getSettings();
      debugPrint(
        '📊 Local snapshot counts -> dailies:${dailies.length}, weeklies:${weeklies.length}, deadlines:${deadlines.length}, quests:${quests.length}, prizes:${prizes.length}, settings:${settings == null ? 'none' : 'present'}',
      );
      String sigPartTask(Task t) =>
          '${t.taskId}|${t.taskCatagory}|${t.taskDesctiption}|${t.deadlineDate}|${t.deadlineTime}|${t.dayOfWeek}|${t.isDone}|${t.orderIndex ?? ''}';
      final signature = [
        ...dailies.map(sigPartTask),
        ...weeklies.map(sigPartTask),
        ...deadlines.map(sigPartTask),
        ...quests.map(sigPartTask),
        ...prizes.map((p) => 'P:${p.prizeId}:${p.prizeUrl}'),
        if (settings != null)
          'S:${settings.appSkinColor}:${settings.language}:${settings.location}:${settings.startOfDay.hour}:${settings.startOfDay.minute}:${settings.startOfWeek.name}',
      ].join('||');
      final newHash = signature.hashCode;
      final oldHash = _lastSignature?.hashCode;
      debugPrint(
        '🧾 Signature len=${signature.length}, hash(new)=$newHash hash(old)=$oldHash',
      );
      if (!_forceNextSync && _lastSignature == signature) {
        debugPrint('⏸️ Sync skipped (no local changes, force=false).');
        return;
      }

      // Only push changed tasks using per-task checksums stored locally
      final prefs = await SharedPreferences.getInstance();
      final rawChecksums = prefs.getString('sync_checksums_v1');
      final Map<String, dynamic> storedChecksums =
          (rawChecksums == null || rawChecksums.isEmpty)
              ? <String, dynamic>{}
              : (jsonDecode(rawChecksums) as Map<String, dynamic>);

      String checksumFor(Task t) => sigPartTask(t);
      bool hasChanged(Task t) => storedChecksums[t.taskId] != checksumFor(t);

      // Exclude tombstoned IDs from any future upserts
      final tombstoneSet = await _tombstonedIds();
      bool notTombstoned(Task t) => !tombstoneSet.contains(t.taskId);

      final dChanged = dailies.where(hasChanged).where(notTombstoned);
      final wChanged = weeklies.where(hasChanged).where(notTombstoned);
      final dlChanged = deadlines.where(hasChanged).where(notTombstoned);
      final qChanged = quests.where(hasChanged).where(notTombstoned);

      final changedAll = [
        ...dChanged,
        ...wChanged,
        ...dlChanged,
        ...qChanged,
      ];
      debugPrint('⏫ Will push changed only -> ${changedAll.length} tasks');
      if (changedAll.isNotEmpty && mainRepo is FirestoreRepository) {
        await (mainRepo as FirestoreRepository).batchUpsertTasks(changedAll);
      } else {
        if (dChanged.isNotEmpty) await _pushTasks(dChanged.toList());
        if (wChanged.isNotEmpty) await _pushTasks(wChanged.toList());
        if (dlChanged.isNotEmpty) await _pushTasks(dlChanged.toList());
        if (qChanged.isNotEmpty) await _pushTasks(qChanged.toList());
      }

      // Prizes: offline-first; weekly summary will add to Firestore via repository.
      debugPrint(
        '🎁 Skipping prizes sync (handled during weekly summary only)',
      );

      // Settings
      if (settings != null) {
        debugPrint(
          '⚙️ Pushing settings (skin:${settings.appSkinColor}, lang:${settings.language}, loc:${settings.location}, SOD:${settings.startOfDay.hour}:${settings.startOfDay.minute}, SOW:${settings.startOfWeek.name})',
        );
        final settingsSig =
            'S:${settings.appSkinColor}:${settings.language}:${settings.location}:${settings.startOfDay.hour}:${settings.startOfDay.minute}:${settings.startOfWeek.name}';
        final lastSettingsSig = prefs.getString('sync_settings_sig_v1');
        if (lastSettingsSig != settingsSig) {
          await mainRepo.setSettings(
            settings.appSkinColor,
            settings.language,
            settings.location,
            settings.startOfDay,
            settings.startOfWeek,
          );
          await prefs.setString('sync_settings_sig_v1', settingsSig);
        } else {
          debugPrint('⚙️ Settings unchanged; skipping write');
        }
      }

      // Persist per-task checksums for next run
      final Map<String, String> nextChecksums = {
        for (final t in [...dailies, ...weeklies, ...deadlines, ...quests])
          t.taskId: checksumFor(t),
      };
      await (await SharedPreferences.getInstance()).setString(
        'sync_checksums_v1',
        jsonEncode(nextChecksums),
      );
      _lastSignature = signature;
      debugPrint("✅ Sync finished.");
    } catch (e, stack) {
      debugPrint("❌ Sync error: $e\n$stack");
    } finally {
      _forceNextSync = false; // reset after an attempt
      isSyncing = false;
      isSyncingNotifier.value = false;
      _lastSync = DateTime.now();
      if (_pending) {
        _pending = false;
        Future.microtask(syncAll);
      }
    }
  }

  Future<void> _addTombstone(String taskId, String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_tombstonesKey);
      final List<dynamic> list =
          (raw == null || raw.isEmpty) ? [] : (jsonDecode(raw) as List);
      list.add({
        'taskId': taskId,
        'category': category,
        'ts': DateTime.now().toIso8601String(),
      });
      await prefs.setString(_tombstonesKey, jsonEncode(list));
    } catch (e) {
      debugPrint('⚠️ Failed adding tombstone for $taskId: $e');
    }
  }

  Future<Set<String>> _tombstonedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_tombstonesKey);
      if (raw == null || raw.isEmpty) return <String>{};
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => (e as Map<String, dynamic>)['taskId'] as String)
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _flushTombstones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_tombstonesKey);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      if (list.isEmpty) return;
      for (final entry in list) {
        final m = (entry as Map<String, dynamic>);
        final id = m['taskId'] as String?;
        final cat = m['category'] as String?;
        if (id == null || cat == null) continue;
        switch (cat) {
          case 'Daily':
            await mainRepo.deleteDaily(id);
            break;
          case 'Weekly':
            await mainRepo.deleteWeekly(id);
            break;
          case 'Deadline':
            await mainRepo.deleteDeadline(id);
            break;
          case 'Quest':
            await mainRepo.deleteQuest(id);
            break;
          default:
            break;
        }
      }
      // Clear queue after successful flush
      await prefs.remove(_tombstonesKey);
    } catch (e) {
      debugPrint('⚠️ Failed flushing tombstones: $e');
    }
  }

  Future<void> _pushTasks(List<Task> tasks) async {
    for (final t in tasks) {
      try {
        debugPrint(
          '   ↪︎ Upsert ${t.taskCatagory} id=${t.taskId} done=${t.isDone}',
        );
        switch (t.taskCatagory) {
          case 'Daily':
            await _upsertDaily(t);
            break;
          case 'Weekly':
            await _upsertWeekly(t);
            break;
          case 'Deadline':
            await _upsertDeadline(t);
            break;
          case 'Quest':
            await _upsertQuest(t);
            break;
          default:
            debugPrint('   ⚠️ Unknown task category: ${t.taskCatagory}');
            break;
        }
      } catch (e) {
        debugPrint('   ❌ Upsert failed for ${t.taskCatagory} ${t.taskId}: $e');
        rethrow;
      }
    }
  }

  Future<void> _upsertDaily(Task t) async {
    if (mainRepo is FirestoreRepository) {
      await (mainRepo as FirestoreRepository).upsertDailyTask(t);
    } else {
      // Fallback: edit if exists by taskId, else add (may duplicate)
      final remote = await mainRepo.getDailyTasks();
      final exists = remote.any((r) => r.taskId == t.taskId);
      if (exists) {
        await mainRepo.editDaily(t.taskId, t.taskDesctiption);
        await mainRepo.toggleDaily(t.taskId, t.isDone);
      } else {
        await mainRepo.addDaily(t.taskDesctiption);
      }
    }
  }

  Future<void> _upsertWeekly(Task t) async {
    if (mainRepo is FirestoreRepository) {
      await (mainRepo as FirestoreRepository).upsertWeeklyTask(t);
    } else {
      final remote = await mainRepo.getWeeklyTasks();
      final exists = remote.any((r) => r.taskId == t.taskId);
      if (exists) {
        await mainRepo.editWeekly(
          t.taskId,
          t.taskDesctiption,
          Weekday.values.firstWhere(
            (w) => w.name == (t.dayOfWeek ?? 'any'),
            orElse: () => Weekday.any,
          ),
        );
        await mainRepo.toggleWeekly(t.taskId, t.isDone);
      } else {
        await mainRepo.addWeekly(t.taskDesctiption, t.dayOfWeek ?? 'any');
      }
    }
  }

  Future<void> _upsertDeadline(Task t) async {
    if (mainRepo is FirestoreRepository) {
      await (mainRepo as FirestoreRepository).upsertDeadlineTask(t);
    } else {
      final remote = await mainRepo.getDeadlineTasks();
      final exists = remote.any((r) => r.taskId == t.taskId);
      if (exists) {
        await mainRepo.editDeadline(
          t.taskId,
          t.taskDesctiption,
          t.deadlineDate,
          t.deadlineTime,
        );
      } else {
        await mainRepo.addDeadline(
          t.taskDesctiption,
          t.deadlineDate,
          t.deadlineTime,
        );
      }
    }
  }

  Future<void> _upsertQuest(Task t) async {
    if (mainRepo is FirestoreRepository) {
      await (mainRepo as FirestoreRepository).upsertQuestTask(t);
    } else {
      final remote = await mainRepo.getQuestTasks();
      final exists = remote.any((r) => r.taskId == t.taskId);
      if (exists) {
        await mainRepo.editQuest(t.taskId, t.taskDesctiption);
      } else {
        await mainRepo.addQuest(t.taskDesctiption);
      }
    }
  }

  void triggerSync({bool force = false}) {
    // Fire-and-forget with debounce behavior handled in syncAll
    if (force) _forceNextSync = true;
    debugPrint(
      '📣 triggerSync(force=$force) isSyncing=$isSyncing pending=$_pending',
    );
    Future.microtask(syncAll);
  }

  /// Sync locally-won prizes to remote once per day. Uses an idempotent
  /// deterministic upsert when available on FirestoreRepository.
  Future<void> syncPrizesToRemoteIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getString('prizes_last_sync');
      final now = DateTime.now();
      if (last != null) {
        final when = DateTime.tryParse(last);
        if (when != null) {
          final diff = now.difference(when);
          if (diff.inHours < 24) {
            debugPrint('🎁 Prizes recently synced ${diff.inHours}h ago; skip');
            return;
          }
        }
      }

      final prizes = await localRepo.getPrizes();
      if (prizes.isEmpty) {
        await prefs.setString('prizes_last_sync', now.toIso8601String());
        return;
      }

      if (mainRepo is FirestoreRepository) {
        final fsRepo = mainRepo as FirestoreRepository;
        for (final p in prizes) {
          try {
            await fsRepo.upsertPrizeDeterministic(p.prizeId, p.prizeUrl);
          } catch (e) {
            debugPrint('⚠️ Failed to upsert prize ${p.prizeId}: $e');
          }
        }
      } else {
        // best-effort: call generic addPrize which will create new docs
        for (final p in prizes) {
          try {
            await mainRepo.addPrize(p.prizeId, p.prizeUrl);
          } catch (e) {
            debugPrint('⚠️ Failed to push prize ${p.prizeId} to mainRepo: $e');
          }
        }
      }

      await prefs.setString('prizes_last_sync', now.toIso8601String());
      debugPrint('🎁 Prizes sync completed; pushed ${prizes.length} items');
    } catch (e) {
      debugPrint('⚠️ Prizes sync failed: $e');
    }
  }

  // Reverse sync: explicit flows only (settings swap, load saved game)
  Future<void> hydrateLocalFromRemote() async {
    // Fetch all remote
    final dailies = await mainRepo.getDailyTasks();
    final weeklies = await mainRepo.getWeeklyTasks();
    final deadlines = await mainRepo.getDeadlineTasks();
    final quests = await mainRepo.getQuestTasks();
    final prizes = await mainRepo.getPrizes();
    final settings = await mainRepo.getSettings();

    // Overwrite local atomically where possible
    if (localRepo is SharedPreferencesRepository) {
      final sp = localRepo as SharedPreferencesRepository;
      await sp.setDailyTasks(dailies);
      await sp.setWeeklyTasks(weeklies);
      await sp.setDeadlineTasks(deadlines);
      await sp.setQuestTasks(quests);
      await sp.replacePrizes(prizes);
      if (settings != null) {
        await sp.setSettingsLocal(settings);
      }

      // Align the local counter to the max server counter we see in taskIds
      int maxCounter = 0;
      String extract(String tid) {
        final m = RegExp(r'^\d+').firstMatch(tid);
        return m?.group(0) ?? '0';
      }

      for (final t in [...dailies, ...weeklies, ...deadlines, ...quests]) {
        final n = int.tryParse(extract(t.taskId)) ?? 0;
        if (n > maxCounter) maxCounter = n;
      }
      // Always set, to avoid carrying over previous user's counter
      await sp.setLocalTaskCounterAbsolute(maxCounter);
    } else {
      // Fallback: clear and re-add through the abstract API
      for (final t in await localRepo.getDailyTasks()) {
        await localRepo.deleteDaily(t.taskId);
      }
      for (final t in dailies) {
        await localRepo.addDaily(t.taskDesctiption);
        await localRepo.toggleDaily(t.taskId, t.isDone);
      }
      for (final t in await localRepo.getWeeklyTasks()) {
        await localRepo.deleteWeekly(t.taskId);
      }
      for (final t in weeklies) {
        await localRepo.addWeekly(t.taskDesctiption, t.dayOfWeek ?? 'any');
        await localRepo.toggleWeekly(t.taskId, t.isDone);
      }
      for (final t in await localRepo.getDeadlineTasks()) {
        await localRepo.deleteDeadline(t.taskId);
      }
      for (final t in deadlines) {
        await localRepo.addDeadline(
          t.taskDesctiption,
          t.deadlineDate,
          t.deadlineTime,
        );
      }
      for (final t in await localRepo.getQuestTasks()) {
        await localRepo.deleteQuest(t.taskId);
      }
      for (final t in quests) {
        await localRepo.addQuest(t.taskDesctiption);
      }
    }
  }

  // One-time dedup marking (safe mode: mark-only)
  Future<void> runOneTimeDedupMarking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const flag = 'dedup_mark_done_v1';
      if (prefs.getBool(flag) == true) return;
      if (mainRepo is! FirestoreRepository) return;
      final repo = mainRepo as FirestoreRepository;
      await repo.markDuplicatesInCollection('dailyTasks');
      await repo.markDuplicatesInCollection('weeklyTasks');
      await repo.markDuplicatesInCollection('deadlineTasks');
      await repo.markDuplicatesInCollection('questTasks');
      await prefs.setBool(flag, true);
      debugPrint('✅ One-time duplicate marking completed');
    } catch (e) {
      debugPrint('⚠️ One-time duplicate marking skipped: $e');
    }
  }
}
