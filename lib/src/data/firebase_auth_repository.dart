import 'package:adhd_0_1/src/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Removed SharedPreferences for firebaseUid; using secure storage only.

class FirebaseAuthRepository implements AuthRepository {
  final _storage = FlutterSecureStorage();
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _storage.write(key: 'firebaseUid', value: uid);
    }
  }

  @override
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _storage.write(key: 'firebaseUid', value: uid);
    }
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _storage.delete(key: 'firebaseUid');
  }

  @override
  Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }

  @override
  Future<void> sendVerificationEmail() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }
}
