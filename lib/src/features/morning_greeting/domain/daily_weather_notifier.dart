import 'dart:async';
import 'dart:io' show Platform;

import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/open_meteo_service.dart';
import 'package:adhd_0_1/src/data/city_timezone_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:adhd_0_1/src/common/notifications/awesome_notif_service.dart';

class DailyWeatherNotifier {
  DailyWeatherNotifier._();
  static final DailyWeatherNotifier instance = DailyWeatherNotifier._();

  static const int _notificationId = 12001;

  bool _initialized = false;
  bool _scheduling = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }
    _initialized = true;
  }

  Future<void> scheduleRelativeToDaily(
    TimeOfDay dailyStart,
    DataBaseRepository repo,
  ) async {
    if (_scheduling) return;
    _scheduling = true;
    try {
      await init();
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        dailyStart.hour,
        dailyStart.minute,
      );
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
      // Fire one minute before daily start
      final tz.TZDateTime fireAt = next.subtract(const Duration(minutes: 1));

      // Compose notification content by fetching weather. Use user's saved location if available.
      String cityLabel = '';
      double lat = 0;
      double lon = 0;
      try {
        final settings = await repo.getSettings();
        if (settings != null && settings.location.isNotEmpty) {
          cityLabel = settings.location;
          // Try to match to representativeCities
          final match = representativeCities.firstWhere(
            (c) => c.label.toLowerCase() == cityLabel.toLowerCase(),
            orElse: () => representativeCities.first,
          );
          lat = match.lat;
          lon = match.lon;
        } else {
          // Fallback: choose by local timezone
          final tzName = await FlutterTimezone.getLocalTimezone();
          final match = representativeCities.firstWhere(
            (c) => c.timezone == tzName,
            orElse: () => representativeCities.first,
          );
          lat = match.lat;
          lon = match.lon;
          cityLabel = match.label;
        }
      } catch (e) {
        final match = representativeCities.first;
        lat = match.lat;
        lon = match.lon;
        cityLabel = match.label;
      }

      // Try to fetch now; if fails, retry every 5 minutes until success.
      WeatherSummary? summary;
      final attemptFetch = () async {
        try {
          final tzName = tz.local.name;
          summary = await OpenMeteoService.instance.fetchDailySummary(
            lat: lat,
            lon: lon,
            timezone: tzName,
          );
          return true;
        } catch (e) {
          return false;
        }
      };

      bool ok = await attemptFetch();
      if (!ok) {
        // Retry loop every 5 minutes until success or until fireAt has passed
        final completer = Completer<void>();
        Timer? retryTimer;
        retryTimer = Timer.periodic(const Duration(minutes: 5), (t) async {
          final now2 = tz.TZDateTime.now(tz.local);
          if (now2.isAfter(fireAt) && summary == null) {
            // time passed, stop retrying
            retryTimer?.cancel();
            completer.complete();
            return;
          }
          final success = await attemptFetch();
          if (success) {
            retryTimer?.cancel();
            completer.complete();
            return;
          }
        });
        // Wait until either success or time passed
        await completer.future;
        ok = summary != null;
      }

      String body;
      String iconName = 'ic_weather_partly';
      if (summary != null) {
        iconName = _iconForCode(summary!.weatherCode);
        final max = summary!.maxTemp.round();
        final min = summary!.minTemp.round();
        body = '$cityLabel: High $max°C / Low $min°C';
      } else {
        body = 'Weather unavailable for $cityLabel.';
      }

      // Save prefs and message to native side and schedule native alarm so native receivers/workers show same message
      if (Platform.isAndroid) {
        const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
        final tzName = tz.local.name;
        try {
          await platform.invokeMethod('saveNextWeatherPrefs', {
            'lat': lat,
            'lon': lon,
            'label': cityLabel,
            'timezone': tzName,
          });
        } catch (e) {}
        try {
          await platform.invokeMethod('saveNextWeatherMessage', {
            'message': body,
          });
        } catch (e) {}
        try {
          await platform.invokeMethod('scheduleWeather', {
            'hour': dailyStart.hour,
            'minute': dailyStart.minute,
            'offsetSec': -60,
          });
        } catch (e) {}
      }

      // Schedule via AwesomeNotifications to ensure it fires even if app is in background
      await AwesomeNotifService.instance.schedulePersistentAt(
        channelKey: AwesomeNotifService.dailyWeatherChannelKey,
        id: _notificationId,
        when: fireAt.toLocal(),
        title: 'Weather',
        body: body,
        payload: {'route': 'dailys'},
        groupKey: AwesomeNotifService.dailyGroupKey,
        largeIcon: 'resource://drawable/$iconName',
        locked: false,
        autoDismissible: true,
      );

      // If fetch succeeded after the scheduled time, fire immediately.
      final now3 = tz.TZDateTime.now(tz.local);
      if (summary != null && now3.isAfter(fireAt)) {
        if (Platform.isAndroid) {
          const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
          try {
            await platform.invokeMethod('showDeadlineNowWithBody', {
              'body': body,
            });
          } catch (_) {}
        } else {
          // On iOS / other, show via Awesome immediately
          await AwesomeNotifService.instance.showPersistent(
            channelKey: AwesomeNotifService.dailyWeatherChannelKey,
            id: _notificationId + 1,
            title: 'Weather',
            body: body,
            payload: {'route': 'dailys'},
            groupKey: AwesomeNotifService.dailyGroupKey,
            locked: false,
            autoDismissible: true,
          );
        }
      }
    } finally {
      _scheduling = false;
    }
  }

  String _iconForCode(int code) {
    // Map Open-Meteo weather codes to drawable resource names
    return ifCodeIn(code, 0, 'ic_weather_clear') ??
        ifCodeInRange(code, 1, 3, 'ic_weather_partly') ??
        ifCodeInRange(code, 45, 48, 'ic_weather_fog') ??
        ifCodeInRange(code, 51, 67, 'ic_weather_drizzle') ??
        ifCodeInRange(code, 71, 77, 'ic_weather_snow') ??
        ifCodeInRange(code, 80, 82, 'ic_weather_rain') ??
        ifCodeInRange(code, 95, 99, 'ic_weather_thunder') ??
        'ic_weather_partly';
  }

  String? ifCodeIn(int code, int target, String name) =>
      code == target ? name : null;
  String? ifCodeInRange(int code, int lo, int hi, String name) =>
      (code >= lo && code <= hi) ? name : null;
}
