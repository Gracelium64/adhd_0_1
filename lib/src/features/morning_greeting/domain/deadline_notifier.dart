import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;

import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/navigation/notification_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:adhd_0_1/src/common/diagnostics/diag_log.dart';
import 'package:adhd_0_1/src/common/notifications/awesome_notif_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/data/domain/prefs_keys.dart';

/// Schedules a small "heads up" notification shortly after the Daily Quote
/// when there's something due today/tomorrow.
class DeadlineNotifier {
  DeadlineNotifier._();
  static final DeadlineNotifier instance = DeadlineNotifier._();

  // Channel metadata (must match AwesomeNotifService)
  static const String _channelId = AwesomeNotifService.deadlineChannelKey;
  // Name/description are defined where channel is created (AwesomeNotifService)

  // Unique ID for this notification
  static const int _notificationId = 11001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _scheduling = false;

  Future<bool> _isSilentNotificationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(PrefsKeys.silentNotificationKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> init() async {
    if (_initialized) return;

    // Timezone init (match DailyQuoteNotifier behavior)
    try {
      tz.initializeTimeZones();
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
      debugPrint('[DeadlineNotifier] Timezone set to $localTz');
      DiagnosticsLog.instance.log('Timezone set to $localTz');
    } catch (e) {
      debugPrint('[DeadlineNotifier] Timezone init failed ($e). Using UTC');
      DiagnosticsLog.instance.log('Timezone init failed: $e. Using UTC');
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Keep simple for now: open Dailys tab
        NotificationRouter.instance.openDailys();
      },
    );

    // Channel/sound handled by AwesomeNotifService during app init

    _initialized = true;
    DiagnosticsLog.instance.log('Plugin initialized and channel ensured');
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedule a one-shot alert 5–30 seconds after the next DailyQuote time
  /// if there are relevant tasks for that day.
  Future<void> scheduleRelativeToDaily(
    TimeOfDay dailyStart,
    DataBaseRepository repo,
  ) async {
    if (_scheduling) {
      debugPrint('[DeadlineNotifier] schedule in progress; skipping');
      DiagnosticsLog.instance.log(
        'scheduleRelativeToDaily skipped (in progress)',
      );
      return;
    }
    _scheduling = true;
    try {
      await init();
      await requestPermissions();

      final silentNotification = await _isSilentNotificationEnabled();
      final resolvedChannelKey =
          silentNotification
              ? AwesomeNotifService.deadlineSilentChannelKey
              : AwesomeNotifService.deadlineChannelKey;

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      // Next occurrence of the daily start time
      tz.TZDateTime nextBase = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        dailyStart.hour,
        dailyStart.minute,
      );
      if (!nextBase.isAfter(now)) {
        nextBase = nextBase.add(const Duration(days: 1));
      }

      // Random offset in seconds in [5, 30]
      final rnd = Random();
      final int offsetSec = 5 + rnd.nextInt(30 - 5 + 1);
      final tz.TZDateTime fireAt = nextBase.add(Duration(seconds: offsetSec));

      // Determine whether we should notify for the "current day" of firing
      final DateTime fireDay = DateTime(fireAt.year, fireAt.month, fireAt.day);
      final DateTime nextDay = fireDay.add(const Duration(days: 1));

      final shouldNotify = await _shouldNotifyForDays(
        repo,
        fireDay,
        nextDay,
      );
      DiagnosticsLog.instance.log(
        'shouldNotify=$shouldNotify for $fireDay / $nextDay',
      );

      if (!shouldNotify) {
        await _plugin.cancel(_notificationId);
        debugPrint('[DeadlineNotifier] No due items; nothing scheduled.');
        return;
      }

      // Using Awesome Notifications for a persistent notification at fireAt
      final body = await _composeBodyAsync(repo, fireDay, nextDay);
      // Also prime native Android path: save composed body and schedule native alarm
      // so that native receivers (boot / exact alarms) show the same message when triggered.
      if (Platform.isAndroid) {
        const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
        try {
          await platform.invokeMethod('saveNextDeadlineMessage', {
            'message': body,
          });
        } catch (e) {
          debugPrint('[DeadlineNotifier] saveNextDeadlineMessage failed: $e');
        }
        try {
          await platform.invokeMethod('setSilentNotification', {
            'value': silentNotification,
          });
        } catch (_) {}
        try {
          await platform.invokeMethod('scheduleNextDeadlineAlarm', {
            'hour': dailyStart.hour,
            'minute': dailyStart.minute,
            'offsetSec': offsetSec,
          });
        } catch (e) {
          debugPrint('[DeadlineNotifier] scheduleNextDeadlineAlarm failed: $e');
        }
      }
      await AwesomeNotifService.instance.schedulePersistentAt(
        channelKey: resolvedChannelKey,
        id: _notificationId,
        when: fireAt.toLocal(),
        title: "Today's focus",
        body: body,
        payload: {'route': 'dailys'},
        groupKey: AwesomeNotifService.deadlineGroupKey,
        locked: true,
        autoDismissible: false,
      );
      DiagnosticsLog.instance.log(
        'Awesome scheduled at $fireAt with body len=${body.length}',
      );
    } finally {
      _scheduling = false;
      DiagnosticsLog.instance.log('scheduleRelativeToDaily finished');
    }
  }

