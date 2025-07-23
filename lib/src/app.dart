import 'package:adhd_0_1/src/data/firebase_auth_repository.dart';
import 'package:adhd_0_1/src/features/tutorial/presentation/tutorial.dart';
import 'package:adhd_0_1/src/main_screen.dart';
import 'package:adhd_0_1/src/cold_start.dart';
import 'package:adhd_0_1/src/theme/app_theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool? onboardingComplete;
  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('onboardingComplete') ?? false;

    setState(() {
      onboardingComplete = status;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<FirebaseAuthRepository>();

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
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
                  ? ColdStart()
                  : onboardingComplete!
                  ? MainScreen()
                  : ColdStart(),
        );
      },
    );
  }
}


//navigate to next

// WidgetsBinding.instance.addPostFrameCallback((_) {
//                         if (!mounted) return;

//                         Navigator.of(
//                           context,
//                           rootNavigator: true,
//                         ).pushReplacement(
//                           PageRouteBuilder(
//                             opaque: false,
//                             pageBuilder:
//                                 (_, __, ___) => NEXT_SCREEN/OVERLAY(
//                                   repository: widget.repository,
//                                   auth: widget.auth,
//                                   userName: userName.text,
//                                 ),
//                             transitionsBuilder: (_, animation, __, child) {
//                               return FadeTransition(
//                                 opacity: animation,
//                                 child: child,
//                               );
//                             },
//                           ),
//                         );
//                       });



// /finish setting up the onboarding
// ConfirmButton(
//                         onPressed: () async {
//                           final prefs = await SharedPreferences.getInstance();
//                           await prefs.setBool('onboardingComplete', true);

//                           Navigator.of(
//                             context,
//                             rootNavigator: true,
//                           ).pushReplacement(
//                             MaterialPageRoute(
//                               builder: (_) => MainScreen(repository, auth),
//                             ),
//                           );
//                         },
//                       ),