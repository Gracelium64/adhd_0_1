import 'package:adhd_0_1/src/common/domain/app_user.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class DebugPrefsOverlay extends StatefulWidget {
  const DebugPrefsOverlay({super.key});

  @override
  State<DebugPrefsOverlay> createState() => _DebugPrefsOverlayState();
}

class _DebugPrefsOverlayState extends State<DebugPrefsOverlay> {
  bool _isOpen = false;
  Map<String, String> _prefsMap = {};
  final _storage = const FlutterSecureStorage();

  String _prettifyIfJson(String rawValue) {
    try {
      final decoded = jsonDecode(rawValue);

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('userId') &&
            decoded.containsKey('userName') &&
            decoded.containsKey('email')) {
          final user = AppUser.fromMap(decoded);
          return '[AppUser] ${user.userName} (${user.email})\nID: ${user.userId}, Power: ${user.isPowerUser}';
        }

        if (decoded.containsKey('taskId') &&
            decoded.containsKey('taskDesctiption')) {
          final task = Task.fromMap(decoded);
          return '[Task] ${task.taskDesctiption} (ID: ${task.taskId}, Type: ${task.taskCatagory}, Done: ${task.isDone})';
        }

        if (decoded.containsKey('appSkinColor') &&
            decoded.containsKey('startOfDay')) {
          return '[Settings]\nSkin: ${decoded['appSkinColor']}, Language: ${decoded['language']}, Start: ${decoded['startOfDay']}, Week: ${decoded['startOfWeek']}';
        }
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }

      if (decoded is List) {
        if (decoded.isNotEmpty && decoded.first is Map<String, dynamic>) {
          final isTaskList = decoded.first.containsKey('taskDesctiption');
          if (isTaskList) {
            return decoded
                .map<Task>((item) => Task.fromMap(item))
                .map(
                  (task) =>
                      '[Task] ${task.taskDesctiption} (ID: ${task.taskId}, Type: ${task.taskCatagory}, Done: ${task.isDone})',
                )
                .join('\n');
          }
          return const JsonEncoder.withIndent('  ').convert(decoded);
        }
      }

      return rawValue;
    } catch (e) {
      return rawValue;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final allPrefs = <String, String>{};

    for (var key in prefs.getKeys()) {
      allPrefs[key] = prefs.get(key).toString();
    }

    final securePrefs = await _storage.readAll();
    for (var entry in securePrefs.entries) {
      allPrefs['secure_${entry.key}'] = entry.value;
    }

    setState(() {
      _prefsMap = allPrefs;
    });
  }

  void _toggleOverlay() async {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) await _loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isOpen)
          Positioned(
            top: 50,
            right: 20,
            left: 20,
            bottom: 100,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      'Shared Preferences & Secure Storage',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children:
                              _prefsMap.entries
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              e.key,
                                              style: const TextStyle(
                                                color: Colors.orangeAccent,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              _prettifyIfJson(e.value),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            onPressed: _toggleOverlay,
            icon: Icon(_isOpen ? Icons.close : Icons.visibility),
            label: Text(_isOpen ? 'Hide Debug' : 'Show Debug'),
            backgroundColor: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}