  /// Quick test fire (ignores repository conditions)
  Future<void> showTestNow() async {
    await init();
    await requestPermissions();
    final silentNotification = await _isSilentNotificationEnabled();
    final resolvedChannelKey =
        silentNotification
            ? AwesomeNotifService.deadlineSilentChannelKey
            : AwesomeNotifService.deadlineChannelKey;
    await AwesomeNotifService.instance.showPersistent(
      channelKey: resolvedChannelKey,
      id: _notificationId,
      title: "Today's focus",
      body: 'Tasks may be due today/tomorrow. Tap to review.',
      payload: {'route': 'dailys'},
      groupKey: AwesomeNotifService.deadlineGroupKey,
      locked: true,
      autoDismissible: false,
    );
    DiagnosticsLog.instance.log('Awesome showTestNow');
  }

  Future<void> cancelScheduled() async {
    await init();
    await AwesomeNotifService.instance.cancel(_notificationId);
    DiagnosticsLog.instance.log('Awesome canceled id=$_notificationId');
  }

  Future<void> debugStatus() async {
    await init();
    final android =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final enabled = await android?.areNotificationsEnabled() ?? true;
    final pending = await _plugin.pendingNotificationRequests();
    debugPrint('[DeadlineNotifier] Notifications enabled: $enabled');
    debugPrint('[DeadlineNotifier] Pending notifications: ${pending.length}');
    DiagnosticsLog.instance.log(
      'areNotificationsEnabled=$enabled, pending=${pending.length}',
    );
    // Enrich: list pending IDs/titles (truncated)
    for (final p in pending.take(5)) {
      final title = (p.title ?? '').replaceAll('\n', ' ');
      final body = (p.body ?? '').replaceAll('\n', ' ');
      await DiagnosticsLog.instance.log(
        'pending: id=${p.id} t="$title" b.len=${body.length}',
      );
    }
    if (Platform.isAndroid) {
      const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
      try {
        final diag = await platform.invokeMethod('diagnosticSnapshot');
        await DiagnosticsLog.instance.log('nativeDiag=${diag.toString()}');
      } catch (e) {
        await DiagnosticsLog.instance.log('nativeDiag failed: $e');
      }
    }
    for (final p in pending) {
      debugPrint('  • id=${p.id}, title=${p.title}, body=${p.body}');
    }
  }

  /// Collects a detailed debug snapshot across plugin and native sides
  Future<String> collectDebugSnapshot(DataBaseRepository repo) async {
    await init();
    final b = StringBuffer();
    b.writeln('== Deadline Debug Snapshot ==');
    // Permissions
    final android =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final enabled = await android?.areNotificationsEnabled() ?? true;
    b.writeln('Notifications enabled (Android): $enabled');

    // Pending notifications (plugin)
    final pending = await _plugin.pendingNotificationRequests();
    b.writeln('Pending (plugin): ${pending.length}');
    for (final p in pending) {
      b.writeln('  - id=${p.id} title=${p.title} body=${p.body}');
    }

    // Native prefs snapshot
    if (Platform.isAndroid) {
      const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
      try {
        final snap = await platform.invokeMethod('debugPrefsSnapshot');
        b.writeln('Native prefs: $snap');
      } catch (e) {
        b.writeln('Native prefs read failed: $e');
      }
      try {
        final diag = await platform.invokeMethod('diagnosticSnapshot');
        b.writeln('Native diagnostic: $diag');
      } catch (e) {
        b.writeln('Native diagnostic failed: $e');
      }
    }

    // Next composed message preview (recomputed)
    try {
      final now = DateTime.now();
      final fireDay = DateTime(now.year, now.month, now.day);
      final nextDay = fireDay.add(const Duration(days: 1));
      final body = await _composeBodyAsync(repo, fireDay, nextDay);
      b.writeln('Composed body (now): ${body.replaceAll('\n', ' | ')}');
    } catch (e) {
      b.writeln('Compose failed: $e');
    }

    return b.toString();
  }

