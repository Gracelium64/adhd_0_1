import 'package:adhd_0_1/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// void main() {
Future main() async {
  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove;

  runApp(const App());

  //TODO: add task button - with destinations per screen activation ** onTap needed per screen
  //TODO: overlay windows - including setState for differant catagories (aleart dialog?)
  //TODO: theming - fonts in main theme
  //TODO: mockdatabase - for catagories and won prizes
}
