import 'package:adhd_0_1/firebase_options.dart';
import 'package:adhd_0_1/src/app.dart';
import 'package:adhd_0_1/src/data/domain/firestore_initializer.dart';
import 'package:adhd_0_1/src/data/firebase_auth_repository.dart';
import 'package:adhd_0_1/src/data/domain/sharedpreferences_initializer.dart';
import 'package:adhd_0_1/src/data/firestore_repository.dart';
import 'package:adhd_0_1/src/data/old/mockdatabaserepository.dart';
import 'package:adhd_0_1/src/data/sharedpreferencesrepository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:adhd_0_1/src/data/syncrepository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter/foundation.dart';
// import 'package:device_preview/device_preview.dart';

/*
There is A LOT of redundent code in this file.
I know that it's there, it has been left there on purpose.
It was before we started using a Firebase Repository, it was actually made in preparation for it.
Since this is an Offline First App, I've build it so that it would prefer the local Repository and back it up to the server when connected to the internet.
Only a couple of days later I learned in class that this feature is default in Firebase anyway.
Fuck it, the code stays.

There will not be many comments in this project, you've just collected your first!  
*/

void initSyncListeners(SyncRepository repository) {
  final Connectivity connectivity = Connectivity();

  connectivity.onConnectivityChanged.listen((status) {
    if (status != ConnectivityResult.none) {
      repository.syncAll();
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesInitializer.initializeDefaults();

  final storage = FlutterSecureStorage();
  String? userId = await storage.read(key: 'userId');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirestoreInitializer.initializeDefaults(userId);

  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final auth = FirebaseAuthRepository();
  // final mainRepo = FirestoreRepository();
  // final mainRepo = MockDataBaseRepository();
  final localRepo = SharedPreferencesRepository();
  // final repository = SyncRepository(mainRepo: mainRepo, localRepo: localRepo);
  final repository = FirestoreRepository();

  // initSyncListeners(repository);
  runApp(App(repository, auth));

  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => App(repository),
  //   ),
  // );

  //
  //

  //
  // v.0.1.11 //
  //

  //  // // SPRINT 1.2 // // ---------------------- UNTIL 13.7.25 / 18.7.25 ---------------------- // //
  // // API SECURITY // //
  //TODO: SECURE API KEYS REVOKE CURRENT
  // // MVP Visual // //
  //TODO: tutorial overlay
  //TODO: single prize overlay
  // // ONBOARDING // //
  //TODO: on the last onboarding screen confirmation button opens main screen with tutorial overlay open
  // // MVP Logic // //
  //TODO: Logic of isDone reset for daily and weekly tasks
  //TODO: Logic for weekly score counters - for each day seperatly, for the week, for special tasks
  //TODO: Logic for prize system
  //TODO: BUG - deadline and quest complete quest, something got messed up in the code of all of this

  //
  // v.0.1.12 //
  //

  //  // // SPRINT 2 // // ---------------------- UNTIL 20.7.25 / 23.7.25 ---------------------- // //
  // // OFFLINE FIRST // //
  // TODO: make sync and firestore repositories play nice with each other
  // Functionality // //
  //TODO: weather API
  //TODO: how to save files outside of shared memory / sharing files / save local backup of user data from local repository
  // // Visual // //
  //TODO: responsive design - this design is problematic for up- and downscaling
  //TODO: weeklyTaskWidget - if day is "any" don't show it
  //TODO: week summery overlay
  //TODO: good morning overlay
  //TODO: backup overlays
  //TODO: about overlay
  //TODO: when setting appSkinColor to null it still displays pink *************************
  // // Logic // //
  //TODO: remove initializer for shared preferences
  //TODO: BUG - confirm button in edit_task_widget.dart only works when taskDescription is changed
  // // SECURITY // //
  //TODO: Autogenerate random password to replace current default
  //TODO: aleart user to it's userId and password through the settings menu and make it clickable copy to clipboard

  //
  // v.0.1.2 //
  //

  // // READY FOR CLINICAL TRIALS // //
  //TODO: recruit test subjects
  //TODO: automated testing (?)
  //

  //  // // SPRINT 3 // // ---------------------- UNTIL 26.7.25 / 29.7.25 ---------------------- // //
  // // Non MVP // //
  //TODO: UNDO Button in SncakBar when completing a Quest or Deadline Tasks
  //TODO: eastereggs
  //TODO: translations
  //TODO: display tasks for today
  //TODO: make more AI abominations for prizes
  //TODO: review tip of the day
  //TODO: repurpose FridgeLock (?)
  //TODO: tasks with multiple subtasks
  //TODO: animated splash screen
  //TODO: user console area through settings, console looks and user input
  //  [
  //delete user information,
  //load user information from file,
  //load user information of existing user
  //(copy in database from one user document with another with entering a valid unique userId),
  //backup user information to file, back to app
  //  ]

  //
  // v.0.1.3 //
  //
}
