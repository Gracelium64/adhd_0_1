import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/main_screen.dart';

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

      // 2) Login to Firebase using reconstructed email and fixed password
      final email = '${widget.userName}@adventurer.adhd';
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: 'password',
      );

      final currentUid = _auth.currentUser?.uid;
      if (currentUid == null || currentUid != widget.identifier) {
        throw Exception('Identifier does not match the authenticated user.');
      }

      // 3) Validate Firestore user doc matches ownerUid and ownerPassword.
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userName)
              .get();
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
      await storage.write(key: 'userId', value: widget.userName);
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

      if (!mounted) return;
      // 6) Navigate to main screen, clearing stack
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
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Couldn\'t switch user'),
            content: Text(e.toString()),
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
