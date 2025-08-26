import 'dart:math';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/morning_greeting/domain/tip_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhd_0_1/src/navigation/notification_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:adhd_0_1/src/common/notifications/awesome_notif_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyQuoteNotifier {
  DailyQuoteNotifier._();
  static final DailyQuoteNotifier instance = DailyQuoteNotifier._();

  // Centralized channel metadata (easy to change before release)
  static const String _channelId = 'daily_quote_channel_v3';
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

      // Best-effort: check if notifications are enabled on Android; if not, surface settings
      final android =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final bool notificationsEnabled =
          await android?.areNotificationsEnabled() ?? true;
      if (!notificationsEnabled) {
        debugPrint('[DailyQuoteNotifier] Notifications disabled by user');
        try {
          const platform = MethodChannel('shadowapp.grace6424.adhd01/alarm');
          await platform.invokeMethod('openAppNotificationSettings');
        } catch (_) {}
      }

      // Cancel only our daily ID to avoid interfering with other flows
      try {
        await AwesomeNotifService.instance.cancel(1001);
      } catch (_) {}

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

      // iOS time sensitive intention is implied by category/reminder; channel sound is set in AwesomeNotifService

      try {
        // Use Awesome Notifications daily repeating schedule (reboot persistent)
        await AwesomeNotifService.instance.scheduleDailyRepeating(
          id: 1001,
          hour: time.hour,
          minute: time.minute,
          title: 'Good morning',
          body: quote,
          payload: {'route': 'dailys'},
          channelKey: AwesomeNotifService.dailyChannelKey,
          groupKey: AwesomeNotifService.dailyGroupKey,
          // Daily quote likely dismissible and not locked
          locked: false,
          autoDismissible: true,
        );
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
    await AwesomeNotifService.instance.showPersistent(
      channelKey: AwesomeNotifService.dailyChannelKey,
      id: 2002,
      title: 'Good morning',
      body: quote,
      payload: {'route': 'dailys'},
      groupKey: AwesomeNotifService.dailyGroupKey,
      locked: false,
      autoDismissible: true,
    );
  }

  /// iOS-only: show a one-off local notification that explicitly uses
  /// the bundled my_sound.wav to verify custom sound playback.
  Future<void> showIosSoundTestNow() async {
    await init();
    await requestPermissions();
    const int id = 99001;
    const DarwinNotificationDetails ios = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      sound: 'my_sound.wav',
    );
    const NotificationDetails details = NotificationDetails(iOS: ios);
    await _plugin.show(
      id,
      'iOS Sound Test',
      'This should play my_sound.wav',
      details,
      payload: 'dailys',
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

    if (Platform.isAndroid) {
      const platform = MethodChannel('shadowapp.grace6424.adhd01/alarm');
      try {
        final bool ignoring = await platform.invokeMethod(
          'isIgnoringBatteryOptimizations',
        );
        debugPrint(
          '[DailyQuoteNotifier] Ignoring battery optimizations: $ignoring',
        );
        if (!ignoring) {
          debugPrint(
            '[DailyQuoteNotifier] Suggesting user to disable battery optimization for reliability',
          );
        }
      } catch (_) {}
      try {
        final dynamic res = await platform.invokeMethod(
          'hasExactAlarmPermission',
        );
        debugPrint('[DailyQuoteNotifier] hasExactAlarmPermission: $res');
      } catch (_) {}
    }
  }

  Future<void> rescheduleFromRepository(DataBaseRepository repo) async {
    final settings = await repo.getSettings();
    final t = settings?.startOfDay ?? const TimeOfDay(hour: 7, minute: 15);
    await scheduleDailyQuote(t);
  }

  String _randomQuote() {
    if (tipOfTheDay.isEmpty) return 'Mood is for love play and cattle.';
    final rnd = Random();
    final s = tipOfTheDay[rnd.nextInt(tipOfTheDay.length)];
    // strip surrounding quotes if any; and trim
    return s.replaceAll('"', '').trim();
  }
}
