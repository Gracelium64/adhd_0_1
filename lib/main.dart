import 'package:adhd_0_1/src/app.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/mockdatabaserepository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove;
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  DataBaseRepository repository = MockDataRepository();

  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => App(repository),
  //   ),
  // );

  runApp(App(repository));

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

  //TODO: TextFormField, controllers, validators

  //TODO: AppUser class = userInput.text + DateTime.now() ; as unique identifier

  //TODO: Logic of progress bars
  //TODO: Logic of isDone reset for daily and weekly tasks
  //TODO: Logic for weekly score counters - for each day seperatly, for the week, for special tasks

  //TODO: how to save files outside of shared memory / sharing files / local backup of user data
  //TODO: display notification at specific time of day
  //TODO: weather API
  //TODO: how to work with random seed (for daily motivation message, for winning prizes)

  //TODO: finish database implemintierung

  //TODO: make more AI abominations for prizes

  //TODO: eastereggs

  //TODO: repurpose FridgeLock (?)

  //TODO: translations
}
