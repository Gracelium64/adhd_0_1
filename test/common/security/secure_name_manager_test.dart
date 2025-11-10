import 'package:adhd_0_1/src/common/security/secure_name_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SecureNameManager', () {
    late _FakeSecureStore store;
    late SecureNameManager manager;

    setUp(() {
      store = _FakeSecureStore();
      manager = SecureNameManager(store: store);
    });

    test('returns existing secure_name and clears legacy key', () async {
      store.values[SecureNameManager.secureNameKey] = 'ExistingUser';
      store.values[SecureNameManager.legacySecureNameKey] = 'LegacyUser';

      final result = await manager.ensure();

      expect(result, 'ExistingUser');
      expect(store.values[SecureNameManager.secureNameKey], 'ExistingUser');
      expect(
        store.values.containsKey(SecureNameManager.legacySecureNameKey),
        isFalse,
      );
    });

    test('migrates legacy value when secure_name missing', () async {
      store.values[SecureNameManager.legacySecureNameKey] = 'LegacyUser';

      final result = await manager.ensure();

      expect(result, 'LegacyUser');
      expect(store.values[SecureNameManager.secureNameKey], 'LegacyUser');
      expect(
        store.values.containsKey(SecureNameManager.legacySecureNameKey),
        isFalse,
      );
    });

    test('uses fallback when neither value exists', () async {
      final result = await manager.ensure(fallbackRawUserName: 'alice_1234');

      expect(result, 'alice');
      expect(store.values[SecureNameManager.secureNameKey], 'alice');
    });

    test('deriveSecureName mirrors legacy underscore behaviour', () {
      expect(SecureNameManager.deriveSecureName('bob_2024'), 'bob');
      expect(SecureNameManager.deriveSecureName('eve'), 'eve');
      expect(SecureNameManager.deriveSecureName('  carol__meta  '), 'carol');
    });
  });
}

class _FakeSecureStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}
