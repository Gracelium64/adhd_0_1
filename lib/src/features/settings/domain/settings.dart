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
}
