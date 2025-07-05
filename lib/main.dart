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

  //  // // PHASE 1 // //
  // // API SECURITY // //
  //TODO: SECURE API KEYS REVOKE CURRENT
  // // MVP Functionality // //
  //TODO: add task overlay - remove delete button, touch up and implement working overlay
  //TODO: edit task overlay - based on add task overlay
  //TODO: weekly isDone
  //TODO: deadline isDone
  //TODO: quest isDone
  //TODO: click on task open edit task overlay
  // // MVP Visual // //
  //TODO: tutorial overlay
  //TODO: single prize overlay
  // // ONBOARDING // //
  //TODO: on the last onboarding screen confirmation button opens main screen with tutorial overlay open
  // // MVP Logic // //
  //TODO: Logic of isDone reset for daily and weekly tasks
  //TODO: Logic for weekly score counters - for each day seperatly, for the week, for special tasks
  //TODO: Logic for prize system

  //
  //

  //  // // PHASE 2 // //
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

  //
  //

  //  // // PHASE 3 // //
  // // APP TESTING // //
  //TODO: recruit test subjects
  //TODO: automized testing (?)
  // // Non MVP // //
  //TODO: translations
  //TODO: display tasks for today (optional for update)
  //TODO: make more AI abominations for prizes
  //TODO: repurpose FridgeLock (?)
}