  /// Android-only: show a native deadline notification immediately using a composed message
  Future<void> androidShowNativeNow(DataBaseRepository repo) async {
    if (!Platform.isAndroid) return;
    await init();
    // Compose body similar to scheduled path using today and tomorrow
    final now = DateTime.now();
    final fireDay = DateTime(now.year, now.month, now.day);
    final nextDay = fireDay.add(const Duration(days: 1));
    final body = await _composeBodyAsync(repo, fireDay, nextDay);

    const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
    try {
      await platform.invokeMethod('showDeadlineNowWithBody', {'body': body});
      debugPrint('[DeadlineNotifier] Requested native showDeadlineNow');
      DiagnosticsLog.instance.log(
        'Native show now with body len=${body.length}',
      );
    } catch (e) {
      debugPrint('[DeadlineNotifier] showDeadlineNow failed: $e');
      DiagnosticsLog.instance.log('showDeadlineNow failed: $e');
    }
  }

  /// Plugin-only: schedule a test notification in [seconds] seconds (bypasses native)
  Future<void> pluginScheduleInSeconds(int seconds) async {
    await init();
    await requestPermissions();
    final now = tz.TZDateTime.now(tz.local);
    final when = now.add(Duration(seconds: seconds));
    // For testing we now use Awesome to mirror production behavior
    await AwesomeNotifService.instance.schedulePersistentAt(
      channelKey: _channelId,
      id: _notificationId,
      when: when.toLocal(),
      title: "Today's focus",
      body: 'Test in $seconds seconds',
      payload: {'route': 'dailys'},
      groupKey: AwesomeNotifService.deadlineGroupKey,
      locked: true,
      autoDismissible: false,
    );
  }

  /// Android-only: schedule a native deadline in [seconds] seconds
  Future<void> androidScheduleInSeconds(int seconds) async {
    if (!Platform.isAndroid) return;
    const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
    try {
      await platform.invokeMethod('scheduleDeadlineIn', {'seconds': seconds});
    } catch (e) {
      debugPrint('[DeadlineNotifier] scheduleDeadlineIn failed: $e');
    }
  }

  /// Android-only: compose and persist the next message body for native alert
  Future<void> primeAndroidNextMessageFromRepo(DataBaseRepository repo) async {
    if (!Platform.isAndroid) return;
    await init();
    final now = DateTime.now();
    final fireDay = DateTime(now.year, now.month, now.day);
    final nextDay = fireDay.add(const Duration(days: 1));
    final body = await _composeBodyAsync(repo, fireDay, nextDay);
    const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
    try {
      await platform.invokeMethod('saveNextDeadlineMessage', {
        'message': body,
      });
      debugPrint('[DeadlineNotifier] Primed next native message');
    } catch (e) {
      debugPrint('[DeadlineNotifier] saveNextDeadlineMessage failed: $e');
    }
  }

  Future<void> rescheduleFromRepository(DataBaseRepository repo) async {
    final settings = await repo.getSettings();
    final t = settings?.startOfDay ?? const TimeOfDay(hour: 7, minute: 15);
    await scheduleRelativeToDaily(t, repo);
  }

  // ===== Helpers =====
  Future<bool> _shouldNotifyForDays(
    DataBaseRepository repo,
    DateTime fireDay,
    DateTime nextDay,
  ) async {
    try {
      final List<Task> deadlineTasks = await repo.getDeadlineTasks();
      final List<Task> weeklyTasks = await repo.getWeeklyTasks();

      bool hasDeadlineToday = _hasDeadlineOn(deadlineTasks, fireDay);
      bool hasDeadlineTomorrow = _hasDeadlineOn(deadlineTasks, nextDay);
      bool hasWeeklyToday = _hasWeeklyForDay(weeklyTasks, fireDay);
      // Also check weekly tasks scheduled for the next day so weekly tasks
      // that fall on "tomorrow" still trigger the notifier.
      bool hasWeeklyTomorrow = _hasWeeklyForDay(weeklyTasks, nextDay);
      return hasDeadlineToday ||
          hasDeadlineTomorrow ||
          hasWeeklyToday ||
          hasWeeklyTomorrow;
    } catch (e) {
      debugPrint('[DeadlineNotifier] _shouldNotifyForDays error: $e');
      return false;
    }
  }

