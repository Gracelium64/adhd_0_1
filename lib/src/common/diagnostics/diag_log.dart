import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class DiagnosticsLog extends ChangeNotifier {
  DiagnosticsLog._();
  static final DiagnosticsLog instance = DiagnosticsLog._();

  static const String _prefsKey = 'diag_log';
  static const int _maxEntries = 500;
  final List<String> _entries = <String>[];
  bool _loaded = false;

  List<String> get entries => List.unmodifiable(_entries);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? const <String>[];
    _entries
      ..clear()
      ..addAll(list);
    _loaded = true;
    notifyListeners();
  }

  // Public: ensure entries are loaded from storage so UI can reflect counts immediately
  Future<void> ensureLoaded() => _ensureLoaded();

  String _ts() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  Future<void> log(String message) async {
    await _ensureLoaded();
    final line = '[${_ts()}] $message';
    _entries.add(line);
    if (_entries.length > _maxEntries) {
      _entries.removeRange(0, _entries.length - _maxEntries);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _entries);
    notifyListeners();
  }

  Future<void> clear() async {
    await _ensureLoaded();
    _entries.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _entries);
    notifyListeners();
  }

  Future<void> shareAll({String subject = 'ADHD App Diagnostics'}) async {
    await _ensureLoaded();
    final text = _entries.join('\n');
    if (text.isEmpty) return;
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
