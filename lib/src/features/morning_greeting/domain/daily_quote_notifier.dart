import 'dart:math';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/morning_greeting/domain/tip_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhd_0_1/src/navigation/notification_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyQuoteNotifier {
  DailyQuoteNotifier._();
  static final DailyQuoteNotifier instance = DailyQuoteNotifier._();

  // Centralized channel metadata (easy to change before release)
  static const String _channelId = 'daily_quote_channel_v2';
  static const String _channelName = 'Daily Quotes';
  static const String _channelDescription =
      'Daily tip of the day notification at startOfDay';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _scheduling = false;

  Future<void> init() async {
    if (_initialized) return;

    // Init timezone database
    try {
      tz.initializeTimeZones();
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
      debugPrint('[DailyQuoteNotifier] Timezone set to $localTz');
    } catch (e) {
      debugPrint(
        '[DailyQuoteNotifier] Timezone init failed ($e). Falling back to UTC',
      );
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
        // Route to Dailys tab when user taps the notification
        NotificationRouter.instance.openDailys();
      },
    );

    // Explicitly create Android notification channel with custom sound
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

  Future<void> scheduleDailyQuote(TimeOfDay time) async {
    if (_scheduling) {
      debugPrint('[DailyQuoteNotifier] schedule already in progress; skipping');
      return;
    }
    _scheduling = true;
    try {
      await init();
      // Ensure permissions are granted (Android 13+/iOS)
      await requestPermissions();

      // Cancel previous notifications and native alarm to avoid duplicates
      await _plugin.cancelAll();
      try {
        const platform = MethodChannel('shadowapp.grace6424.adhd01/alarm');
        await platform.invokeMethod('cancelAlarm');
      } catch (e) {
        debugPrint('[DailyQuoteNotifier] cancelAlarm failed: $e');
      }

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      // Candidate next occurrence today at chosen hh:mm; if it already passed, move to tomorrow
      tz.TZDateTime next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (!next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }

      // Pick a random quote without quotes
      final quote = _randomQuote();

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
        // Android: prefer native one-shot exact alarm chain for reliability (Samsung/OEM)
        if (Platform.isAndroid) {
          const platform = MethodChannel('shadowapp.grace6424.adhd01/alarm');
          bool allowed = true;
          try {
            final dynamic res = await platform.invokeMethod(
              'hasExactAlarmPermission',
            );
            if (res is bool) allowed = res;
          } catch (e) {
            debugPrint(
              '[DailyQuoteNotifier] hasExactAlarmPermission check failed: $e',
            );
          }
          if (!allowed) {
            try {
              await platform.invokeMethod('requestExactAlarmPermission');
            } catch (_) {}
          }
          // Persist the next quote and time, then schedule next one-shot natively
          try {
            await platform.invokeMethod('saveNextQuote', {
              'quote': quote,
            });
          } catch (e) {
            debugPrint('[DailyQuoteNotifier] saveNextQuote failed: $e');
          }
          await platform.invokeMethod('saveStartOfDay', {
            'hour': time.hour,
            'minute': time.minute,
          });
          await platform.invokeMethod('scheduleNextAlarm', {
            'hour': time.hour,
            'minute': time.minute,
          });
          debugPrint(
            '[DailyQuoteNotifier] Scheduled native next alarm for ${next.toLocal()}',
          );
        } else {
          // iOS: use plugin daily repeating schedule
          await _plugin.zonedSchedule(
            1001,
            'Good morning',
            quote,
            next,
            const NotificationDetails(android: androidDetails, iOS: iosDetails),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'open_app',
          );
        }
      } on PlatformException catch (e) {
        debugPrint('Schedule failed (${e.code}): ${e.message}.');
      }

      // Print pending notifications for diagnostics
      await debugStatus();

      // Removed the near-term fallback timer used for emulator testing

      // Note: saveStartOfDay is called above on Android; iOS doesn't need it.
    } finally {
      _scheduling = false;
    }
  }

  Future<void> showTestNow() async {
    await init();
    await requestPermissions();
    final quote = _randomQuote();
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
      2002,
      'Good morning',
      quote,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'open_app',
    );
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
    debugPrint('[DailyQuoteNotifier] Notifications enabled: $enabled');
    debugPrint('[DailyQuoteNotifier] Pending notifications: ${pending.length}');
    for (final p in pending) {
      debugPrint('  • id=${p.id}, title=${p.title}, body=${p.body}');
    }
  }

  Future<void> rescheduleFromRepository(DataBaseRepository repo) async {
    final settings = await repo.getSettings();
    final t = settings?.startOfDay ?? const TimeOfDay(hour: 7, minute: 15);
    await scheduleDailyQuote(t);
  }

  String _randomQuote() {
    if (tipOfTheDay.isEmpty) return 'Make today count.';
    final rnd = Random();
    final s = tipOfTheDay[rnd.nextInt(tipOfTheDay.length)];
    // strip surrounding quotes if any; and trim
    return s.replaceAll('"', '').trim();
  }
}
