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

/// Schedules a small "heads up" notification shortly after the Daily Quote
/// when there's something due today/tomorrow.
class DeadlineNotifier {
  DeadlineNotifier._();
  static final DeadlineNotifier instance = DeadlineNotifier._();

  // Channel metadata
  static const String _channelId = 'deadline_alerts_channel_v1';
  static const String _channelName = 'Task Deadlines';
  static const String _channelDescription =
      'Alerts for deadlines due today/tomorrow and weekly tasks for today';

  // Unique ID for this notification
  static const int _notificationId = 11001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _scheduling = false;

  Future<void> init() async {
    if (_initialized) return;

    // Timezone init (match DailyQuoteNotifier behavior)
    try {
      tz.initializeTimeZones();
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
      debugPrint('[DeadlineNotifier] Timezone set to $localTz');
    } catch (e) {
      debugPrint('[DeadlineNotifier] Timezone init failed ($e). Using UTC');
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

    // Android channel with custom sound
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('my_sound'),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
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
      return;
    }
    _scheduling = true;
    try {
      await init();
      await requestPermissions();

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

      if (!shouldNotify) {
        await _plugin.cancel(_notificationId);
        debugPrint('[DeadlineNotifier] No due items; nothing scheduled.');
        return;
      }

      // Build notification details once
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('my_sound'),
          );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'my_sound.wav',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      try {
        // Branch by platform using runtime Platform class
        if (Platform.isAndroid) {
          // Android: prefer native exact alarm chain; fall back to plugin if not allowed
          const platform = MethodChannel('shadowapp.grace6424.adhd01/alarm');
          bool allowed = true;
          try {
            final dynamic res = await platform.invokeMethod(
              'hasExactAlarmPermission',
            );
            if (res is bool) allowed = res;
          } catch (e) {
            debugPrint('[DeadlineNotifier] hasExactAlarmPermission failed: $e');
          }

          if (!allowed) {
            try {
              await platform.invokeMethod('requestExactAlarmPermission');
            } catch (_) {}
            debugPrint('[DeadlineNotifier] Falling back to plugin schedule');
            await _plugin.cancel(_notificationId);
            final body = await _composeBodyAsync(repo, fireDay, nextDay);
            await _plugin.zonedSchedule(
              _notificationId,
              "Today's focus",
              body,
              fireAt,
              const NotificationDetails(
                android: androidDetails,
                iOS: iosDetails,
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.time,
              payload: 'open_app',
            );
          } else {
            // Cancel any prior plugin schedule to avoid duplicates
            await _plugin.cancel(_notificationId);
            // Save the composed body so native can display it
            final body = await _composeBodyAsync(repo, fireDay, nextDay);
            await platform.invokeMethod('saveNextDeadlineMessage', {
              'message': body,
            });
            await platform.invokeMethod('scheduleNextDeadlineAlarm', {
              'hour': dailyStart.hour,
              'minute': dailyStart.minute,
              'offsetSec': offsetSec,
            });
            debugPrint(
              '[DeadlineNotifier] Scheduled native deadline alarm with offset=$offsetSec',
            );
          }
        } else {
          // iOS: schedule a fixed-offset daily repeating notification for reliability
          await _plugin.cancel(_notificationId);
          final body = await _composeBodyAsync(repo, fireDay, nextDay);
          await _plugin.zonedSchedule(
            _notificationId,
            "Today's focus",
            body,
            fireAt,
            const NotificationDetails(android: androidDetails, iOS: iosDetails),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'open_app',
          );
          debugPrint(
            '[DeadlineNotifier] Scheduled iOS daily at ${fireAt.toLocal()}',
          );
        }
      } on PlatformException catch (e) {
        debugPrint('[DeadlineNotifier] Schedule failed ($e)');
      }
    } finally {
      _scheduling = false;
    }
  }

  /// Quick test fire (ignores repository conditions)
  Future<void> showTestNow() async {
    await init();
    await requestPermissions();
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('my_sound'),
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'my_sound.wav',
    );
    await _plugin.show(
      _notificationId,
      "Today's focus",
      'Tasks may be due today/tomorrow. Tap to review.',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'open_app',
    );
  }

  Future<void> cancelScheduled() async {
    await init();
    await _plugin.cancel(_notificationId);
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
    for (final p in pending) {
      debugPrint('  • id=${p.id}, title=${p.title}, body=${p.body}');
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
      return hasDeadlineToday || hasDeadlineTomorrow || hasWeeklyToday;
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
    final List<String> lines = [];

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
          lines.add('$desc is today!');
        } else if (d.year == nextDay.year &&
            d.month == nextDay.month &&
            d.day == nextDay.day) {
          lines.add('$desc is tomorrow!');
        } else {
          final nextWeek = DateTime(
            fireDay.year,
            fireDay.month,
            fireDay.day,
          ).add(const Duration(days: 7));
          if (d.year == nextWeek.year &&
              d.month == nextWeek.month &&
              d.day == nextWeek.day) {
            lines.add('$desc is next week');
          }
        }
      }
    } catch (_) {}

    try {
      final weekly = await repo.getWeeklyTasks();
      final today = _weekdayAbbrev(fireDay.weekday);
      for (final t in weekly) {
        if (t.isDone) continue;
        final raw = t.dayOfWeek;
        if (raw == null) continue;
        if (raw.toLowerCase() == today) {
          final desc = t.taskDesctiption.trim();
          lines.add("don't forget $desc today");
        }
      }
    } catch (_) {}

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
