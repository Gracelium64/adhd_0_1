import 'package:adhd_0_1/src/app.dart';
import 'package:adhd_0_1/src/data/localbackuprepository.dart';
import 'package:adhd_0_1/src/data/mockdatabaserepository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:device_preview/device_preview.dart';
import 'package:adhd_0_1/src/data/syncrepository.dart';

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

  final mainRepo = MockDataRepository();
  final backupRepo = LocalBackupRepository();
  final repository = SyncRepository(mainRepo: mainRepo, localRepo: backupRepo);

  initSyncListeners(repository);
  runApp(App(repository));

  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => App(repository),
  //   ),
  // );

  //TODO: responsive design - this design is problematic for up- and downscaling

  //TODO:  fix other TODO's scattered across the design

  //OVERLAYS TO MAKE
  // // // // // // // // // //tutorial overlay
  // // // // // // // // // //add task overlays - basic design done, refine
  // // // // // // // // // //edit task overlays
  // //single prize overlay
  //good morning overlay
  //week summery overlay
  //backup overlays
  //about overlay

  //TODO: UNDO Button in SncakBar when completing a Quest or Deadline Tasks

  //TODO: TextFormField, controllers, validators

  //TODO: AppUser class = userInput.text + DateTime.now() ; as unique identifier

  //TODO: Logic of progress bars
  //TODO: Logic of isDone reset for daily and weekly tasks
  //TODO: Logic for weekly score counters - for each day seperatly, for the week, for special tasks

  //TODO: how to save files outside of shared memory / sharing files / save local backup of user data from local repository
  //TODO: display notification at specific time of day
  //TODO: weather API
  //TODO: how to work with random seed (for daily motivation message, for winning prizes)

  //TODO: finish database implemintierung

  //TODO: make more AI abominations for prizes

  //TODO: eastereggs

  //TODO: repurpose FridgeLock (?)

  //TODO: translations
}
