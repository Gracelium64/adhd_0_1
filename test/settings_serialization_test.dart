import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_0_1/src/common/domain/settings.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';

void main() {
  test('Settings toJson/fromJson roundtrip with string time works', () {
    final s = Settings(
      appSkinColor: true,
      language: 'en',
      location: 'home',
      startOfDay: const TimeOfDay(hour: 8, minute: 5),
      startOfWeek: Weekday.wed,
    );

    final json = s.toJson();
    final restored = Settings.fromJson(json);

    expect(restored.appSkinColor, equals(s.appSkinColor));
    expect(restored.language, equals(s.language));
    expect(restored.location, equals(s.location));
    expect(restored.startOfDay.hour, equals(8));
    expect(restored.startOfDay.minute, equals(5));
    expect(restored.startOfWeek, equals(Weekday.wed));
  });

  test('Settings fromJson accepts integer minutes format', () {
    // startOfDay as integer minutes since midnight (e.g., 8:30 -> 8*60+30 = 510)
    final json = {
      'appSkinColor': false,
      'language': 'es',
      'location': 'work',
      'startOfDay': 510,
      'startOfWeek': 'fri',
    };

    final restored = Settings.fromJson(json);
    expect(restored.startOfDay.hour, equals(8));
    expect(restored.startOfDay.minute, equals(30));
    expect(restored.startOfWeek, equals(Weekday.fri));
  });

  test('Settings toMap and fromMap preserve values', () {
    final s = Settings(
      appSkinColor: null,
      language: 'fr',
      location: 'city',
      startOfDay: const TimeOfDay(hour: 7, minute: 0),
      startOfWeek: Weekday.mon,
    );
    final map = s.toMap();
    final restored = Settings.fromMap(map);

    expect(restored.appSkinColor, equals(s.appSkinColor));
    expect(restored.language, equals(s.language));
    expect(restored.location, equals(s.location));
    expect(restored.startOfDay.hour, equals(7));
    expect(restored.startOfDay.minute, equals(0));
    expect(restored.startOfWeek, equals(Weekday.mon));
  });
}
