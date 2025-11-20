import 'package:shared_preferences/shared_preferences.dart';

class FilePickerPrefs {
  static const _prefsKey = 'file_picker_supports_custom_filter_v1';

  /// Returns true when we should attempt the custom extension filter.
  /// Defaults to true for backwards compatibility.
  static Future<bool> shouldUseCustomFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? true;
  }

  /// Mark that the device/file-picker does NOT support custom extension filters
  /// so future pick operations use FileType.any directly.
  static Future<void> markFilterUnsupported() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, false);
  }

  /// Optional: reset to default (useful for tests or debugging)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
