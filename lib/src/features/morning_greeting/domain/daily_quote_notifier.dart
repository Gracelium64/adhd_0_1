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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/data/domain/prefs_keys.dart';

class DailyQuoteNotifier {
  DailyQuoteNotifier._();
  static final DailyQuoteNotifier instance = DailyQuoteNotifier._();

  // Centralized channel metadata (easy to change before release)
  static const String _channelId = 'daily_quote_channel_v3';
  static const String _channelName = 'Daily Quotes';
  static const String _channelDescription =
      'Daily tip of the day notification at startOfDay';
  static const String _quoteHistoryKey = 'daily_quote_history_v1';
  static const int _quoteHistoryLimit = 100;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Random _random = Random();

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
    final quote = await _pickQuote();
    try {
      await init();
      // Ensure permissions are granted (Android 13+/iOS)
      await requestPermissions();

      bool silentNotification = false;
      try {
        final prefs = await SharedPreferences.getInstance();
        silentNotification =
            prefs.getBool(PrefsKeys.silentNotificationKey) ?? false;
      } catch (_) {}
      final channelKey =
          silentNotification
              ? AwesomeNotifService.dailySilentChannelKey
              : AwesomeNotifService.dailyChannelKey;

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
          const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
          await platform.invokeMethod('openAppNotificationSettings');
        } catch (_) {}
      }

      // Cancel only our daily ID to avoid interfering with other flows
      try {
        await AwesomeNotifService.instance.cancel(1001);
      } catch (_) {}
      try {
        await _plugin.cancel(1001);
      } catch (_) {}

      final int hour = time.hour.clamp(0, 23).toInt();
      final int minute = time.minute.clamp(0, 59).toInt();

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      // Candidate next occurrence today at chosen hh:mm; if it already passed, move to tomorrow
      tz.TZDateTime next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (!next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }

      // iOS time sensitive intention is implied by category/reminder; channel sound is set in AwesomeNotifService
      try {
        // Use Awesome Notifications daily repeating schedule (reboot persistent)
        await AwesomeNotifService.instance.scheduleDailyRepeating(
          id: 1001,
          hour: hour,
          minute: minute,
          title: 'Good morning',
          body: quote,
          payload: {'route': 'dailys'},
          groupKey: AwesomeNotifService.dailyGroupKey,
          channelKey: channelKey,
          // Daily quote likely dismissible and not locked
          locked: false,
          autoDismissible: true,
        );
      } on PlatformException catch (e) {
        debugPrint('Schedule failed (${e.code}): ${e.message}.');
        rethrow;
      } on TypeError catch (e, stack) {
        debugPrint(
          '⚠️ Invalid time components when scheduling daily quote: $e',
        );
        debugPrint(stack.toString());
        const fallbackHour = 7;
        const fallbackMinute = 15;
        debugPrint(
          '[DailyQuoteNotifier] Falling back to default time '
          '$fallbackHour:$fallbackMinute for daily quote schedule.',
        );
        await AwesomeNotifService.instance.scheduleDailyRepeating(
          id: 1001,
          hour: fallbackHour,
          minute: fallbackMinute,
          title: 'Good morning',
          body: quote,
          payload: {'route': 'dailys'},
          groupKey: AwesomeNotifService.dailyGroupKey,
          channelKey: channelKey,
          locked: false,
          autoDismissible: true,
        );
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
    final quote = await _pickQuote();
    bool silentNotification = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      silentNotification =
          prefs.getBool(PrefsKeys.silentNotificationKey) ?? false;
    } catch (_) {}
    final channelKey =
        silentNotification
            ? AwesomeNotifService.dailySilentChannelKey
            : AwesomeNotifService.dailyChannelKey;
    await AwesomeNotifService.instance.showPersistent(
      channelKey: channelKey,
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
    List<PendingNotificationRequest> pending = const [];
    try {
      pending = await _plugin.pendingNotificationRequests();
    } catch (e, stack) {
      // Some platform implementations may return malformed pending entries
      // (e.g., null id) which can throw inside the plugin mapping.
      debugPrint(
        '[DailyQuoteNotifier] pendingNotificationRequests failed (ignored): $e',
      );
      debugPrint(stack.toString());
    }
    debugPrint('[DailyQuoteNotifier] Notifications enabled: $enabled');
    debugPrint('[DailyQuoteNotifier] Pending notifications: ${pending.length}');
    for (final p in pending) {
      debugPrint('  • id=${p.id}, title=${p.title}, body=${p.body}');
    }

    if (Platform.isAndroid) {
      const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
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
    TimeOfDay scheduleTime = const TimeOfDay(hour: 7, minute: 15);
    try {
      final settings = await repo.getSettings();
      if (settings != null) {
        scheduleTime = TimeOfDay(
          hour: settings.startOfDay.hour,
          minute: settings.startOfDay.minute,
        );
      }
    } catch (e, stack) {
      debugPrint(
        '⚠️ Failed to load startOfDay from repository, using default: $e',
      );
      debugPrint(stack.toString());
    }

    await scheduleDailyQuote(scheduleTime);
  }

  @visibleForTesting
  Future<String> debugPickQuote({Random? random}) => _pickQuote(random: random);

  Future<String> _pickQuote({Random? random}) async {
    final rng = random ?? _random;
    if (tipOfTheDay.isEmpty) return 'Mood is for love play and cattle.';

    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e, stack) {
      debugPrint('⚠️ Failed to access SharedPreferences for quote history: $e');
      debugPrint(stack.toString());
    }

    final totalQuotes = tipOfTheDay.length;
    final history = <int>[];
    final seen = <int>{};

    if (prefs != null) {
      final rawHistory = prefs.getStringList(_quoteHistoryKey) ?? const [];
      for (final entry in rawHistory) {
        final parsed = int.tryParse(entry);
        if (parsed == null) continue;
        if (parsed < 0 || parsed >= totalQuotes) continue;
        if (seen.add(parsed)) history.add(parsed);
      }
    }

    final unseen = <int>[];
    for (int i = 0; i < totalQuotes; i++) {
      if (!seen.contains(i)) unseen.add(i);
    }

    int chosenIndex;
    if (unseen.isNotEmpty) {
      chosenIndex = unseen[rng.nextInt(unseen.length)];
    } else if (history.isNotEmpty) {
      final oldestFirst = history.reversed.toList();
      const int windowCap = 25;
      final int windowSize = min(windowCap, oldestFirst.length);
      final pool = oldestFirst.take(windowSize).toList(growable: false);
      chosenIndex = pool[rng.nextInt(pool.length)];
    } else {
      chosenIndex = rng.nextInt(totalQuotes);
    }

    if (prefs != null) {
      history.remove(chosenIndex);
      history.insert(0, chosenIndex);
      if (history.length > _quoteHistoryLimit) {
        history.removeRange(_quoteHistoryLimit, history.length);
      }
      await prefs.setStringList(
        _quoteHistoryKey,
        history.map((index) => index.toString()).toList(growable: false),
      );
    }

    final rawQuote = tipOfTheDay[chosenIndex];
    return rawQuote.replaceAll('"', '').trim();
  }
}
