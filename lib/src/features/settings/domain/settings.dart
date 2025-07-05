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

  Map<String, dynamic> toJson() => {
    'appSkinColor': appSkinColor,
    'language': language,
    'location': location,
    'startOfDay': '${startOfDay.hour}:${startOfDay.minute}',
    'startOfWeek': startOfWeek.name,
  };

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
    // Assume it's total minutes since midnight
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
}