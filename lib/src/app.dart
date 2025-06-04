import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/main_screen.dart';
import 'package:adhd_0_1/src/ms_paint.dart';
import 'package:adhd_0_1/src/theme/app_theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  final DataBaseRepository repository;

  const App(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: MainScreen(repository),
      // home: MsPaint(repository),
    );
  }
}
