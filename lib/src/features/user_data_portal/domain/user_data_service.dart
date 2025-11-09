import 'dart:math';

import 'package:adhd_0_1/src/common/domain/app_user.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/sharedpreferencesrepository.dart';
import 'package:adhd_0_1/src/data/syncrepository.dart';
import 'package:adhd_0_1/src/features/prizes/domain/available_prizes.dart';
import 'package:adhd_0_1/src/features/user_data_portal/domain/user_data_snapshot.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataService {
  static const int _schemaVersion = 1;

  final SyncRepository repository;
  final FlutterSecureStorage secureStorage;
  final Random _random;

  UserDataService({
    required this.repository,
    FlutterSecureStorage? secureStorage,
    Random? random,
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _random = random ?? Random();

  Future<UserDataSnapshot> buildSnapshot({
    bool includeBonusPrize = false,
  }) async {
    final user = await repository.getAppUser();
    final settings = await repository.getSettings();
    final dailies = await repository.getDailyTasks();
    final weeklies = await repository.getWeeklyTasks();
    final deadlines = await repository.getDeadlineTasks();
    final quests = await repository.getQuestTasks();
    final prizes = await repository.getPrizes();
    final secureValues = await secureStorage.readAll();
    final remoteOptOut = await repository.getRemoteWriteOptOut();

    final prizesAggregate = List<Prizes>.from(prizes);
    Prizes? bonusPrize;
    if (includeBonusPrize) {
      bonusPrize = _pickBonusPrize(prizesAggregate);
      if (bonusPrize != null) {
        prizesAggregate.add(bonusPrize);
      }
    }

    return UserDataSnapshot(
      schemaVersion: _schemaVersion,
      generatedAtUtc: DateTime.now().toUtc(),
      user: user,
      settings: settings,
      dailyTasks: dailies,
      weeklyTasks: weeklies,
      deadlineTasks: deadlines,
      questTasks: quests,
      prizes: prizesAggregate,
      bonusPrize: bonusPrize,
      secureStorage: secureValues,
      remoteSyncOptOut: remoteOptOut,
    );
  }

  Prizes? _pickBonusPrize(List<Prizes> existing) {
    final existingIds = existing.map((p) => p.prizeId).toSet();
    final candidates = availablePrizes
        .where((p) => !existingIds.contains(p.prizeId))
        .toList(growable: false);
    final pool = candidates.isNotEmpty ? candidates : availablePrizes;
    if (pool.isEmpty) return null;
    return pool[_random.nextInt(pool.length)];
  }

  Future<void> applySnapshot(
    UserDataSnapshot snapshot, {
    bool triggerRemoteSync = true,
  }) async {
    final local = repository.localRepo;
    if (local is! SharedPreferencesRepository) {
      throw StateError(
        'UserDataService requires SharedPreferencesRepository as the local cache implementation.',
      );
    }
    final spRepo = local;

    await spRepo.setDailyTasks(snapshot.dailyTasks);
    await spRepo.setWeeklyTasks(snapshot.weeklyTasks);
    await spRepo.setDeadlineTasks(snapshot.deadlineTasks);
    await spRepo.setQuestTasks(snapshot.questTasks);

    final dedupedPrizes = _dedupePrizes(snapshot.prizes, snapshot.bonusPrize);
    await spRepo.replacePrizes(dedupedPrizes);

    if (snapshot.settings != null) {
      await spRepo.setSettingsLocal(snapshot.settings!);
    }

    if (snapshot.user != null) {
      final user = snapshot.user!;
      await spRepo.setAppUser(
        user.userId,
        user.userName,
        user.email,
        user.password,
        user.isPowerUser,
      );
    }

    await _updateSecureStorage(snapshot.secureStorage, snapshot.user);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sync_checksums_v1');
    await prefs.remove('sync_settings_sig_v1');
    await prefs.remove('sync_tombstones_v1');
    await prefs.remove('prizes_last_sync');

    await repository.setRemoteWriteOptOut(
      snapshot.remoteSyncOptOut,
      triggerSyncNow: false,
    );

    await _alignTaskCounter(spRepo, snapshot.allTasks);
    repository.invalidateSignatureCache();

    if (triggerRemoteSync && !snapshot.remoteSyncOptOut) {
      repository.triggerSync(force: true);
    }
  }

  List<Prizes> _dedupePrizes(List<Prizes> prizes, Prizes? bonus) {
    final dedupe = <int, Prizes>{for (final p in prizes) p.prizeId: p};
    if (bonus != null) {
      dedupe[bonus.prizeId] = bonus;
    }
    return dedupe.values.toList();
  }

  Future<void> _updateSecureStorage(
    Map<String, String> snapshotValues,
    AppUser? user,
  ) async {
    final desired = Map<String, String>.from(snapshotValues);
    if (user != null) {
      desired.putIfAbsent('userId', () => user.userId);
      desired.putIfAbsent('password', () => user.password);
      desired.putIfAbsent('email', () => user.email);
    }

    for (final entry in desired.entries) {
      await secureStorage.write(key: entry.key, value: entry.value);
    }
  }

  Future<void> _alignTaskCounter(
    SharedPreferencesRepository repo,
    List<Task> tasks,
  ) async {
    int maxCounter = 0;
    for (final task in tasks) {
      final match = RegExp(r'^\d+').firstMatch(task.taskId);
      if (match == null) continue;
      final counter = int.tryParse(match.group(0) ?? '0') ?? 0;
      if (counter > maxCounter) {
        maxCounter = counter;
      }
    }
    await repo.setLocalTaskCounterAbsolute(maxCounter);
  }
}
