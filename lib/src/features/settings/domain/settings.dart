// appSkinColor
// true = pink;
// null = white;
// false = blue;

class Settings {
  final bool? appSkinColor;
  final String language;
  final String location;
  final int startOfDay;
  final int startOfWeek;

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
    'startOfDay': startOfDay,
    'startOfWeek': startOfWeek,
  };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    appSkinColor: json['appSkinColor'],
    language: json['language'],
    location: json['location'],
    startOfDay: json['startOfDay'],
    startOfWeek: json['startOfWeek'],
  );
}