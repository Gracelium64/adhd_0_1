import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/main_screen.dart';
import 'package:adhd_0_1/src/cold_start.dart';
import 'package:adhd_0_1/src/theme/app_theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatefulWidget {
  final DataBaseRepository repository;

  const App(this.repository, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool? isColdStrart;

  @override
  void initState() {
    super.initState();
    checkColdStart();
  }

  Future<void> checkColdStart() async {
    final prefs = await SharedPreferences.getInstance();
    final firstTime = prefs.getBool('isColdStart') ?? true;

    // if (firstTime) {
    //   await prefs.setBool('isColdStart', false);
    // }
    // // // // // // // Autoreset of Cold Start, not the goal // // // // // // //

    setState(() {
      isColdStrart = firstTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isColdStrart == null) {
      return MaterialApp(home: Scaffold(body: CircularProgressIndicator()));
    }

    return MaterialApp(
      // useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home:
          isColdStrart!
              ? ColdStart(widget.repository)
              : MainScreen(widget.repository),
    );
  }
}
