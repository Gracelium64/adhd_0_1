import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/syncrepository.dart';

class AccountSwitchingScreen extends StatefulWidget {
  final String userName;
  final String ownerPassword;
  final String identifier;

  const AccountSwitchingScreen({
    super.key,
    required this.userName,
    required this.ownerPassword,
    required this.identifier,
  });

  @override
  State<AccountSwitchingScreen> createState() => _AccountSwitchingScreenState();
}

class _AccountSwitchingScreenState extends State<AccountSwitchingScreen> {
  final _auth = FirebaseAuth.instance;

  String _extractBaseName(String input) {
    final idx = input.indexOf('_');
    if (idx <= 0) return input;
    return input.substring(0, idx);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSwitch();
    });
  }

  Future<void> _runSwitch() async {
    try {
      // 1) If logged in, sign out
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }

      // 2) Attempt sign-in against candidate emails (reconstructed and profile email)
      final uname = widget.userName.trim();
      final primaryEmail = '$uname@adventurer.adhd';
      final candidates = <String>{primaryEmail};
      try {
        final proj = Firebase.app().options.projectId;
        debugPrint(
          '🔎 Account switch in project=$proj, candidates=$candidates',
        );
      } catch (_) {}

      // Try to include the profile email if it exists (in same project)
      String? profileEmail;
      try {
        final profileDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uname)
                .get();
        if (profileDoc.exists) {
          final data = profileDoc.data() ?? {};
          profileEmail = data['email'] as String?;
          if (profileEmail != null && profileEmail.isNotEmpty) {
            candidates.add(profileEmail);
          }
        }
      } catch (_) {}

      String? signedInEmail;
      FirebaseAuthException? wrongPasswordErr;
      for (final candidate in candidates) {
        try {
          await _auth.signInWithEmailAndPassword(
            email: candidate,
            password: widget.ownerPassword,
          );
          signedInEmail = candidate;
          break;
        } on FirebaseAuthException catch (ex) {
          if (ex.code == 'wrong-password') {
            wrongPasswordErr = ex;
            break; // no need to try others; email exists but password is wrong
          } else if (ex.code == 'user-not-found') {
            // try next candidate
            continue;
          } else if (ex.code == 'invalid-credential') {
            // try next; could be non-password provider
            continue;
          } else {
            // other errors: keep last and break
            break;
          }
        }
      }

      if (signedInEmail == null) {
        if (wrongPasswordErr != null) {
          throw wrongPasswordErr;
        }
        // Distinguish profile present vs missing to give better guidance
        if (profileEmail != null && profileEmail.isNotEmpty) {
          final hint =
              (profileEmail != primaryEmail)
                  ? ' (profile email: $profileEmail)'
                  : '';
          throw FirebaseAuthException(
            code: 'wrong-provider',
            message:
                'No email/password sign-in found for $primaryEmail$hint. Use the original provider or complete registration, then try again.',
          );
        }
        throw FirebaseAuthException(
          code: 'account-not-found',
          message:
              'No account found for $primaryEmail. Check the username, or create/link this account.',
        );
      }
      final email = signedInEmail;

      final currentUid = _auth.currentUser?.uid;
      if (currentUid == null || currentUid != widget.identifier) {
        throw Exception('Identifier does not match the authenticated user.');
      }

      // 3) Validate Firestore user doc matches ownerUid and ownerPassword.
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uname).get();
      if (!doc.exists) {
        throw Exception('User document not found');
      }
      final data = doc.data();
      final ownerUid = data?['ownerUid'] as String?;
      final savedOwnerPassword = data?['ownerPassword'] as String?;
      if (ownerUid != currentUid) {
        throw Exception('Owner UID mismatch for this user.');
      }
      if (savedOwnerPassword != widget.ownerPassword) {
        throw Exception('Owner password mismatch for this user.');
      }

      // 4) Update local secure storage
      const storage = FlutterSecureStorage();
      await storage.write(key: 'userId', value: uname);
      await storage.write(key: 'password', value: widget.ownerPassword);
      await storage.write(key: 'email', value: email);
      // Migrate legacy key to 'secure_name' and delete legacy so only 'secure_name' remains
      final legacySecure = await storage.read(key: 'secure_secure_name');
      if (legacySecure != null && legacySecure.trim().isNotEmpty) {
        await storage.write(key: 'secure_name', value: legacySecure);
        await storage.delete(key: 'secure_secure_name');
      } else {
        await storage.write(
          key: 'secure_name',
          value: _extractBaseName(widget.userName),
        );
      }
      await storage.write(key: 'firebaseUid', value: currentUid);

      // 5) Mark onboarding as complete (firebaseUid stored in secure storage already)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', true);

      // 6) Proactively hydrate local cache from server for the new user
      try {
        // Lazy import to avoid cyclic references
        // ignore: avoid_dynamic_calls
        if (!mounted) return;
        final repo = context.read<DataBaseRepository?>();
        if (repo is SyncRepository) {
          await repo.hydrateLocalFromRemote();
        }
      } catch (_) {}

      if (!mounted) return;
      // 7) Navigate to main screen, clearing stack
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder:
              (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      // Show error in a dialog, then return to the Load Saved Game form
      final reconstructedEmail = '${widget.userName.trim()}@adventurer.adhd';
      String dialogTitle = 'Couldn\'t switch user';
      String dialogMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-not-found':
            dialogTitle = 'Account not found';
            dialogMessage =
                e.message ??
                'No account found for $reconstructedEmail. Check the username, or create/link this account.';
            break;
          case 'wrong-provider':
            dialogTitle = 'Use the right sign-in method';
            dialogMessage =
                e.message ??
                'This account does not use email/password. Sign in using the original provider or link a password to switch.';
            break;
          default:
            dialogMessage =
                '[${e.code}] ${e.message ?? 'Authentication failed'}';
        }
      } else {
        dialogMessage = e.toString();
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return AlertDialog(
            title: Text(dialogTitle),
            content: Text(dialogMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      // Return to the previous LoadSaveGame screen that remains on the stack
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
