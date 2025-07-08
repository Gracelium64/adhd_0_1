// appSkinColor
// true = pink;
// null = white;
// false = blue;

import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:flutter/material.dart';

class Settings {
  final bool? appSkinColor;
  final String language;
  final String location;
  final TimeOfDay startOfDay;
  final Weekday startOfWeek;

  Settings({
    required this.appSkinColor,
    required this.language,
    required this.location,
    required this.startOfDay,
    required this.startOfWeek,
  });

  Map<String, dynamic> toJson() {
    return {
    'appSkinColor': appSkinColor,
    'language': language,
    'location': location,
    'startOfDay': '${startOfDay.hour}:${startOfDay.minute}',
    'startOfWeek': startOfWeek.name,
  };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    late TimeOfDay startTime;

    final startOfDayRaw = json['startOfDay'];
    if (startOfDayRaw is String) {
      final parts = startOfDayRaw.split(':');
      startTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else if (startOfDayRaw is int) {
      startTime = TimeOfDay(
        hour: startOfDayRaw ~/ 60,
        minute: startOfDayRaw % 60,
      );
    } else {
      throw FormatException('Invalid startOfDay format');
    }

    return Settings(
      appSkinColor: json['appSkinColor'],
      language: json['language'],
      location: json['location'],
      startOfDay: startTime,
      startOfWeek: Weekday.values.firstWhere(
        (e) => e.name == json['startOfWeek'],
        orElse: () => Weekday.mon,
      ),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'appSkinColor': appSkinColor,
      'language': language,
      'location': location,
      'startOfDay': '${startOfDay.hour}:${startOfDay.minute}',
      'startOfWeek': startOfWeek.name,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      appSkinColor: map['appSkinColor'],
      language: map['language'],
      location: map['location'],
      startOfDay: TimeOfDay(
        hour: int.parse(map['startOfDay'].split(':')[0]),
        minute: int.parse(map['startOfDay'].split(':')[1]),
      ),
      startOfWeek: Weekday.values.firstWhere(
        (e) => e.name == map['startOfWeek'],
        orElse: () => Weekday.mon,
      ),
    );
  }
}