  Future<String> _composeBodyAsync(
    DataBaseRepository repo,
    DateTime fireDay,
    DateTime nextDay,
  ) async {
    // Collect items into categories to control order and ensure one-per-line output
    final List<String> todayLines = [];
    final List<String> tomorrowLines = [];
    final List<String> nextWeekLines = [];
    final List<String> weeklyTodayLines = [];
    final List<String> weeklyTomorrowLines = [];

    try {
      final deadlines = await repo.getDeadlineTasks();
      for (final t in deadlines) {
        if (t.isDone) continue;
        final d = _parseDate(t.deadlineDate);
        if (d == null) continue;
        final desc = t.taskDesctiption.trim();
        if (d.year == fireDay.year &&
            d.month == fireDay.month &&
            d.day == fireDay.day) {
          todayLines.add('$desc is today!');
          continue;
        }
        if (d.year == nextDay.year &&
            d.month == nextDay.month &&
            d.day == nextDay.day) {
          tomorrowLines.add('$desc is tomorrow!');
          continue;
        }

        // Check the same weekday next week (fireDay + 7 days)
        final nextWeek = DateTime(
          fireDay.year,
          fireDay.month,
          fireDay.day,
        ).add(const Duration(days: 7));
        if (d.year == nextWeek.year &&
            d.month == nextWeek.month &&
            d.day == nextWeek.day) {
          nextWeekLines.add('$desc is next week');
        }
      }
    } catch (_) {}

    try {
      final weekly = await repo.getWeeklyTasks();
      final today = _weekdayAbbrev(fireDay.weekday);
      final tomorrow = _weekdayAbbrev(nextDay.weekday);
      for (final t in weekly) {
        if (t.isDone) continue;
        final raw = t.dayOfWeek;
        if (raw == null) continue;
        final low = raw.toLowerCase();
        if (low == today) {
          final desc = t.taskDesctiption.trim();
          weeklyTodayLines.add("Don't forget today: $desc");
        } else if (low == tomorrow) {
          final desc = t.taskDesctiption.trim();
          weeklyTomorrowLines.add("Don't forget tomorrow: $desc");
        }
      }
    } catch (_) {}

    // Combine in priority order: today, tomorrow, next week, today from weekly
    final lines = <String>[
      ...todayLines,
      ...tomorrowLines,
      ...weeklyTomorrowLines,
      ...nextWeekLines,
      ...weeklyTodayLines,
    ];

    if (lines.isEmpty) {
      return 'Check your tasks for today and tomorrow.';
    }
    return lines.join('\n');
  }

  bool _hasDeadlineOn(List<Task> tasks, DateTime day) {
    for (final t in tasks) {
      if (t.isDone) continue;
      final d = _parseDate(t.deadlineDate);
      if (d == null) continue;
      if (d.year == day.year && d.month == day.month && d.day == day.day) {
        return true;
      }
    }
    return false;
  }

  bool _hasWeeklyForDay(List<Task> tasks, DateTime day) {
    final abbrev = _weekdayAbbrev(day.weekday);
    for (final t in tasks) {
      if (t.isDone) continue;
      final raw = t.dayOfWeek;
      if (raw == null) continue;
      if (raw.toLowerCase() == abbrev) return true;
    }
    return false;
  }

  String _weekdayAbbrev(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'mon';
      case DateTime.tuesday:
        return 'tue';
      case DateTime.wednesday:
        return 'wed';
      case DateTime.thursday:
        return 'thu';
      case DateTime.friday:
        return 'fri';
      case DateTime.saturday:
        return 'sat';
      case DateTime.sunday:
      default:
        return 'sun';
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final parts = dateStr.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year2 = int.tryParse(parts[2]);
    if (day == null || month == null || year2 == null) return null;
    return DateTime(2000 + year2, month, day);
  }
}
