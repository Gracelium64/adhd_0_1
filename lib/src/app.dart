import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/main_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  final DataBaseRepository repository;
  
  const App(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(repository),
      // home: Bla(),
    );
  }
}
