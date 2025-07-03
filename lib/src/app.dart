import 'package:adhd_0_1/main.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/auth_repository.dart';
import 'package:adhd_0_1/src/main_screen.dart';
import 'package:adhd_0_1/src/cold_start.dart';
import 'package:adhd_0_1/src/theme/app_theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatefulWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;

  const App(this.repository, this.auth, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool? onboardingComplete;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('onboardingComplete') ?? false;

    setState(() {
      onboardingComplete = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.auth.authStateChanges(),
      builder: (context, snapshot) {
        if (onboardingComplete == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home:
              snapshot.data == null
                  ? ColdStart(widget.repository, widget.auth)
                  : onboardingComplete!
                  ? MainScreen(widget.repository, widget.auth)
                  : ColdStart(
                    widget.repository,
                    widget.auth,
                  ), // stay in ColdStart flow
        );
      },
    );
  }
}
