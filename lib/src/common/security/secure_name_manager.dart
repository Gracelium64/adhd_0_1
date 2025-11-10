import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureNameManager {
  SecureNameManager({required SecureKeyValueStore store}) : _store = store;

  final SecureKeyValueStore _store;

  static const String secureNameKey = 'secure_name';
  static const String legacySecureNameKey = 'secure_secure_name';

  Future<String?> ensure({String? fallbackRawUserName}) async {
    final current = await _store.read(secureNameKey);
    if (_isMeaningful(current)) {
      await _store.delete(legacySecureNameKey);
      return current!.trim();
    }

    final legacy = await _store.read(legacySecureNameKey);
    if (_isMeaningful(legacy)) {
      final normalized = legacy!.trim();
      await _store.write(secureNameKey, normalized);
      await _store.delete(legacySecureNameKey);
      debugPrint(
        '🔧 Migrated secure_secure_name to secure_name and removed legacy key',
      );
      return normalized;
    }

    await _store.delete(legacySecureNameKey);

    if (fallbackRawUserName != null && fallbackRawUserName.trim().isNotEmpty) {
      final derived = deriveSecureName(fallbackRawUserName);
      await _store.write(secureNameKey, derived);
      debugPrint('🔧 Derived secure_name from fallback user name');
      return derived;
    }

    return null;
  }

  static String deriveSecureName(String raw) {
    final trimmed = raw.trim();
    final underscoreIndex = trimmed.indexOf('_');
    if (underscoreIndex <= 0) {
      return trimmed;
    }
    return trimmed.substring(0, underscoreIndex).trim();
  }

  static bool _isMeaningful(String? value) =>
      value != null && value.trim().isNotEmpty;
}

abstract class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureStorageStore implements SecureKeyValueStore {
  FlutterSecureStorageStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
