import 'dart:convert';

import 'package:adhd_0_1/src/common/domain/app_user.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';

class UserDataSnapshot {
  final int schemaVersion;
  final DateTime generatedAtUtc;
  final AppUser? user;
  final Settings? settings;
  final List<Task> dailyTasks;
  final List<Task> weeklyTasks;
  final List<Task> deadlineTasks;
  final List<Task> questTasks;
  final List<Prizes> prizes;
  final Prizes? bonusPrize;
  final Map<String, String> secureStorage;
  final bool remoteSyncOptOut;

  const UserDataSnapshot({
    required this.schemaVersion,
    required this.generatedAtUtc,
    required this.user,
    required this.settings,
    required this.dailyTasks,
    required this.weeklyTasks,
    required this.deadlineTasks,
    required this.questTasks,
    required this.prizes,
    required this.bonusPrize,
    required this.secureStorage,
    required this.remoteSyncOptOut,
  });

  List<Task> get allTasks => [
    ...dailyTasks,
    ...weeklyTasks,
    ...deadlineTasks,
    ...questTasks,
  ];

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'generatedAtUtc': generatedAtUtc.toIso8601String(),
      'metadata': {
        'remoteSyncOptOut': remoteSyncOptOut,
      },
      if (user != null) 'user': user!.toJson(),
      if (settings != null) 'settings': settings!.toJson(),
      'secureStorage': secureStorage,
      'tasks': {
        'daily': dailyTasks.map((t) => t.toJson()).toList(),
        'weekly': weeklyTasks.map((t) => t.toJson()).toList(),
        'deadlines': deadlineTasks.map((t) => t.toJson()).toList(),
        'quests': questTasks.map((t) => t.toJson()).toList(),
      },
      'prizes': prizes.map((p) => p.toJson()).toList(),
      if (bonusPrize != null) 'bonusPrize': bonusPrize!.toJson(),
    };
  }

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  static UserDataSnapshot fromJsonString(String jsonString) {
    return UserDataSnapshot.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  factory UserDataSnapshot.fromJson(Map<String, dynamic> json) {
    final schema = (json['schemaVersion'] as int?) ?? 1;
    final generatedRaw = json['generatedAtUtc'] as String?;
    final generatedAt =
        generatedRaw != null ? DateTime.tryParse(generatedRaw) : null;

    final metadata = (json['metadata'] as Map<String, dynamic>?) ?? const {};
    final remoteOptOut =
        metadata['remoteSyncOptOut'] == true ||
        json['remoteSyncOptOut'] == true;

    final userMap = json['user'] as Map<String, dynamic>?;
    final settingsMap = json['settings'] as Map<String, dynamic>?;

    Map<String, dynamic> ensureMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      return Map<String, dynamic>.from(value as Map);
    }

    List<Task> parseTasks(String key) {
      final raw =
          ((json['tasks'] as Map<String, dynamic>?) ?? const {})[key]
              as List<dynamic>?;
      if (raw == null) return const [];
      return raw
          .map((e) => Task.fromJson(ensureMap(e)))
          .toList(growable: false);
    }

    List<Prizes> parsePrizes() {
      final raw = json['prizes'] as List<dynamic>?;
      if (raw == null) return const [];
      return raw
          .map((e) => Prizes.fromJson(ensureMap(e)))
          .toList(growable: false);
    }

    final secureStorageRaw =
        (json['secureStorage'] as Map<String, dynamic>?) ?? const {};
    final secureStorage = secureStorageRaw.map(
      (key, value) => MapEntry(key, value == null ? '' : value.toString()),
    );

    Prizes? parseBonusPrize() {
      final raw = json['bonusPrize'];
      if (raw == null) return null;
      return Prizes.fromJson(ensureMap(raw));
    }

    return UserDataSnapshot(
      schemaVersion: schema,
      generatedAtUtc: generatedAt?.toUtc() ?? DateTime.now().toUtc(),
      user: userMap != null ? AppUser.fromJson(userMap) : null,
      settings: settingsMap != null ? Settings.fromJson(settingsMap) : null,
      dailyTasks: parseTasks('daily'),
      weeklyTasks: parseTasks('weekly'),
      deadlineTasks: parseTasks('deadlines'),
      questTasks: parseTasks('quests'),
      prizes: parsePrizes(),
      bonusPrize: parseBonusPrize(),
      secureStorage: secureStorage,
      remoteSyncOptOut: remoteOptOut,
    );
  }
}
