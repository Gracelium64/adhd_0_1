import 'package:adhd_0_1/firebase_options.dart';
import 'package:adhd_0_1/src/app.dart';
import 'package:adhd_0_1/src/data/domain/auth_repository.dart';
import 'package:adhd_0_1/src/data/domain/firebase_auth_repository.dart';
import 'package:adhd_0_1/src/data/domain/sharedpreferencesinitializer.dart';
import 'package:adhd_0_1/src/data/old/mockdatabaserepository.dart';
import 'package:adhd_0_1/src/data/sharedpreferencesrepository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:device_preview/device_preview.dart';
import 'package:adhd_0_1/src/data/syncrepository.dart';

final AuthRepository auth = FirebaseAuthRepository();

void initSyncListeners(SyncRepository repository) {
  final Connectivity connectivity = Connectivity();

  connectivity.onConnectivityChanged.listen((status) {
    if (status != ConnectivityResult.none) {
      repository.syncAll();
    }
  });
}

Future<void> main() async {
  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove;
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesInitializer.initializeDefaults();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final mainRepo = MockDataBaseRepository();
  final backupRepo = SharedPreferencesRepository();
  final repository = SyncRepository(mainRepo: mainRepo, localRepo: backupRepo);

  initSyncListeners(repository);
  runApp(App(repository, auth));

  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => App(repository),
  //   ),
  // );

  //
  //

  //  // // SPRINT 1 // //
  //  // // SPRINT 1.1 // // ---------------------- UNTIL P21 (6.7.25 16:14) ---------------------- // //
  // // MVP Functionality // //
  //TODO: add task overlay - remove delete button, touch up and implement working overlay
  //TODO: edit task overlay - based on add task overlay
  //TODO: weekly isDone
  //TODO: deadline isDone
  //TODO: quest isDone
  //TODO: click on task open edit task overlay

  //
  // v.0.1.11 //
  //

  //  // // SPRINT 1.2 // // ---------------------- UNTIL (13.7.25 16:14) ---------------------- // //
  // // ONBOARDING // //
  //TODO: on the last onboarding screen confirmation button opens main screen with tutorial overlay open
  // // MVP Visual // //
  //TODO: tutorial overlay
  //TODO: single prize overlay
  // // MVP Logic // //
  //TODO: Logic of isDone reset for daily and weekly tasks
  //TODO: Logic for weekly score counters - for each day seperatly, for the week, for special tasks
  //TODO: Logic for prize system
  // // API SECURITY // //
  //TODO: SECURE API KEYS REVOKE CURRENT

  //
  // v.0.1.12 //
  //

  // // READY FOR CLINICAL TRIALS // //
  //TODO: recruit test subjects
  //TODO: automated testing (?)
  //

  //  // // SPRINT 2 // // ---------------------- UNTIL (26.7.25 16:14) ---------------------- // //
  // Functionality // //
  //TODO: weather API
  //TODO: how to save files outside of shared memory / sharing files / save local backup of user data from local repository
  // // Visual // //
  //TODO: responsive design - this design is problematic for up- and downscaling
  //TODO: week summery overlay
  //TODO: good morning overlay
  //TODO: backup overlays
  //TODO: about overlay
  // // Logic // //
  //TODO: UNDO Button in SncakBar when completing a Quest or Deadline Tasks
  //TODO: eastereggs
  //TODO: remove initializer for shared preferences

  //
  // v.0.1.2 //
  //

  //  // // SPRINT 3 // // ---------------------- UNTIL (3.8.25 16:14) ---------------------- // //
  // // Non MVP // //
  //TODO: auto copy user unique id to clipboard when registring and aleart the user about it
  //TODO: translations
  //TODO: display tasks for today (optional for update)
  //TODO: make more AI abominations for prizes
  //TODO: repurpose FridgeLock (?)
  //TODO: tasks with multiple subtasks
  //TODO: animated splash screen

  //
  // v.0.1.3 //
  //
}
