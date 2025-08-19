import 'package:adhd_0_1/src/data/firebase_auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PendingRegistration {
  static const _keyEmail = 'pending_reg_email_v1';
  static const _keyPw = 'pending_reg_pw_v1';
  static const _storage = FlutterSecureStorage();

  static Future<void> save(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPw, value: password);
  }

  static Future<bool> hasPending() async {
    final email = await _storage.read(key: _keyEmail);
    final pw = await _storage.read(key: _keyPw);
    return (email != null && email.isNotEmpty && pw != null && pw.isNotEmpty);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPw);
  }

  static Future<bool> attempt(FirebaseAuthRepository auth) async {
    try {
      final email = await _storage.read(key: _keyEmail);
      final pw = await _storage.read(key: _keyPw);
      if (email == null || pw == null) return false;
      await auth.createUserWithEmailAndPassword(email, pw);
      await clear();
      debugPrint('✅ Pending registration completed for $email');
      return true;
    } catch (e) {
      // Keep pending; will retry on next connectivity regain
      debugPrint('⏳ Pending registration attempt failed: $e');
      return false;
    }
  }
}
