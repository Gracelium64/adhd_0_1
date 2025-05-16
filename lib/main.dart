import 'package:adhd_0_1/src/app.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/mockdatabaserepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// void main() {
Future main() async {
  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove;

  DataBaseRepository repository = MockDataRepository();

  runApp(App(repository));

  //TODO: ListView.builder for tasks and prizes screens
  //TODO: theming - fonts in main theme
  //TODO: Overlays: (AleartDialog?)
  //good morning overlay
  //week summery overlay
  //tutorial overlay
  //add task overlays
  //single prize overlay
  //prizes listview
  //settings page
  //backup overlays
  //about overlay

  //TODO: Tip of the day Database
}
