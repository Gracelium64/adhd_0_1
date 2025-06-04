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

  //TODO: Overlays: (AleartDialog?)
  // // // // // // // // // //tutorial overlay
  // // // // // // // // // //add task overlays - basic design done
  // // // // // // // // // //edit task overlays
  // //single prize overlay
  //good morning overlay
  //week summery overlay
  //backup overlays
  //about overlay

  //TODO: Tip of the day Database
}
